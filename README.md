#DALI Bridge 


This project is made for the course of Intelligent Agent at the University of l'Aquila. The vision is a virtual representation and simulation in Gazebo of a Multi Agent System developed in DALI. The  agents are implemented in a stand-alone program where they carry out their actions, and the Gazebo robot simulator show their behavior. 



The DALIbridge establish a connection between two different and stand-alone components:

1. the Multi Agent System with two agents that move around randomly in a flat environment;
2. the Gazebo robot simulator that receive instruction from the Multi Agent System, and translate them in a virtual representation. 

![example](https://github.com/pierfrancescoran/DaliBridge/blob/master/simulation.png)


###DEPENDENCIES 

This project run using different modules and technologies: 

DALI, PyDALI, and PySicstus, at https://github.com/AAAI-DISIM-UnivAQ 
(the last two modules have been modified for the purpose of the project)

Gazebo 4.0, at http://gazebosim.org/ 



###EXECUTION INSTRUCTION

To make the project run it is necessary to correct some file: 

1. the paths in the start.sh and startNT.sh files at lines 4 and 5 in the DaliBridge folder; 

2. the path in the tcpCon.py file at line 11 in the DaliBridge folder; 

3. build the Gazebo plugin: 

	1.     $cd ../DaliBridge/Listener/build 
	
	2.     $cmake ../ 
	
	3.     $make 
	
4. start the execution of the project opening from terminal: 

	1.     $cd ../DaliBridge 
	
	2.     $ ./start.sh 
	
	       $ ./startNT.sh
5. to stop and close the execution push the button start from terminal (wait at least till the Gazebo is launched). 
