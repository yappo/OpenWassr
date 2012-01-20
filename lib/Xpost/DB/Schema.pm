package Xpost::DB::Schema;
use DateTime::Format::MySQL;

use Teng::Schema::Declare;
table {
    name 'favorite';
    pk 'created_at','id';
    columns (
        {name => 'tweet_id', type => 4},
        {name => 'from_user_id', type => 4},
        {name => 'created_at', type => 11},
        {name => 'user_id', type => 4},
        {name => 'id', type => 4},
    );
    row_class 'Xpost::Model::Favorite';
    inflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return DateTime::Format::MySQL->parse_datetime($value)->set_time_zone('Asia/Tokyo');
    };
    deflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return $value unless ref $value;
        return DateTime::Format::MySQL->format_datetime($value);
    };

};

table {
    name 'friend';
    pk 'id';
    columns (
        {name => 'to_user_id', type => 4},
        {name => 'status', type => 12},
        {name => 'from_user_id', type => 4},
        {name => 'id', type => 4},
    );
    row_class 'Xpost::Model::Friend';

};

table {
    name 'message';
    pk 'created_at','id';
    columns (
        {name => 'to_user_id', type => 4},
        {name => 'is_read', type => 12},
        {name => 'from_user_id', type => 4},
        {name => 'body', type => 12},
        {name => 'created_at', type => 11},
        {name => 'id', type => 4},
    );
    row_class 'Xpost::Model::Message';
    inflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return DateTime::Format::MySQL->parse_datetime($value)->set_time_zone('Asia/Tokyo');
    };
    deflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return $value unless ref $value;
        return DateTime::Format::MySQL->format_datetime($value);
    };

};

table {
    name 'sessions';
    pk 'id';
    columns (
        {name => 'session_data', type => 12},
        {name => 'id', type => 1},
    );
    row_class 'Xpost::Model::Sessions';

};

table {
    name 'tweet';
    pk 'created_at','id';
    columns (
        {name => 'status', type => 12},
        {name => 'body', type => 12},
        {name => 'created_at', type => 11},
        {name => 'user_id', type => 4},
        {name => 'id', type => 4},
    );
    row_class 'Xpost::Model::Tweet';
    inflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return DateTime::Format::MySQL->parse_datetime($value)->set_time_zone('Asia/Tokyo');
    };
    deflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return $value unless ref $value;
        return DateTime::Format::MySQL->format_datetime($value);
    };

};

table {
    name 'user';
    pk 'email','id';
    columns (
        {name => 'profile', type => 12},
        {name => 'email_hash', type => 4},
        {name => 'username_hash', type => 4},
        {name => 'status', type => 12},
        {name => 'full_name', type => 12},
        {name => 'username', type => 12},
        {name => 'email', type => 12},
        {name => 'created_at', type => 11},
        {name => 'password', type => 12},
        {name => 'password_hash', type => 4},
        {name => 'id', type => 4},
    );
    row_class 'Xpost::Model::User';
    inflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return DateTime::Format::MySQL->parse_datetime($value)->set_time_zone('Asia/Tokyo');
    };
    deflate qr{_at$} => sub {
        my $value = shift;
        return unless $value;
        return $value unless ref $value;
        return DateTime::Format::MySQL->format_datetime($value);
    };

};

1;