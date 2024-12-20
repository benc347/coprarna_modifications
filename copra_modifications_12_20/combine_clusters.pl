#!/usr/bin/env perl

## edit 2.0.4 // changed this scripts name from scale_clusters.pl to combine_clusters.pl

use strict;
use warnings;
use Cwd 'abs_path'; ## edit 2.0.5.1

my $orgcount = $ARGV[0];
my $molchrono = "16s_sequences.fa"; ## edit 2.0.4 // does not need to be an argument
my $ncrnaname = "ncRNA"; ## edit 2.0.4 // does not need to be an argument
## edit 2.0.4 // removed $mergedinput

# get absolute path
my $ABS_PATH = abs_path($0); ## edit 2.0.5.1
# remove script name at the end
# match all non slash characters at the end of the string
$ABS_PATH =~ s|[^/]+$||g; ## edit 2.0.5.1
my $PATH_COPRA_SUBSCRIPTS = $ABS_PATH;

# check if CopraRNA1 prediction should be made
my $cop1 = `grep 'CopraRNA1:' CopraRNA_option_file.txt | sed 's/CopraRNA1://g'`; ## edit 2.0.6
chomp $cop1;

# fix issue with IDs that are longer than 10 chars ## edit 2.0.3.2
open (DISTMAT, "compatible.distmat") or die ("\nError: cannot open compatible.distmat in combine_clusters.pl\n\n");
    my @distmat_lines = <DISTMAT>;
close (DISTMAT);

my $c = 1000; ## edit 2.0.5.1 // changed this to 1000 because it was causing  wrong matches when more than 10 long IDs were present
my %ID_to_ID_hash = (); # new_id -> old_id

system "cp compatible.distmat compatible.distmat.mapped";

for (my $i=1;$i<scalar(@distmat_lines);$i++) {

    my $curr_line = $distmat_lines[$i];
    chomp $curr_line;
    my @split = split(/\t+/,$curr_line);
    my $RID = $split[0];
    if( length($RID)>10 ) { # remap ID
        my $new_id = "na_" . $c;
        $ID_to_ID_hash{$new_id} = $RID;
        system "sed -i 's/$RID/$new_id/g' compatible.distmat.mapped";
        $c++;
    }
}

system "fneighbor -datafile compatible.distmat.mapped -outfile compatible.fneighbor.mapped -treetype u > /dev/null 2> /dev/null"; ## edit 2.0.4 // changed to UPGMA tree // ## edit 2.0.5.1 // moving terminal output to /dev/null to silence it
system "sed -i 's/0.00000/0.00001/g' compatible.fneighbor.mapped"; ## edit 1.2.9 fix zero dist between org issue
system "sed -i 's/0.00000/0.00001/g' distmat.treefile"; ## edit 1.2.9 fix zero dist between org issue

system "mv compatible.fneighbor.mapped compatible.fneighbor";
system "mv distmat.treefile compatible.treefile";

# reverse the mapping
for my $key (keys %ID_to_ID_hash) {
    system "sed -i 's/$key/$ID_to_ID_hash{$key}/g' compatible.fneighbor";
    system "sed -i 's/$key/$ID_to_ID_hash{$key}/g' compatible.treefile";
}
# end fix IDs issue end ## edit 2.0.3.2

# calculate full organism set weights
system $PATH_COPRA_SUBSCRIPTS . "mod_compute_weights.pl compatible.treefile compatible.fneighbor > zscore.weight"; ## edit 2.0.6 // renamed to mod_compute_weights.pl

## calculate combined pvalues

# combination with missing p-value sampling and empiric rho estimation
# CopraRNA1 table combination with p-value sampling
system "R --slave -f " . $PATH_COPRA_SUBSCRIPTS . "join_pvals_coprarna1.R --args opt_tags.clustered_rcsize" if ($cop1);

# prepare input for CopraRNA 2 combination
system "R --slave -f " . $PATH_COPRA_SUBSCRIPTS . "prep_cop2.R --args opt_tags.clustered"; ## edit 2.0.6 // prepare lines for CopraRNA 2 combination

# sort the final raw output
# with pvalue sampling
system "env LC_ALL=C sort -g -k1 CopraRNA1_with_pvsample.csv > CopraRNA1_with_pvsample_sorted.csv" if ($cop1); ## edit 2.0.6

# without pvalue sampling
system "env LC_ALL=C sort -g -k1 CopraRNA2_prep.csv > CopraRNA2_prep_sorted.csv"; ## edit 2.0.6

