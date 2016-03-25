use Time::Piece;
use DateTime;

my $out2 = <<HERE;
sequence_number=12345,remote_client=sapserver,2016-03-25 11:36:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 11:36:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 11:36:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 11:36:44:782 EDT,messageID=1002,user=jdoe@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 11:36:44:782 EDT,messageID=1002,user=jdoe4@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=2,result_action=Login Failure,result_reason=Invalid Password
sequence_number=12345,remote_client=sapserver,2016-03-25 12:36:44:782 EDT,messageID=1002,user=jdoe3@example.com,client_ip_address=10.129.220.45,client_port=10250,browser_ip_address=x.x.x.x,result_code=5,result_action=Login Failure,result_reason=Invalid Password
HERE

my $out = <<HERE;
127.0.0.1 - - [25/Mar/2016:14:27:17 +0300] "GET / HTTP/1.1" 200 396 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"
127.0.0.1 - - [25/Mar/2016:14:27:17 +0300] "GET /favicon.ico HTTP/1.1" 404 151 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"
127.0.0.1 - - [25/Mar/2016:14:27:17 +0300] "GET /favicon.ico HTTP/1.1" 404 151 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:45.0) Gecko/20100101 Firefox/45.0"
HERE


my $cnt = 0;

for my $l (split "\n", $out ){

  my $tp = config()->{logdog}->{time_pattern};

  my $re = qr/$tp/;

  my @chunks = $l =~ /$re/;

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

  if ( DateTime->compare( $check_date , $date ) == -1 ){
    set_stdout('line_start');
    set_stdout($l);
    set_stdout('line_end');
    $cnt++;
  }
}

set_stdout("lines count: $cnt");


