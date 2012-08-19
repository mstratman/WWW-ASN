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
ok(-e $xml_file, "$xml_file was created");
is_deeply($jurisdictions, [], 'jurisdictions() returned...');

done_testing;
