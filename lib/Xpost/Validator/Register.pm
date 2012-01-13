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
}
1;
