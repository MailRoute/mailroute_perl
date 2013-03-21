#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Customer');
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
my $customer = $mailrouteAPI->customer();

# default reseller id
use constant RESELLER_ID => 11;

ok(
	sub {
		my $name = md5_hex(time());
		diag "customer name: $name";

		diag 'get reseller by id: ' . RESELLER_ID;
		my $rc = $reseller->get({ id => RESELLER_ID });
		diag Dumper($rc);
		if (RESELLER_ID != $rc->{object}->{id})
		{
			diag 'error get reseller by id: ' . $rc->{error_code};
			return 0;
		}

		diag 'create customer';
		my $rc_customer = $customer->create({
			name => $name,
			reseller => $rc
		});
		diag Dumper($rc_customer);
		my $rc_customer_id = 0;
		if ($rc_customer->{object} && $rc_customer->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'created customer id: ' . $rc_customer->{object}->{id};
			$rc_customer_id = $rc_customer->{object}->{id};
		}
		else
		{
			diag 'error create customer: ' . $rc_customer->{error_code};
			return 0;
		}

		diag "get customer by id: $rc_customer_id";
		$rc_customer = $customer->get({
			id => $rc_customer_id
		});
		diag Dumper($rc_customer);
		if ($rc_customer->{object}->{id} == $rc_customer_id)
		{
			diag 'get customer by id ok';
		}
		else
		{
			diag 'error get customer by id: ' . $rc_customer->{error_code};
			return 0;
		}

		diag 'list customers';
		$rc_customer = $customer->list({
		 	order_by => 'name',
		 	offset => 0,
		 	limit => 5,
		 	reseller => $rc
		});
		diag Dumper($rc_customer);
		#if (!$rc_customer->{object}->{objects} || @{$rc_customer->{object}->{objects}} != 5)
		if ($rc->{error_code} != 200)
		{
			diag 'get customers list error: ' . $rc_customer->{error_code};
		 	return 0;
		}
		else
		{
			diag 'get customers list ok';
		}

		diag "update customer";
		my $new_name = md5_hex(time());
		$rc_customer = $customer->update({
		 	name => $new_name,
		 	reseller => $rc,
		 	id => $rc_customer_id
		});
		diag Dumper($rc_customer);
		if ($rc_customer->{object}->{name} ne $new_name)
		{
			diag 'update customer error: ' . $rc_customer->{error_code};
		 	return 0;
		}
		else
		{
			diag 'update customer ok';
		}

		diag "delete reseller contact";
		$rc_customer = $customer->delete({
		 	id => $rc_customer_id,
		});
		$rc_customer = $customer->get({
			id => $rc_customer_id
		});
		diag Dumper($rc_customer);

		if ($rc_customer->{error_code} == 404) # NOT FOUND
		{
			diag 'delete ok';
		}
		else
		{
			diag 'delete error: ' . $rc_customer->{error_code};
		 	return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::Customer create/get/update/delete customer'
);

1;
