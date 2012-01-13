package Xpost::Web::App::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

use Xpost::Validator::Register;
use Xpost::Model::User;
use Xpost::Email;

any '/' => sub {
    my ($c) = @_;
    $c->render('index.tx');
};

post '/register/email' => sub {
    my $c = shift;
    my $validator = Xpost::Validator::Register->new($c->req);
    $validator->email;
    unless($validator->has_error) {
        my $uname = Xpost::Model::User->register_email(%{$validator->valid_data});
        Xpost::Email->send(
            template => 'register_email',
            to       => $c->req->param('email'),
            param    => {uname => $uname},
        );
    } else {
        $c->stash->{validator} = $validator;
        return $c->render('index.tx');
    }
    $c->redirect('/register/email', {success => 1});
};

get '/register/email' => sub {
    my $c = shift;
    $c->render('register/email.tx');
};

get '/register/' => sub {
    my $c = shift;
    
    $c->render('register/index.tx');
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    $c->redirect('/');
};

1;
