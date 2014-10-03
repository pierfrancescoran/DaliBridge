clear 


sicstus_home=/usr/local/sicstus4.2.3
dali_home=../DALI-master/src
prolog="$sicstus_home/bin/sicstus"
WAIT="ping -c 4 127.0.0.1" 
main_home=mas

#------------------------start MAS------------------------------------------------

#clear history

rm -rf mas/conf/mas/*

#activate server DALI
xterm -hold -e "$prolog -l $dali_home/active_server_wi.pl --goal \"go(3010,'server.txt').\"" & 
echo Server activated. Activating MAS....
$WAIT > /dev/null 

xterm -hold -e "$prolog -l $dali_home/active_user_wi.pl --goal utente." & 
echo Server DALI activated. Activating agents...
$WAIT > /dev/null 

#activating agents
agent_base="robot1.txt"
echo "Agente: $agent_base $prolog $dali_home $agent_filename"
xterm -e "./conf/makeconf.sh $agent_base $dali_home" &
xterm -hold -e "./conf/startagent.sh $agent_base $prolog $dali_home" &
$WAIT > /dev/null # %WAIT% >nul

agent_base="robot2.txt"
echo "Agente: $agent_base $prolog $dali_home $agent_filename"
xterm -e "./conf/makeconf.sh $agent_base $dali_home" &
xterm -hold -e "./conf/startagent.sh $agent_base $prolog $dali_home" &
$WAIT > /dev/null # %WAIT% >nul


#---------------------------------start Gazebo--------------------------
cd listener

xterm -hold -e "gazebo -u model_push.world" & 
$WAIT > /dev/null 
echo gazebo semulator actvated

#---------------------------------start the gazebo plugin--------------------------
cd build
xterm -hold -e  "./listener" &
$WAIT > /dev/null 
gazebo plugin cannection activated

cd ..
cd ..

#---------------------------------start the connection simple agent--------------------------
xterm -hold -e "./tcpCon.py" &
DALI connection activated


echo Actions completed.
echo press start to close the MAS
read -p "$*"
echo Chiudo il MAS...
killall sicstus
killall xterm

