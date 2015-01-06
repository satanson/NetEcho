#!/usr/bin/python
from socket import *
import sys

HOST = sys.argv[1];
FILE = sys.argv[2];
PORT = 21567
BUFSIZ = 4096
ADDR = (HOST, PORT)

tcpCliSock = socket(AF_INET, SOCK_STREAM)
tcpCliSock.connect(ADDR)
fout=file(FILE,"wb",4096)
while True:
   data = tcpCliSock.recv(BUFSIZ)
   fout.write(data)
   if len(data)!=BUFSIZ: break

tcpCliSock.send("ok")
fout.close()    
tcpCliSock.close()
