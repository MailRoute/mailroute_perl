package MailrouteAPI::CustomerAdmin;

use strict;
use warnings;
use utf8;

=head1 NAME
The Customer Admin Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

my $cfg = {

	login => 'login',

	apikey => 'key',

	endpoint => 'https://ci.mailroute.net',

	timeout => 10,
};

my $mr = MailRouteAPI->new(1);

$mr->configure($cfg);

my $customer = $mailRouteAPI->customer();

my $admin = $customer->admin();

my $schema = $admin->schema();

=cut

=head2 get()

my $r = $customerContact->get({ id => 12345 });

=cut

=head2 create()

my $rc_admin = $admin->create({

	email => 'email',

	customer => $customer,
});

=over 2

=item * email          required            String - Email Address

=item * send_welcome   false               Boolean - send a welcome email to this new admin

=back

=cut

=head2 list()

my $r = $customer->list({

 	order_by => 'field name',

 	limit => 123,

 	offset => 123
});


field name is one of:

=over 2

=item * is_full_user_list

=item * name

=item * branding_info

=item * resource_uri

=item * created_at

=item * allow_branding

=item * updated_at

=item * absolute_url

=item * id

=item * reported_user_count

=item * reseller

=back

=cut

=head2 delete()

my $r = $customerAdmin->delete({

	id => '123'

	customer => $customer,

});

=cut

my @rest_api = (
	'schema:get:/api/v1/admins/schema/',
	'get:get:/api/v1/admins/customer/{id1}/admin/{id2}/',
	'list:get:/api/v1/admins/customer/{id}/',
	'create:post:/api/v1/admins/customer/{id}/',
	'delete:delete:/api/v1/admins/customer/{id1}/admin/{id2}/'
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
		my $method_name = 'MailrouteAPI::CustomerAdmin::' . $obj_method;
		if (!MailrouteAPI::CustomerAdmin->can($obj_method))
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
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{customer}->{object}->{id}/i if $url =~ /\{id\}/;
					delete $params->{customer};
				}
				elsif ($_obj_method eq 'delete')
				{
					#die Data::Dumper->Dumper($params);
					$_url = $url;
					$_url =~ s/(\{id1\})/$params->{customer}->{object}->{id}/i if $url =~ /\{id1\}/;
					$_url =~ s/(\{id2\})/$params->{id}/i if $url =~ /\{id2\}/;
					#die $_url;
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					$_url =~ s/(\{id1\})/$params->{customer}->{object}->{id}/i if $url =~ /\{id1\}/;
					$_url =~ s/(\{id2\})/$params->{id}/i if $url =~ /\{id2\}/;
				}
				elsif($_obj_method eq 'list')
				{
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{customer}->{object}->{id}/i if $url =~ /\{id\}/;
					delete $params->{customer};
					$_url = "$_url?" . join('&', map { $_ . '=' . $params->{$_} } keys %{$params});
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
