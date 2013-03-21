package MailrouteAPI::UA;

use strict;
use warnings FATAL => 'all';
use utf8;

use JSON;
use HTTP::Response;
use WWW::Curl::Easy;
use Carp qw(carp croak);

=head1 NAME

User Agent

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
	my ($class, $endpoint, $login, $apikey, $timeout, $debug) = @_;

	my $self = {
		endpoint => $endpoint || 'https://ci.mailroute.net',
		login => $login,
		apikey => $apikey,
		timeout => $timeout || 5,
		DEBUG => $debug || 0,
		ua => WWW::Curl::Easy->new,
		json => JSON->new()->utf8(),

		obj => undef,
		_response => undef,

		_rc => 0,			# curl result code
		_rc_http => 200,	# http result code
	};

	bless $self, $class;

	die 'login must be defined' if !$self->{login};
	die 'apikey must be defined' if !$self->{apikey};

	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_VERBOSE(), 1) if $self->{DEBUG};
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_MAXCONNECTS(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_FORBID_REUSE(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_FRESH_CONNECT(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_HEADER(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CONNECTTIMEOUT(), $self->{timeout});
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_SSL_VERIFYPEER(), 0);
	return $self;
}

=head2 _query()

Private method

Error handling:

=item Codes in the 2xx range indicate success

=item those in the 4xx range indicate that there's an error in the provided information (ie, missing parameter, duplicate entry, etc).

=item Errors in the 5xx range indicate an error in the MailRoute servers.

=cut

sub _query
{
	my ($self, $entry_point, $length) = @_;
	print "request url: $self->{endpoint}$entry_point\n" if $self->{DEBUG};
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_URL(), "$self->{endpoint}$entry_point");
	my $content_length = ($length && $length > 0 ? "Content-Length: $length" : '');
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_HTTPHEADER(), [
		'Accept: application/json',
		'Content-Type: application/json',
		"Authorization: ApiKey $self->{login}:$self->{apikey}",
		$content_length
	]);

	# stupid code
	my $f;
	open($f, '>', \$self->{_response});
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_WRITEDATA(), \$f);
	$self->{_rc} = $self->{ua}->perform();
	close($f);
	
	print "$self->{_response}\n" if $self->{_response} && $self->{DEBUG};
	$self->{_rc_http} = $self->{ua}->getinfo(WWW::Curl::Easy::CURLINFO_HTTP_CODE);

	if ($self->{_rc} == 0)
	{
		$self->{obj} = eval { $self->{json}->decode(HTTP::Response->parse($self->{_response})->content) };
		return 0 if $@;
		$self->_dump($self->{obj}) if $self->{obj} && $self->{DEBUG};

		if($self->{_rc_http} > 399 && $self->{_rc_http} < 500)
		{
			;
		}
		if($self->{_rc_http} > 499 && $self->{_rc_http} < 600)
		{
			$self->{_error_str} = 'Error in the provided information (ie, missing parameter, duplicate entry, etc)' if $self->{_rc_http} >= 400 && $self->{_rc_http} < 500;
			$self->{_error_str} = 'Error in the MailRoute server: ' . $self->{obj}->{error_message} if $self->{_rc_http} >= 500 && $self->{_rc_http} < 600;
			return 0;
		}
	}
	else
	{
		return 0;
	}
	$self->{_response} = undef;
	return 1;
}

=head2 errorToString()
=cut

sub errorToString
{
	my ($self) = @_;
	if ($self->{_rc} > 0)
	{
		return ($self->{_rc} ? $self->{ua}->strerror($self->{_rc}) : 'no error description');
	}
	return $self->{_error_str};
}

=head2 errorCode()
=cut

sub errorCode
{
	my ($self) = @_;
	return $self->{_rc} || $self->{_rc_http};
}

=head2 get()
=cut

sub get
{
	my ($self, $entry_point) = @_;
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), 'GET');
	return ($self->_query($entry_point) ? $self->{obj} : undef);
}

=head2 post()
=cut

sub post
{
	my ($self, $entry_point, $data) = @_;
	$data = $self->{json}->encode($data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), 'POST');
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_GET(), 0);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POST(), 1);
	$self->{ua}->setopt(CURLOPT_POSTFIELDS(), $data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDSIZE(), length($data));
	return ($self->_query($entry_point) ? $self->{obj} : undef);
}

=head2 put()
=cut

sub put
{
	my ($self, $entry_point, $data) = @_;
	$data = $self->{json}->encode($data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POST(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDS(), $data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDSIZE(), length($data));
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), 'PUT');
	return ($self->_query($entry_point, length($data)) ? $self->{obj} : undef);
}

=head2 delete()
=cut

sub delete
{
	my ($self, $entry_point) = @_;
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), 'DELETE');
	return ($self->_query($entry_point) ? $self->{obj} : undef);
}

=head2 head()
=cut

sub head
{
	my ($self, $entry_point) = @_;
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_HEAD(), 1);
	return ($self->_query($entry_point) ? $self->{obj} : undef);
}

=head2 patch()
=cut

sub patch
{
	my ($self, $entry_point, $data) = @_;
	$data = $self->{json}->encode($data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POST(), 1);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_CUSTOMREQUEST(), 'PATCH');
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDS(), $data);
	$self->{ua}->setopt(WWW::Curl::Easy::CURLOPT_POSTFIELDSIZE(), length($data));
	return ($self->_query($entry_point) ? $self->{obj} : undef);
}

=head2 _dump()
=cut

sub _dump
{
	my ($self, $v) = @_;
	use Data::Dumper;
	print Dumper($v) . "\n";
}

1;
