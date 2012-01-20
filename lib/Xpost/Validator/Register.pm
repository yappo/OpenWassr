use 5.014001;
use warnings;
package Xpost::Validator::Register {
    use parent qw/Xpost::Validator/;

    use Xpost::Model::User;

    sub email {
        my $self = shift;
        $self->check(
            email => ['NOT_NULL', 'EMAIL_LOOSE'],
        );
        return if $self->has_error;

        if(Xpost::Model::User->count('id' => {email => $self->query->param('email')})) {
            $self->set_error(email => 'UNIQUE');
        }
    }

    sub create {
        my $self = shift;
        $self->check(
            u          => ['NOT_NULL', 'ASCII'],
            username   => [[FILTER => 'trim'], 'NOT_NULL', 'ASCII', [qw/LENGTH 3 16/]],
            password   => ['NOT_NULL', 'ASCII', [qw/LENGTH 6 255/]],
            password2  => ['NOT_NULL', 'ASCII', [qw/LENGTH 6 255/]],
            {password2 => [qw/password password2/]} => ['DUPLICATION'],
        );
    }
}
1;
