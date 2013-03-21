#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::ResellerAdmin');
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

$mailrouteAPI->configure($cfg);
my $reseller = $mailrouteAPI->reseller();
my $reseller_admin = $reseller->admin();
ok(
	sub {
	
		my $name = md5_hex(time());
		diag "reseller name: $name";

		my $rc = $reseller->create({ name => $name });
		if ($rc->{error_code} == 201) # CREATED
		{
			diag 'created reseller id: ' . $rc->{object}->{id};
		}
		else
		{
			diag 'error create reseller: ' . $rc->{error_str};
			return 0;
		}

		my $reseller_id = $rc->{object}->{id};
		diag "getting reseller by id: $reseller_id";
		$rc = $reseller->get({ id => $reseller_id });
		diag Dumper($rc);
		if ($reseller_id != $rc->{object}->{id})
		{
			diag 'error get reseller by id: ' . $rc->{error_code};
			return 0;
		}

		diag 'create reseller admin';
		my $rc_admin = $reseller_admin->create({
			email => $name . '@mail.ru',
			reseller => $rc,
		});
		diag Dumper($rc_admin);
		my $rc_admin_id = 0;
		if ($rc_admin->{object} && $rc_admin->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'created reseller admin id: ' . $rc_admin->{object}->{id};
			$rc_admin_id = $rc_admin->{object}->{id};
		}
		else
		{
			diag 'error create reseller admin: ' . $rc_admin->{error_code};
			return 0;
		}

		diag "get reseller admin by id: $rc_admin_id";
		$rc_admin = $reseller_admin->get({
			id => $rc_admin_id,
			reseller=> $rc
		});
		diag Dumper($rc_admin);
		if ($rc_admin->{object}->{id} == $rc_admin_id)
		{
			diag 'get reseller admin by id ok';
		}
		else
		{
			diag 'error get reseller admin by id: ' . $rc_admin->{error_code};
			return 0;
		}

		diag "list reseller admins";
		$rc_admin = $reseller_admin->list({
		 	order_by => 'last_login',
		 	offset => 0,
		 	limit => 5,
		 	reseller => $rc
		});
		diag Dumper($rc_admin);
		#if (!$rc_admin->{object}->{objects} || @{$rc_admin->{object}->{objects}} != 1)
		if ($rc->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_admin->{error_code};
		 	return 0;
		}
		else
		{
			diag 'get list ok';
		}

		diag "delete reseller admin";
		$rc_admin = $reseller_admin->delete({
		 	id => $rc_admin_id,
		 	reseller => $rc
		});
		$rc_admin = $reseller_admin->get({
			id => $rc_admin_id,
			reseller => $rc
		});
		diag Dumper($rc_admin);

		if ($rc_admin->{error_code} == 404) # NOT FOUND
		{
			diag 'delete ok';
		}
		else
		{
			diag 'delete error: ' . $rc_admin->{error_code};
		 	return 0;
		}
		
		return 1;
	}->() == 1,
	'MailrouteAPI::ResellerAdmin create/get/update/delete reseller admin'
);

1;
