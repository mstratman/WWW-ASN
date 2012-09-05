package WWW::ASN;
use Moo;
extends 'WWW::ASN::Base';

use File::Slurp qw(read_file write_file);
use XML::Twig;

use WWW::ASN::Jurisdiction;
use WWW::ASN::Subject;


=head1 NAME

WWW::ASN - Retrieve learning objectives from Achievement Standards Network

=cut

our $VERSION = '0.01';

has jurisdictions_cache => (
    is => 'ro',
);

has subjects_cache => (
    is => 'ro',
);

=head1 SYNOPSIS

    use WWW::ASN;

    my $asn = WWW::ASN->new({
        jurisdictions_cache => './jurisdictions.xml',
    });
    for my $jurisdiction (@{ $asn->jurisdictions }) {
        if ($jurisdictions->name =~ /Common Core/i) {
            my @standards_docs = $jurisdictions->documents({ status => 'published' })
            ...
        }
    }


=head1 DESCRIPTION

This module allows you to retrieve standards documents from
the Achievement Standards Network (L<http://asn.jesandco.org/>).

As illustrated in the L</SYNOPSIS>, you will typically first
retrieve a L<jurisdiction|WWW::ASN::Jurisdiction> such as a state,
or other organization that creates L<standards documents|WWW::ASN::Document>.
From this jurisdiction you can then retrieve specific documents.

=head1 ATTRIBUTES

=head2 jurisdictions_cache

Optional.  The name of a file containing the XML data from
http://asn.jesandco.org/api/1/jurisdictions

If the file does not exist, it will be created.

Leave this option undefined to force retrieval 
each time L</jurisdictions> is called.

=head2 subjects_cache

Optional.  The name of a file containing the XML data from
http://asn.jesandco.org/api/1/subjects

If the file does not exist, it will be created.

Leave this option undefined to force retrieval 
each time L</subjects> is called.

=head1 METHODS

=head2 jurisdictions

Returns an array reference of L<WWW::ASN::Jurisdiction> objects.

=cut

sub jurisdictions {
    my $self = shift;

    my $jurisdictions_xml = $self->_read_or_download(
        $self->jurisdictions_cache, 
        'http://asn.jesandco.org/api/1/jurisdictions',
    );

    my @rv = ();
    my $handle_jurisdiction = sub {
        my ($twig, $jur) = @_;

        my %jur_params = ();
        for my $info ($jur->children) {
            my $tag = $info->tag;

            my $val = $info->text;

            # tags should be organizationName, organizationAlias, ...
            # with 'DocumentCount' being the exception
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
            } elsif ($tag eq 'documentcount') {
                $jur_params{document_count} = $val;
            } else {
                warn "Unknown tag in Jurisdiction: " . $info->tag;
            }
        }
        push @rv, WWW::ASN::Jurisdiction->new(%jur_params);
    };

    my $twig = XML::Twig->new(
        twig_handlers => {
            '/asnJurisdictions/Jurisdiction' => $handle_jurisdiction,
        },
    );
    $twig->parse($jurisdictions_xml);

    return \@rv;
}

=head2 subjects

Returns an array reference of L<WWW::ASN::Subject> objects.

=cut

sub subjects {
    my $self = shift;

    my $subjects_xml = $self->_read_or_download(
        $self->subjects_cache, 
        'http://asn.jesandco.org/api/1/subjects',
    );

    my @rv = ();
    my $handle_subject = sub {
        my ($twig, $subject) = @_;

        push @rv, WWW::ASN::Subject->new(
            id             => $subject->first_child('SubjectIdentifier')->text,
            name           => $subject->first_child('Subject')->text,
            document_count => $subject->first_child('DocumentCount')->text,
        );
    };

    my $twig = XML::Twig->new(
        twig_handlers => {
            '/asnSubjects/Subject' => $handle_subject,
        },
    );
    $twig->parse($subjects_xml);

    return \@rv;
}

sub _read_or_download {
    my ($self, $cache_file, $url) = @_;

    my $content;

    if (defined $cache_file && -e $cache_file) {
        $content = read_file($cache_file);
    }

    unless (defined $content && length $content) {
        $content = $self->get_url($url);

        if (defined $cache_file) {
            write_file($cache_file, $content);
        }
    }

    return $content;
}

=head1 AUTHOR

Mark A. Stratman, C<< <stratman at gmail.com> >>

=head1 SEE ALSO

L<WWW::ASN::Jurisdiction>

L<WWW::ASN::Document>

L<WWW::ASN::Subject>

=head1 ACKNOWLEDGEMENTS

This library retrieves and manipulates data from the Achievement Standards Network.
L<http://asn.jesandco.org/>


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Mark A. Stratman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of WWW::ASN
