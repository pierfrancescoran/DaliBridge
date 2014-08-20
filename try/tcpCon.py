from time import sleep
import pydali as pd


userAgent = pd.UserAgent()
userAgent.start()

ag1 = pd.Agent('agent1')

ag1.setSource(" :- send(world, attack, [robot1, robot2]).  ")

ag1.start( 'send(world, join). send(world, attack, [11,1])')
print 'sending msg'

userAgent.send('world', 'agent1',' send_message(agent1, join)', debug=True)

print 'msg sent'

#userAgent.send('test','user','send_message(go,user)',debug=True)
#print 'Are agents still alive?', ag1.isAlive(), userAgent.isAlive()
ag1.terminate()
userAgent.terminate()
#print 'Agents terminated.'
#sleep(2)
#print 'Are agents still alive?', ag1.isAlive(), userAgent.isAlive()

