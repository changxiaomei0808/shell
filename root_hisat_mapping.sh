#$ -S /bin/bash

#$ -l h_vmem=10G 
#$ -R yes 
#$ -j yes 
#$ -pe serial 5


module load hisat
module load samtools
module load stringtie
module list

genome=$1
index_prefix=$2

hisat2-build -p $NSLOTS $genome ${index_prefix}

for i in {1952640,1952641,1952642,1952643}
do
	#Align RNA-seq data using HISAT2#
	hisat2 -p $NSLOTS -x ${index_prefix} -1 /scratch/zosteramarina/annotation/data/rnadata/root/SRR${i}.1_1.fastq -2 /scratch/zosteramarina/annotation/data/rnadata/root/SRR${i}.1_2.fastq -S SRR${i}.1.hisat_mapping.sam 

	#Covert sam foramt to bam format#
	samtools view -bS SRR${i}.1.hisat_mapping.sam > SRR${i}.1.hisat_mapping.bam 

	#Sort the bam file#
	samtools sort SRR${i}.1.hisat_mapping.bam SRR${i}.1.hisat_mapping.sorted

	#Creat index for bam file#
	samtools index SRR${i}.1.hisat_mapping.sorted.bam

	#Assembly transcripts to produce gtf file using stringtie based on each bam file#
	stringtie -p $NSLOTS -o SRR${i}.1.gtf -l SRR${i}.1 SRR${i}.1.hisat_mapping.sorted.bam
done

#Produce the merge list that contain all of gtf file(然后利用软件stringtie将12个含有转录本信息的gtf文件合并成一个gtf，此时需要预先将12个GTF文件的文件名录入到mergelist.txt文件中)#
for i in *.gtf;do echo $i >> mergelist.txt;done

#Merge all of gtf files to produce merged gtf file using stringtie#
stringtie --merge -p $NSLOTS -o stringtie.merged.gtf mergelist.txt



