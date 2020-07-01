# tesmart.sh

## Disclaimer

This has only been tested with the [8-PORT HDMI 1.4 4K 30HZ](https://buytesmart.com/products/tesmart-8-port-hdmi-kvm-switch-autoscan-rackmount-ethernet-usb-hub-4k-30hz) device.

## Dependencies

- awk
- bash
- bc
- hexdump
- netcat
- sed

## Usage

```bash
# Get current input
./tesmart.sh get-input

# Switch to input #2
./tesmart.sh switch 2

# Mute buzzer
./tesmart.sh mute

# Unmute buzzer
./tesmart.sh unmute

# Set LED timeout
./tesmart.sh led-timeout 10
./tesmart.sh led-timeout 30
./tesmart.sh led-timeout never

# Enable/disable input detection
./tesmart.sh input-detection on
./tesmart.sh input-detection off

# Custom HOST/PORT
TESMART_HOST=10.78.81.10 TESMART_PORT=5001 ./tesmart.sh get-input
# Alternative
./tesmart.sh -H 10.78.81.10 -p 5001 get-input

# Network info
./tesmart.sh network-info

# Set network settings
./tesmart.sh set-ip 10.79.82.11
./tesmart.sh set-port 5011
./tesmart.sh set-netmask 255.255.252.0
./tesmart.sh set-gateway 10.79.82.1

# DEBUG
DEBUG=1 ./tesmart.sh get-input
# Alternative
./tesmart.sh -d get-input
```

## Upstream Documentation

- https://buytesmart.com/pages/support-manuals
