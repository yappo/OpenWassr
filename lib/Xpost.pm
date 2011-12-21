use 5.014001;
use warnings;
package Xpost {
    use parent qw/Amon2/;

    # initialize database
    use DBI;
    sub setup_schema {
        my $self = shift;
        my $dbh = $self->get_dbi(type => 'master');
        my $driver_name = $dbh->{Driver}->{Name};
        my $fname = lc("sql/${driver_name}.sql");
        open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
        my $source = do { local $/; <$fh> };
        for my $stmt (split /;/, $source) {
            next unless $stmt =~ /\S/;
            $dbh->do($stmt) or die $dbh->errstr();
        }
    }

    use Xpost::DB;
    sub get_db {
        state $type_validator = Data::Validator->new(
            type => {isa => 'Xpost::DBType', default => 'master'},
        )->with(qw/Method/);
        my ($self, $args) = $type_validator->validate(@_);
        $self->{db} //= {};
        my $type = $args->{type};
        if ( !defined $self->{db}->{$type} ) {
            $self->{db}->{$type} = Xpost::DB->get_db(type => $type);
        }
        return $self->{db};
    }

}
1;
