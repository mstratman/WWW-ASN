package WWW::ASN::Jurisdiction;
use Moo;

has 'id' => (
    is       => 'ro',
    required => 1,
);
has 'name' => (
    is       => 'ro',
    required => 1,
);
has 'type' => (
    is       => 'ro',
    required => 1,
);
has 'abbreviation' => (
    is       => 'ro',
    required => 1,
);

=head1 NAME

WWW::ASN::Jurisdiction - Represents a state, organization, or other entity that publishes standards

=head1 SYNOPSIS

    use WWW::ASN;

    my $asn = WWW::ASN->new();
    for my $jurisdiction ($asn->jurisdictions) {
        say $jurisdiction->name,
            "( ", $jurisdiction->abbreviation, ") ",
            "Type: ", $jurisdiction->type,
            "id: ", $jurisdiction->id;
    }


=head1 ATTRIBUTES

=head2 name

The name of the jurisdiction.  This is typically the state or organization name.

e.g. "Alabama", "Common Core State Standards"

=head2 abbreviation

An abbreviation for the jurisdiction.

e.g. "AL", "CCSS"

=head2 type

e.g. "U.S. States and Territories", "Organization", "Country"

=head2 id

This is a globally unique URI for this jurisdiction.

=cut

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
