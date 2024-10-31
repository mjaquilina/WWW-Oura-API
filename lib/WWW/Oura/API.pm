#!/usr/bin/perl

package WWW::Oura::API;

use strict;
use warnings;

use Carp;
use HTTP::Request::Common qw(GET);
use JSON;
use LWP::UserAgent;
use Time::HiRes;

our $VERSION = '0.01';

sub new
{
    my ($class, %params) = @_;

    my $agent = LWP::UserAgent->new;

    my $self = {};

    $self->{lwp}      = $agent;
    $self->{token}    = $params{token};

    die "Credentials not provided"
        unless $self->{token};

    bless $self, $class;
    return $self;
}

sub api_call
{
    my ($self, $path, $params) = @_;

    my $url_base     = "https://api.ouraring.com/v2/";
    my $url_params   = map { "$_=$params->{$_}" } keys %$params;
    my $url          = "$url_base$path?$url_params";
    my $json_params  = encode_json( $params || {} );
    my $http_request = GET(
        $url,
        Authorization => "Bearer $self->{token}",
    );

    my $response = $self->{lwp}->request($http_request);

    croak "No response content" unless $response->decoded_content;

    my $decoded_content = $response->decoded_content;
    return JSON->new->decode($decoded_content);
}

1;

