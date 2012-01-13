use 5.014001;
use warnings;
package Xpost::Model::User {

    use String::Random;

    use parent qw/Xpost::Model/;

    our $UNATH_PREFIX = '__UNAUTH__';

    sub register_email {
        state $validator = Data::Validator->new(
            email => {isa => 'Str'}
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $random_uname = $class->create_initial_username;
        $class->fast_insert({%$args, username => $UNATH_PREFIX.$random_uname});
        return $random_uname;
    }

    sub create_initial_username {
        my $class = shift;
        state $rand = String::Random->new;
        my $random_uname = $rand->randregex('[a-zA-Z0-9]{16}');
        my $full_random_uname = $UNATH_PREFIX . $random_uname;
        if ($class->db->count('user' => 'id', {username_hash => $class->make_hash($full_random_uname), username => $full_random_uname})) {
            $random_uname = $class->create_initial_username;
        }
        return $random_uname;
    }

}
1;
