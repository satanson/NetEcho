#include<unistd.h>
#include<sys/signalfd.h>
#include<cstdio>
#include<cstdlib>
#include<csignal>
#include<ctime>

#include "NetEcho.h"
#include<iostream>
#include<thrift/protocol/TBinaryProtocol.h>
#include<thrift/transport/TSocket.h>
#include<thrift/transport/TTransportUtils.h>
//#include<thrift/transport/TBufferedTransports.h>

using namespace std;
using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;

using namespace boost;
using namespace nynn::mm;

int main(int argc,char**argv){
	boost::shared_ptr<TTransport> socket(new TSocket("localhost",9090));	
	boost::shared_ptr<TTransport> transport(new TFramedTransport(socket));
	boost::shared_ptr<TProtocol>  protocol(new TBinaryProtocol(transport));
	NetEchoClient client(protocol);
	try{
		socket->open();

		sigset_t set,saved_set,pending_set;
		sigemptyset(&set);
		sigaddset(&set,SIGINT);
		int fd=signalfd(-1,&set,SFD_NONBLOCK);
		struct signalfd_siginfo siginfo;

		int n=0;
		int rc;
		struct timespec begin,end,elapse,remain;
		elapse.tv_sec=argc!=2?10:atoi(argv[1]);
		elapse.tv_nsec=0;
		const double NANO=1.0/1000000000;
		printf("sleep for %d in each round\n",elapse.tv_sec);

		int request_num=(argc<2)?10000:atoi(argv[1]);
		sigprocmask(SIG_BLOCK,&set,&saved_set);
		double ave_per_sec=0;
		string s,us;
		s.reserve(100);
		us.reserve(100);
		s="This is a concurrency test of thrift";
		while(1){
			clock_gettime(CLOCK_MONOTONIC,&begin);
			for (int i=0;i<request_num;++i){
				client.echo(us,s);
				//cout<<us<<endl;
			}
			clock_gettime(CLOCK_MONOTONIC,&end);

			double t=end.tv_sec-begin.tv_sec
				+(end.tv_nsec-begin.tv_nsec >0? (end.tv_nsec-begin.tv_nsec)*NANO
						: (1/NANO+end.tv_nsec-begin.tv_nsec)*NANO-1
				 );		
			if (n==0){
				ave_per_sec=request_num/t;
			}
			else{
				ave_per_sec=(n+1)*request_num/(t+n*request_num/ave_per_sec);
			}
			fprintf(stderr,"handling:%f/s\n",ave_per_sec);

			++n;
			sigemptyset(&pending_set);
			sigpending(&pending_set);

			if (sigismember(&pending_set,SIGINT)){
				printf("Gotten a SIGINT!!!\n");
				break;
			}
		}
	}catch(TException &tx){
		cerr<<"ERROR: "<<tx.what()<<endl;
	}
}
