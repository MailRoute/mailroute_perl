#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::DomainMailServer');
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
		my $ms = $domain->mailServer();
		my $schema = $ms->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::DomainMailServer::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		diag Dumper($rc_domain);
		my $ms = $domain->mailServer();

		my ($i1, $i2, $i3, $i4) = (int rand() * 255, int rand() * 255, int rand() * 255, int rand() * 255);
		my $ip = "$i1.$i2.$i3.$i4";
		diag "domain mail selver ip: $ip";

		my $rc_ms = $ms->create({
		 	server => $ip,
		 	domain => $rc_domain,
		 	priority => 10
		});
		diag Dumper($rc_ms);
		if ($rc_ms->{error_code} == 201) # CREATED
		{
			diag 'created domain mail server id: ' . $rc_ms->{object}->{id};
		}
		else
		{
			diag 'error create mail server alias: ' . $rc_ms->{error_str};
			return 0;
		}

		my $ms_id = $rc_ms->{object}->{id};
		diag "getting domain mail server by id: $ms_id";
		$rc_ms = $ms->get({ id => $ms_id });
		diag Dumper($rc_ms);
		if ($ms_id != $rc_ms->{object}->{id})
		{
			diag 'error get domain alias by id: ' . $rc_ms->{error_code};
			return 0;
		}
		else
		{
			diag 'get domain alias by id ok';
		}

		diag "update domain mail server by id: $ms_id";
		($i1, $i2, $i3, $i4) = (int rand() * 255, int rand() * 255, int rand() * 255, int rand() * 255);
		$ip = "$i1.$i2.$i3.$i4";
		$rc_ms = $ms->update({
			server => $ip,
			id => $ms_id,
			domain => $rc_domain,
			priority => 5
		});
		diag Dumper($rc_ms);
		diag "get updated domain mail server by id: $ms_id";
		$rc_ms = $ms->get({
			id => $ms_id
		});
		diag Dumper($rc_ms);
		if ($rc_ms->{object}->{priority} != 5)
		{
			diag 'error update domain mail server by id: ' . $rc_ms->{error_code};
			return 0;
		}
		else
		{
			diag 'update domain mail server by id ok';
		}

		diag "delete domain mail server by id: $ms_id";
		$rc_ms = $ms->delete({ id => $ms_id });
		$rc_ms = $ms->get({ id => $ms_id });
		diag Dumper($rc_ms);
		if (exists($rc_ms->{object}->{id}) && $rc_ms->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete domain mail server by id: ' . $rc_ms->{error_code};
			return 0;
		}
		else
		{
			diag 'delete domain mail server by id ok';
		}

		diag "list mail servers";
		my $rc_ms = $ms->list({
			order_by => 'server',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc_ms);
		#if (!$rc_ms->{object}->{objects} || @{$rc_ms->{object}->{objects}} != 5)
		if ($rc_ms->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_ms->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::DomainMailServer create/get/update/delete domain mail server'
);

1;
