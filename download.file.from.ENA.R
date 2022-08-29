library(foreach)
library(dplyr)
library(doParallel)

registerDoParallel(2)


# Reference: https://ena-docs.readthedocs.io/en/latest/retrieval/file-download.html#using-aspera
#aspera.address.file should be a tsv file with two columns:
# run_accession	fastq_aspera
#This tsv file could be downloaded from ENA,see https://www.fatalerrors.org/a/sra-data-download-through-ebi-ena-database-using-aspera.html


args                   <- commandArgs(TRUE)
ENA.meta.data.file     <- args[1]
output.path            <- args[2]
download.option        <- args[3]


df                 <- read.table(file = ENA.meta.data.file, stringsAsFactors=FALSE, header=TRUE)
url.vec            <- strsplit(df[,download.option] %>% as.character(),";") %>% unlist

foreach(i = url.vec) %dopar% {
    if(grepl(download.option, pattern ='aspera')){
        download.cmd <- sprintf("ascp -QT -l 300m -P 33001 -i /home/liuke/miniconda3/envs/bioklab/etc/asperaweb_id_dsa.openssh era-fasp@%s %s",i, output.path)
    }else{
        download.cmd <- sprintf("wget -P %s ftp://%s ",output.path, i)
    }
    system(download.cmd, wait = TRUE, intern = TRUE)
}
