package WWW::ASN::Document;
use strict;
use warnings;
use Moo;
extends 'WWW::ASN::Base';

use JSON;

has 'id' => (
    is       => 'ro',
    required => 0,
);
has 'titles' => (
    is       => 'ro',
    required => 0,
);
has 'subject_names' => (
    is       => 'ro',
    required => 0,
);
has 'uri' => (
    is       => 'ro',
    required => 1,
);
has 'jurisdiction_abbreviation' => (
    is       => 'ro',
    required => 0,
);
has 'adoption_date' => (
    is       => 'ro',
    required => 0,
);
has 'status' => (
    is       => 'ro',
    required => 0,
);

sub title {
    my $self = shift;
    return undef unless defined $self->titles;
    my @titles = @{ $self->titles };
    return undef unless @titles;

    for (@titles) {
        if ($_->{language} eq 'en') {
            return $_->{title};
        }
    }
    return $titles[0]->{title};
}

sub subject {
    my $self = shift;
    return join '; ', @{ $self->subject_names || [] };
}

=head1 NAME

WWW::ASN::Document - Represents a collection of standards or learning objectives

=head1 SYNOPSIS

=head1 ATTRIBUTES

=cut

sub uri_manifest_json { return $_[0]->uri . '_manifest.json'; }

sub uri_full_xml { return $_[0]->uri . '_full.xml'; }

sub uri_full_json { return $_[0]->uri . '_full.json'; }

sub uri_full_turtle { return $_[0]->uri . '_full.ttl'; }

sub uri_full_notation3 { return $_[0]->uri . '_full.n3'; }

sub contents_full_json {
    my $self = shift;
    my $opt = shift || {};

    return $self->_read_or_download(
        $opt->{cache_file},
        $self->uri_full_json,
    );
}

sub contents_full {
    my $self = shift;
    my $opt = shift || {};

    my $json = $self->contents_full_json($opt);

    return JSON->new->utf8->decode($json);
}

sub contents_manifest_json {
    my $self = shift;
    my $opt = shift || {};

    return $self->_read_or_download(
        $opt->{cache_file},
        $self->uri_manifest_json,
    );
}

sub contents_manifest {
    my $self = shift;
    my $opt = shift || {};

    my $json = $self->contents_manifest_json($opt);

    return JSON->new->utf8->decode($json);
}

=head1 AUTHOR

Mark A. Stratman, C<< <stratman at gmail.com> >>


=head1 SEE ALSO

L<WWW::ASN>

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Mark A. Stratman.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;
