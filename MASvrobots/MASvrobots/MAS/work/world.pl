
worldFilename('conf/world.txt').

:-dynamic worldWidth/1.

:-dynamic worldHeight/1.

:-dynamic worldCell/3.

:-dynamic worldAgent/2.

line_of_sight(4).

:-dynamic started/1.

starting(this):-not(started(this)).

evi(starting(var_X)):-main,assert(started(this)).

main:-use_module(library(random)),use_module('mas_modules/utils.txt'),use_module('mas_modules/world_objects.txt'),retrieveIdentity,nl,write('Started'),nl,loadWorldFromFile.

loadWorldFromFile:-nl,write('Loading world file...'),nl,worldFilename(var_Filename),getFileLines(var_Filename,var_Lines),eachFileLine(var_Lines,handleWorldLine),first(var_Lines,var_FirstLine),calculateWorldWidth(var_FirstLine),calculateWorldHeight(var_Lines),worldWidth(var_Width),worldHeight(var_Height),nl,write('World Width: '),write(var_Width),nl,write('World Height: '),write(var_Height),nl.

eachHandler(handleWorldLine,var_Line,var_Index):-name(var_Line,var_LineCharList),each(var_LineCharList,handler(handleWorldLineChar,var_Index)).

eachHandler(handler(handleWorldLineChar,var_LineIndex),var_Char,var_CharIndex):-char_code(var_CharAtom,var_Char),saveWorldCell(var_CharIndex,var_LineIndex,var_CharAtom).

saveWorldCell(var_X,var_Y,var_Type):-assert(worldCell(var_X,var_Y,var_Type)),write('('),write(var_X),write(','),write(var_Y),write('): '),write(var_Type),nl.

calculateWorldWidth(var_WorldLine):-name(var_WorldLine,var_WorldLineCharList),length(var_WorldLineCharList,var_Width),assert(worldWidth(var_Width)).

calculateWorldHeight(var_WorldLines):-length(var_WorldLines,var_Length),var_Height is var_Length-1,assert(worldHeight(var_Height)).

eve(received(var_From,join)):-nl,write('Received join request from '),write(var_From),nl,worldObject(var_AgentCellType,agent),worldCell(var_X,var_Y,var_AgentCellType),\+worldAgent(var_AnotherAgent,position(var_X,var_Y)),assert(worldAgent(var_From,position(var_X,var_Y))),assert(worldAgent(var_From,health(100))),write('Sending acceptance...'),nl,worldWidth(var_WorldWidth),worldHeight(var_WorldHeight),send(var_From,joined,[var_X,var_Y,var_WorldWidth,var_WorldHeight]).

eve(received(var_From,sense)):-nl,write('Received sensing request from '),write(var_From),write(', press enter to continue: '),nl,get_code(var__),worldAgent(var_From,position(var_FromX,var_FromY)),write('Sending position...'),nl,send(var_From,'position',[var_FromX,var_FromY]),line_of_sight(var_Span),calculateRect(var_FromX,var_FromY,var_Span,var_Top,var_Left,var_Width,var_Height),write('Sending sensing information...'),nl,sendRectCells(var_From,var_Top,var_Left,var_Width,var_Height),send(var_From,'senseEnd').

calculateRect(var_X,var_Y,var_Span,var_Top,var_Left,var_Width,var_Height):-calculateRectTop(var_Y,var_Span,var_Top),calculateRectLeft(var_X,var_Span,var_Left),calculateRectHeight(var_Y,var_Top,var_Span,var_Height),calculateRectWidth(var_X,var_Left,var_Span,var_Width).

calculateRectTop(var_Y,var_Span,var_Top):-var_TopCandidate is var_Y-var_Span,(var_TopCandidate<0,var_Top is 0;var_Top is var_TopCandidate).

calculateRectLeft(var_X,var_Span,var_Left):-var_LeftCandidate is var_X-var_Span,(var_LeftCandidate<0,var_Left is 0;var_Left is var_LeftCandidate).

calculateRectHeight(var_Y,var_Top,var_Span,var_Height):-worldHeight(var_WorldHeight),var_TopSpan is var_Y-var_Top,(var_WorldHeight-var_Y<var_Span,var_BottomSpan is var_WorldHeight-var_Y;var_BottomSpan is var_Span),var_Height is var_TopSpan+1+var_BottomSpan.

calculateRectWidth(var_X,var_Left,var_Span,var_Width):-worldWidth(var_WorldWidth),var_LeftSpan is var_X-var_Left,(var_WorldWidth-var_X<var_Span,var_RightSpan is var_WorldWidth-var_X;var_RightSpan is var_Span),var_Width is var_LeftSpan+1+var_RightSpan.

createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_ResultList):-createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,[],var_ResultList,0).

createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_CurrentList,var_ResultList,var_Row):-var_Row=var_Height,var_ResultList=var_CurrentList.

createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_CurrentList,var_ResultList,var_Row):-append(var_CurrentList,[newRow],var_NewCurrentList),createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_NewCurrentList,var_ResultList,var_Row,0).

createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_CurrentList,var_ResultList,var_Row,var_Column):-var_Column=var_Width,var_NextRow is var_Row+1,createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_CurrentList,var_ResultList,var_NextRow).

createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_CurrentList,var_ResultList,var_Row,var_Column):-var_X is var_Left+var_Column,var_Y is var_Top+var_Row,worldCell(var_X,var_Y,var_Type),append(var_CurrentList,[var_X,var_Y,var_Type],var_NewCurrentList),var_NextColumn is var_Column+1,createRectCellsInfo(var_Top,var_Left,var_Width,var_Height,var_NewCurrentList,var_ResultList,var_Row,var_NextColumn).

sendRectCells(var_To,var_Top,var_Left,var_Width,var_Height):-forRange(0,var_Height,handler(sendRectRowCells,var_To,var_Top,var_Left,var_Width)).

forRangeHandler(handler(sendRectRowCells,var_To,var_Top,var_Left,var_Width),var_I):-send(var_To,'senseNewY'),forRange(0,var_Width,handler(sendRectCell,var_To,var_Top,var_Left,var_I)).

forRangeHandler(handler(sendRectCell,var_To,var_Top,var_Left,var_I),var_J):-var_X is var_Left+var_J,var_Y is var_Top+var_I,worldCell(var_X,var_Y,var_Type),send(var_To,'cell',[var_X,var_Y,var_Type]).

eve(received(var_From,move,var_FromX,var_FromY,var_ToX,var_ToY)):-nl,write('Received move request from '),write(var_From),nl,moveObject(var_FromX,var_FromY,var_ToX,var_ToY),retract(worldAgent(var_From,position(var__,var__))),assert(worldAgent(var_From,position(var_ToX,var_ToY))).

moveObject(var_FromX,var_FromY,var_ToX,var_ToY):-worldCell(var_FromX,var_FromY,var_FromCellType),worldCell(var_ToX,var_ToY,var_ToCellType),worldObject(var_ToCellType,var_ToObject),var_ToObject=blank,write('Moving object...'),nl,retract(worldCell(var_FromX,var_FromY,var_FromCellType)),assert(worldCell(var_FromX,var_FromY,var_ToCellType)),retract(worldCell(var_ToX,var_ToY,var_ToCellType)),assert(worldCell(var_ToX,var_ToY,var_FromCellType)).

eve(received(var_From,consume,var_X,var_Y)):-nl,write('Received consume request from '),write(var_From),nl,consumeObject(var_X,var_Y).

consumeObject(var_X,var_Y):-worldObject(var_BlankCellType,blank),write('Consuming object...'),nl,retract(worldCell(var_X,var_Y,var_CellType)),assert(worldCell(var_X,var_Y,var_BlankCellType)).

eve(received(var_From,attack,var_X,var_Y)):-worldAgent(var_Agent,position(var_X,var_Y)),nl,write('agente '),write(var_From),write(' ha trovato '),write(var_Agent),nl,write(var_Agent),write('aspetta'),nl.

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

receive(send_message(var_X,var_Ag)):-told(var_Ag,send_message(var_X)),call_send_message(var_X,var_Ag).

receive(propose(var_A,var_C,var_Ag)):-told(var_Ag,propose(var_A,var_C)),call_propose(var_A,var_C,var_Ag).

receive(cfp(var_A,var_C,var_Ag)):-told(var_Ag,cfp(var_A,var_C)),call_cfp(var_A,var_C,var_Ag).

receive(accept_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,accept_proposal(var_A,var_Mp),var_T),call_accept_proposal(var_A,var_Mp,var_Ag,var_T).

receive(reject_proposal(var_A,var_Mp,var_Ag)):-told(var_Ag,reject_proposal(var_A,var_Mp),var_T),call_reject_proposal(var_A,var_Mp,var_Ag,var_T).

receive(failure(var_A,var_M,var_Ag)):-told(var_Ag,failure(var_A,var_M),var_T),call_failure(var_A,var_M,var_Ag,var_T).

receive(cancel(var_A,var_Ag)):-told(var_Ag,cancel(var_A)),call_cancel(var_A,var_Ag).

receive(execute_proc(var_X,var_Ag)):-told(var_Ag,execute_proc(var_X)),call_execute_proc(var_X,var_Ag).

receive(query_ref(var_X,var_N,var_Ag)):-told(var_Ag,query_ref(var_X,var_N)),call_query_ref(var_X,var_N,var_Ag).

receive(inform(var_X,var_M,var_Ag)):-told(var_Ag,inform(var_X,var_M),var_T),call_inform(var_X,var_Ag,var_M,var_T).

receive(inform(var_X,var_Ag)):-told(var_Ag,inform(var_X),var_T),call_inform(var_X,var_Ag,var_T).

receive(refuse(var_X,var_Ag)):-told(var_Ag,refuse(var_X),var_T),call_refuse(var_X,var_Ag,var_T).

receive(agree(var_X,var_Ag)):-told(var_Ag,agree(var_X)),call_agree(var_X,var_Ag).

receive(confirm(var_X,var_Ag)):-told(var_Ag,confirm(var_X),var_T),call_confirm(var_X,var_Ag,var_T).

receive(disconfirm(var_X,var_Ag)):-told(var_Ag,disconfirm(var_X)),call_disconfirm(var_X,var_Ag).

receive(reply(var_X,var_Ag)):-told(var_Ag,reply(var_X)).

send(var_To,query_ref(var_X,var_N,var_Ag)):-tell(var_To,var_Ag,query_ref(var_X,var_N)),send_m(var_To,query_ref(var_X,var_N,var_Ag)).

send(var_To,send_message(var_X,var_Ag)):-tell(var_To,var_Ag,send_message(var_X)),send_m(var_To,send_message(var_X,var_Ag)).

send(var_To,reject_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,reject_proposal(var_X,var_L)),send_m(var_To,reject_proposal(var_X,var_L,var_Ag)).

send(var_To,accept_proposal(var_X,var_L,var_Ag)):-tell(var_To,var_Ag,accept_proposal(var_X,var_L)),send_m(var_To,accept_proposal(var_X,var_L,var_Ag)).

send(var_To,confirm(var_X,var_Ag)):-tell(var_To,var_Ag,confirm(var_X)),send_m(var_To,confirm(var_X,var_Ag)).

send(var_To,propose(var_X,var_C,var_Ag)):-tell(var_To,var_Ag,propose(var_X,var_C)),send_m(var_To,propose(var_X,var_C,var_Ag)).

send(var_To,disconfirm(var_X,var_Ag)):-tell(var_To,var_Ag,disconfirm(var_X)),send_m(var_To,disconfirm(var_X,var_Ag)).

send(var_To,inform(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,inform(var_X,var_M)),send_m(var_To,inform(var_X,var_M,var_Ag)).

send(var_To,inform(var_X,var_Ag)):-tell(var_To,var_Ag,inform(var_X)),send_m(var_To,inform(var_X,var_Ag)).

send(var_To,refuse(var_X,var_Ag)):-tell(var_To,var_Ag,refuse(var_X)),send_m(var_To,refuse(var_X,var_Ag)).

send(var_To,failure(var_X,var_M,var_Ag)):-tell(var_To,var_Ag,failure(var_X,var_M)),send_m(var_To,failure(var_X,var_M,var_Ag)).

send(var_To,execute_proc(var_X,var_Ag)):-tell(var_To,var_Ag,execute_proc(var_X)),send_m(var_To,execute_proc(var_X,var_Ag)).

send(var_To,agree(var_X,var_Ag)):-tell(var_To,var_Ag,agree(var_X)),send_m(var_To,agree(var_X,var_Ag)).

call_send_message(var_X,var_Ag):-send_message(var_X,var_Ag).

call_execute_proc(var_X,var_Ag):-execute_proc(var_X,var_Ag).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),meta_ref(var_X,var_N,var_L,var_Ag),a(message(var_Ag,inform(query_ref(var_X,var_N),values(var_L),var_A))).

call_query_ref(var_X,var__,var_Ag):-clause(agent(var_A),var__),var(var_X),a(message(var_Ag,refuse(query_ref(variable),motivation(refused_variables),var_A))).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),not(meta_ref(var_X,var_N,var__,var__)),a(message(var_Ag,inform(query_ref(var_X,var_N),motivation(no_values),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),meta_agree(var_X,var_Ag),a(message(var_Ag,inform(agree(var_X),values(yes),var_A))).

call_confirm(var_X,var_Ag,var_T):-ground(var_X),statistics(walltime,[var_Tp,var__]),asse_cosa(past_event(var_X,var_T)),retractall(past(var_X,var_Tp,var_Ag)),assert(past(var_X,var_Tp,var_Ag)).

call_disconfirm(var_X,var_Ag):-ground(var_X),retractall(past(var_X,var__,var_Ag)),retractall(past_event(var_X,var__)).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),not(meta_agree(var_X,var__)),a(message(var_Ag,inform(agree(var_X),values(no),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),not(ground(var_X)),a(message(var_Ag,refuse(agree(variable),motivation(refused_variables),var_A))).

call_inform(var_X,var_Ag,var_M,var_T):-asse_cosa(past_event(inform(var_X,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_M,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_M,var_Ag),var_Tp,var_Ag)).

call_inform(var_X,var_Ag,var_T):-asse_cosa(past_event(inform(var_X,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_Ag),var_Tp,var_Ag)).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_527009,var_Ontology,_527013),_527003),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_527047)),a(message(var_Ag,propose(var_A,[_527047],var_AgI))),retractall(ext_agent(var_Ag,_527085,var_Ontology,_527089)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_526883,var_Ontology,_526887),_526877),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_526953,var_Ontology,_526957)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_526771,var_Ontology,_526775),_526765),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_526827,var_Ontology,_526831)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_526335),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_526369),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_526151).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_525999),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_525947),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_525823,_525825)),clause(agente(_525845,_525847,_525849,var_S),_525841),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_525617,_525619,_525621,var_S),_525613),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_525717,[]),repeat,read(_525717,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_525717).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(var_From,send_message(var_M)):-true.

told(var_Ag,execute_proc(var__)):-true.

told(var_Ag,query_ref(var__,var__)):-true.

told(var_Ag,agree(var__)):-true.

told(var_Ag,confirm(var__),200):-true.

told(var_Ag,disconfirm(var__)):-true.

told(var_Ag,request(var__,var__)):-true.

told(var_Ag,propose(var__,var__)):-true.

told(var_Ag,accept_proposal(var__,var__),20):-true.

told(var_Ag,reject_proposal(var__,var__),20):-true.

told(var__,failure(var__,var__),200):-true.

told(var__,cancel(var__)):-true.

told(var_Ag,inform(var__,var__),70):-true.

told(var_Ag,inform(var__),70):-true.

told(var_Ag,reply(var__)):-true.

told(var__,refuse(var__,var_Xp)):-functor(var_Xp,var_Fp,var__),var_Fp=agree.

tell(var_To,var_From,send_message(var_M)):-true.

tell(var_To,var__,confirm(var__)):-true.

tell(var_To,var__,disconfirm(var__)):-true.

tell(var_To,var__,propose(var__,var__)):-true.

tell(var_To,var__,request(var__,var__)):-true.

tell(var_To,var__,execute_proc(var__)):-true.

tell(var_To,var__,agree(var__)):-true.

tell(var_To,var__,reject_proposal(var__,var__)):-true.

tell(var_To,var__,accept_proposal(var__,var__)):-true.

tell(var_To,var__,failure(var__,var__)):-true.

tell(var_To,var__,query_ref(var__,var__)):-true.

tell(var_To,var__,eve(var__)):-true.

tell(var__,var__,refuse(var_X,var__)):-functor(var_X,var_F,var__),(var_F=send_message;var_F=query_ref).

tell(var_To,var__,inform(var__,var_M)):-true;var_M=motivation(refused_message).

tell(var_To,var__,inform(var__)):-true,var_To\=user.

tell(var_To,var__,propose_desire(var__,var__)):-true.

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),var_N=0,clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_V,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_V,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_V,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_V,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_V,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_V,var_PreM,[var_RepM,var_HostM])),true,false),false)).

meta(var_P,var_V,var_AgM):-functor(var_P,var_F,var_N),(var_N=1;var_N=2),clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var__):-functor(var_P,var_F,var_N),var_N=2,symmetric(var_F),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),append([var_F],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,(symmetric(var_F,var_AgM);symmetric(var_F)),var_P=..var_L,delete(var_L,var_F,var_R),reverse(var_R,var_R1),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),if((eq_property(var_F,var_Y,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_Y,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_Y,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_Y,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_Y,var_PreM,[var_RepM,var_HostM])),true,false),false)),append([var_Y],var_R1,var_R2),var_V=..var_R2.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N>2,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),var_P=..var_L,substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.

meta(var_P,var_V,var_AgM):-clause(agent(var_Ag),var__),clause(ontology(var_Pre,[var_Rep,var_Host],var_Ag),var__),functor(var_P,var_F,var_N),var_N=2,var_P=..var_L,if((eq_property(var_F,var_H,var_Pre,[var_Rep,var_Host]);same_as(var_F,var_H,var_Pre,[var_Rep,var_Host]);eq_class(var_F,var_H,var_Pre,[var_Rep,var_Host])),true,if(clause(ontology(var_PreM,[var_RepM,var_HostM],var_AgM),var__),if((eq_property(var_F,var_H,var_PreM,[var_RepM,var_HostM]);same_as(var_F,var_H,var_PreM,[var_RepM,var_HostM]);eq_class(var_F,var_H,var_PreM,[var_RepM,var_HostM])),true,false),false)),substitute(var_F,var_L,var_H,var_Lf),var_V=..var_Lf.
