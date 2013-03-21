#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::CustomerContact');
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
my $contact = $customer->contact();
my $rc_customer = $customer->get({id => CUSTOMER_ID});

ok(
	sub {
	
		my $name = md5_hex(time());
		diag "contact name: $name";

		my $first_name = substr($name, 0, 16);
		my $last_name = substr($name, 16);
		my $rc_contact = $contact->create({
			email => $name . '@mail.ru',
			customer => $rc_customer,
		 	first_name => $first_name,
		 	last_name => $last_name
		});
		diag Dumper($rc_contact);
		my $rc_contact_id = 0;
		if ($rc_contact->{error_code} == 201) # CREATED
		{
			diag 'created contact id: ' . $rc_contact->{object}->{id};
		 	$rc_contact_id = $rc_contact->{object}->{id};
		}
		else
		{
			diag 'error create contact: ' . $rc_contact->{error_str};
			return 0;
		}

		diag "get contact by id: $rc_contact_id";
		$rc_contact = $contact->get({
			id => $rc_contact_id
		});
		diag Dumper($rc_contact);
		if ($rc_contact->{object}->{id} == $rc_contact_id)
		{
			diag 'get contact by id ok';
		}
		else
		{
			diag 'error get contact by id: ' . $rc_contact->{error_code};
			return 0;
		}

		diag "list customer contacts";
		$rc_contact = $contact->list({
		 	order_by => 'email',
		 	offset => 0,
		 	limit => 5,
		 	customer => $rc_customer
		});
		diag Dumper($rc_contact);
		#if (!$rc_contact->{object}->{objects} || @{$rc_contact->{object}->{objects}} != 5)
		if ($rc_contact->{error_code} != 200)
		{
			diag 'get contact list error: ' . $rc_contact->{error_code};
		 	return 0;
		}
		else
		{
			diag 'get contact list ok';
		}

		diag "update customer contact";
		$rc_contact = $contact->update({
		 	email => $name . '@mail.ru',
		 	customer => $rc_customer,
		 	id => $rc_contact_id,
		 	zipcode => '123456'
		});
		diag Dumper($rc_contact);
		if ($rc_contact->{object}->{zipcode} ne '123456')
		{
			diag 'update error: ' . $rc_contact->{error_code};
		 	return 0;
		}
		else
		{
			diag 'update ok';
		}

		diag "delete customer contact";
		$rc_contact = $contact->delete({
		 	id => $rc_contact_id,
		});
		$rc_contact = $contact->get({
			id => $rc_contact_id
		});
		diag Dumper($rc_contact);

		if ($rc_contact->{error_code} == 404) # NOT FOUND
		{
			diag 'delete ok';
		}
		else
		{
			diag 'delete error: ' . $rc_contact->{error_code};
		 	return 0;
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::CustomerContact create/get/update/delete customer contact'
);

1;
