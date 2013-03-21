#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::CustomerAdmin');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));

my $mailrouteAPI = MailrouteAPI->new(1);

isa_ok($mailrouteAPI, 'MailrouteAPI');
can_ok($mailrouteAPI, ('configure'));

my $cfg = {
	login => 'test_perl',
	apikey => '66956c7f27fc89ff8169f9b6dca8150a7ffb5ea7',
 	endpoint => 'https://ci.mailroute.net'
};

use constant CUSTOMER_ID => 1;

$mailrouteAPI->configure($cfg);
my $customer = $mailrouteAPI->customer();
my $admin = $customer->admin();
my $rc_customer = $customer->get({id => CUSTOMER_ID});

ok(
	sub {
	
		my $name = md5_hex(time());
		diag "admin name: $name";

		my $rc_admin = $admin->create({
			email => $name . '@mail.ru',
			customer => $rc_customer,
		});
		diag Dumper($rc_admin);
		my $rc_admin_id = 0;
		if ($rc_admin->{error_code} == 201) # CREATED
		{
			diag 'created admin id: ' . $rc_admin->{object}->{id};
		 	$rc_admin_id = $rc_admin->{object}->{id};
		}
		else
		{
			diag 'error create admin: ' . $rc_admin->{error_str};
			return 0;
		}

		diag "get admin by id: $rc_admin_id";
		$rc_admin = $admin->get({
			id => $rc_admin_id,
			customer => $rc_customer
		});
		diag Dumper($rc_admin);
		if ($rc_admin->{object}->{id} == $rc_admin_id)
		{
			diag 'get admin by id ok';
		}
		else
		{
			diag 'error get admin by id: ' . $rc_admin->{error_code};
			return 0;
		}

		diag 'list customer admins';
		$rc_admin = $admin->list({
		 	order_by => 'username',
		 	offset => 0,
		 	limit => 5,
		 	customer => $rc_customer
		});
		diag Dumper($rc_admin);
		#if (!$rc_admin->{object}->{objects} || @{$rc_admin->{object}->{objects}} != 5)
		if ($rc_admin->{error_code} != 200)
		{
			diag 'get admin list error: ' . $rc_admin->{error_code};
		 	return 0;
		}
		else
		{
			diag 'get admin list ok';
		}

		diag "delete customer admin";
		$rc_admin = $admin->delete({
		 	id => $rc_admin_id,
		 	customer => $rc_customer
		});
		diag Dumper($rc_admin);
		$rc_admin = $admin->get({
			id => $rc_admin_id,
			customer => $rc_customer
		});
		diag Dumper($rc_admin);

		if ($rc_admin->{error_code} == 404) # NOT FOUND
		{
			diag 'delete admin ok';
		}
		else
		{
			diag 'delete admin error: ' . $rc_admin->{error_code};
		 	return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::CustomerAdmin create/get/update/delete customer admin'
);

1;
