i=0
for eb in 1 2 4 8 16 32 64 128 256 512 1024 2048 4096
do
	numactl -C $i -- bash get_pgm.sh $eb &
	(( i++ ))
done
wait
