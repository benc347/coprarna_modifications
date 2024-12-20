#!/usr/bin/env perl

#THE BELOW IS A MODIFIED VERSION OF THE BUILD_KEGG2REFSEQ.PL SCRIPT PROVIDED
#IN THE COPRARNA GITHUB. IT HAS BEEN MODIFIED TO TAKE A LIST OF GENBANK IDS
#FROM THE USER IN ORDER TO BYPASS COPRARNA'S LIMITATION TO THE USE OF REFSEQ
#CONTENT ONLY

use warnings;
use strict;
use List::MoreUtils qw(uniq);

# usage
# build_kegg2refseq.pl

# load list of genomes from NCBI
# the below works but takes forever when submitted as a batch job
# easiest just to download prokaryotes.txt interactively

# system "wget ftp://ftp.ncbi.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt";

# prokaryotes.txt is in DOS format, which seems to throw stuff off, so convert to UNIX
# system "dos2unix prokaryotes.txt";

open MYDATA, "prokaryotes.txt" or die("\nERROR: Can't open prokaryotes.txt at build_kegg2refseq.pl\n\n");
    my @genomeInfo = <MYDATA>;
close MYDATA;

# open writing file handles
open (HP, '>CopraRNA_available_organisms.tmp');
open (New, '>kegg2refseqnew.csv');

#create hashes, a list of variables with a paired index
my %rdmStringHash = ();
my %printedHash = ();

#importing user input that will tell the program what genomes to keep in the new list
open userorgs, "user_orgs.txt"; 
	my @user_orgs = <userorgs>;
close userorgs;

# remove newline characters from list of queries
chomp @user_orgs;

foreach my $line (@genomeInfo) {
	my $printLineHP = "";
	my $printLineNew = "";
	my $switch = 1;
	
	foreach my $org (@user_orgs) {
		
		# this if loop is essential to the modification
		# check if the current line contains one of the provided organisms
		# if so, proceed with the following
		if ($line =~ /$org/) { 
		
			# create a random string as an ID to use as a hash
			my $rdmString = &generate_random_string(4);
			
			# make sure no duplicate IDs are present
			while ($switch) {
				if (exists $rdmStringHash{$rdmString}) {
					$rdmString = &generate_random_string(4);
				} else {
					$switch = 0;
					$rdmStringHash{$rdmString} = "exists";
					$printLineNew = $rdmString . "\t";
				}
			}
		
			# take the current line and delimit it by a tab
			my @splitLine = split(/\t/, $line);
			
			# find the ID cell, which is cell 8 in the prokaryotes.txt file
			# subsequently, split cell 8 apart by the subdelimiter ;
			my $ID_cell = $splitLine[8];
			my @split_ID_cell = split(/;/, $ID_cell);
		
			# for every "piece" of the split cell 8
			# assign the part of the string that matches :.+ (colon and all trailing chars) to RID
			foreach my $entry (@split_ID_cell) {
				if ($entry =~ m/(:.+)/) {  
					my $RID = $1;
					chomp $RID;
					
					# remove .1 at the end of new ids
					$RID =~ s/\.\d+//g; ## an original edit, edit 2.0.2
					
					# remove all after '/'
					$RID =~ s/\/.*//g; ## an original edit, edit 2.0.5.1
					
					# remove the leading :
					$RID =~ s/://g;
					
					$printLineHP = $printLineHP . $RID . " ";
					$printLineNew = $printLineNew . $RID . " ";
				}
			}
			
			#reformat the names of the organisms
			$printLineHP =~ s/\s+$//;
			$printLineNew =~ s/\s+$//;
			
			my $orgName = $splitLine[0];
			$orgName =~ s/^\s+//;
			$orgName =~ s/\s+$//;
			$orgName =~ s/\s+/_/g;
			$printLineHP = $printLineHP . "\t" . $orgName . "\n";
			$printLineNew = $printLineNew . "\n";
	 
			# don't print same line twice
			print HP $printLineHP unless (exists $printedHash{$printLineHP});
			print New $printLineNew unless (exists $printedHash{$printLineHP});

			$printedHash{$printLineHP} = "exists";
		}
	}
}

# close writing file handles
close (HP);
close (New);

# calling the other function to remove the temporary files
system "sh add_date_omit_incompatible.sh";

# the below is the string generation subfunction that is generated and used above
sub generate_random_string
    {
	my $length_of_randomstring=shift;# the length of 
        my @chars=('a'..'z');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
            $random_string.=$chars[rand @chars];
	}
	return $random_string;
    }

# usage
# my $random_string=&generate_random_string(4);

