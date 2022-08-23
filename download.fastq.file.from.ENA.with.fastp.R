library(foreach)
library(dplyr)
library(doParallel)

registerDoParallel(2)


# Reference: https://ena-docs.readthedocs.io/en/latest/retrieval/file-download.html#using-aspera
#aspera.address.file should be a tsv file with two columns:
# run_accession	fastq_aspera
#This tsv file could be downloaded from ENA,see https://www.fatalerrors.org/a/sra-data-download-through-ebi-ena-database-using-aspera.html


args                   <- commandArgs(TRUE)
aspera.address.file    <- args[1]
file.path              <- args[2]


df                 <- read.table(file =aspera.address.file, stringsAsFactors=FALSE, header=TRUE)
aspera.address.vec <- strsplit(df$fastq_aspera,";") %>% unlist

foreach(i = aspera.address.vec) %dopar% {
    aspera.cmd <- sprintf("ascp -QT -l 300m -P 33001 -i /home/liuke/miniconda3/envs/bioklab/etc/asperaweb_id_dsa.openssh era-fasp@%s %s",i,file.path)
    system(aspera.cmd, wait = TRUE, intern = TRUE)
}

