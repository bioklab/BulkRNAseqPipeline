#!/usr/bin/env  Rscript
require(data.table)
require(plyr)
require(dplyr)
require(foreach)
require(parallel)
require(doParallel)

system('mkdir tmp')
system('mkdir alignment')
system('mkdir RData')
system('mkdir RSEM.output')

args        <- commandArgs(TRUE)
srr.id.file <- args[1]
cmd.str     <- sprintf('cat %s',srr.id.file)
srr.list    <- system(cmd.str,wait=TRUE,intern=TRUE)

registerDoParallel(2)
foreach(srr.id = srr.list) %do% {
    cmd.str <- sprintf('ls fastq|grep %s',srr.id)
    tmp     <- system(cmd.str,wait=TRUE,intern=TRUE)
    if(length(tmp) > 0){
        cmd     <- sprintf('perl /home/ubuntu/chenlab_v2/pipeline/bulk_rna_seq/code/process.one.sample.pl %s',srr.id)
        rsem.file <- sprintf('RSEM.output/%s.genes.results',srr.id)
        if(file.exists(rsem.file) == FALSE){
            system(cmd,wait=TRUE,intern=TRUE)
        }    
        print(sprintf("sample %s finished!",srr.id))
    }else{
        print(sprintf("fastq files for %s do not exist!",srr.id))
    }
}



remove.ensemble.version.id <- function(x){
    v <- strsplit(x = x,split = "\\.") %>% unlist
    v[1]
}

file.list   <- system('ls RSEM.output|grep genes',wait = TRUE,intern = TRUE)
srr.id      <- sapply(file.list,remove.ensemble.version.id)
df          <- read.table(sprintf("RSEM.output/%s",file.list[1]),header=TRUE,stringsAsFactors=FALSE)
gene.list   <- as.character(df$gene_id)


log2.read.count.matrix <- foreach(rsem.file = file.list,.combine='cbind') %dopar% {
    df           <- read.table(sprintf("RSEM.output/%s",rsem.file),header=TRUE,stringsAsFactors=FALSE)
    rownames(df) <- df$gene_id
    log2(df[gene.list,'expected_count']+1) %>% c
}
rownames(log2.read.count.matrix) <- sapply(gene.list,remove.ensemble.version.id)
colnames(log2.read.count.matrix) <- srr.id


log2.fpkm.matrix <- foreach(rsem.file = file.list,.combine='cbind') %dopar% {
    df           <- read.table(sprintf("RSEM.output/%s",rsem.file),header=TRUE,stringsAsFactors=FALSE)
    rownames(df) <- df$gene_id
    log2(df[gene.list,'FPKM']+1) %>% c
}
rownames(log2.fpkm.matrix) <- sapply(gene.list,remove.ensemble.version.id)
colnames(log2.fpkm.matrix) <- srr.id


log2.tpm.matrix <- foreach(rsem.file = file.list,.combine='cbind') %dopar% {
    df           <- read.table(sprintf("RSEM.output/%s",rsem.file),header=TRUE,stringsAsFactors=FALSE)
    rownames(df) <- df$gene_id
    log2(df[gene.list,'TPM']+1) %>% c
}
rownames(log2.tpm.matrix) <- sapply(gene.list,remove.ensemble.version.id)
colnames(log2.tpm.matrix) <- srr.id

save(file= 'RData/gene.expression.RData',list = c('log2.fpkm.matrix','log2.read.count.matrix','log2.tpm.matrix'))






