#!/usr/bin/env perl

use strict;
use warnings;

use v5.14;

use File::Slurper qw(read_text read_lines);
use JSON;
use utf8;

my $url_file = shift || "miniurls.csv";
my $data_dir = shift || "data";

my @urls = read_lines( $url_file);

my %data;
my @columns = qw ( Accommodates: Bathrooms: Bedrooms: Beds: limpieza extra finde precio lat lng);
say "ID, ", join(", ", @columns);
for my $u ( @urls ) {
  my ($id) = ($u =~ /(\d+)/);
  my ($json_chunk) = read_text("$data_dir/airbnb-$id.json");
  if (!$json_chunk) {
    say "Problem parsing $id ";
  } else {
    my $u_data = utf8::is_utf8($json_chunk) ? Encode::encode_utf8($json_chunk) : $json_chunk;
    my $airbnb_data = decode_json $u_data;
    my $space_data = $airbnb_data->{'bootstrapData'}{'listing'}{'space_interface'};
    for my $d (@$space_data) {
      $data{$id}{$d->{'label'}} = $d->{'value'}
    }
    my $price_data = $airbnb_data->{'bootstrapData'}{'listing'}{'price_interface'};
    $data{$id}{'limpieza'} = $price_data->{'cleaning_fee'}{'value'};
    $data{$id}{'extra'} = $price_data->{'extra_people'}{'value'};
    $data{$id}{'finde'} = $price_data->{'weekend_price'}{'value'};
    for my $l ( qw( lat lng ) ) {
      $data{$id}{$l} = $airbnb_data->{'bootstrapData'}{'listing'}{$l};
    }
    ($data{$id}{'precio'}) = ( $airbnb_data->{'bootstrapData'}{'listing'}{'seo_features'}{'meta_description'} =~ /\x{20AC}(\d+)/ );
    #Print now
    print "$id";
    for my $c ( @columns ) {
      if (!$data{$id}{"$c"}) {
	print ", ";
	next;
      }
      my $u_data = utf8::is_utf8($data{$id}{"$c"}) ? Encode::encode_utf8($data{$id}{"$c"}) : $data{$id}{"$c"};
      print ", $u_data";
    }
  }
    
  print "\n";
}

