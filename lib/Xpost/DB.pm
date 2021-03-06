use 5.014002;
use warnings;
package Xpost::DB {

    use parent qw/Teng/;

    use Carp ();
    use Data::GUID::URLSafe;
    use Data::Validator;
    use DateTime;
    use Digest::MurmurHash qw/murmur_hash/;
    use Scope::Container::DBI;
    use Class::Method::Modifiers;

    use Xpost;

    __PACKAGE__->load_plugin('Count');
    __PACKAGE__->load_plugin('Pager');

    sub conf {Xpost->config}

    sub db {
        my $class = shift;
        my $dbh = $class->get_dbh(@_);
        return $class->new(dbh => $dbh);
    }

    sub get_dbh {
        return Scope::Container::DBI->connect(shift->conf->{DBI});
    }


    #各メソッドへのtrigger
    #TODO 共通化すべし
    before 'insert', 'fast_insert' => sub {
        my ($self, $table_name, $row_data) = @_;
        my $table = $self->schema->get_table($table_name);
        if ($table) {
            my @columns = @{$table->columns};
            my $now = DateTime->now(time_zone => Xpost->context->time_zone);

            #GUID
            if(grep /^guid$/, @columns) {
                $row_data->{guid} = Data::GUID->guid_hex;
            }

            #(created|updated)_at
            my @datetime_columns = grep /^(created|updated)_(at|on)$/, @columns;
            for my $column (@datetime_columns) {
                $row_data->{$column} ||= $now;
            }

            #hash値計算
            my @hash_columns = grep /_hash$/, @columns;
            for my $column (@hash_columns) {
                (my $origin = $column) =~ s/_hash$//;
                if($row_data->{$origin}) {
                    $row_data->{$column} = murmur_hash($row_data->{$origin});
                }
            }
        }
    };

    before 'update' => sub {
        my ($self, $table_name, $row_data) = @_;
        my $table = $self->schema->get_table($table_name);
        if ($table) {
            my $columns = $table->columns;
            my $now = DateTime->now(time_zone => Xpost->context->time_zone);
            my @datetime_columns = grep /^updated_(at|on)$/, @$columns;

            #updated_at
            for my $column (@datetime_columns) {
                $row_data->{$column} ||= $now;
            }

            #hash値計算
            my @hash_columns = grep /_hash$/, @$columns;
            for my $column (@hash_columns) {
                (my $origin = $column) =~ s/_hash$//;
                if($row_data->{$origin}) {
                    $row_data->{$column} = murmur_hash($row_data->{$origin});
                }
            }
        }
    };

}

1;

