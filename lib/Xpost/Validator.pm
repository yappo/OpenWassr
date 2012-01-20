use 5.014001;
use warnings;
package Xpost::Validator {
    use Amon2;
    use Amon2::Config::Simple;
    use FormValidator::Lite qw/
        Date
        Email
    /;
    use parent qw/-norequire FormValidator::Lite/;


    sub new {
        my $class = shift;
        my $self = $class->SUPER::new(@_);
        $self->load_function_message('ja');
        $self->set_message_data(Amon2::Config::Simple->load(Amon2->context(), {environment => 'validator'}));
        return $self;
    }

   sub check {
        my $self = shift;

        my %args = @_;

        $self->SUPER::check(@_);
        return if $self->has_error;
        $self->{valid_params} = {};
        for my $key (keys %args) {
            next if ref $key;
            $self->{valid_params}->{$key} = 1;
        }
    }



    sub valid_data {
        my $self = shift;

        die "invalid request" if $self->has_error;

        return {
            map { $_ => $self->query->param($_) }
              grep { defined $self->query->param($_) }
                keys %{ $self->{valid_params} }
        };
    }
}
1;
