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
        $c->fillin_form($c->req);
        return $c->render('index.tx');
    }
    $c->redirect('/register/email', {success => 1});
};

get '/register/email' => sub {
    my $c = shift;
    $c->render('register/email.tx');
};

sub _register {
    my $c = shift;
    $c->fillin_form($c->req, fill_password => 1);
    my $u = $c->req->param('u');
    my $user = Xpost::Model::User->fetch_unauthorized_user(username => $u);
    return $c->redirect('/') unless $user;
    $c->stash->{user} = $user;
    return;
}

get '/register/' => sub {
    my $c = shift;
    my $res = _register($c);
    return $res if $res;
    $c->render('register/index.tx');
};

post '/register/' => sub {
    my $c = shift;
    my $res = _register($c);
    return $res if $res;
    my $validator = Xpost::Validator::Register->new($c->req);
    $validator->create;
    unless($validator->has_error) {
        my $register = $c->req->param('register');
        if($register) {
            #TODO 登録してログインしてリダイレクト
            my $user = $c->stash->{user};
            $user->register(%{$validator->valid_data});
            return $c->redirect('/');
        } else {
            return $c->render('register/confirm.tx');
        }
    } else {
        $c->stash->{validator} = $validator;
        return $c->render('register/index.tx');
    }
    $c->render('register/index.tx');
};

post '/account/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    $c->redirect('/');
};

1;
