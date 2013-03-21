#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::ResellerContact');
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
my $reseller_contact = $reseller->contact();
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
		$rc = $reseller->get({
			id => $reseller_id
		});
		diag Dumper($rc);
		if ($reseller_id != $rc->{object}->{id})
		{
			diag 'error get reseller by id: ' . $rc->{error_code};
			return 0;
		}

		diag 'create reseller contact';
		my $first_name = substr($name, 0, 16);
		my $last_name = substr($name, 16);
		my $rc_contact = $reseller_contact->create({
			email => $name . '@mail.ru',
			reseller => $rc,
			first_name => $first_name,
			last_name => $last_name
		});
		diag Dumper($rc_contact);
		my $rc_contact_id = 0;
		if ($rc_contact->{object} && $rc_contact->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'created reseller contact id: ' . $rc_contact->{object}->{id};
			$rc_contact_id = $rc_contact->{object}->{id};
		}
		else
		{
			diag 'error create reseller contact: ' . $rc_contact->{error_code};
			return 0;
		}

		diag "get reseller contact by id: $rc_contact_id";
		$rc_contact = $reseller_contact->get({
			id => $rc_contact_id
		});
		diag Dumper($rc_contact);
		if ($rc_contact->{object}->{id} == $rc_contact_id)
		{
			diag 'get reseller contact by id ok';
		}
		else
		{
			diag 'error get reseller contact by id: ' . $rc_contact->{error_code};
			return 0;
		}

		diag "list reseller contacts";
		$rc_contact = $reseller_contact->list({
		 	order_by => 'email',
		 	offset => 0,
		 	limit => 5,
		 	reseller => $rc
		});
		diag Dumper($rc_contact);
		#if (!$rc_contact->{object}->{objects} || @{$rc_contact->{object}->{objects}} != 1)
		if ($rc->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_contact->{error_code};
		 	return 0;
		}
		else
		{
			diag 'get list ok';
		}

		diag "update reseller contact";
		$rc = $reseller_contact->update({
		 	email => $name . '@mail.ru',
		 	reseller => $rc,
		 	id => $rc_contact_id,
		 	zipcode => '123456'
		});
		diag Dumper($rc);
		if ($rc->{object}->{zipcode} ne '123456')
		{
			diag 'update error: ' . $rc->{error_code};
		 	return 0;
		}
		else
		{
			diag 'update ok';
		}

		diag "delete reseller contact";
		$rc_contact = $reseller_contact->delete({
		 	id => $rc_contact_id,
		});
		$rc_contact = $reseller_contact->get({
			id => $rc_contact_id
		});
		diag Dumper($rc_contact);

		if ($rc_contact->{error_code} == 404) # NOT FOUND
		{
			diag 'delete ok';
		}
		else
		{
			diag 'delete error: ' . $rc->{error_code};
		 	return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::ResellerContact create/get/update/delete reseller contact'
);

1;
