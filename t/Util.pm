package t::Util;
BEGIN {
    unless ($ENV{PLACK_ENV}) {
        $ENV{PLACK_ENV} = 'test';
    }
    if ($ENV{PLACK_ENV} eq 'deployment') {
        die "Do not run a test script on deployment environment";
    }
}
use File::Spec;
use File::Basename;
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'extlib', 'lib', 'perl5'));
use lib File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..', 'lib'));
use parent qw/Exporter/;
use Test::More 0.98;

our @EXPORT = qw(slurp);

{
    # utf8 hack.
    binmode Test::More->builder->$_, ":utf8" for qw/output failure_output todo_output/;
    no warnings 'redefine';
    my $code = \&Test::Builder::child;
    *Test::Builder::child = sub {
        my $builder = $code->(@_);
        binmode $builder->output,         ":utf8";
        binmode $builder->failure_output, ":utf8";
        binmode $builder->todo_output,    ":utf8";
        return $builder;
    };
}


sub slurp {
    my $fname = shift;
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    do { local $/; <$fh> };
}

# initialize database
use Xpost;
{
    my $c = Xpost->new();
    $c->setup_schema();
}

sub setup_db {
    my $c = Xpost->new();
    my $config = $c->config;
    my $datasource = $config->{DBI};
    my $dsn = $datasource->[0];
    $dsn =~ s/mysql:([^;]+)/mysql:/;
    my $dbname = $1;
    my $dbh = DBI->connect(@{$datasource}, $config->{dbi_option});
    $dbh->do(sprintf(q{ drop database if exists %s}, $dbname))
        or die $dbh->errstr;
    $dbh->do(sprintf(q{ create database %s}, $dbname))
        or die $dbh->errstr;

    $dbh->disconnect;

    Xpost->context->setup_schema();
}

1;
