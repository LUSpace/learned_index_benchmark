eb=$1

datasets=(books_200M_uint64 osm_cellids_200M_uint64 fb_200M_uint64 biology_200M_uint64 wise_all_sky_data_htm_200M_uint64 planet_features_osm_id_200M_uint64 covid_tweets_200M_uint64 yago_triple_194M_uint64 eth_gas_27M_uint64 osm_history_node_200M_uint64)

datasets_32=(wiki_ts_unique_90M_uint32 libraries_io_repository_dependencies_200M_uint32 gnomad_46M_uint32 stovf_vote_48M_uint32)

datasets_64=(wiki_ts_unique_90M_uint64 libraries_io_repository_dependencies_200M_uint64 gnomad_46M_uint64 stovf_vote_48M_uint64)

function run(){
    keys_file=$1
    data_type=$2
    # if [ "$keys_file_type" = "text" ]; then
    #     table_size=$(wc -l ./resources/${keys_file} | cut -d' ' -f1)
    # else
    #     table_size=$(echo ./resources/${keys_file} | awk -F '_' '{print $(NF-1)}' | sed "s/M/000000/g")
    # fi
    # echo $keys_file $table_size
    ../build/microbench --keys_file=../resources/${keys_file} --keys_file_type=binary --read=0.5 --insert=0.5 --operations_num=1000 --init_table_ratio=0.01 --runtime=50 --thread_num=1 --index_type=alex  --sample_distribution=uniform --dataset_statistic --error_bound=$eb --data_type=${data_type} --output_path="../pgm/pgm_${eb}.csv"
}

run stovf_vote_id_200M_uint64 uint64_t
exit 0

for d in "${datasets_64[@]}"
do
    run $d uint64_t
done
for d in "${datasets[@]}"
do
    run $d uint64_t
done
for d in "${datasets_32[@]}"
do
    run $d uint32_t
done
