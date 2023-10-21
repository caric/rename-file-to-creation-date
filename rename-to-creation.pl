#!/usr/bin/perl

use Getopt::Long;
use DateTime;

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

my $LocalTZ = DateTime::TimeZone->new( name => 'local' );

while ( my $name = shift @ARGV ) {
  $name =~ s/^[.\/]+//;
  print $name;
  
  open my $fh, "-|", ( 'mdls', '-n', 'kMDItemContentCreationDate', '--', $name ) or die "Failed spawning $command: $!";
  my @output_lines = <$fh>;
  close $fh;
  #print scalar @output_lines, "\n";
  #print "'", @output_lines, "'\n";
  #chomp $output_lines[0];
  #my $creation = `mdls -n kMDItemContentCreationDate "$name"`;
  $output_lines[0] =~ m/kMDItemContentCreationDate = (\d+)-(\d+)-(\d+)\s+(\d+):(\d+):(\d+)\s+/ or die "Failed getting creation time: $!";

  my $year = $1;
  my $month = $2;
  my $day = $3;
  my $hour = $4;
  my $min = $5;
  my $sec = $6;
  #print "$year-$month-$day $hour:$min:$sec\n";
  my $creation_time = DateTime->new(year=>$year,month=>$month,day=>$day,hour=>$hour,minute=>$min,second=>$sec,time_zone=>"0000");
  print "; creation (UTC): $creation_time";

  # check email headers
  my $email_time = $creation_time;
  if ( $ROPTS->{email} ) {
    if ( open(my $in, "<$name") ) {
      while ( <$in> ) {
        if ( m/^Date: (?:\w{3},)? (\d{1,2}) (\w{3}) (\d{4}) (\d\d):(\d\d):(\d\d) ((?:\+|-)\d{4})/ ) {
          my $day = $1;
          my $email_month = $months{$2};
          my $year = $3;
          my $hour = $4;
          my $min = $5;
          my $sec = $6;
          my $tz_offset = $7;
          $email_time = DateTime->new( year => $year, month=>$email_month+1, day=>$day, hour=>$hour, minute=>$min, second=>$sec, time_zone=>$tz_offset );
          print "; email UTC: $email_time";
          $email_time->set_time_zone("UTC");
          close $in;
          break;
        }
      }
    }
  }
  if ( DateTime->compare($email_time, $creation_time) < 0 )
  {
    $creation_time = $email_time;
  }

  # Convert to local time (note: if you run this while travelling you'll not get your home timezone! it will use your computer's current timezone)
  $creation_time->set_time_zone($LocalTZ);
  my $newname = sprintf "%04d%02d%02d", $creation_time->year, $creation_time->month, $creation_time->day;
  if ( $ROPTS->{time} ) {
    $newname .= sprintf "T%02d%02d%02d", $creation_time->hour, $creation_time->minute, $creation_time->second;
  }
  $newname .= " $name";
  print "; timezone ", $LocalTZ->name, "; mv \"$name\" \"$newname\"\n";
  my @cmd = ();
  if ( $ROPTS->{git} ) {
    @cmd = ("git", "mv", $name, $newname);
  } else {
    @cmd = ("mv", "-i", $name, $newname);
  }
  system(@cmd) if $ROPTS->{x};
}
