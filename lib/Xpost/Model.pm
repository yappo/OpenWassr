use 5.014001;
use warnings;
package Xpost::Model {
    use parent qw/Teng::Row/;

    use String::CamelCase ();

    use Xpost::DB;
    use Xpost::Util::Hash;

    sub db {Xpost->context->db}
    sub dbh {shift->db->dbh}

    sub table_name {
        my $class = shift;
        $class = ref $class || $class;
        Carp::confess("This class can't use directly") if __PACKAGE__ eq $class;
        $class =~ s{^Xpost::Model::}{};
        my $table_name = String::CamelCase::decamelize($class);
        my $code = sub {$table_name};
        {
            no strict 'refs';
            no warnings 'redefine';
            *{"$class\::table_name"} = $code; ## no critic
        }
        return $table_name;
    }

    sub search {
        my $class = shift;
        return $class->db->search($class->table_name => @_);
    }

    sub search_with_pager {
        my $class = shift;
        return $class->db->search_with_pager($class->table_name => @_);
    }

    sub single {
        my $class = shift;
        return $class->db->single($class->table_name => @_);
    }

    sub insert {
        my $class = shift;
        return $class->db->insert($class->table_name => @_);
    }

    sub fast_insert {
        my $class = shift;
        return $class->db->fast_insert($class->table_name => @_);
    }
}
1;
