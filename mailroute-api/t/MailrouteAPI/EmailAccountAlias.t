#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::EmailAccount');
 	use_ok('MailrouteAPI::EmailAccountAlias');
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
		my $emailAccount = $mailrouteAPI->emailAccount();
		my $alias = $emailAccount->alias();
		my $schema = $alias->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountAlias::schema()'
);

ok(
	sub {
		my $emailAccount = $mailrouteAPI->emailAccount();
		my $rc_ea = $emailAccount->get({ id => EA_ID });
		diag Dumper($rc_ea);
		my $alias = $emailAccount->alias();

		my $name = substr(md5_hex(time()), 0, 5);
		diag "email account alias name: $name";

		my $rc_alias = $alias->create({
		 	localpart => $name,
		 	email_account => $rc_ea
		});
		diag Dumper($rc_alias);
		if ($rc_alias->{error_code} == 201) # CREATED
		{
			diag 'created email account alias id: ' . $rc_alias->{object}->{id};
		}
		else
		{
			diag 'error create email account alias: ' . $rc_alias->{error_str};
			return 0;
		}

		my $alias_id = $rc_alias->{object}->{id};
		diag "get email account alias by id: $alias_id";
		$rc_alias = $alias->get({ id => $alias_id });
		diag Dumper($rc_alias);
		if ($alias_id != $rc_alias->{object}->{id})
		{
			diag 'error get email account alias by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'get email account alias by id ok';
		}

		diag "update email account alias by id: $alias_id";
		$rc_alias = $alias->update({
			localpart => 'zzz' . $name,
			id => $alias_id,
			email_account => $rc_ea,
		});
		diag Dumper($rc_alias);
		diag "get updated email account alias by id: $alias_id";
		$rc_alias = $alias->get({
			id => $alias_id
		});
		diag Dumper($rc_alias);
		if ($rc_alias->{object}->{localpart} ne 'zzz' . $name)
		{
			diag 'error update email account by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'update email account by id ok';
		}

		diag "delete email account alias by id: $alias_id";
		$rc_alias = $alias->delete({ id => $alias_id });
		return 0 if $rc_alias->{error_code} =! 204; # NO CONTENT
		$rc_alias = $alias->get({ id => $alias_id });
		diag Dumper($rc_alias);
		if (exists($rc_alias->{object}->{id}) && $rc_alias->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error email account domain by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'delete email account alias by id ok';
		}

		diag "list email account aliases";
		my $rc_alias = $alias->list({
			order_by => 'localpart',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc_alias);
		#if (!$rc_alias->{object}->{objects} || @{$rc_alias->{object}->{objects}} != 5)
		if ($rc_alias->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountAlias create/get/update/delete email account alias'
);

1;
