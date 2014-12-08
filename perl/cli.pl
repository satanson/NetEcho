#!/usr/bin/perl -w
use strict;
use Socket;
use IO::Handle;

my ($bytes_out,$bytes_in)=(0,0);

my $servhost = shift || 'localhost';
my $servport = shift || getservbyname('echo','tcp');
my $clihost = shift || 'localhost';
my $cliport = shift || die "need client port";

my $protocol =getprotobyname('tcp');
$servhost = inet_aton($servhost) or die "$servhost:unknown";
$clihost = inet_aton($clihost) or die "$clihost:unknown";

socket(SOCK,AF_INET,SOCK_STREAM,$protocol) or die "socket() failed:$!";
my $cli_addr = sockaddr_in($cliport,$clihost);
my $serv_addr = sockaddr_in($servport,$servhost);
bind(SOCK,$cli_addr) or die "bind() failed:$!";
connect(SOCK,$serv_addr) or die "connect() failed:$!";

SOCK->autoflush(1);

while(my $msg_out=<>){
	print SOCK $msg_out;
	my $msg_in=<SOCK>;
	print $msg_in;
	
	$bytes_out+=length($msg_out);
	$bytes_in +=length($msg_in);
}
close SOCK;
print STDERR "bytes_sent=$bytes_out,bytes_received=$bytes_in\n";
