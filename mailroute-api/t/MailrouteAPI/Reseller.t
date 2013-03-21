#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Reseller');
}

require_ok('MailrouteAPI');

can_ok('MailrouteAPI', ('new'));

my $mailRouteAPI = MailrouteAPI->new(1);

isa_ok($mailRouteAPI, 'MailrouteAPI');
can_ok($mailRouteAPI, ('configure'));

my $cfg = {
	login => 'test_perl',
	apikey => '66956c7f27fc89ff8169f9b6dca8150a7ffb5ea7',
	endpoint => 'https://ci.mailroute.net'
};

ok(
	sub {
		$mailRouteAPI->configure($cfg);
		my $reseller = $mailRouteAPI->reseller();
		my $schema = $reseller->schema();
		diag Dumper($schema);
		return 0 if (!$schema || (exists($schema->{error_code}) && $schema->{error_code} > 299));
		return 1;
	}->() == 1,
	'MailrouteAPI::Reseller::schema()'
);

ok(
	sub {
		my $reseller = $mailRouteAPI->reseller();
	
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
		else
		{
			diag 'get reseller by id ok';
		}

		diag "update reseller by id: $reseller_id";
		my $new_name = "+$name+";
		diag "$name -> $new_name";
		$rc = $reseller->update({
			id => $reseller_id,
			name => $new_name
		});
		diag Dumper($rc);
		diag "get updated reseller by id: $reseller_id";
		$rc = $reseller->get({ id => $reseller_id });
		diag Dumper($rc);
		if ($new_name ne $rc->{object}->{name})
		{
			diag 'error update reseller by id: ' . $rc->{error_code};
			return 0;
		}
		else
		{
			diag 'update reseller by id name ok';
		}

		diag "delete reseller by id: $reseller_id";
		$rc = $reseller->delete({ id => $reseller_id });
		$rc = $reseller->get({ id => $reseller_id });
		diag Dumper($rc);
		if (exists($rc->{object}->{id}) && $rc->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete reseller by id: ' . $rc->{error_code};
			return 0;
		}
		else
		{
			diag 'reseller deleted by id ok';
		}

		diag "list resellers";
		my $rc = $reseller->list({
			order_by => 'name',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc);
		#if (!$rc->{object}->{objects} || @{$rc->{object}->{objects}} != 5)
		if ($rc->{error_code} != 200)
		{
			diag 'get list error: ' . $rc->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::Reseller create/get/update/delete reseller'
);

1;
