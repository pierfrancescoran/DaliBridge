#!/usr/bin/env python

__author__ = 'MarinoAndrea'
__author__ = 'RanieriPierfrancesco'

from time import sleep
import pydali as pd
import string
import socket

# start tcp connection with Gazebo plugin
TCP_IP = ' your-computer '
TCP_PORT = 2005 
BUFFER_SIZE = 1024

connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
connection.connect((TCP_IP, TCP_PORT))


#start the simple agent
userAgent = pd.UserAgent()
userAgent.start()

ag1 = pd.Agent('tcpCon')
ag1.setSource(" :- tell('tcpCon.txt'),write('simple agent'),told, writeLog('gone!'). ")
ag1.start()

#simple agent loop:
# 1. it reads the messages from the buffer
# 2.1 if the message is not "TIMEOUT", then send the message to gazebo plugin
# 2.2 if the message is "found", then close the connection with the gazebo plugin and terminate the agent
while True:
	
        msg = ag1.readMsg()

	if msg[0]!="TIMEOUT":
           msg= [msg[8],msg[9],msg[10],msg[11]]
           message= " ".join(msg)
           connection.send(message)

           if msg[0]=="found":
              connection.close()
              print 'connection closed'
              ag1.terminate()
              userAgent.terminate()
              print 'Agents terminated.'
              exit(0)

        ag1.pul()
	
	

