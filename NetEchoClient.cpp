
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

int main(){
	boost::shared_ptr<TTransport> socket(new TSocket("localhost",9090));	
	boost::shared_ptr<TTransport> transport(new TFramedTransport(socket));
	boost::shared_ptr<TProtocol>  protocol(new TBinaryProtocol(transport));
	NetEchoClient client(protocol);
	
	do{
		try{
			socket->open();
			string s,us;
			s.reserve(100);
			us.reserve(100);

			while(cin>>s){
				client.echo(us,s);
				cout<<us<<endl;
			}

		}catch(TException &tx){
			cerr<<"ERROR: "<<tx.what()<<endl;
		}
	}while(1);
}

