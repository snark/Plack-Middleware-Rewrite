package Plack::Middleware::Rewrite;
use strict;
use warnings;
use version; our $VERSION = 0.0001;

use Plack::Request;
use Plack::Response;
use parent qw/Exporter Plack::Middleware/;
our @EXPORT = qw( rewrite r301 r302 );
__PACKAGE__->mk_accessors(qw( rewrite_rules ));
 
sub rewrite ($$) { 
    my ( $condition, $substitute ) = @_;
    $substitute = '' unless defined $substitute;
    my $sub = sub { 
        my $env = shift; 
        my $url = my $orig_url = $env->{PATH_INFO};
        if ( ref $condition eq q{Regexp} 
            && ref $substitute eq 'CODE' ) {
            $url =~ s/$condition/$substitute->()/e;
        } else { # Straightforward string
            $url =~ s/$condition/$substitute/;
        }
        if ( $url ne $orig_url ) {
            $env->{PATH_INFO} = $url;
            $env->{'psgix.rewrite_modified'} = 1;
        }
        return $env;
    }; 
    return $sub;
}

sub r301 ($$) {
    return _redirect(@_, '301');
}

sub r302 ($$) {
    return _redirect(@_, '302');
}

sub _redirect { 
    my ( $condition, $substitute, $status ) = @_;
    $substitute = '' unless defined $substitute;
    my $rewrite = rewrite( $condition, $substitute );    
    my $sub = sub {
        my $env = shift;
        my $orig_url = $env->{PATH_INFO};
        $rewrite->($env);
        if ( $env->{PATH_INFO} ne $orig_url ) {
            $env->{'psgix.rewrite_terminate'} = $status;
        } 
        return $env;
    };
    return $sub;
}

sub call {
    my ( $self, $env ) = @_;
    my $rules = $self->rewrite_rules;
    my $continue = 1;
    for my $rule ( @$rules ) {
        $env = $rule->( $env );
        last if ( $env->{'psgix.rewrite_terminate'} );
    };
    if ( $env->{'psgix.rewrite_terminate'} ) {
       my $res = Plack::Response->new;
       $res->redirect(
           $env->{PATH_INFO}, $env->{'psgix.rewrite_terminate'}
       );
       return $res->finalize;
    }
    return $self->app->($env);
}

1;
