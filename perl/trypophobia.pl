#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use SelectSaver;
use Carp qw(carp croak confess cluck);
use IPC::Open3;

my $cmd;
my $procsz;
my @pids=();
$SIG{INT}=sub{
	foreach (@pids){
		system "kill -INT $_";
	}
};
GetOptions(
	"cmd=s"=>\$cmd,
	"procsz=i"=>\$procsz,
) or croak "Something wrong with GetOptions";
print "trypophobia --procsz=n --cmd=command\n" unless defined($cmd) or defined($procsz);

foreach (1 .. $procsz) {
	my $pid=fork;
	if ($pid==0){
		exec $cmd;
		exit 0;
	}elsif ($pid>0){
		push @pids,$pid;
	}else {
		croak "Failed to fork a new process!";
	}
}

foreach (@pids){waitpid $_,0;}
print "DONE\n";
