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
        'Teng'                            => '0.14_05',
        'Config::Pit'                     => '0.04',
        #FIXME 最新バージョンの指定誰か書いて
        'DateTime'                        => '0',
        'DBIx::QueryLog'                  => '0',
        'DBIx::Inspector'                  => '0',
        'Path::Class'                  => '0',
        'Data::Validator'                 => '0',
        'Data::GUID'                      => '0',
        'Digetst::MurmurHash'                      => '0',
        'Scope::Container::DBI'                      => '0',
        'Scope::Container'                      => '0',
        'Class::Method::Modifiers'                      => '0',
        'Class::Method::Modifiers'                      => '0',
        'Data::Recursive::Encode'                      => '0',
        'Email::Sender'                      => '0',
        'Email::Simple'                      => '0',
        'Email::Sender::Transport::SMTP::TLS'                      => '0',
        'Text::Xslate'                      => '0',
        'Log::Minimal'                      => '0',
        'String::CamelCase'                      => '0',
        'String::Random'                      => '0',
        'FormValidator::Lite'                      => '0',
        'DateTimeX::Factory'                      => '0',
        'Data::Section::Simple'                      => '0',
        'JSON::XS'                      => '0',
        'Exporter::Lite'                      => '0',
        'Mouse'                      => '0',
        'Class::Accessor::Lite'                      => '0',

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
