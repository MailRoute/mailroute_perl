#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);

BEGIN {
	use_ok('MailrouteAPI');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));


my $mailrouteAPI = MailrouteAPI->new();
isa_ok($mailrouteAPI, 'MailrouteAPI');
can_ok($mailrouteAPI, ('configure'));

my $cfg = {
	login => 'devrow@gmail.com',
	apikey => '008a4ceb245beb3584493f0269f606dc691dd7f4',
	endpoint => 'https://admin-dev.mailroute.net/api/v1/',
	timeout => 10
};

ok (
	sub {
		my $mrapi = MailrouteAPI->new();
		return $mrapi->configure($cfg);
	}->() == 1,
	'test confugure method'
);

ok (
	defined (sub {
		my $mrapi = MailrouteAPI->new();
		return $mrapi->account();
	}->()),
	'create MailrouteAPI::Account object'
);

ok (
	defined (sub {
		my $mrapi = MailrouteAPI->new();
		return $mrapi->domain();
	}->()),
	'create MailrouteAPI::Domain object'
);

ok (
	defined (sub {
		my $mrapi = MailrouteAPI->new();
		return $mrapi->customer();
	}->()),
	'create MailrouteAPI::Customer object'
);

ok (
	defined (sub {
		my $mrapi = MailrouteAPI->new();
		return $mrapi->reseller();
	}->()),
	'create MailrouteAPI::Reseller object'
);
