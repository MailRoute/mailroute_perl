#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::EmailAccountBWList');
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
		my $bw = $ea->bwList();
		my $schema = $bw->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountBWList::schema()'
);

ok(
	sub {
		my $ea = $mailrouteAPI->emailAccount();
		my $rc_ea = $ea->get({ id => EA_ID });
		diag Dumper($rc_ea);
		my $bw = $ea->bwList();

		my $name = md5_hex(time()) . '@mail.ru';
		diag "bw list email: $name";

		my $rc_bw = $bw->create({
			email => $name,
			email_account => $rc_ea,
		 	wb => 'w'
		});
		diag Dumper($rc_bw);
		if ($rc_bw->{error_code} == 201) # CREATED
		{
			diag 'created email account wb list id: ' . $rc_bw->{object}->{id};
		}
		else
		{
			diag 'error create email account wb list: ' . $rc_bw->{error_str};
			return 0;
		}

		my $bw_id = $rc_bw->{object}->{id};
		diag "getting email account bw list by id: $bw_id";
		$rc_bw = $bw->get({
			id => $bw_id
		});
		diag Dumper($rc_bw);
		if ($bw_id != $rc_bw->{object}->{id})
		{
			diag 'error get email account bw list by id: ' . $rc_bw->{error_code};
			return 0;
		}
		else
		{
			diag 'get email account bw list by id ok';
		}

		diag "delete email account bw list by id: $bw_id";
		$rc_bw = $bw->delete({ id => $bw_id });
		$rc_bw = $bw->get({ id => $bw_id });
		diag Dumper($rc_bw);
		if (exists($rc_bw->{object}->{id}) && $rc_bw->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete email account bw list by id: ' . $rc_bw->{error_code};
			return 0;
		}
		else
		{
			diag 'delete domain bw list by id ok';
		}

		diag "list bw lists";
		my $rc_bw = $bw->list({
			order_by => 'email',
			offset => 0,
			limit => 5
		});
		diag Dumper($rc_bw);
		if (!$rc_bw->{object}->{objects} || @{$rc_bw->{object}->{objects}} != 5)
		{
			diag 'get list error: ' . $rc_bw->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::EmailAccountBWList create/get/update/delete email account black and white list'
);

1;
