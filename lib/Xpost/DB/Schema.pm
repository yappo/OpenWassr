package Xpost::DB::Schema;
use Teng::Schema::Declare;

table {
    name 'sessions';
    pk 'id';
    columns qw(id session_data);
};

1;
