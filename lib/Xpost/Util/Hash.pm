use 5.014001;
use warnings;
package Xpost::Util::Hash {
    use Digest::MurmurHash qw/murmur_hash/;

    use Exporter::Lite;

    our @EXPORT = qw/make_hash/;

    sub make_hash {
        state $validator = Data::Validator->new(
            str => {isa => 'Str'},
        )->with(qw/Method Sequenced/);
        my ($class, $args) = $validator->validate(@_);
        return murmur_hash($args->{str});
    }

}
1;
