import socket
import subprocess

UDP_IP = "<YOUR_IP_ADDRESS>"
UDP_PORT = <YOUR_PORT>


sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

print("Start listening for UDP data...")

while True:
	data, addr = sock.recvfrom(1024)
	print(data)
