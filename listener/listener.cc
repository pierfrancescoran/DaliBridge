
#include <gazebo/gazebo.hh>
#include <gazebo/transport/transport.hh>
#include <gazebo/msgs/msgs.hh>
#include <gazebo/math/gzmath.hh>
#include <iostream>
  
//
#define DEBUG
#define PORT 2005
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
//


//
extern int	errno;
struct protoent		*getprotobyname();
struct hostent		*gethostbyname();
int			server_id,s1_id;
struct protoent		*pp;
struct hostent		*server;
struct in_addr		server_addr;



char*  pch;
 double x,y;
char tipo[80],nome[80],messo[80];
char 	hostname[40];
char 	command[BUFSIZ],data[BUFSIZ];
int 		length,nbytes,pid;
struct sockaddr_in	server_sock;


int main(int _argc, char **_argv)
{

  // Load gazebo
  gazebo::setupClient(_argc, _argv);
 
  // Create our node for communication
  gazebo::transport::NodePtr node(new gazebo::transport::Node());
  node->Init();
  gazebo::transport::PublisherPtr modelPub = node->Advertise<gazebo::msgs::Model>("~/model/modify");

  // Wait for a subscriber to connect
  modelPub->WaitForConnection();

	//connetcing the server
	if (gethostname(hostname,40) != 0) {
		fprintf(stderr,"server: errore gethostname()\n");
		exit(1);
		 }

	if ((server = gethostbyname(hostname)) == 0) {
		fprintf(stderr,"server: gethostbyname()  local sconosciuto\n");
		exit(1);
		 }
		 bcopy(server->h_addr,(char *)&server_addr,server->h_length);

	 if ((pp = getprotobyname("tcp")) == 0) {
		fprintf(stderr,"server: errore getprotobyname()\n");
		exit(1);
		 }

	if ((server_id = socket(AF_INET,SOCK_STREAM,pp->p_proto)) == -1) {
		perror("server: socket()\n");
		exit(1);
		 }


 server_sock.sin_family = AF_INET;
 server_sock.sin_addr = server_addr;
 server_sock.sin_port = htons(PORT);
 length = sizeof(server_sock);

 if (bind(server_id,(struct sockaddr *) &server_sock,sizeof(server_sock)) == -1) {
	perror("server: bind()\n");
	close(server_id);
	exit(1);
    }

 if (getsockname(server_id, (struct sockaddr *) &server_sock, (socklen_t *)&length) == -1) {
	perror("server: getsockname() ");
	exit(1);
   }

 if(listen(server_id,5) == -1){
	perror("server: errore listen() ");
	exit(1);
   }



	if((s1_id = accept(server_id,0,0)) == -1){
        	perror("server: accept \n");
        	exit(1);
       }


   while (1) {
       
	    close(server_id);

 			if ((nbytes = recv(s1_id,command,sizeof(command),0)) < 0) {
        	perror("server figlio: errore recv() \n");
        	exit(1);
            }

            
			pch = strtok (command," ");
			strcpy(tipo,pch);
			pch = strtok (NULL, " ");
			strcpy(nome,pch);
			pch = strtok (NULL, " ");
			x = strtod(pch,NULL);
			pch = strtok (NULL, " ");
			y = strtod(pch,NULL);
			strcpy(command,messo);

			/*reading the message
				if the first element of the message is "joined" or "move", change the position to the model
				if the first element of the message is "found", close the connection and the plugin
			*/
		  if((strcmp(tipo, "joined")==0)||(strcmp(tipo, "move")==0)){

	 			gazebo::common::Time::MSleep(1000);
 
   	 		// Generate a pose
    		gazebo::math::Pose pose(x, y, 0.5, 0, 0, 0);
 
   	 		gazebo::msgs::Model msg;  
 				msg.set_name(nome); // name of the model as defined in the .world file
 				gazebo::msgs::Set(msg.mutable_pose(), pose);
   			modelPub->Publish(msg);
		

			}
			
			else if(strcmp(tipo, "found")==0){
				close(server_id);
				gazebo::shutdown();
				exit(0);
			}
			else printf("errore messaggio non riconosciuto");

          
   		close(server_id); 
   }


  gazebo::shutdown();
}
