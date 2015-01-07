package MT::Plugin::Priority::Util;

use strict;
use warnings;
use base qw(Exporter);

use Data::Dumper;

our @EXPORT = qw(plugin pp);

sub plugin { MT->component('Priority') }

sub pp { print STDERR Dumper(@_); }

1;