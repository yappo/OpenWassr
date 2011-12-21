use 5.014001;
use warnings;
package Xpost::Model {
    use parent qw/Teng::Row/;

    use Xpost::DB;
    use String::CamelCase ();

    sub get_db {
        my $class = shift;
        return Xpost::DB->get_db(@_);
    }

    sub get_dbi {
        my $class = shift;
        return Xpost::DB->get_dbi(@_);
    }

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
        state $validator = Data::Validator->new(
            from => {isa => 'Xpost::DBType', default => 'slave'},
            args => {isa => 'ArrayRef', default => sub { [{}, {}] }},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $db = $class->get_db(type => $args->{from});
        return $db->search($class->table_name => @{$args->{args}});
    }

    sub search_with_pager {
        state $validator = Data::Validator->new(
            from => {isa => 'Xpost::DBType', default => 'slave'},
            args => {isa => 'ArrayRef', default => sub { [{}, {}] }},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $db = $class->get_db(type => $args->{from});
        return $db->search_with_pager($class->table_name => @{$args->{args}});
    }

    sub single {
        state $validator = Data::Validator->new(
            from => {isa => 'Xpost::DBType', default => 'slave'},
            args => {isa => 'ArrayRef', default => sub { [{}, {}] }},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        my $db = $class->get_db(type => $args->{from});
        return $db->single($class->table_name => @{$args->{args}});
    }

    sub insert {
        state $validator = Data::Validator->new(
            args => {isa => 'HashRef'},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        return $class->get_db(type => 'master')->insert($class->table_name => {%{$args->{args}}});
    }

    sub fast_insert {
        state $validator = Data::Validator->new(
            args => {isa => 'HashRef'},
        )->with(qw/Method/);
        my ($class, $args) = $validator->validate(@_);
        return $class->get_db(type => 'master')->fast_insert($class->table_name => {%{$args->{args}}});
    }
}
1;
