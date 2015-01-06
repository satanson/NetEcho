#!/usr/bin/python
from socket import *
from time import ctime
import sys

HOST = ''
PORT = 21567
BUFSIZ = 4096 
ADDR = (HOST, PORT)
FILE = sys.argv[1]
tcpSerSock = socket(AF_INET, SOCK_STREAM)
tcpSerSock.bind(ADDR)
tcpSerSock.listen(5)
fin =file(FILE,"rb",4096)
content=fin.read()
while True:
    print 'waiting for connection...'
    tcpCliSock, addr = tcpSerSock.accept()
    print '...connected from:', addr

    tcpCliSock.send(content)
    ok =tcpCliSock.recv(BUFSIZ)
    if not ok:
	print "err"
    else:
	print "ok"

    tcpCliSock.close()
tcpSerSock.close()
