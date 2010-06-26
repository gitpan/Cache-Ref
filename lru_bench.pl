#!/usr/bin/perl

use strict;
use warnings;

use Cache::Ref::Util::LRU::Array;
use Cache::Ref::Util::LRU::List;

for my $i ( 10 .. 25 ) {
    warn "size: $i (" . 2 ** $i . ")\n\n";
    foreach my $impl qw(Cache::Ref::Util::LRU::List) {
        warn "testing $impl ...\n";

        my $t0 = times;

        my $l = $impl->new;

        my $items;

        my @refs;
        for my $iter ( 1 .. (2 ** $i) ) {
            my @items = map { rand > 0.5 ? ["foo"] : "$iter $_" } 1 .. 10;
            $items += @items;
            push @refs, $l->insert(@items);
        }

        my $t1 = times;

        for ( 1 .. ( int(@refs / 2) + 1000 ) ) {
            $l->hit($refs[int rand @refs]);
        }

        my $t2 = times;

        $l->remove($refs[int rand @refs]) for 1 .. int(scalar(@refs)/2);

        my $t3 = times;

        for ( 1 .. int(@refs / 2) ) {
            $l->remove_lru;
        }

        my $t4 = times;

        $l->clear;

        my $t5 = times;

        warn "finished\n";
        warn sprintf "insert: %0.3fs ($items items)\nhit:%0.3fs\nremove: %0.3fs\npop: %0.3fs\nclear: %0.3fs\ntotal: %0.3fs\n", $t1-$t0, $t2-$t1, $t3-$t2, $t4-$t3, $t5-$t4, $t5-$t1;
        warn "\n\n";
    }

    warn "$i finished\n\n\n\n";
}
