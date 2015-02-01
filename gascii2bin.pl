#!/usr/bin/perl -w
use strict;
use Carp qw(carp croak confess cluck);
use FileHandle;
use Getopt::Long;
my $if;
my $of;
my $mask_bits;
GetOptions(
	"if=s"=>\$if,
	"of=s"=>\$of,
	"mask_bits=s"=>\$mask_bits,
) or croak "fail to parse options";

croak "file '$if' not exists" unless -f $if;

my $FIN=FileHandle->new("< $if");
croak "fail to open file '$if' for reading" unless defined($FIN);
#my $FOUT=FileHandle->new("> $of");
#croak "fail to open file '$of' for writing" unless defined($FOUT);
#binmode $FOUT;

my %FOUT=();
my $count=0;

sub gethandle{
	my $vtxno=shift;
	my $sgkey=$vtxno&~((1<<$mask_bits)-1);
	#printf "%0x\n",((1<<$mask_bits)-1);
	#printf "vtxno=%0x; sgkey=%0x\n",$vtxno,$sgkey;
	unless (exists $FOUT{$sgkey}){
		$FOUT{$sgkey}=FileHandle->new(">> $of.$count");
		$count++;
	}
	return $FOUT{$sgkey};
}
my ($vtxcnt,$edgecnt) = (0,0);
while(<$FIN>){
	chomp;
	my @neighbor=split ":",$_;
	my $sv=shift @neighbor;
	my $n=@neighbor;
	$vtxcnt++;
	$edgecnt+=$n;
	my $s=pack "VV",$sv,$n;
	my $FOUT=gethandle($sv);
	syswrite $FOUT,$s,length($s);

	foreach my $e (@neighbor){
		my($dv,$w,$t)=split ",",$e;
		my $s=pack "VdQ",$dv,$w,$t;
		syswrite $FOUT,$s,length($s);
	}
}
foreach my $f (values %FOUT){
	$f->close();
}
printf "vertices:%d edges: %d average outdegree: %f\n",$vtxcnt,$edgecnt,$edgecnt/$vtxcnt;
