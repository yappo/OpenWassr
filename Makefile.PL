use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Xpost',
    AUTHOR        => 'Nishibayashi Takuji <takuji@senchan.jp>',
    VERSION_FROM  => 'lib/Xpost.pm',
    PREREQ_PM     => {
        'Amon2'                           => '3.31',
        'Text::Xslate'                    => '1.5006',
        'Test::More'                      => '0.98',
        'DBD::SQLite'                     => '1.33',
        'HTML::FillInForm::Lite'          => '1.09',
        'JSON'                            => '2.50',
        'Plack::Middleware::ReverseProxy' => '0.09',
        'Plack::Middleware::Session'      => '0',
        'Plack::Session'                  => '0.14',
        'Test::WWW::Mechanize::PSGI'      => '0',
        'Time::Piece::Plus'               => '0.02',
    },
    MIN_PERL_VERSION => '5.014002',
    (-d 'xt' and $ENV{AUTOMATED_TESTING} || $ENV{RELEASE_TESTING}) ? (
        test => {
            TESTS => 't/*.t xt/*.t',
        },
    ) : (),
);
