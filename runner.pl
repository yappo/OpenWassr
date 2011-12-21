#!/usr/bin/env perl
use 5.14.0;
use warnings;

use lib './lib';

use Class::Load ();
use Xpost;

my $module = shift @ARGV;

die "Module name is empty" unless $module;

$module = "Xpost::Script::$module";

my $c = Xpost->bootstrap;
Class::Load::load_class($module);

$module->run($c, @ARGV);
