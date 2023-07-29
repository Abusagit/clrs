#! /bin/bash
OUTPUT_PREFIX=''
RANDOM_SEEDS_NUMBER=0
while getopts ":o:s:" opt; do
    case $opt in
        o)
            OUTPUT_PREFIX=$OPTARG;;
        s)
            RANDOM_SEEDS_NUMBER=$OPTARG;;
        \?)
            echo "Invalid parameter!"
            exit;;
    esac
done

if [[ $RANDOM_SEEDS_NUMBER -eq 0 ]]
then
    # no hints
    echo "Launching the training with predefined seeds"

    bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/test_from_dataset_no_hints" -m none -f 1 -s -1
    bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/test_from_failed_generator_no_hints" -m none -f 1 -s 64

    #encoded decoded hints
    bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/test_from_dataset_encoded_decoded_hints" -m encoded_decoded -f 1 -s -1
    bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/test_from_failed_generator_encoded_decoded_hints" -m encoded_decoded -f 1 -s 64


else
    for ((seed=1; seed <= RANDOM_SEEDS_NUMBER; seed++));
    do
        echo "Launching the training with seeds set ${seed}"
        sleep 2
        seeds=($(shuf -i 0-1000 -n 5))

        bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/seed_set_${seed}/test_from_dataset_no_hints" -m none -f 1 -s -1 -g $seeds
        bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/seed_set_${seed}/test_from_failed_generator_no_hints" -m none -f 1 -s 64 -g $seeds

        #encoded decoded hints
        bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/seed_set_${seed}/test_from_dataset_encoded_decoded_hints" -m encoded_decoded -f 1 -s -1 -g $seeds
        bash run_multiple_algos_single_task.sh -o "${OUTPUT_PREFIX}/seed_set_${seed}/test_from_failed_generator_encoded_decoded_hints" -m encoded_decoded -f 1 -s 64 -g $seeds


    done    
fi