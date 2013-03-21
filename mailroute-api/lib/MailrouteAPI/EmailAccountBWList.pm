package MailrouteAPI::EmailAccountBWList;

use strict;
use warnings;
use utf8;

my @rest_api = (
	'schema:get:/api/v1/wblist/schema/',
	'get:get:/api/v1/wblist/',
	'list:get:/api/v1/wblist/',
	'create:post:/api/v1/wblist/',
	'delete:delete:/api/v1/wblist/{id}/',
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
		my $method_name = 'MailrouteAPI::EmailAccountBWList::' . $obj_method;
		if (!MailrouteAPI::EmailAccountBWList->can($obj_method))
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
					$params->{email_account} = $params->{email_account}->{object}->{resource_uri};
				}
				elsif ($_obj_method eq 'delete')
				{
					$_url = $url;
					$_url =~ s/(\{id\})/$params->{id}/i if $url =~ /\{id\}/;
					$params->{email_account} = $params->{email_account}->{object}->{resource_uri};
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

1;

=head1 NAME
The Email Account Black and White List Object

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

=over 2

=back

=cut

=head2 delete()

=cut
