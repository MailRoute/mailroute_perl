package MailrouteAPI::EmailAccount;

use strict;
use warnings;
use utf8;
use vars qw(@ISA @EXPORT $VERSION);
use base 'MailrouteAPI::BaseAPI';

my @rest_api = (
	'schema:get:/api/v1/email_account/schema/',
	'get:get:/api/v1/email_account/',
	'list:get:/api/v1/email_account/',
	'create:post:/api/v1/email_account/',
	'update:put:/api/v1/email_account/{id}/',
	'delete:delete:/api/v1/email_account/{id}/',
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
		my $method_name = 'MailrouteAPI::EmailAccount::' . $obj_method;
		if (!MailrouteAPI::EmailAccount->can($obj_method))
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
				elsif ($_obj_method eq 'create')
				{
					$params->{domain} = $params->{domain}->{object}->{resource_uri};
				}
				elsif ($_obj_method =~ /update|delete/ig)
				{
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					$params->{domain} = $params->{domain}->{object}->{resource_uri};
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					$_url .= "$params->{id}/" if exists($params->{id}) && $params->{id} =~ /[0-9]+/ig;
				}
				elsif($_obj_method eq 'list')
				{
					$_url = "$url?" . join('&', map { $_ . '=' . $params->{$_} } keys %{$params});
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

sub alias
{
	my ($self) = @_;
	require MailrouteAPI::EmailAccountAlias;
	return MailrouteAPI::EmailAccountAlias->new($self->{ua}, $self->{DEBUG});
}

sub userPolicy
{
	my ($self) = @_;
	require MailrouteAPI::EmailAccountUserPolicy;
	return MailrouteAPI::EmailAccountUserPolicy->new($self->{ua}, $self->{DEBUG});
}

sub bwList
{
	my ($self) = @_;
	require MailrouteAPI::EmailAccountBWList;
	return MailrouteAPI::EmailAccountBWList->new($self->{ua}, $self->{DEBUG});
}

sub accountNotificationTask
{
	my ($self) = @_;
	require MailrouteAPI::EmailAccountNotificationTask;
	return MailrouteAPI::EmailAccountNotificationTask->new($self->{ua}, $self->{DEBUG});
}

1;

=head1 NAME
The Email Account Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

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

field name is one of:

=over 2

=back

=cut

=head2 delete()

=cut
