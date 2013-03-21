package MailrouteAPI::Reseller;

use strict;
use warnings;
use utf8;

my @rest_api = (
	'schema:get:/api/v1/reseller/schema/',
	'get:get:/api/v1/reseller/',
	'list:get:/api/v1/reseller/',
	'create:post:/api/v1/reseller/',
	'update:put:/api/v1/reseller/{id}/',
	'delete:delete:/api/v1/reseller/{id}/',
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
		my $method_name = 'MailrouteAPI::Reseller::' . $obj_method;
		if (!MailrouteAPI::Reseller->can($obj_method))
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
					;
				}
				elsif ($_obj_method =~ /update|delete/ig)
				{
					$_url = $url;
					$_url =~ s/(\{id\})\/$/$params->{id}\//i if $url =~ /(\{id\})\/$/;
					delete $params->{id};
				}
				elsif($_obj_method eq 'get')
				{
					$_url = $url . "$params->{id}/" if exists($params->{id}) && $params->{id} =~ /[0-9]+/ig;
				}
				elsif($_obj_method eq 'list')
				{
					$_url = $url;
					$_url = "$_url?" . join('&', map { $_ . '=' . $params->{$_} } keys %{$params});
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

=head2 contact()

return MailRouteAPI::ResellerContact object

=cut

sub contact
{
	my ($self) = @_;
	require MailrouteAPI::ResellerContact;
	return MailrouteAPI::ResellerContact->new($self->{ua}, $self->{DEBUG});
}

=head2 contact()

return MailRouteAPI::ResellerAdmin object

=cut

sub admin
{
	my ($self) = @_;
	require MailrouteAPI::ResellerAdmin;
	return MailrouteAPI::ResellerAdmin->new($self->{ua}, $self->{DEBUG});
}

1;

=head1 NAME
The Reseller Object

=head1 VERSION

Version 0.01

our $VERSION = '0.01';

=head1 SYNOPSIS

=head1 EXPORT

=head1 SUBROUTINES/METHODS
=cut

=head2 schema()

my $r = $reseller->schema();

=cut

=head2 get()

my $r = $reseller->get({ id => 12345 });

=cut

=head2 create()

my $cfg = {
	login => 'login',
	apikey => 'password',
	endpoint => 'https://ci.mailroute.net',
	timeout => 10,
};
my $mr = MailRouteAPI->new(1);
$mr->configure($cfg);
my $reseller = $mr->reseller();
my $r = $reseller->create( { name => 'name' } );

=over 2

=item * name       required        String - The name of the Reseller

=back

my $r = $reseller->create( { name => 'reseller name' } );

=cut

=head2 update()

=over 2

=item * name       required        String - The name of the Reseller

=back

my $r = $reseller->update( { name => 'new reseller name' } );

=pod

=head2 list()

my $r = $reseller->filter({
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

my $r = $reseller->delete({ id => 12345 });

=cut
