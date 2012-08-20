use strict;
use warnings;
use Test::More;

use WWW::ASN;
use FindBin qw($Bin);
use File::Spec::Functions qw(catfile);

my $xml_file = catfile($Bin, 'jurisdictions.xml');

if ($ENV{ASN_USE_NET}) {
    unlink($xml_file);
    ok(! -e $xml_file, "$xml_file does not exist");
}


my $asn = new_ok 'WWW::ASN' => [ jurisdictions_cache => $xml_file ];

my $jurisdictions = $asn->jurisdictions;
ok(-e $xml_file, "$xml_file exists");

isa_ok($jurisdictions->[0], 'WWW::ASN::Jurisdiction');

my @wyoming = grep { $_->id eq 'http://purl.org/ASN/scheme/ASNJurisdiction/WY' } @$jurisdictions;
ok(@wyoming, "found wyoming");
is($wyoming[0]->abbreviation, 'WY', 'abbreviation');
like($wyoming[0]->name, qr/Wyoming/, 'name');
like($wyoming[0]->type, qr/State/i, 'type');
ok($wyoming[0]->document_count > 1, 'document_count > 1');

done_testing;
