rename -v 's/\.fq$/\.fastq/' *.fq # rename fq to fastq

prefetch  -a "/home/ubuntu/.aspera/cli/bin/ascp|/home/ubuntu/.aspera/cli/etc/asperaweb_id_dsa.openssh" --max-size 1000000000 --option-file exp.txt # use prefecth to downloadsra files

