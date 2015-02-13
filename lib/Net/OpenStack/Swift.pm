package Net::OpenStack::Swift;

=pod

V3
http://docs.openstack.org/developer/keystone/api_curl_examples.html

=cut

use strict;
use warnings;
use Moo;
use JSON;
#use namespace::clean;
#use Carp;
use Data::Dumper;
use Net::OpenStack::Swift::KeystoneClient;

our $VERSION = "0.01";

has auth_url     => (is => 'rw', required => 1); 
has user         => (is => 'rw', required => 1); 
has password     => (is => 'rw', required => 1); 
has tenant_name  => (is => 'rw');
has verify_ssl   => (is => 'ro', default => sub {! $ENV{OSCOMPUTE_INSECURE}});
has agent => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        my $self = shift;
        my $agent = Furl->new(
            #agent    => "Mozilla/5.0",
        );  
        return $agent;
    },  
);


# V2
sub get_auth_keystoneclient {
    my $self = shift;
    my $ksclient = Net::OpenStack::Swift::KeystoneClient::V2->new(
        auth_url => $self->auth_url,
        user     => $self->user,
        password => $self->password,
        tenant_name => $self->tenant_name,
    );
    #print Dumper($ksclient);
    return $ksclient;
}

sub get_account {
    my $self = shift;
    my $ksclient = $self->get_auth_keystoneclient();
    my ($storage_url, $token) = $ksclient->get_tokens();
    print Dumper($storage_url);
    print Dumper($token);
    my $access_url = sprintf "%s?%s", ($storage_url, "format=json");
    #[format=>'json', marker=>'', limit=>'', prefix=>'', end_marker=>''],      # form data (HashRef/FileHandle are also okay)
    #['Content-Type'=>'application/json',
    my $res = $self->agent->get(
        $access_url,
        ['X-Auth-Token'=>$token], # headers
    );
    die $res->status_line unless $res->is_success;
    my $body_params = from_json($res->content);
    my %headers = $res->headers->flatten();
    return (\%headers, $body_params);

 
    


}

sub get_servers {
    my $self = shift;

    my $ksclient = $self->get_auth_keystoneclient();

    my ($storage_url, $token) = $ksclient->get_tokens();
    print Dumper($storage_url);
    print Dumper($token);

    #print Dumper(to_json($data));

    #my $res = $self->agent->post(
    #    $self->auth_url."/tokens",
    #    ['Content-Type'=>'application/json'], # headers
    #    to_json($data),      # form data (HashRef/FileHandle are also okay)
    #);
    #print Dumper($res);
    #die $res->status_line unless $res->is_success;
    #print $res->content;
}


1;
__END__

=encoding utf-8

=head1 NAME

Net::OpenStack::Swift - It's new $module

=head1 SYNOPSIS

    use Net::OpenStack::Swift;

=head1 DESCRIPTION

Net::OpenStack::Swift is ...

=head1 LICENSE

Copyright (C) masakyst.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

masakyst E<lt>masakyst.mobile@gmail.comE<gt>

=cut

