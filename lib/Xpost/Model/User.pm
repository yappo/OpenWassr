use 5.014001;
use warnings;
package Xpost::Model::User {

    use String::Random;
    use DBIx::QueryLog;

    use parent qw/Xpost::Model/;

    sub register_email {
        state $validator = Data::Validator->new(
            email => {isa => 'Str'}
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $random_uname = $class->create_initial_username;
        $class->fast_insert({%$args, username => $random_uname});
        return $random_uname;
    }

    sub create_initial_username {
        my $class = shift;
        state $rand = String::Random->new;
        my $random_uname = $rand->randregex('[a-zA-Z0-9]{32}');
        if ($class->db->count('user' => 'id', {username => $random_uname})) {
            $random_uname = $class->create_initial_username;
        }
        return $random_uname;
    }

    sub fetch_unauthorized_user {
        state $validator = Data::Validator->new(
            username => {isa => 'Str'}
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        $class->single({%$args, status => 'unauthorized'});
    }

    sub register {
        state $validator = Data::Validator->new(
            username => {isa => 'Str'},
            password => {isa => 'Str'},
        )->with(qw/Method AllowExtra/);
        my ($self, $args) = $validator->validate(@_);
        $self->update({%$args, status => 'registered'});
        return $self->refetch;
    }

}
1;
