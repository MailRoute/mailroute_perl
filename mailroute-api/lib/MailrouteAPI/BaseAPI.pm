package MailrouteAPI::BaseAPI;

use strict;
use warnings;
use utf8;
use vars qw(@ISA @EXPORT $VERSION);

sub new
{
	my ($class, $args) = @_;
	# process $$args
	return bless {}, $class;
}

sub parseId
{
	my ($self, $resource_uri) = @_;
	my $matches =()= $resource_uri =~ /.+\/([0-9]{1,})\// if $resource_uri;
	return $1 if $matches && $matches == 1;
	return undef;
}

1;
