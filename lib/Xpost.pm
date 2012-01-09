use 5.014001;
use warnings;
package Xpost {
    use parent qw/Amon2/;

    our $VERSION = '0.01';

    # initialize database
    sub setup_schema {
        my $self = shift;
        my $dbh = $self->db->dbh;
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
    sub db {
        my $self = shift;
        if ( !defined $self->{db} ) {
            $self->{db} = Xpost::DB->db;
        }
        return $self->{db};
    }

}
1;
