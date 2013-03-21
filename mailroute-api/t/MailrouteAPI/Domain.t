#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::Customer');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));

my $mailrouteAPI = MailrouteAPI->new(1);

isa_ok($mailrouteAPI, 'MailrouteAPI');
can_ok($mailrouteAPI, ('configure'));

use constant CUSTOMER_ID => 1;

my $cfg = {
	login => 'test_perl',
	apikey => '66956c7f27fc89ff8169f9b6dca8150a7ffb5ea7',
 	endpoint => 'https://ci.mailroute.net'
};

ok(
	sub {
		$mailrouteAPI->configure($cfg);
		my $domain = $mailrouteAPI->domain();
		my $schema = $domain->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::Domain::schema()'
);

ok(
	sub {
		my $customer = $mailrouteAPI->customer();
		my $rc_customer = $customer->get({ id => CUSTOMER_ID });

		my $domain = $mailrouteAPI->domain();

		my $name = substr(md5_hex(time()), 0, 5) . '.com';
		diag "domain name: $name";

		my $rc_domain = $domain->create({
			name => $name,
			customer => $rc_customer
		});
		diag Dumper($rc_domain);
		if ($rc_domain->{error_code} == 201) # CREATED
		{
			diag 'created domain id: ' . $rc_domain->{object}->{id};
		}
		else
		{
			diag 'error create domain: ' . $rc_domain->{error_str};
			return 0;
		}

		my $domain_id = $rc_domain->{object}->{id};
		diag "getting domain by id: $domain_id";
		$rc_domain = $domain->get({ id => $domain_id });
		diag Dumper($rc_domain);
		if ($domain_id != $rc_domain->{object}->{id})
		{
			diag 'error get domain by id: ' . $rc_domain->{error_code};
			return 0;
		}
		else
		{
			diag 'get domain by id ok';
		}

		diag "update domain by id: $domain_id";
		$rc_domain = $domain->update({
			name => '123' . $name,
			id => $domain_id,
			customer => $rc_customer,
			active => JSON::true
		});
		diag Dumper($rc_domain);
		diag "get updated domain by id: $domain_id";
		$rc_domain = $domain->get({
			id => $domain_id
		});
		diag Dumper($rc_domain);
		if ($rc_domain->{object}->{active} != JSON::true)
		{
			diag 'error update domain by id: ' . $rc_domain->{error_code};
			return 0;
		}
		else
		{
			diag 'update domain by id ok';
		}

		diag "delete domain by id: $domain_id";
		$rc_domain = $domain->delete({ id => $domain_id });
		$rc_domain = $domain->get({ id => $domain_id });
		diag Dumper($rc_domain);
		if (exists($rc_domain->{object}->{id}) && $rc_domain->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete domain by id: ' . $rc_domain->{error_code};
			return 0;
		}
		else
		{
			diag 'delete domain by id ok';
		}

		diag "list domains";
		my $rc_domain = $domain->list({
			order_by => 'name',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc_domain);
		#if (!$rc_domain->{object}->{objects} || @{$rc_domain->{object}->{objects}} != 5)
		if ($rc_domain->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_domain->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::Domain create/get/update/delete domain'
);

1;
