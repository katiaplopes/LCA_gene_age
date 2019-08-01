export PATH=/home/katia:$PATH

cumula100="/home/katia/Documentos/biodados/cumula_data_rnaseq/exp100"
cumula500="/home/katia/Documentos/biodados/cumula_data_rnaseq/exp500"

tissues=("ovary" "cerebral_cortex" "lung" "pancreas" "placenta" "prostate" "skin" "testis")

for x in ${tissues[@]}
do
        mysql -u root -e "select * from ref_${x}_lca1 where ${x} > 100 group by uniprot;" rnaseq_embl > $cumula100/${x}_exp100.txt
done

for x in ${tissues[@]}
do
        mysql -u root -e "select * from ref_${x}_lca1 where ${x} > 500 group by uniprot;" rnaseq_embl > $cumula500/${x}_exp500.txt
done