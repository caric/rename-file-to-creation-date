#!/usr/bin/perl

use Getopt::Long;
use Time::Local qw( timegm_modern timelocal_modern );

$ROPTS = {
           x => 0,
           git => 0,
           time => 0,
           email => 0,
         };
GetOptions( $ROPTS,
            'x!',
            'git!',
            'time!',
            'email!',
           );
my %months = (Jan => 0, Feb => 1, Mar => 2, Apr => 3, May => 4, Jun => 5, Jul => 6, Aug => 7, Sep => 8, Oct => 9, Nov => 10, Dec => 11 );

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
  print $time, "\n";

  # check email headers
  my $email_time = $time;
  if ( $ROPTS->{email} ) {
      if ( open(my $in, "<$name") ) {
        while ( <$in> ) {
          if ( m/\w{3}, (\d{1,2}) (\w{3}) (\d{4}) (\d\d):(\d\d):(\d\d) ((?:\+|-)\d{4})/ ) {
            my $mday = $1;
            my $email_month = $months{$2};
            my $year = $3;
            my $hour = $4;
            my $min = $5;
            my $sec = $6;
            print "$mday $email_month $2\n";
            $email_time = timelocal_modern( $sec, $min, $hour, $mday, $email_month, $year );
            print $email_time, "\n";
            close $in;
            break;
          }
      }
    }
  }
  if ( $email_time < $time )
  {
    $time = $email_time;
    print "switching to $email_time\n";
  }
  ($sec,$min,$hour,$day,$month,$year,$wday,$yday) = localtime $time;

  my $newname = sprintf "%04d%02d%02d", $year+1900, $month+1, $day;
  if ( $ROPTS->{time} ) {
    $newname .= sprintf "T%02d%02d%02d", $hour, $min, $sec;
  }
  $newname .= " $name";
  print "mv \"$name\" \"$newname\"\n";
  my @cmd = ();
  if ( $ROPTS->{git} ) {
    @cmd = ("git", "mv", $name, $newname);
  } else {
    @cmd = ("mv", "-i", $name, $newname);
  }
  system(@cmd) if $ROPTS->{x};
}
