use strict;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use Xpost::Web::App;
use Xpost;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;
use DBI;

{
    my $c = Xpost->new();
    $c->setup_schema();
}
my $db_config = Xpost->config->{DBI} || die "Missing configuration for DBI";
builder {
    enable 'Log::Minimal';
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/static/)},
        root => File::Spec->catdir(dirname(__FILE__));
    enable 'Plack::Middleware::Static',
        path => qr{^(?:/robots\.txt|/favicon\.ico)$},
        root => File::Spec->catdir(dirname(__FILE__), 'static');
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect( @$db_config )
                    or die $DBI::errstr;
            }
        ),
        state => Plack::Session::State::Cookie->new(
            httponly => 1,
        );
    Xpost::Web::App->to_app();
};
