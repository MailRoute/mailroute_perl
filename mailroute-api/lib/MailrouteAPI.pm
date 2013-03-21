package MailrouteAPI;

use 5.006;
use strict;
use warnings FATAL => 'all';

use utf8;
use Carp qw(carp croak);

use MailrouteAPI::UA;

=head1 NAME

MailRouteAPI - MailRoute.com API client

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS

=head2 ctor

=cut

sub new
{
	my ($class, $debug) = @_;
	my $self = {
		DEBUG => $debug || 0,
		configured => 0,
		ua => undef
	};
	bless $self, $class;
	return $self;
}

=head2 configure()

	my $cfg = {
		login => 'login',
		apikey => 'key',
		endpoint => 'https://admin.mailroute.net/api/v1/',
		timeout => 10
	};
	my $mrapi = MailRouteAPI->new(0);
	$mrapi->configure($cfg);

=cut

sub configure
{
	my ($self, $params) = @_;
	eval {
		$self->{ua} = MailrouteAPI::UA->new(
			$params->{endpoint},
			$params->{login},
			$params->{apikey},
			$params->{timeout},
			$self->{DEBUG}
		),
		$self->{configured} = 1;
	};
	return 0 if $@;
	return 1;
}

=head2 account()
=cut

sub emailAccount
{
	my ($self) = @_;
	require MailrouteAPI::EmailAccount;
	return MailrouteAPI::EmailAccount->new($self->{ua}, $self->{DEBUG});
}

=head2 domain()
=cut

sub domain
{
	my ($self) = @_;
	require MailrouteAPI::Domain;
	return MailrouteAPI::Domain->new($self->{ua}, $self->{DEBUG});
}

=head2 customer()
=cut

sub customer
{
	my ($self) = @_;
	require MailrouteAPI::Customer;
	return MailrouteAPI::Customer->new($self->{ua}, $self->{DEBUG});
}

=head2 reseller()
=cut

sub reseller
{
	my ($self) = @_;
	require MailrouteAPI::Reseller;
	return MailrouteAPI::Reseller->new($self->{ua}, $self->{DEBUG});
}

=head1 AUTHOR

devrow, C<< <devrow at gmail.com> >>

=head1 BUGS

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc MailrouteAPI


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MailrouteAPI>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MailrouteAPI>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MailrouteAPI>

=item * Search CPAN

L<http://search.cpan.org/dist/MailrouteAPI/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 john smith.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1; # End of MailrouteAPI
