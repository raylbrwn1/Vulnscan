
import socket

# Create a raw socket
sock = socket.socket(socket.AF_INET6, socket.SOCK_RAW, socket.IPPROTO_RAW)

# Define the IPv6 header and payload (simplified example)
ipv6_header = b'\x60\x00\x00\x00\x00\x08\x3a\xff'  # Version, Traffic Class, Flow Label, Payload Length, Next Header, Hop Limit
ipv6_header += b'\x20\x01\x0d\xb8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01'  # Source Address
ipv6_header += b'\x20\x01\x0d\xb8\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02'  # Destination Address

# Custom payload
payload = b'Hello, IPv6!'

# Send the packet
sock.sendto(ipv6_header + payload, ("fe80::b5d3:909b:5033:9a57%23", 0))