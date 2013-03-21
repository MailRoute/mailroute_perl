package MailrouteAPI::ResellerAdmin;

use strict;
use warnings;
use utf8;

my @rest_api = (
	'schema:get:/api/v1/admins/schema/',
	'get:get:/api/v1/admins/reseller/{id1}/admin/{id2}/',
	'list:get:/api/v1/admins/reseller/{id}/',
	'create:post:/api/v1/admins/reseller/{id}/',
	'delete:delete:/api/v1/admins/reseller/{id1}/admin/{id2}/',
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
		my $method_name = 'MailrouteAPI::ResellerAdmin::' . $obj_method;
		if (!MailrouteAPI::ResellerAdmin->can($obj_method))
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
					$_url =~ s/(\{id\})/$params->{reseller}->{object}->{id}/i if $url =~ /\{id\}/i;
					$params->{reseller} = $params->{reseller}->{object}->{resource_uri};
				}
				elsif ($_obj_method eq 'delete')
				{
					$_url = $url;
					$_url =~ s/(\{id1\})/$params->{reseller}->{object}->{id}/i if $url =~ /(\{id1\})/;
					$_url =~ s/(\{id2\})/$params->{id}/i if $url =~ /(\{id2\})/;
					$params = ();
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url;
					$_url =~ s/(\{id1\})/$params->{reseller}->{object}->{id}/i if $url =~ /\{id1\}/;
					$_url =~ s/(\{id2\})/$params->{id}/i if $url =~ /\{id2\}/;
					$params = ();
				}
				elsif($_obj_method eq 'list')
				{
					$params->{id} = $params->{reseller}->{object}->{id};
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					delete $params->{id};
					delete $params->{reseller};
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
					error_code => ($self->{ua}->errorCode() > 299 ? $self->{ua}->errorCode() : 0),
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
The Reseller Admin Object

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
my $a = $reseller->admin();
my $r = $a->schema();

=cut

=head2 get()

my $a = $reseller->admin();
my $r = $a->get({ id => 123 });

=cut

=head2 create()

=over 2

=item * email           required          String - Email Address
=item * send_welcome    false             Boolean - send a welcome email to this new admin

=back

my $a = $reseller->admin();
$a->create({
	email => 'email@domain.com',
	reseller => $reseller->ger({ id=>123 })
});

=cut

=head2 update()

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

$r->list({
 	order_by => 'username',
 	limit => 20,
 	offset => 21,

 	id => 634
});


field name is one of:

=over 2

=item * last_login

=item * send_welcome

=item * username

=item * date_joined

=item * email

=item * resource_uri

=item * is_active

=item * customer

=item * id

=item * reseller
  
=back

=cut

=head2 delete()

my $r = $reseller->delete({ id => 12345 });

=cut
