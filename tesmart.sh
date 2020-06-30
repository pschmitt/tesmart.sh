#!/usr/bin/env bash

# https://buytesmart.com/pages/support-manuals

TESMART_HOST=${TESMART_HOST:-192.168.1.10}
TESMART_PORT=${TESMART_PORT:-5000}

usage() {
  echo "Usage: $(basename "$0") ACTION [ARGS]"
  echo -e "\n   ACTIONS: get-input|switch|mute|unmute"
}

send_cmd() {
  local -a extra_args

  if [[ -n "$DEBUG" ]]
  then
    extra_args+=(-vv)
  fi

  echo -ne "$@" | nc "${extra_args[@]}" -n "$TESMART_HOST" "$TESMART_PORT"
}

_set_buzzer() {
  local cmd

  case "$1" in
    off|mute)
      cmd="\xaa\xbb\x03\x02\x00\xee"
      ;;
    *)
      cmd="\xaa\xbb\x03\x02\x01\xee"
      ;;
  esac
  send_cmd "$cmd"
}

mute_buzzer() {
  _set_buzzer off
}

unmute_buzzer() {
  _set_buzzer on
}

switch_input() {
  # 0xAA 0xBB 0x03 0x01 0x{01-10} 0xEE
  send_cmd "\xaa\xbb\x03\x01\x0${1}\xee"
}

_set_input_detection() {
  local cmd

  case "$1" in
    off|disable)
      cmd="\xaa\xbb\x03\x81\x01\xee"
      ;;
    *)  # on|enable
      cmd="\xaa\xbb\x03\x81\x00\xee"
      ;;
  esac
  send_cmd "$cmd"
}

_set_led_timeout() {
  local cmd

  case "$1" in
    off|disable|never)
      cmd="\xaa\xbb\x03\x03\x00\xee"
      ;;
    10|10s|10-seconds)
      cmd="\xaa\xbb\x03\x03\x0a\xee"
      ;;
    30|30s|30-seconds)
      cmd="\xaa\xbb\x03\x03\x1e\xee"
      ;;
    *)
      echo "Invalid time. It's either 10s, 30s or never" >&2
      return 2
      ;;
  esac
  send_cmd "$cmd"
}

get_current_input() {
  local dec
  local hex
  local input_id
  local res

  res="$(send_cmd "\xaa\xbb\x03\x10\x00\xee" 2>/dev/null | tr -d '\0')"
  hex="$(echo -en "$res" | hexdump -C | awk '/^00000000/ {print $(NF - 2)}')"
  # The next line does not get parsed correctly
  # dec="$(( 16#${hex} ))"
  dec=$(bc <<< "ibase=16; ${hex}")

  if [[ -n "$DEBUG" ]]
  then
    { # DEBUG
      echo "$ hexdump -C"
      echo -en "$res" | hexdump -C
      echo
      echo "HEX=$hex"
      echo "DEC=$dec"
    } >&2
  fi

  if [[ -z "$dec" ]]
  then
    echo "❌ Unable to determine input ID" >&2
    return 4
  fi

  case "$dec" in
    17)
      input_id="1"
      ;;
    *)
      input_id="$(( dec + 1 ))"
      ;;
  esac

  echo "$input_id"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]
then
  while true
  do
    case "$1" in
      --host|-H)
        TESMART_HOST="$2"
        shift 2
        ;;
      --port|-p)
        TESMART_PORT="$2"
        shift 2
        ;;
      --debug|-d|-D)
        DEBUG=1
        shift
        ;;
      *)
        break
        ;;
    esac
  done

  case "$1" in
    help|--help|-h|h)
      usage
      exit 0
      ;;
    mute)
      mute_buzzer
      ;;
    unmute)
      unmute_buzzer
      ;;
    sound|beep)
      _set_buzzer "$2"
      ;;
    led|led-timeout|lights|light|l)
      _set_led_timeout "$2"
      ;;
    switch|sw|s)
      switch_input "$2"
      input="$(get_current_input 2>/dev/null)"
      while [[ -z "$input" ]]
      do
        input="$(get_current_input 2>/dev/null)"
        sleep 0.25
      done
      if [[ "$2" == "$input" ]]
      then
        echo "✔️ Switched to input $input"
      else
        echo "❌ Failed switching to $2. Current input: $input" >&2
        exit 4
      fi
      ;;
    get|get-input|g)
      echo "📺 Current input: $(get_current_input)"
      ;;
    *)
      echo "❌ Unknown command: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
fi
