package WWW::ASN;
use Moo;
extends 'WWW::ASN::Base';

use WWW::ASN::Jurisdiction;
use File::Slurp qw(read_file write_file);
use XML::Twig;


=head1 NAME

WWW::ASN - Retrieve learning objectives from Achievement Standards Network

=cut

our $VERSION = '0.01';

has jurisdictions_cache => (
    is => 'ro',
);

=head1 SYNOPSIS

    use WWW::ASN;

    my $asn = WWW::ASN->new();
    ...


=head1 ATTRIBUTES

=head2 jurisdictions_cache

Optional.  The name of a file containing the XML data from
http://asn.jesandco.org/api/1/jurisdictions

If the file does not exist, it will be created.

Leave this option undefined to force retrieval 
each time L</jurisdictions> is called.

=head1 METHODS

=head2 jurisdictions

...

=cut

sub jurisdictions {
    my $self = shift;

    my $jurisdictions_xml;
    if ($self->jurisdictions_cache && -e $self->jurisdictions_cache) {
        $jurisdictions_xml = read_file($self->jurisdictions_cache);
    }

    unless ($jurisdictions_xml) {
        $jurisdictions_xml = $self->get_url('http://asn.jesandco.org/api/1/jurisdictions');

        if ($self->jurisdictions_cache) {
            write_file($self->jurisdictions_cache, $jurisdictions_xml);
        }
    }

    my @rv = ();
    my $handle_jurisdiction = sub {
        my ($twig, $jur) = @_;

        my %jur_params = ();
        for my $info ($jur->children) {
            my $tag = $info->tag;
            next if $tag eq 'DocumentCount';

            my $val = $info->text;

            # tags should be organizationName, organizationAlias, ...
            $tag =~ s/^organization//;
            $tag = lc $tag;
            if ($tag eq 'name') {
                $jur_params{name} = $val;
            } elsif ($tag eq 'alias') {
                $jur_params{id} = $val;
            } elsif ($tag eq 'jurisdiction') {
                $jur_params{abbreviation} = $val;
            } elsif ($tag eq 'class') {
                $jur_params{type} = $val;
            } else {
                warn "Unknown tag in Jurisdiction: " . $info->tag;
            }
        }
        push @rv, WWW::ASN::Jurisdiction->new(%jur_params);
    };

    my $twig = XML::Twig->new(
        twig_handlers => {
            Jurisdiction => $handle_jurisdiction,
        },
    );
    $twig->parse($jurisdictions_xml);

    return \@rv;
}

=head1 AUTHOR

Mark A. Stratman, C<< <stratman at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-www-asn at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-ASN>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 ACKNOWLEDGEMENTS

This library retrieves and manipulates data from the Achievement Standards Network.
http://asn.jesandco.org/


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Mark A. Stratman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::ASN
