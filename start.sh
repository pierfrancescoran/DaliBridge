clear 

#------------------------start MAS------------------------------------------------

cd mas

xterm -hold -e "./startmas.sh" &
$WAIT > /dev/null 
cd ..

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

