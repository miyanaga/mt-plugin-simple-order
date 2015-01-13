package MT::SimpleOrder::Util;

use strict;
use warnings;
use base qw(Exporter);

use Data::Dumper;

our @EXPORT = qw(plugin pp);

sub plugin { MT->component('SimpleOrder') }

sub pp { print STDERR Dumper(@_); }

1;