package Xpost::Script::SchemaDumper;
use strict;
use warnings;
use 5.014002;

use Cwd ();
use Data::Section::Simple;
use Data::Validator;
use DBIx::Inspector;
use File::Slurp;
use Path::Class ();
use Teng::Schema;
use Teng::Schema::Dumper;
use Text::Xslate;
use Text::Xslate::Util;

use Xpost::DB;
use Xpost;

sub this_file_path { Path::Class::file(Cwd::realpath(__FILE__)) }
sub data_section   { Data::Section::Simple->new(__PACKAGE__)->get_data_section }

sub run {
    my ($class, $c) = @_;
    my $dbi = Xpost::DB->get_dbh(type => 'master');
    my $schema = Teng::Schema::Dumper->dump(
        dbh => $dbi,
        namespace => 'Xpost::DB',
        inflate   => $class->create_inflate_rule_and_row_class(dbh => $dbi),
    );
    my $header = $class->data_section->{header};
    my @schema = split /\n/, $schema;
    splice @schema, 1, 0, $header;
    $schema = join "\n", @schema;
    eval $schema;
    die "Schema is broken! cause:$@" if $@;
    my $path = $class->this_file_path->parent->parent->subdir('DB/');
    $path->mkpath;
    my $file = $path->file('Schema.pm');
    write_file($file->stringify, $schema);
    say "update Schema [$file] done.";
}

sub create_inflate_rule_and_row_class {
    state $validator = Data::Validator->new(
        dbh => {isa => 'DBI::db'},
    )->with(qw/Method/);
    my ($class, $args) = $validator->validate(@_);
    my $inspector = DBIx::Inspector->new(dbh => $args->{dbh});

    my $rules = {};
    my $already_use_module = {};
    my $use_module = sub {
        my $module = shift;
        return if $already_use_module->{$module};
        $already_use_module->{$module} = 1;
        return Text::Xslate::Util::mark_raw("    use $module;\n");
    };
    my $xslate = Text::Xslate->new(path => $class->data_section, function => {use_module => $use_module});

    for my $table ( sort {$a->name cmp $b->name} $inspector->tables() ) {
        my $name = $table->name;
        my $model_name = Teng::Schema::camelize($name);
        my $table_info = {};
        my @columns = $table->columns->all;
        $table_info->{columns} = [sort map{$_->name} @columns];
        $table_info->{datetime_exists} = (grep {$_->name =~ /_at$/} @columns) ? 1 : 0;
        $table_info->{date_exists} = (grep {$_->name =~ /_on$/} @columns) ? 1 : 0;
        $table_info->{exists} = {};
        $table_info->{model_name} = $model_name;
        for my $column (@columns) {
            $table_info->{exists}->{$column->name} = 1;
        }
        $rules->{$name} = $xslate->render('inflate', $table_info);
        my $row_path = $class->this_file_path->parent->parent->subdir('Model/');
        $row_path->mkpath;
        my $row_file = $row_path->file("$model_name.pm");
        unless(-f $row_file->stringify) {
            write_file($row_file->stringify, $xslate->render('row', $table_info));
        }
    }



    return $rules;
}


1;
__DATA__
@@ inflate
    row_class 'Xpost::Model::<: $model_name :>';
:if $datetime_exists {
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
: }
:if $date_exists {
    inflate qr{_on$} => sub {
        my $value = shift;
        return unless $value;
        return DateTime::Format::MySQL->parse_date($value)->set_time_zone('Asia/Tokyo');
    };
    deflate qr{_on$} => sub {
        my $value = shift;
        return unless $value;
        return $value unless ref $value;
        return DateTime::Format::MySQL->format_date($value);
    };
: }

@@ row
package Xpost::Model::<: $model_name :>;
use strict;
use warnings;
use 5.010;

use parent qw/Xpost::Model/;

1;

@@ header
use DateTime::Format::MySQL;
