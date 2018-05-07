#!/usr/bin/env perl
# 讀入moe的辭典檔案，印出文字和注音一式的部分。
# 有些單字詞會有多種讀音，記錄在第12欄，並且以(一)(二)等格式紀錄各種注音。
# note: 注音一式會將輕聲符號放在最前面。
# known issues:
# 1. 有些字詞是以圖片檔名呈現，例如異體字，這部分會直接忽略。
# 2. 約有四個詞出現utf-8編碼範圍外的問題。
# usage: moedict_parser.pl xls-file > output.txt

use Spreadsheet::ParseExcel;
use utf8;
binmode(STDIN, ':encoding(utf8)');
binmode(STDOUT, ':encoding(utf8)');
binmode(STDERR, ':encoding(utf8)');

sub split_comma {
  my @cols = split(' ',$_[0]);# 小空白前面是詞，後面是注音
  my $pos = 1; # 現在字數
  my $buf = ""; # output buffer
  my $output = "";
  my @wlist = split('，',@cols[0]);
  foreach my $w (@wlist) { # 用大豆號隔開
    $end_pos = $pos + length($w);
    $buf = "$w";
    for (;$pos<$end_pos;$pos++) {
      $buf.= " @cols[$pos]";
    }
    $output.="$buf\n";
  }
  return $output;
}

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
  my $ext = $worksheet->get_cell($i, 12)->value(); # 其他讀音

  $word =~ s/[（(].*[）)]//g;
  $zuyin =~ s/[（(].*[）)]//g;
  @ext_zuyin = split /\([一二三四]\)/, $ext;
  if ($word !~ m/gif/)  { # 多字詞會用大空白隔開每個字的注音。
    if ($zuyin =~ m/(^[ˊˇˋ˙ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ　]+)/) {
      print split_comma("$word $zuyin");
    }
    foreach my $w (@ext_zuyin) {
      if ($w =~ m/(^[ˊˇˋ˙ㄅㄆㄇㄈㄉㄊㄋㄌㄍㄎㄏㄐㄑㄒㄓㄔㄕㄖㄗㄘㄙㄧㄨㄩㄚㄛㄜㄝㄞㄟㄠㄡㄢㄣㄤㄥㄦ　]+)/) {
        print split_comma("$word $1");
      }
    }
  }
}
