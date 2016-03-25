use Time::Piece;
use DateTime;

my $out = <<HERE;
sequence_number=12345,remote_client=sapserver,2016-03-18 03:29:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-18 03:29:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=valid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 13:36:00:782 EDT,messageID=1002,user=jdoe2@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=valid Password
HERE

for my $l (split "\n", $out ){

  my $tp = config()->{logdog}->{time_pattern};

  my $re = qr/$tp/;

  my @chunks = $l =~ /$re/;

  my $time_str = join ' ' , @chunks;

  my $time_fmt = config()->{logdog}->{time_format};

  my $t = Time::Piece->strptime( $time_str, $time_fmt );

  my $check_date = DateTime->now( 
    time_zone =>  config()->{logdog}->{timezone}
  )->subtract( seconds => config()->{logdog}->{threshold} );

  my $date = DateTime->new(
    year       => $t->year,
    month      => $t->mon,
    day        => $t->mday,
    hour       => $t->hour,
    minute     => $t->minute,
    second     => $t->second,
    time_zone  => config()->{logdog}->{timezone},
  );

  warn $check_date, " ... ", $date;

  if ( DateTime->compare( $check_date , $date ) == -1 ){
    set_stdout( 
      'localtime time: '.
      localtime()->strftime($time_fmt).
      ' time: '.$t->strftime($time_fmt).
      ' thold: '.
      config()->{logdog}->{threshold}
    );
  }
}
