package Xpost;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
use 5.008001;

__PACKAGE__->load_plugin(qw/DBI/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
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
        my $conf = $self->config->{'DBI'}
        or die "missing configuration for 'DBI'";
        my $dbh = DBI->connect(@{$conf});
        $self->{db} = Xpost::DB->new(
            dbh    => $dbh,
	    );
    }
    return $self->{db};
}

1;
