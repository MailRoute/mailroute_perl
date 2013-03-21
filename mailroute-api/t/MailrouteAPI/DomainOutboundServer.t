#!/usr/bin/perl -w

use strict;
use Test::More qw(no_plan);
use Data::Dumper;
use Digest::MD5 qw(md5_hex);
use JSON;

BEGIN {
 	use_ok('MailrouteAPI');
 	use_ok('MailrouteAPI::Domain');
 	use_ok('MailrouteAPI::DomainOutboundServer');
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
		my $obs = $domain->outboundServer();
		my $schema = $obs->schema();
		diag Dumper($schema);
		return 0 if !$schema;
		return 1;
	}->() == 1,
	'MailrouteAPI::DomainOutboundServer::schema()'
);

ok(
	sub {
		my $domain = $mailrouteAPI->domain();
		my $rc_domain = $domain->get({ id => DOMAIN_ID });
		diag Dumper($rc_domain);
		my $obs = $domain->outboundServer();

		my ($i1, $i2, $i3, $i4) = (int rand() * 255, int rand() * 255, int rand() * 255, int rand() * 255);
		my $ip = "$i1.$i2.$i3.$i4";
		diag "domain outbound selver ip: $ip";

		my $rc_obs = $obs->create({
		 	server => $ip,
		 	domain => $rc_domain
		});
		diag Dumper($rc_obs);
		if ($rc_obs->{error_code} == 201) # CREATED
		{
			diag 'created domain outbound server id: ' . $rc_obs->{object}->{id};
		}
		else
		{
			diag 'error create outbound server alias: ' . $rc_obs->{error_str};
			return 0;
		}

		my $obs_id = $rc_obs->{object}->{id};
		diag "getting domain outbound server by id: $obs_id";
		$rc_obs = $obs->get({ id => $obs_id });
		diag Dumper($rc_obs);
		if ($obs_id != $rc_obs->{object}->{id})
		{
			diag 'error get domain outbound by id: ' . $rc_obs->{error_code};
			return 0;
		}
		else
		{
			diag 'get domain outbound by id ok';
		}

		diag "update domain outbound server by id: $obs_id";
		($i1, $i2, $i3, $i4) = (int rand() * 255, int rand() * 255, int rand() * 255, int rand() * 255);
		$ip = "$i1.$i2.$i3.$i4";
		$rc_obs = $obs->update({
			server => $ip,
			id => $obs_id,
			domain => $rc_domain
		});
		diag Dumper($rc_obs);
		diag "get updated domain outbound server by id: $obs_id";
		$rc_obs = $obs->get({
			id => $obs_id
		});
		diag Dumper($rc_obs);
		if ($rc_obs->{object}->{server} ne $ip)
		{
			diag 'error update domain outbound server by id: ' . $rc_obs->{error_code};
			return 0;
		}
		else
		{
			diag 'update domain outbound server by id ok';
		}

		diag "delete domain outbound server by id: $obs_id";
		$rc_obs = $obs->delete({ id => $obs_id });
		$rc_obs = $obs->get({ id => $obs_id });
		diag Dumper($rc_obs);
		if (exists($rc_obs->{object}->{id}) && $rc_obs->{object}->{id} =~ /[0-9]+/g)
		{
			diag 'error delete domain outbound server by id: ' . $rc_obs->{error_code};
			return 0;
		}
		else
		{
			diag 'delete domain outbound server by id ok';
		}

		diag "list outbound servers";
		my $rc_obs = $obs->list({
			order_by => 'server',
			offset => 20,
			limit => 5
		});
		diag Dumper($rc_obs);
		#if (!$rc_obs->{object}->{objects} || @{$rc_obs->{object}->{objects}} != 5)
		if ($rc_obs->{error_code} != 200)
		{
			diag 'get list error: ' . $rc_obs->{error_code};
			return 0;
		}
		else
		{
			diag 'get list ok';
		}

		return 1;
	}->() == 1,
	'MailrouteAPI::DomainOutboundServer create/get/update/delete domain outbound server'
);

1;
