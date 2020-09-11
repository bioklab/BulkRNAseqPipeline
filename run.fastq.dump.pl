#! /usr/bin/perl
use strict;

my @sra_file_list;
my $file_name = $ARGV[0];
open INFILE, "< $file_name";
while(my $line=<INFILE>){
    chomp $line;
    push @sra_file_list,$line;
}
close INFILE;
chdir 'fastq'; 
foreach my $file (@sra_file_list){
    my $fastq_file ="${file}_1.fastq";
    if (-e $fastq_file){
        print "Existing $fastq_file\n";
    }else{
        print "Not existing $file\n";
        `fastq-dump --split-files ~/chenlab_temp/fastq_repository/sra/${file}.sra`;
    }
}
