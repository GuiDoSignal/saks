#!/usr/bin/perl -w

#unstash.pl - "decrypt" IBM HTTP server stash files. No, really. They <strong>are</strong> this pathetic.

use strict;
die "Usage: $0 <stash file>\n" if $#ARGV != 0;
my $file=$ARGV[0];
open(F,$file) || die "Can't open $file: $!";
my $stash;
read F,$stash,1024;
my @unstash=map { $_^0xf5 } unpack("C*",$stash);
foreach my $c (@unstash) {
   last if $c eq 0;
      printf "%c",$c;
      }
printf "\n";
