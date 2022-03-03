SOCKET_THREAD=24
SOCKET_NUM=4

divide_and_ceiling(){
    perl -MPOSIX -e "print ceil($1/$2);"
}

get_numa_nodes(){
    thread_num=$1
    if [[ $thread_num -gt $SOCKET_THREAD*$SOCKET_NUM ]]
    then
        echo "all"
    else
        requested_socket=$(divide_and_ceiling $thread_num $SOCKET_THREAD)
        if [[ $requested_socket -eq 1 ]]
        then
            echo 0
        else
            echo 0-$(($requested_socket-1))
        fi
    fi
}



get_cpu_nodes(){
    thread_num=$1
    hyper_thread=$2
    start_socket=$3

    if [[ $hyper_thread -eq 1 ]]
    then
      SOCKET_THREAD=48
    fi


    if [[ $start_socket -eq "" ]]
    then
      start_socket=0
    fi

    cpu_string=""

    rest_thread=$thread_num

    if [[ $thread_num -gt $SOCKET_THREAD*$SOCKET_NUM ]]
    then
        echo "all"
    else
        cpu_list=-1
        requested_socket=$(divide_and_ceiling $thread_num $SOCKET_THREAD)
        for((i = $start_socket; i < $((($start_socket+$requested_socket))); i++))
        do
          start_core=`expr $i \* $SOCKET_THREAD`
          end_core=`expr $i \* $SOCKET_THREAD + $SOCKET_THREAD`
          for((core = $start_core; core < $end_core; core++))
          do
            if [[ $rest_thread -eq 0 ]]
            then
              break
            fi

            if [[ $cpu_list -eq -1 ]]
            then
              cpu_list=$core
            else
              cpu_list=$cpu_list,$core
            fi

            rest_thread=`expr $rest_thread - 1`

            if [[ $hyper_thread -eq 1 ]]
            then
              if [[ $rest_thread -eq 0 ]]
              then
                break
              fi
              cpu_list=$cpu_list,`expr 96 + $core`
              rest_thread=`expr $rest_thread - 1`
            fi


          done
        done
        echo $cpu_list

    fi
}