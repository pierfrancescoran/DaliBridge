
clear 
sicstus_home=/usr/local/sicstus4.2.3
dali_home=../DALI-master/src
conf_dir=MAS/conf
prolog="$sicstus_home/bin/sicstus"
WAIT="ping -c 4 127.0.0.1" 
instances_home=MAS/mas/instances
types_home=MAS/mas/types
build_home=MAS/build


#------------------------start MAS------------------------------------------------

#clear history
rm -rf MAS/tmp/*
rm -rf MAS/build/*
rm -f MAS/work/*.txt 
rm -rf MAS/conf/mas/*


for instance_filename in $instances_home/*
do	
	type=$(<$instance_filename) 
	type_filename="$types_home/$type"
	instance_base="${instance_filename##*/}" 
	cat $type_filename >> "$build_home/$instance_base"
done

cp $build_home/*.txt MAS/work

#activate server DALI
$prolog -l $dali_home/active_server_wi.pl --goal "go(3010,'server.txt')." >>output.txt & 
echo Server activated. Activating MAS... 
$WAIT > /dev/null 

$prolog -l $dali_home/active_user_wi.pl --goal utente. >>output.txt & 
echo Server DALI activated. Activating agents... 
$WAIT > /dev/null 

#activating agents
for agent_filename in $build_home/*
do
	agent_base="${agent_filename##*/}"
    echo "Agente: $agent_base $prolog $dali_home $agent_filename"
    cd MAS
    xterm -e "./conf/makeconf.sh $agent_base $dali_home" &
    xterm -hold -e "./conf/startagent.sh $agent_base $prolog $dali_home" &
    $WAIT > /dev/null 
    cd ..
done

#---------------------------------starti Gazebo--------------------------
cd listener

gazebo -u model_push.world >>output.txt & 
$WAIT > /dev/null 
echo gazebo semulator actvated

#---------------------------------start the gazebo plugin--------------------------
cd build
./listener & 
$WAIT > /dev/null
gazebo plugin cannection activated

cd ..
cd ..

#---------------------------------start the connection simple agent--------------------------
./tcpCon.py >>output.txt & 
DALI connection activated


echo Press any key to close the MAS
read -p "$*"
echo Teminating program
kill -9 %1
killall sicstus
killall xterm
