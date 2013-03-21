package MailrouteAPI::Domain;

use strict;
use warnings;
use utf8;
use vars qw(@ISA @EXPORT $VERSION);
use base 'MailrouteAPI::BaseAPI';

my @rest_api = (
	'schema:get:/api/v1/domain/schema/',
	'get:get:/api/v1/domain/',
	'list:get:/api/v1/domain/',
	'create:post:/api/v1/domain/',
	'update:put:/api/v1/domain/{id}/',
	'delete:delete:/api/v1/domain/{id}/',
);

sub new
{
	my ($class, $ua, $debug) = @_;
	my $self = {
		DEBUG => $debug || 0,
		ua => $ua
	};
	bless $self, $class;

	map {
		my ($obj_method, $http_method, $url) = split(/:/, $_);
		my $method_name = 'MailrouteAPI::Domain::' . $obj_method;
		if (!MailrouteAPI::Domain->can($obj_method))
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
					$params->{customer} = $params->{customer}->{object}->{resource_uri};
				}
				elsif ($_obj_method =~ /update|delete/ig)
				{
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					$params->{customer} = $params->{customer}->{object}->{resource_uri};
					delete $params->{id};
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
	require MailrouteAPI::DomainAlias;
	return MailrouteAPI::DomainAlias->new($self->{ua}, $self->{DEBUG});
}

sub mailServer
{
	my ($self) = @_;
	require MailrouteAPI::DomainMailServer;
	return MailrouteAPI::DomainMailServer->new($self->{ua}, $self->{DEBUG});
}

sub outboundServer
{
	my ($self) = @_;
	require MailrouteAPI::DomainOutboundServer;
	return MailrouteAPI::DomainOutboundServer->new($self->{ua}, $self->{DEBUG});
}

sub userPolicy
{
	my ($self) = @_;
	require MailrouteAPI::DomainUserPolicy;
	return MailrouteAPI::DomainUserPolicy->new($self->{ua}, $self->{DEBUG});
}

sub bwList
{
	my ($self) = @_;
	require MailrouteAPI::DomainBWList;
	return MailrouteAPI::DomainBWList->new($self->{ua}, $self->{DEBUG});
}

sub accountNotificationTask
{
	my ($self) = @_;
	require MailrouteAPI::DomainAccountNotificationTask;
	return MailrouteAPI::DomainAccountNotificationTask->new($self->{ua}, $self->{DEBUG});
}

1;

=head1 NAME
The Domain Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

my $rc = $domain->schema();

=cut

=head2 get()

my $rc = $domain->get({ id => 12345 });

=cut

=head2 create()

my $cfg = {

	login => 'login@email.com',

	apikey => 'password',

	endpoint => 'https://admin.mailroute.net',

	timeout => 10,
};

my $mr = MailRouteAPI->new(1);

$mr->configure($cfg);

my $domain = $mr->domain();

my $rc_domain = $domain->create({

	name => 'name',

	customer => $customer
});

=over 2

=item * name              required       String - The name of the domain

=item * customer          required       String - customer_uri

=item * active            false          Boolean - is the domain active and accepting mail?

=item * bounce_unlisted   false          Boolean - is email list complete, bounce email to unlisted users?

=item * customer          required       A single related resource. Can be either a URI or set of nested resource data

=item * deliveryport      25             Integer - port for email delivery to domain mailservers

=item * hold_email        false          Boolean - is domain email deliver on hold?

=item * outbound_enabled  false          Boolean - is domain enabled for outbound mail (may incur an extra cost)

=item * policy                           A single related resource. Can be either a URI or set of nested resource data

=back

=cut

=head2 update()

my $r = $domain->update({

	name => 'name',

	id => $domain_id,

	customer => $customer,

	active => JSON::true

});

=over 2

=item * name              required       String - The name of the domain

=item * customer          required       String - customer_uri

=item * active            false          Boolean - is the domain active and accepting mail?

=item * bounce_unlisted   false          Boolean - is email list complete, bounce email to unlisted users?

=item * customer          required       A single related resource. Can be either a URI or set of nested resource data

=item * deliveryport      25             Integer - port for email delivery to domain mailservers

=item * hold_email        false          Boolean - is domain email deliver on hold?

=item * outbound_enabled  false          Boolean - is domain enabled for outbound mail (may incur an extra cost)

=item * policy                           A single related resource. Can be either a URI or set of nested resource data

=back

=cut

=head2 list()

my $r = $domain->list({

	order_by => 'field name',

	limit => 123,

	offset => 123
});


field name is one of:

=over 2

=item * bounce_unlisted

=item * name

=item * deliveryport

=item * active

=item * resource_uri

=item * hold_email

=item * created_at

=item * updated_at

=item * customer

=item * policy

=item * outbound_enabled

=item * absolute_url

=item * id

=back

=cut

=head2 delete()

my $r = $domain->delete({ id => 12345 });

=cut
