#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::DomainAccountNotificationTask');
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
		my $ant = $domain->accountNotificationTask();
		my $schema = $ant->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::DomainAccountNotificationTask::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		my $ant = $domain->accountNotificationTask();

		diag "getting domain account n task by domain id $rc_domain->{object}->{id}";
		my $rc_ant = $ant->get({
			domain => $rc_domain
		});
		diag Dumper($rc_ant);
		my $ant_id = $domain->parseId($rc_domain->{object}->{notification_task});
		if ($rc_ant->{object}->{resource_uri} && $rc_ant->{object}->{resource_uri} eq $rc_domain->{object}->{notification_task})
		{
			diag 'get domain account n task by id ok';
		}
		else
		{
			diag 'error get domain account n task by id: ' . $rc_ant->{error_code};
			return 0;
		}

		diag "update domain account n task by id: $ant_id";
		$rc_ant = $ant->update({
			enabled => JSON::true,
			domain => $rc_domain
		});
		diag Dumper($rc_ant);
		diag "get updated domain account n task by domain id: $ant_id";
		$rc_ant = $ant->get({
			domain => $rc_domain
		});
		diag Dumper($rc_ant);
		if ($rc_ant->{object}->{enabled} == JSON::true)
		{
			diag 'update domain account n task by id ok';
		}
		else
		{
			diag 'error update domain n account task by id: ' . $rc_ant->{error_code};
			return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::DomainAccountNotificationTask create/get/update/delete domain task'
);

1;
