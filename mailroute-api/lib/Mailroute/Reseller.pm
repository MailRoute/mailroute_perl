package Mailroute::Reseller;

use strict;
use warnings;
use utf8;

use MailRouteAPI::Reseller;

sub new
{
	my ($class, $debug, $id) = @_;
	my $self = {
		DEBUG => $debug || 0,
		reseller => ($id && $id =~ /[0-9]+/ ? MailRouteAPI::Reseller->new($debug)->get({ id => $id }) : undef),
		params => undef
	};
	bless $self, $class;
}

sub limit
{
	my ($self, $limit) = @_;
	$self->{params}->{limit} = $limit;
	return $self;
}

sub orderBy
{
	my ($self, $orderBy) = @_;
	$self->{params}->{order_by} = $orderBy;
	return $self;
}

sub offset
{
	my ($self, $offset) = @_;
	$self->{params}->{offset} = $offset;
	return $self;
}

sub create
{

}

sub search
{
	my ($self) = @_;
	$result = $self->{reseller}->list($self->{params});
	return (
		undef,
		$result->{error_code},
		$result->{error_str},
		0
	) if !exists($result->{object}->{objects};
	return (
		$result->{object}->{objects},
		$result->{error_code},
		$result->{error_str}
		$result->{object}->{meta}->{total_count},
	);
}

sub delete
{

}

sub update
{

}

sub createAdmin
{

}

sub searchAdmin
{

}

sub deleteAdmin
{

}

sub createContact
{

}

sub searchContact
{

}

sub deleteContact
{

}

sub updateContact
{

}

1;
