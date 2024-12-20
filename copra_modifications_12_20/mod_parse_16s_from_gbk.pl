#!/usr/bin/env perl

use strict;
use warnings;

use Bio::Seq;
use Bio::SeqIO;
use Bio::SeqUtils;

# parses 16s rRNA sequences from genbank files

# adding a hash of GenBank IDs for organisms that have their 16S rRNA gene misannotated (should be on the complement strand)

my %need_rev_comp = (
	"CP000350" => 1
);

foreach(@ARGV) {

    my @splitargv = split(/,/, $_);

    # save splitiargv[0] and put this in as header. remove the .gb !!
    my $MainRefID = $splitargv[0];
    chomp $MainRefID;
    # remove .gb
    chop $MainRefID;
    chop $MainRefID;
    chop $MainRefID;

    for (my $i=0; $i<scalar(@splitargv); $i++) {

        my $seqin = Bio::SeqIO->new( -format => 'genbank', -file => $splitargv[$i]);

        while( (my $seq = $seqin->next_seq()) ) {
            foreach my $sf ( $seq->get_SeqFeatures() ) {
                if( $sf->primary_tag eq 'rRNA' ) {
                    my $product = "";
                    if ($sf->has_tag("product")) {
                        my @productlist = $sf->get_tag_values("product");
                        $product = $productlist[0];
                    }
                    my $id = $seq->display_id;
                    if ($product =~ m/16S/i or $product =~ m/Small subunit ribosomal RNA/i) {
                        print ">$MainRefID\n";

			#added code to see if current GenBank ID is one where the reverse complement is needed

			if($need_rev_comp{$MainRefID}) {
				my $seqtorev = $sf->spliced_seq->seq;
				my $seqtorev_obj = Bio::Seq->new(-seq => $seqtorev);
				print $seqtorev_obj->revcom->seq, "\n";
			} else {
                    		print $sf->spliced_seq->seq, "\n";
                        }

			$i = 10000;
                        last;
                    }
                }
            }
            if ($i == 10000) { last; }
        }
    }
}
