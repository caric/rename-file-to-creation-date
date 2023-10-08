#!/usr/bin/perl

use Getopt::Long;
use Time::Local qw( timegm_modern );

$ROPTS = {
           x => 0,
           git => 0,
           time => 0,
         };
GetOptions( $ROPTS,
            'x!',
            'git!',
            'time!',
           );

while ( my $name = shift @ARGV ) {
  print $name, "\n";

  my $creation = `mdls -n kMDItemContentCreationDate "$name"`;
  $creation =~ m/kMDItemContentCreationDate = (\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\s+/;

  my $year = $1;
  my $month = $2;
  my $day = $3;
  my $hour = $4;
  my $min = $5;
  my $sec = $6;
  # Convert to local time (note: if you run this while travelling you'll not get your home timezone!)
  my $time = timegm_modern( $sec, $min, $hour, $day, $month-1, $year );
  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime $time;

  my $newname = sprintf "%04d%02d%02d", $year+1900, $month, $day;
  if ( $ROPTS->{time} ) {
    $newname .= sprintf "T%02d%02d%02d", $hour, $min, $sec;
  }
  $newname .= " $name";
  print "mv \"$name\" \"$newname\"\n";
  if ( $ROPTS->{git} ) {
    system("git", "mv", $name, $newname) if $ROPTS->{x};
  } else {
    system("mv", $name, $newname) if $ROPTS->{x};
  }
}
