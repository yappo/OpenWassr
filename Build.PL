use strict;
use warnings;
use Module::Build;

my $buiild = Module::Build->new(
    dist_author => 'Nishibayashi Takuji <takuji@senchan.jp>',
    dist_abstract => 'Xpost - simple twitter clone',
    license     => 'perl',
    module_name => 'Xpost',
    configure_requires => {'Module::Build' => '0.38'},
    requires => {
        'Amon2'        => '3.31',
        'Text::Xslate' => '1.5006',
        'HTML::FillInForm::Lite' => '1.09',
        'JSON'                            => '2.50',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'Plack::Session'                  => '0.14',
        'Time::Piece::Plus'               => '0.02',
        'Teng'                            => '0.14_03',

    },
    build_requires => {
        'Test::WWW::Mechanize::PSGI' => 0,
        'Test::More'                 => '0.98',
    },
    test_files => (-d '.git' || $ENV{RELEASE_TESTING}) ? 't/ xt/' : 't/',
    recursive_test_files => 1,

    create_readme => 1,
    create_license => 1,
    create_makefile_pl => 'small',
);
$buiild->create_build_script();
