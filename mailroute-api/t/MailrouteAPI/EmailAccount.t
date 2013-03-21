#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::EmailAccount');
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
		my $ea = $mailrouteAPI->emailAccount();
		my $schema = $ea->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccount::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		diag Dumper($rc_domain);
		my $ea = $mailrouteAPI->emailAccount();

		my $name = substr(md5_hex(time()), 0, 5);
		diag "email account name: $name";

		my $rc_ea = $ea->create({
		 	localpart => $name,
		 	domain => $rc_domain,
		 	create_opt => 'generate_pwd'
		});
		diag Dumper($rc_ea);
		if ($rc_ea->{error_code} == 201) # CREATED
		{
			diag 'created email account id: ' . $rc_ea->{object}->{id};
		}
		else
		{
			diag 'error create email account: ' . $rc_ea->{error_str};
			return 0;
		}

		my $ea_id = $rc_ea->{object}->{id};
		diag "getting email account by id: $ea_id";
		$rc_ea = $ea->get({ id => $ea_id });
		diag Dumper($rc_ea);
		if ($ea_id != $rc_ea->{object}->{id})
		{
			diag 'error get email account by id: ' . $rc_ea->{error_code};
			return 0;
		}
		else
		{
			diag 'get email account by id ok';
		}

		diag "update email account by id: $ea_id";
		$rc_ea = $ea->update({
			id => $ea_id,
		 	localpart => 'zzz' . $name,
		 	domain => $rc_domain,
		 	create_opt => 'generate_pwd'
		});
		diag Dumper($rc_ea);
		diag "get updated email account by id: $ea_id";
		$rc_ea = $ea->get({
			id => $ea_id
		});
		diag Dumper($rc_ea);
		if ($rc_ea->{object}->{localpart} ne 'zzz' . $name)
		{
			diag 'error email account by id: ' . $rc_ea->{error_code};
			return 0;
		}
		else
		{
			diag 'update email account by id ok';
		}

		diag "delete email account by id: $ea_id";
		$rc_ea = $ea->delete({ id => $ea_id });
		$rc_ea = $ea->get({ id => $ea_id });
		diag Dumper($rc_ea);
		if (exists($rc_ea->{object}->{id}) && $rc_ea->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error email account by id: ' . $rc_ea->{error_code};
			return 0;
		}
		else
		{
			diag 'delete email account by id ok';
		}

		diag "list email accounts";
		$rc_ea = $ea->list({
			order_by => 'priority',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc_ea);
		#if (!$rc_ea->{object}->{objects} || @{$rc_ea->{object}->{objects}} != 5)
		if ($rc_ea->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_ea->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccount create/get/update/delete email account'
);

1;
