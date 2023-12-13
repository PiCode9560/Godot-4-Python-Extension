import sys
import socket
import json
import os
#import threading


opened_socket = socket.socket(socket.AF_INET,socket.SOCK_DGRAM)

UDP_IP = "127.0.0.1"
PORT = int(sys.argv[1])


#PID have to be sent from python because godot os.execute() blocked the thread from recieving the PID
pid = os.getpid()
pid = bytes(str(pid), "utf-8")
opened_socket.sendto(pid, (UDP_IP, PORT))


while True:
    #Receive data from godot
    rcvdData = opened_socket.recv(1024).decode()
    message, addr = opened_socket.recvfrom(1024)
    message = message.decode()
    
    #Send Data to to godot
    byte_message = bytes(message+" Python", "utf-8")
    opened_socket.sendto(byte_message, (UDP_IP, PORT))





