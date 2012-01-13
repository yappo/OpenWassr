use 5.014001;
use warnings;
package Xpost::Model {
    use parent qw/Teng::Row/;

    use Class::Method::Modifiers;
    use DBIx::QueryLog;
    use Log::Minimal;
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

    before qw/search search_with_pager single/ => sub  {
        my ($class, $args, $opt) = @_;
        $class->add_hash_to_cond($args);
    };

    before qw/count/ => sub  {
        my ($class, $cnt_column, $args, $opt) = @_;
        $class->add_hash_to_cond($args);
    };

    sub add_hash_to_cond {
        my ($class, $args) = @_;
        my $table = $class->db->schema->get_table($class->table_name);
        return unless $table;
        debugf(ddf($table));
        my @hash_coluns = grep /_hash$/, @{$table->columns};
        return unless @hash_coluns;
        for my $hash_column (@hash_coluns) {
            my ($column) = ($hash_column =~ /^(.+)_hash$/);
            warnf($column);
            next unless exists $args->{$column};
            $args->{$hash_column} = $class->make_hash($args->{$column});
        }
    }

    sub count {
        my $class = shift;
        return $class->db->count($class->table_name => @_);
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
