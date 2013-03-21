#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::DomainUserPolicy');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));

my $mailrouteAPI = MailrouteAPI->new(1);

isa_ok($mailrouteAPI, 'MailrouteAPI');
can_ok($mailrouteAPI, ('configure'));

use constant DOMAIN_ID => 3;

my $cfg = {
	login => 'test_perl',
	apikey => '66956c7f27fc89ff8169f9b6dca8150a7ffb5ea7',
 	endpoint => 'https://ci.mailroute.net'
};

ok(
	sub {
		$mailrouteAPI->configure($cfg);
		my $domain = $mailrouteAPI->domain();
		my $up = $domain->userPolicy();
		my $schema = $up->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::DomainUserPolicy::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		diag Dumper($rc_domain);
		my $up = $domain->userPolicy();

		diag "getting domain user policy by domain id $rc_domain->{object}->{id}";
		my $rc_up = $up->get({
			domain => $rc_domain
		});
		diag Dumper($rc_up);
		my $policy_id = $domain->parseId($rc_up->{object}->{policy});
		if ($rc_up->{object}->{policy} && $rc_up->{object}->{policy} ne "/api/v1/policy_domain/$policy_id/")
		{
			diag 'error get domain user policy by policy id: ' . $rc_up->{error_code};
			return 0;
		}
		else
		{
			diag 'get domain user policy by policy id ok';
		}

		diag "update domain user policy by policy id: $rc_domain->{object}->{id}";
		$rc_up = $up->update({
			priority => 3,
			domain => $rc_domain
		});
		diag Dumper($rc_up);
		diag "get updated domain user policy by policy id: $rc_domain->{object}->{id}";
		$rc_up = $up->get({
			domain => $rc_domain
		});
		diag Dumper($rc_up);
		if ($rc_up->{object}->{priority} != 3)
		{
			diag 'error update domain user policy by policy id: ' . $rc_up->{error_code};
			return 0;
		}
		else
		{
			diag 'update domain user policy by policy id ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::DomainUserPolicy create/get/update/delete domain user policy'
);

1;
