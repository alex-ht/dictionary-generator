#!/usr/bin/env perl
use Spreadsheet::ParseExcel;
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

$infile = $ARGV[0];
$parser = Spreadsheet::ParseExcel->new();
$workbook = $parser->parse($infile);
if ( !defined $workbook ) {
  die $parser->error(), ".\n";
}
$worksheet = $workbook->worksheet(0);
( $row_min, $row_max ) = $worksheet->row_range();
foreach my $i ($row_min+1 .. $row_max) {
  my $word = $worksheet->get_cell($i, 2)->value();
  my $zuyin = $worksheet->get_cell($i, 6)->value();
  my $ext = $worksheet->get_cell($i, 12)->value();

  $word =~ s/[（(].*[）)]//g;
  $zuyin =~ s/[（(].*[）)]//g;
  @ext_zuyin = split /\([一二三四]\)/, $ext;
  if ($word !~ m/gif/) {
    if ($zuyin =~ m/(^[ˊˇˋ˙ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ　]+)/) {
      print "$word $zuyin\n";
    }
    foreach my $w (@ext_zuyin) {
      if ($w =~ m/(^[ˊˇˋ˙ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ　]+)/) {
        print "$word $1\n";
      }
    }
  }
}
