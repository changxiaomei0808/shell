if [ $# != 3 ];then \
	echo "Usage:"
	echo "shell $0 \$1 \$2 \$3" 
	echo "\$1:基因组注释文件gff格式"
	echo "\$2:生产的bed文件的前缀"
	echo "\$3:基因组文件"
	exit 1;\
fi


cat $1|grep -v "^#"|awk '$3=="gene" {print $1"\t"$4"\t"$5}' > $2.bed
bedtools getfasta -fi $3 -bed $2.bed -fo $2_genome_extracted_gene.fa

