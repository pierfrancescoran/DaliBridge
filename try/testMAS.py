__author__ = 'giodegas'

from time import sleep
from pydali import Agent, MAS

ag1 = Agent('one')
ag1.setSource('''
                :- writeLog('agent ONE started').

                goE  :> writeLog('gone!').
            ''')

ag2 = Agent('two')
ag2.setSource('''
                :- writeLog('agent TWO started').

                startE:> writeLog('reaction'),  messageA(one,send_message(go,two)).
            ''')

myMAS = MAS('testMAS')
myMAS.add(ag1)
myMAS.add(ag2)

myMAS.start(True, 'two', 'send_message(start,user)')
print 'Sleeping while agents do their job'
sleep(5)
myMAS.terminate()
