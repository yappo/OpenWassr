use 5.014001;
use warnings;
package Xpost::Util::Template {
    use Data::Validator;
    use Mouse::Util::TypeConstraints;

    enum 'Xpost::HTML::InputType' => qw/
        text
        textarea
        select
        dropdown
        email
        number
        radio
        check
    /;

    no Mouse::Util::TypeConstraints;

    #フォームの自動生成に使う値をバリデーションする関数
    sub validate_input_args {
        state $validator = Data::Validator->new(
            name          => {isa => 'Str'},
            id            => {isa => 'Str', default => sub{$_[2]->{name}}},
            input_name    => {isa => 'Str', default => sub{$_[2]->{name}}},
            label         => {isa => 'Str', default => sub{$_[2]->{name}}},
            type          => {isa => 'Xpost::HTML::InputType', default => 'text'},
            help_inline   => {isa => 'Str', default => ''},
            help_block    => {isa => 'Str', default => ''},
            display_error => {isa => 'Bool', default => 1},
            class         => {isa => 'Str', default => ''},
        );
        my $args = $validator->validate(@_);
        return $args;
    }

    #input[type=hidden]自動生成に使う値をバリデーションする関数
    sub validate_hidden_args {
        state $validator = Data::Validator->new(
            name  => {isa => 'Str'},
            value => {isa => 'Str', default => ''},
        );
        my $args = $validator->validate(@_);
        return $args;
    }

    sub get_validator_error {
        state $validator = Data::Validator->new(
            name      => {isa => 'Str'},
            validator => {isa => 'FormValidator::Lite'},
        )->with(qw/Sequenced/);
        my $args = $validator->validate(@_);
        my $v    = $args->{validator};
        my $name = $args->{name};
        my @msg = $v->get_error_messages_from_param($name);
        return $msg[0] // '';
    }

    sub export_functions {
        return {
            validate_input_args => \&validate_input_args,
            validate_hidden_args => \&validate_hidden_args,
            get_validator_error => \&get_validator_error,
        }
    }

}
1;
