use File::Spec;
use File::Basename qw(dirname);
+{
    datasource => {
        master => [
            "dbi:mysql:xpost",
            'root',
            '',
            +{
                RaiseError            => 1,
                mysql_connect_timeout => 4,
                mysql_enable_utf8     => 1,
            }
        ],
        slave => [
            "dbi:mysql:xpost",
            'root',
            '',
            +{
                RaiseError            => 1,
                mysql_connect_timeout => 4,
                mysql_enable_utf8     => 1,
            }
        ],
    },
};
