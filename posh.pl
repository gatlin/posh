#!/usr/bin/env perl

use v5.14;
use strict;
use warnings;

my %env;
%env = (
    prompt => 'posh',
);

my %fun;
%fun = (
    sub => sub {
        my $fn = shift;
        $fun{$fn} = eval "sub { @_; }"
    },
    set => sub {
        $env{$_[0]} = $_[1];
    },
    prompt => sub {
        print "$env{prompt}> ";
    },
);

sub do_cmd {
    my ($fn, @args) = @_;
    warn ("$fn not defined"), return if not defined $fun{$fn};
    $fun{$fn}->(@args);
}

$fun{prompt}->();
while (<>) {
    my @cmds = split /\|/;
    last if $cmds[0] =~ /^exit/;

    my $in = "";
    my $out;
    {
        local *STDIN;
        local *STDOUT;
        local *ARGV;
        for my $cmd (@cmds) {
            open STDIN, "<", \$in;
            open STDOUT, ">", \$out;
            *ARGV = *STDIN;
            do_cmd split " ", $cmd;
            close STDIN;
            close STDOUT;
            $in = $out;
        }
    }

    chomp $in if $in;
    print "$in\n" if $in;
    $fun{prompt}->();
}

print "Goodbye!\n";
