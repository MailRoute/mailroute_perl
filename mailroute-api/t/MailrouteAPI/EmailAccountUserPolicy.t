#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::EmailAccountUserPolicy');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));

my $mailrouteAPI = MailrouteAPI->new(1);

isa_ok($mailrouteAPI, 'MailrouteAPI');
can_ok($mailrouteAPI, ('configure'));

use constant EA_ID => 2;

my $cfg = {
	login => 'test_perl',
	apikey => '66956c7f27fc89ff8169f9b6dca8150a7ffb5ea7',
 	endpoint => 'https://ci.mailroute.net'
};

ok(
	sub {
		$mailrouteAPI->configure($cfg);
		my $ea = $mailrouteAPI->emailAccount();
		my $up = $ea->userPolicy();
		my $schema = $up->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountUserPolicy::schema()'
);

ok(
	sub {
		my $ea = $mailrouteAPI->emailAccount();
		my $rc_ea = $ea->get({ id => EA_ID });
		diag Dumper($rc_ea);
		my $up = $ea->userPolicy();

		diag "getting email account user policy by id: $rc_ea->{object}->{id}";
		my $rc_up = $up->get({
			email_account => $rc_ea
		});
		diag Dumper($rc_up);
		my $ea_id = $ea->parseId($rc_up->{object}->{policy});
		if ($rc_up->{object} && $rc_ea->{object}->{policy} eq $rc_up->{object}->{resource_uri} )
		{
			diag 'get email account user policy by id ok';
		}
		else
		{
			diag 'error get email account user policy by id: ' . $rc_up->{error_code};
			return 0;
		}

		diag "update email account user policy by id: $rc_up->{object}->{id}";
		$rc_up = $up->update({
			priority => 3,
			email_account => $rc_ea
		});
		diag Dumper($rc_up);
		diag "get updated email account user policy by id: $rc_up->{object}->{id}";
		$rc_up = $up->get({
			email_account => $rc_ea
		});
		diag Dumper($rc_up);
		if ($rc_up->{object}->{priority} != 3)
		{
			diag 'error update email account user policy by id: ' . $rc_up->{error_code};
			return 0;
		}
		else
		{
			diag 'update email account user policy by id ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountUserPolicy create/get/update/delete email account user policy'
);

1;
