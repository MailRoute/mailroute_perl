#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::DomainAlias');
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
		my $alias = $domain->alias();
		my $schema = $alias->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::DomainAlias::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		diag Dumper($rc_domain);
		my $alias = $domain->alias();

		my $name = substr(md5_hex(time()), 0, 5) . '.com';
		diag "domain alias name: $name";

		my $rc_alias = $alias->create({
		 	name => $name,
		 	domain => $rc_domain
		});
		diag Dumper($rc_alias);
		if ($rc_alias->{error_code} == 201) # CREATED
		{
			diag 'created domain alias id: ' . $rc_alias->{object}->{id};
		}
		else
		{
			diag 'error create domain alias: ' . $rc_alias->{error_str};
			return 0;
		}

		my $alias_id = $rc_alias->{object}->{id};
		diag "getting domain by id: $alias_id";
		$rc_alias = $alias->get({ id => $alias_id });
		diag Dumper($rc_alias);
		if ($alias_id != $rc_alias->{object}->{id})
		{
			diag 'error get domain alias by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'get domain alias by id ok';
		}

		diag "update domain alias by id: $alias_id";
		$rc_alias = $alias->update({
			name => 'zzz' . $name,
			id => $alias_id,
			domain => $rc_domain,
			active => JSON::true
		});
		diag Dumper($rc_alias);
		diag "get updated domain alias by id: $alias_id";
		$rc_alias = $alias->get({
			id => $alias_id
		});
		diag Dumper($rc_alias);
		if ($rc_alias->{object}->{active} != JSON::true)
		{
			diag 'error update domain by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'update domain by id ok';
		}

		diag "delete domain alias by id: $alias_id";
		$rc_alias = $alias->delete({ id => $alias_id });
		$rc_alias = $alias->get({ id => $alias_id });
		diag Dumper($rc_alias);
		if (exists($rc_alias->{object}->{id}) && $rc_alias->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete domain by id: ' . $rc_alias->{error_code};
			return 0;
		}
		else
		{
			diag 'delete domain alias by id ok';
		}

		diag "list aliases";
		my $rc_alias = $alias->list({
			order_by => 'name',
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
	'MailrouteAPI::DomainAlias create/get/update/delete domain alias'
);

1;
