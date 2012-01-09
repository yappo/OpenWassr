use 5.014001;
use warnings;
package Xpost::Email {
    use Amon2;
    use Carp;
    use Config::Pit;
    use Data::Recursive::Encode;
    use Email::Sender::Simple qw(sendmail);
    use Email::Sender::Transport::SMTP::TLS;
    use Email::Simple;
    use Email::Simple::Creator;
    use Encode;
    use File::Spec;
    use Text::Xslate;

    sub send {
        state $validator = Data::Validator->new(
            to => {isa => 'Str'},
            template => {isa => 'Str'},
            param    => {isa => 'HashRef'},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $sender = Email::Sender::Transport::SMTP::TLS->new(
            host     => 'smtp.gmail.com',
            port     => 587,
            %{pit_get('mail', require => {username => 'username', password => 'password'})},
            helo     => 'example.com',
        );

        my $xslate = Text::Xslate->new(
            path => File::Spec->catdir(Amon2->context()->base_dir, 'tmpl/email'),
            syntax   => 'Kolon',
            suffix   => '.eml',
            type     => 'text',
            module   => ['Text::Xslate::Bridge::Star'],
            function => {
                c => sub { Amon2->context() },
                uri_with => sub { Amon2->context()->req->uri_with(@_) },
                uri_for  => sub { Amon2->context()->uri_for(@_) },
            },
        );
        my $template = $xslate->render($args->{template}. '.eml', { email =>  $args->{to}, %{$args->{param}}});
        unless($template =~ /\A([^\n]+)\n\n(.*)\Z/ms) {
            Carp::croak('invalid template! :'.$args->{template});
        }
        my $header   = [
            To      => $args->{to},
            From    => 'no-reply@senchan.jp',
            Subject => $1,
        ];
        my $body = $2;

        my $email = Email::Simple->create(
            header     => Data::Recursive::Encode->encode('MIME-Header-ISO_2022_JP' => $header),
            body       => encode('iso-2022-jp', $body),
            attributes => {
                content_type => 'text/plain',
                charset      => 'ISO-2022-JP',
                encoding     => '7bit',
            },
        );

        my $ret = sendmail($email, {transport => $sender}); 
    }
}
1;
