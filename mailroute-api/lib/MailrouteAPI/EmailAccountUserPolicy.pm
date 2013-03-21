package MailrouteAPI::EmailAccountUserPolicy;

use strict;
use warnings;
use utf8;
use vars qw(@ISA @EXPORT $VERSION);
use base 'MailrouteAPI::BaseAPI';

my @rest_api = (
	'schema:get:/api/v1/policy_user/schema/',
	'get:get:/api/v1/policy_user/',
	'update:put:/api/v1/policy_user/{id}/',
);

sub new
{
	my ($class, $ua, $debug) = @_;
	my $self = {
		DEBUG => $debug || 0,
		ua => $ua
	};
	$class->SUPER::new(\$self);
	bless $self, $class;

	map {
		my ($obj_method, $http_method, $url) = split(/:/, $_);
		my $method_name = 'MailrouteAPI::EmailAccountUserPolicy::' . $obj_method;
		if (!MailrouteAPI::EmailAccountUserPolicy->can($obj_method))
		{
			no strict 'refs';
			*{$method_name} = sub {
				my ($self, $params) = @_;

				my $_url = $url;
				my $_http_method = $http_method;
				my $_obj_method = $obj_method;

				if ($_obj_method eq 'schema')
				{
					;
				}
				elsif ($_obj_method eq 'update')
				{
					$_url = $url;
					my $ea_id = $self->parseId($params->{email_account}->{object}->{policy});
					$_url =~ s/(\{id\})/$ea_id/i if $ea_id;
					$params->{email_account} = $params->{email_account}->{object}->{resource_uri};
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					my $ea_id = $self->parseId($params->{email_account}->{object}->{policy});
					$_url .= "$ea_id/" if $ea_id;
				}
				else
				{
					return {
						error_code => undef,
						error_str => 'method not supported',
						object => undef
					};
				}

				die 'url undefined' if !$_url;
				my $object = $self->{ua}->$_http_method($_url, $params);

				return {
					error_code => $self->{ua}->errorCode(),
					error_str => $self->{ua}->errorToString(),
					object => $object
				};
			};
		}
	} @rest_api;
	return $self;
}

1;

=head1 NAME
The Email Account User Policy Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

my $rc = $up->schema();

=cut

=head2 get()

=cut

=head2 create()

=over 2

=back

=cut

=head2 update()

=over 2

=back

=cut

=head2 list()

=over 2

=back

=cut

=head2 delete()

=cut
