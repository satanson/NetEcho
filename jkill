#!/usr/bin/perl
$reg=shift || '.*';
print "\$reg=$reg\n";
$reg=qr/$reg/;
open my $jps_out,"jps |" or die "$!";
while(<$jps_out>){
        ($pid,$p)=split /\s+/;
        print "$p\n";
        if ($p =~ $reg){
                print "shudown $p(pid=$pid)\n";
                `kill -9 $pid`;
        }
}

