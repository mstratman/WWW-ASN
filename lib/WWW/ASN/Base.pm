package WWW::ASN::Base;
use Moo;
use File::Slurp qw(read_file);
use LWP::Simple qw(get);

sub get_url {
    my ($self, $url) = @_;
    my $content = get($url);
    die "Unable to download $url" unless defined $content;
    return $content;
}

1;
