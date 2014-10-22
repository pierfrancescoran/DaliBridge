clear 
sicstus_home=/usr/local/sicstus4.2.3
dali_home=../DALI-master/src
prolog="$sicstus_home/bin/sicstus"
WAIT="ping -c 4 127.0.0.1" 
main_home=mas

rm -rf conf/mas/* 

xterm -hold -e "$prolog -l $dali_home/active_server_wi.pl --goal \"go(3010,'server.txt').\"" & #start /B "" "%prolog%" -l "%dali_home%/active_server_wi.pl" --goal go(3010,'%daliH%/server.txt').
echo Server attivato. Attivo il MAS....
$WAIT > /dev/null # %WAIT% >nul

xterm -hold -e "$prolog -l $dali_home/active_user_wi.pl --goal utente." & # start /B "" "%prolog%" -l "%dali_home%/active_user_wi.pl" --goal utente.
echo Server DALI attivato. Attivo gli agenti...
$WAIT > /dev/null # %WAIT% > nul


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



echo Operazione completata.
echo Premere un tasto per terminare il MAS
read -p "$*"
echo Chiudo il MAS...
killall sicstus
killall xterm
