rename -v 's/\.fq$/\.fastq/' *.fq # rename fq to fastq

prefetch  -a "/home/ubuntu/.aspera/cli/bin/ascp|/home/ubuntu/.aspera/cli/etc/asperaweb_id_dsa.openssh" --max-size 1000000000 --option-file exp.txt # use prefecth to download sra files from SRA. In exp.txt, each row contains a SRR id, like SRRxxxx 

