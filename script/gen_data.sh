source $(dirname $0)/config.sh

#model_num=1
error_bound=64
table_size=200000000
#variance=1000
seed=1866
max_val=10000000000

cd $PROJECT_HOME/build

#make clean && cmake .. && make -j
for variance in 2500000
do
for model_num in 1000 10000 50000 100000 200000 300000 400000 500000 600000
#for model_num in 12071 80503 326932 523006
do
        echo "begin generate dataset with metric $model_num"
        ./gen_data \
                --keys_file=../resources/pgm"$model_num"_error"$error_bound"_variance${variance}_seed${seed} \
                --error_bound=$error_bound \
                --model_num=$model_num \
                --table_size=$table_size \
                --variance=$variance \
                --seed=$seed \
                --max=$max_val &

done
wait
done
echo "finish generatinng"

