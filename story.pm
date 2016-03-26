use Time::Piece;
use DateTime;

my $cnt = 0;

open LOG, config()->{logdog}->{file} or die $!; 

while (my $l  = <LOG>){

  chomp $l;

  next unless $l=~/\S/;

  my $tp = config()->{logdog}->{time_pattern};

  my $re = qr/$tp/;

  my @chunks = $l =~ /$re/;

  scalar @chunks or next;
 
  my $time_str = join ' ' , @chunks;

  my $time_fmt = config()->{logdog}->{time_format};

  #warn $time_str;

  my $t = Time::Piece->strptime( $time_str, $time_fmt );

  my $check_date = DateTime->now( 
    time_zone =>  config()->{logdog}->{timezone}
  )->subtract( minutes => config()->{logdog}->{threshold} );

  my $date = DateTime->new(
    year       => $t->year,
    month      => $t->mon,
    day        => $t->mday,
    hour       => $t->hour,
    minute     => $t->minute,
    second     => $t->second,
    time_zone  => config()->{logdog}->{timezone},
  );

  #warn $check_date, " ... ", $date;

  my $filter = config()->{logdog}->{filter};
  my $filter_re = qr/$filter/;
    
  if ( DateTime->compare( $check_date , $date ) == -1  and $l=~/$filter_re/ ){
    set_stdout('line_start');
    set_stdout($l);
    set_stdout('line_end');
    $cnt++;
  }
}

set_stdout("lines count: $cnt");


