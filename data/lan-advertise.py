import socket
from time import sleep
from sys import argv, exit

# Argument stuff
if(len(argv) == 1):
    print("lan-advertise.py: Advertise Minecraft Worlds to LAN.")
    print("Usage: lan-advertise.py <world name> <world port> <bind address> <broadcast ip>")
    exit(0)
elif(len(argv) != 5):
    print("Arguments length is not 4.");

WORLD_NAME = argv[1]
WORLD_PORT = argv[2]

BROADCAST_IP = argv[3]
BROADCAST_PORT = 4445

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((argv[4], 34917))
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)

while 1:
        msg = "[MOTD]%s[/MOTD][AD]%s[/AD]" % (WORLD_NAME, WORLD_PORT)
        sock.sendto(str.encode(msg), (BROADCAST_IP, BROADCAST_PORT))
        sleep(1.5)