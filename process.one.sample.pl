#! /usr/bin/perl

use strict;
my $srr_id      = $ARGV[0];


my $STAR_INDEX           = "/data_200t/liuke/bioklab_data/genome_index/hg38.STAR";
my $RSEM_INDEX           = "/data_200t/liuke/bioklab_data/genome_index/hg38.RSEM/hg38.RSEM.index";
my $KALL_INDEX           = "/srv/persistent/keliu/project/MET500/index/KALLISTO/hg38.transcript.index";

my $star_option = "--runThreadN 8  --quantMode TranscriptomeSAM  --outSAMtype BAM Unsorted --outSAMunmapped Within  --outSAMattributes NH   HI   NM   MD   AS  --outFilterType BySJout  --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04   --alignIntronMin 20  --alignIntronMax 1000000   --alignMatesGapMax 1000000 --alignSJoverhangMin 8   --alignSJDBoverhangMin 1   --sjdbScore 1  ";

my $map_cmd;
my $rsem_cmd;
my $kall_cmd;

`mkdir  ./tmp/${srr_id}` if (! -e "./tmp/${srr_id}");

$map_cmd    = "STAR --genomeDir $STAR_INDEX $star_option --outFileNamePrefix  ./tmp/${srr_id}/   ";

my $is_gz;
my $is_paired_end;

# gzipped fastq files?
if(-e "fastq/${srr_id}_1.fastq.gz" || -e "fastq/${srr_id}.fastq.gz"){
    $is_gz = TRUE;
}else{
    $is_gz = FALSE;
}

# paired-end fastq files?
if(-e "fastq/${srr_id}_2.fastq" || -e "fastq/${srr_id}_2.fastq.gz"){
    $is_paired_end = TRUE;
}else{
    $is_paired_end = FALSE;
}


if($is_paired_end == TRUE){ # paired_end
    if($is_gz){
        $file_str = " --readFilesIn fastq/${srr_id}_1.fastq.gz  fastq/${srr_id}_2.fastq.gz --readFilesCommand zcat ";
    }else{
        $file_str = " --readFilesIn fastq/${srr_id}_1.fastq     fastq/${srr_id}_2.fastq ";
    }
}else{ # single_end
    my $under_score_one = "";
    if(-e "fastq/${srr_id}_1.fastq" ||  -e "fastq/${srr_id}_1.fastq.gz"){
        $under_score_one = "_1";
    }

    if($is_gz){
        $file_str = " --readFilesIn fastq/${srr_id}${under_score_one}.fastq.gz  --readFilesCommand zcat ";
    }else{
        $file_str = " --readFilesIn fastq/${srr_id}${under_score_one}.fastq  ";
    }
}

$map_cmd  = $map_cmd.$file_str;



my $paired_end_str = "";
if($is_paired_end){
    $paired_end_str = " --paired-end ";
}
$rsem_cmd = "rsem-calculate-expression --no-bam-output --quiet --no-qualities -p 8 --forward-prob 0.5 --seed-length 25 --fragment-length-mean -1.0  --bam  $paired_end_str  tmp/${srr_id}/Aligned.toTranscriptome.out.bam    $RSEM_INDEX   RSEM.output/${srr_id}" ;




if(! -e "RSEM.output/$srr_id.genes.results"){
    `$map_cmd`;
    `$rsem_cmd`;
}


print "${srr_id} finished!\n";
