use strict;
use warnings;
use Test::More;
use Xpost;

my $teng = Xpost->new;
is(ref $teng, 'Xpost', 'instance');
is(ref $teng->get_db, 'Xpost::DB', 'instance');
$teng->get_db->do("create table if not exists sessions (id char(72) primary key, session_data text)") or die $teng->get_db->errstr;
$teng->get_db->insert('sessions', { id => 'abcdefghijklmnopqrstuvwxyz', session_data => 'ka2u' });
my $res = $teng->get_db->single('sessions', { id => 'abcdefghijklmnopqrstuvwxyz' });
is($res->get_column('session_data'), 'ka2u', 'search');
$teng->get_db->delete('sessions', {id => 'abcdefghijklmnopqrstuvwxyz'});

done_testing;
