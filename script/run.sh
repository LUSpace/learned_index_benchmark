homedir="/research/dept7/ericlo_hpc/learned_index_benchmark"
st_index="lipp artunsync alex btree hot pgm masstree wormhole_u64 xindex"
mt_index="alexol btreeolc hotrowex artolc masstree wormhole_u64 xindex lippol"
mem_index="alex lipp artunsync btree hot pgm"
range_index="alex btree pgm lipp hot"
datasets_full="covid_tweets_200M_uint64 biology_200M_uint64 osm_cellids_200M_uint64 planet_features_osm_id_200M_uint64 wise_all_sky_data_htm_200M_uint64 libraries_io_repository_dependencies_200M_uint64 books_200M_uint64 fb_200M_uint64 stovf_vote_id_200M_uint64 osm_history_node_200M_uint64"
datasets_light="covid_tweets_200M_uint64 biology_200M_uint64 osm_cellids_200M_uint64 libraries_io_repository_dependencies_200M_uint64"
datasets_excl="planet_features_osm_id_200M_uint64 wise_all_sky_data_htm_200M_uint64 books_200M_uint64 fb_200M_uint64 stovf_vote_id_200M_uint64 osm_history_node_200M_uint64"
workloads=(1 0.5 0)
parallel_core=("0-23" "24-47" "48-71" "72-95")
slurm=$1

datasets=$datasets_light

sequential() {
	tn=$1
	filename=$2
	pin=$3
	cores=$4
	# indexes=$4
	if (($tn > 1)); then
		indexes=$mt_index
	else
		indexes=$st_index
	fi
	if (($tn > 24)); then
		args="--interleave=${pin} -C ${cores}"
	else
		args="-N ${pin} -C ${cores} -l"
	fi
	for index in $indexes
	do
		for dataset in $datasets
		do
			numactl ${args} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=1 --insert=0 --operations_num=800000000 --table_size=-1 --init_table_ratio=1 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv 
		done
		for((j=0;j<2;j++))
		do
			write_ratio=${workloads[j]}
			read_ratio=${workloads[${#workloads[@]}-j-1]}
			for dataset in $datasets
			do
				numactl ${args} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=${read_ratio} --insert=${write_ratio} --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv 
			done
		done
	done
}

parallel() {
	tn=$1
	filename=$2
	if (($tn > 1)); then
		indexes=$mt_index
	else
		indexes=$st_index
	fi
	for index in $indexes
	do
		i=0
		for dataset in $datasets
		do
			numactl -N $i -l -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=1 --insert=0 --operations_num=800000000 --table_size=-1 --init_table_ratio=1 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
		for((j=0;j<2;j++))
		do
			write_ratio=${workloads[j]}
			read_ratio=${workloads[${#workloads[@]}-j-1]}
			i=0
			for dataset in $datasets
			do
				numactl -N $i -l -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=${read_ratio} --insert=${write_ratio} --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv &
				((i++))
				if (($i == 4)); then
					wait
					i=0
				fi
			done
			wait
		done
	done
}

parallel_ht() {
	tn=$1
	filename=$2
	if (($tn > 1)); then
		indexes=$mt_index
	else
		indexes=$st_index
	fi
	for index in $indexes
	do
		i=0
		for dataset in $datasets
		do
			numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=1 --insert=0 --operations_num=800000000 --table_size=-1 --init_table_ratio=1 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
		for((j=0;j<2;j++))
		do
			write_ratio=${workloads[j]}
			read_ratio=${workloads[${#workloads[@]}-j-1]}
			i=0
			for dataset in $datasets
			do
				numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=${read_ratio} --insert=${write_ratio} --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv &
				((i++))
				if (($i == 4)); then
					wait
					i=0
				fi
			done
			wait
		done
	done
}

latency_parallel() {
	tn=$1
	filename=$2
	if (($tn > 1)); then
		indexes=$mt_index
	else
		indexes=$st_index
	fi
	for index in $indexes
	do
		i=0
		for dataset in $datasets
		do
			numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=1 --insert=0 --operations_num=800000000 --table_size=-1 --init_table_ratio=1 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv --latency_sample --latency_sample_ratio=0.01 &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
		for dataset in $datasets
		do
			numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=0 --insert=1 --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv --latency_sample --latency_sample_ratio=0.01 &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
	done
}

memory_parallel() {
	tn=$1

	for index in $mem_index
	do
		i=0
		for dataset in $datasets
		do
			numactl -N $i -l -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=0 --insert=1 --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --memory --output_path=$homedir/result/real/mem.csv &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
	done
}

range_parallel() {
	tn=$1
	filename=$2
	if (($tn > 1)); then
		indexes="alexol hotrowex btreeolc xindex"
	else
		indexes=$range_index
	fi
	for index in $indexes
	do
		for range in 10 100 1000 10000 100000
		do
			i=0
			for dataset in $datasets
			do
				numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=0 --insert=0 --scan=1 --scan_num=${range} --operations_num=10000000 --table_size=-1 --init_table_ratio=1 --thread_num=${tn} --index_type=${index} --output_path=$homedir/result/real/${filename}.csv &
				((i++))
				if (($i == 4)); then
					wait
					i=0
				fi
			done
			wait
		done
	done
}

datashift_parallel() {
	tn=$1
	filename=$2
	if (($tn > 1)); then
		indexes=$mt_index
	else
		indexes=$st_index
	fi
	for index in $indexes
	do
		i=0
		for dataset in covid_osm_sd_200M_uint64 covid_biology_sd_200M_uint64 osm_covid_sd_200M_uint64 biology_covid_sd_200M_uint64
		do
			numactl -N $i -l -C ${parallel_core[$i]} -- $homedir/build/microbench --keys_file=$homedir/resources/${dataset} --keys_file_type=binary --read=0.5 --insert=0.5 --operations_num=800000000 --table_size=-1 --init_table_ratio=0.5 --thread_num=${tn} --index_type=${index} --data_shift --output_path=$homedir/result/real/${filename}.csv &
			((i++))
			if (($i == 4)); then
				wait
				i=0
			fi
		done
		wait
	done
}
