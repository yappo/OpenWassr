package Xpost::Web::App;
use strict;
use warnings;
use utf8;
use parent qw/Xpost Amon2::Web/;
use File::Spec;

use Class::Accessor::Lite (
    new => 0,
    rw  => [qw/stash/],
);

# dispatcher
use Xpost::Web::App::Dispatcher;
sub dispatch {
    return Xpost::Web::App::Dispatcher->dispatch($_[0]) or die "response is not generated";
}

# setup view class
use Text::Xslate;
{
    my $view_conf = __PACKAGE__->config->{'Text::Xslate'} || +{};
    unless (exists $view_conf->{path}) {
        $view_conf->{path} = [ File::Spec->catdir(__PACKAGE__->base_dir(), 'tmpl/app') ];
    }
    my $view = Text::Xslate->new(+{
        'syntax'   => 'Kolon',
        'module'   => [ 'Text::Xslate::Bridge::Star' ],
        'function' => {
            c => sub { Amon2->context() },
            uri_with => sub { Amon2->context()->req->uri_with(@_) },
            uri_for  => sub { Amon2->context()->uri_for(@_) },
            static_file => do {
                my %static_file_cache;
                sub {
                    my $fname = shift;
                    my $c = Amon2->context;
                    if (not exists $static_file_cache{$fname}) {
                        my $fullpath = File::Spec->catfile($c->base_dir(), $fname);
                        $static_file_cache{$fname} = (stat $fullpath)[9];
                    }
                    return $c->uri_for($fname, { 't' => $static_file_cache{$fname} || 0 });
                }
            },
        },
        %$view_conf
    });
    sub create_view { $view }
}


# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::CSRFDefender',
);

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

use Amon2::Config::Simple;
__PACKAGE__->add_trigger(
    BEFORE_DISPATCH => sub {
        my ( $c ) = @_;
        $c->stash({navi => Amon2::Config::Simple->load($c, {environment => 'navi'})->{nav}});
        return;
    },
);

sub render {
    my ($c, $path, $data) = @_;
    $data ||= {};
    $data = {%{$c->stash()}, %$data};
    return $c->SUPER::render($path, $data);
}

1;
