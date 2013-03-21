#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::EmailAccountNotificationTask');
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
		my $ant = $ea->accountNotificationTask();
		my $schema = $ant->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountNotificationTask::schema()'
);

ok(
	sub {
		my $ea = $mailrouteAPI->emailAccount();
		my $rc_ea = $ea->get({ id => EA_ID });
		my $ant = $ea->accountNotificationTask();
		diag Dumper($rc_ea);

		diag "getting email account n task by email account id $rc_ea->{object}->{id}";
		my $rc_ant = $ant->get({
			email_account => $rc_ea
		});
		diag Dumper($rc_ant);
		my $ant_id = $ea->parseId($rc_ea->{object}->{notification_task});
		if ($rc_ant->{object}->{resource_uri} && $rc_ant->{object}->{resource_uri} eq $rc_ea->{object}->{notification_task})
		{
			diag 'get email account n task by id ok';
		}
		else
		{
			diag 'error get email account n task by id: ' . $rc_ant->{error_code};
			return 0;
		}

		diag "update email account n task by id: $ant_id";
		$rc_ant = $ant->update({
			enabled => JSON::true,
			email_account => $rc_ea
		});
		diag Dumper($rc_ant);
		diag "get updated domain email account n task by domain id: $ant_id";
		$rc_ant = $ant->get({
			email_account => $rc_ea
		});
		diag Dumper($rc_ant);
		if ($rc_ant->{object}->{enabled} == JSON::true)
		{
			diag 'update domain email account n task by id ok';
		}
		else
		{
			diag 'error update domain n email account task by id: ' . $rc_ant->{error_code};
			return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountNotificationTask create/get/update/delete email account n task'
);

1;
