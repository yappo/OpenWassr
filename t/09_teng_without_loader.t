use strict;
use warnings;
use Test::More;
use Xpost;

my $teng = Xpost->new;
is(ref $teng, 'Xpost', 'instance');
is(ref $teng->db, 'My::App::DB', 'instance');
$teng->db->do("create table if not exists sessions (id char(72) primary key, session_data text)") or die $teng->db->errstr;
$teng->db->insert('sessions', { id => 'abcdefghijklmnopqrstuvwxyz', session_data => 'ka2u' });
my $res = $teng->db->single('sessions', { id => 'abcdefghijklmnopqrstuvwxyz' });
is($res->get_column('session_data'), 'ka2u', 'search');
$teng->db->delete('sessions', {id => 'abcdefghijklmnopqrstuvwxyz'});

done_testing;
