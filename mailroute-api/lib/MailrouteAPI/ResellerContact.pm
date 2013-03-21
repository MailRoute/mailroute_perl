package MailrouteAPI::ResellerContact;

use strict;
use warnings;
use utf8;

my @rest_api = (
	'schema:get:/api/v1/contact_reseller/schema/',
	'get:get:/api/v1/contact_reseller/{id}/',
	'list:get:/api/v1/reseller/{id}/contacts/',
	'create:post:/api/v1/contact_reseller/',
	'update:put:/api/v1/contact_reseller/{id}/',
	'delete:delete:/api/v1/contact_reseller/{id}/',
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
		my $method_name = 'MailrouteAPI::ResellerContact::' . $obj_method;
		if (!MailrouteAPI::ResellerContact->can($obj_method))
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
					$params->{reseller} = $params->{reseller}->{object}->{resource_uri};
				}
				elsif ($_obj_method =~ /update|delete/ig)
				{
					$params->{reseller} = $params->{reseller}->{object}->{resource_uri};
					$_url = $_url;
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					delete $params->{id};
				}
				elsif($_obj_method eq 'list')
				{
					$params->{id} = $params->{reseller}->{object}->{id};
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					delete $params->{id};
					delete $params->{reseller};
					$_url = "$_url?" . join('&', map { $_ . '=' . $params->{$_} } keys %{$params});
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
				}
				else
				{
					return {
						error_code => 0,
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
The Reseller Contact Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

my $mr = MailRouteAPI->new(1);

$mr->configure($cfg);

my $reseller = $mr->reseller();

my $c = $reseller->contact();

my $s = $c->schema();

=cut

=head2 get()

my $rc = $reseller->contact();

my $r = $rc->get({ id => 123 });

=cut

=head2 create()

my $r = $reseller->contact();

$r->create({

	is_technical => 'true',

	email => 'email@domain.com',

	last_name => 'LastName',

	first_name => 'FirstName',

	reseller => $reseller->get({id => 123})
});

=over 2

=item * email          required      String - Email Address

=item * reseller       required      String - reseller_uri

=item * first_name                  String

=item * last_name                   String

=item * address                     String

=item * address2                    String

=item * city                        String

=item * state                       String

=item * zipcode                     String

=item * country                     String

=item * phone                       String

=item * is_billing    false         Boolean - is a billing contact

=item * is_emergency  false         Boolean - is an emergency contact

=item * is_technical  false         Boolean - is a technical contact

=back

=cut

=head2 update()

my $reseller_contact = $reseller->contact();

$r = $reseller->get({ id => $reseller_id });

$rc = $reseller_contact->update({

 	email => 'email',

 	reseller => $r,

 	id => 123,

 	zipcode => '123456'
});

=over 2

=item * email          required      String - Email Address

=item * reseller       required      String - reseller_uri

=item * first_name                  String

=item * last_name                   String

=item * address                     String

=item * address2                    String

=item * city                        String

=item * state                       String

=item * zipcode                     String

=item * country                     String

=item * phone                       String

=item * is_billing    false         Boolean - is a billing contact

=item * is_emergency  false         Boolean - is an emergency contact

=item * is_technical  false         Boolean - is a technical contact

=back

my $r = $reseller->update( { name => 'new reseller name' } );

=pod

=head2 list()

my $r = $reseller->list({

 	order_by => 'field name',

 	limit => 123,

 	offset => 123
});


field name is one of:

=over 2

=item * absolute_url

=item * allow_branding

=item * allow_customer_branding

=item * branding_info

=item * created_at

=item * id

=item * name

=item * pk

=item * resource_uri

=item * updated_at

=back

=cut

=head2 delete()

$r = $c->delete({

 	id => 123

});

=cut
