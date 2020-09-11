#! /usr/bin/perl

use strict;
my $srr_id      = $ARGV[0];


my $STAR_INDEX           = "/home/ubuntu/chenlab_v2/pipeline/bulk_rna_seq/index/STAR";
my $RSEM_INDEX           = "/home/ubuntu/chenlab_v2/pipeline/bulk_rna_seq/index/RSEM/hg38.RSEM.index";
my $KALL_INDEX           = "/srv/persistent/keliu/project/MET500/index/KALLISTO/hg38.transcript.index";

my $star_option = "--runThreadN 8  --quantMode TranscriptomeSAM  --outSAMtype BAM Unsorted --outSAMunmapped Within  --outSAMattributes NH   HI   NM   MD   AS  --outFilterType BySJout  --outFilterMultimapNmax 20 --outFilterMismatchNmax 999 --outFilterMismatchNoverReadLmax 0.04   --alignIntronMin 20  --alignIntronMax 1000000   --alignMatesGapMax 1000000 --alignSJoverhangMin 8   --alignSJDBoverhangMin 1   --sjdbScore 1  ";

my $map_cmd;
my $rsem_cmd;
my $kall_cmd;

`mkdir  ./tmp/${srr_id}` if (! -e "./tmp/${srr_id}");
if (-e "fastq/${srr_id}_2.fastq" ){
        $map_cmd    = "STAR --genomeDir $STAR_INDEX $star_option --outFileNamePrefix  ./tmp/${srr_id}/  --readFilesIn fastq/${srr_id}_1.fastq  fastq/${srr_id}_2.fastq";
        $rsem_cmd = "rsem-calculate-expression --no-bam-output --quiet --no-qualities -p 8 --forward-prob 0.5 --seed-length 25 --fragment-length-mean -1.0  --bam --paired-end  tmp/${srr_id}/Aligned.toTranscriptome.out.bam    $RSEM_INDEX   RSEM.output/${srr_id}" ;  
        $kall_cmd = "kallisto quant -i $KALL_INDEX -o KALLISTO.output/$srr_id  -t 8 fastq/${srr_id}_1.fastq fastq/${srr_id}_2.fastq ";
    }else{
        $map_cmd    = "STAR --genomeDir $STAR_INDEX $star_option --outFileNamePrefix  ./tmp/${srr_id}/  --readFilesIn fastq/${srr_id}_1.fastq";
        $rsem_cmd = "rsem-calculate-expression --no-bam-output --quiet --no-qualities -p 8 --forward-prob 0.5 --seed-length 25 --fragment-length-mean -1.0  --bam               tmp/${srr_id}/Aligned.toTranscriptome.out.bam   $RSEM_INDEX   RSEM.output/${srr_id} " ;  
        $kall_cmd = "kallisto quant -i $KALL_INDEX -o KALLISTO.output/$srr_id  --single -t 8 fastq/${srr_id}_1.fastq ";
    }
if(! -e "RSEM.output/$srr_id.genes.results"){
    `$map_cmd`;
    `$rsem_cmd`;
}
if(! -e "KALLISTO.output/$srr_id"){
    #`$kall_cmd`; ok, currently we do not care about kallisto
}


print "${srr_id} finished!\n";












