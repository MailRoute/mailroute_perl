package MailrouteAPI::CustomerContact;

use strict;
use warnings;
use utf8;

=head1 NAME
The Customer Contact Object

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

my $mr = MailrouteAPI->new(1);

$mr->configure($cfg);

my $customer = $mr->customer();

my $contact = $customer->contact();

my $schema = $contact->schema();

=cut

=head2 get()

my $r = $customerContact->get({ id => 12345 });

=cut

=head2 create()

my $rc = $contact->create({
	email => 'email',

	customer => $customer,

 	first_name => $first_name,

 	last_name => $last_name
});

=over 2

=item * email          required            String - Email Address

=item * customer       required            String - customer_uri

=item * first_name                         String

=item * last_name                          String

=item * address                            String

=item * address2                           String

=item * city                               String

=item * state                              String

=item * zipcode                            String

=item * country                            String

=item * phone                              String

=item * is_billing     false               Boolean - is a billing contact

=item * is_emergency   false               Boolean - is an emergency contact

=item * is_technical   false               Boolean - is a technical contact

=back

=cut

=head2 update()

$rc = $contact->update({

 	email => 'email',

 	customer => $customer,

 	id => $contact_id,

 	zipcode => '123456'
});

if ($rc->{object}->{zipcode} ne '123456')
{

	print 'update error: ' . $rc->{error_code};

 	return 0;
}
else
{
	print 'update ok';
}

=over 2

=item * email          required            String - Email Address

=item * customer       required            String - customer_uri

=item * first_name                         String

=item * last_name                          String

=item * address                            String

=item * address2                           String

=item * city                               String

=item * state                              String

=item * zipcode                            String

=item * country                            String

=item * phone                              String

=item * is_billing     false               Boolean - is a billing contact

=item * is_emergency   false               Boolean - is an emergency contact

=item * is_technical   false               Boolean - is a technical contact

=back

=cut

=head2 list()

$rc = $contact->list({

 	order_by => 'email',

 	offset => 0,

 	limit => 5,

 	customer => $customer
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

$rc = $contact->delete({

 	id => $contact_id,

});

=cut

my @rest_api = (
	'schema:get:/api/v1/contact_customer/schema/',
	'get:get:/api/v1/contact_customer/',
	'list:get:/api/v1/customer/{id}/contacts/',
	'create:post:/api/v1/contact_customer/',
	'update:put:/api/v1/contact_customer/{id}/',
	'delete:delete:/api/v1/contact_customer/{id}/',
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
		my $method_name = 'MailrouteAPI::CustomerContact::' . $obj_method;
		no strict 'refs';
		if (!MailrouteAPI::CustomerContact->can($obj_method))
		{
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
					$_url =~ s/\{id\}/$params->{id}/i if exists($params->{id}) && $params->{id} =~ /[0-9]+/ig;
					delete $params->{id};
					$params->{customer} = $params->{customer}->{object}->{resource_uri};
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					$_url .= "$params->{id}/" if exists($params->{id}) && $params->{id} =~ /[0-9]+/ig;
				}
				elsif($_obj_method eq 'list')
				{
					$_url = $url;
					$_url =~ s/\{id\}/$params->{customer}->{object}->{id}/i if exists($params->{customer}->{object}->{id}) && $params->{customer}->{object}->{id} =~ /[0-9]+/ig;
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
