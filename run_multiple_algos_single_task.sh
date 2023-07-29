#!/bin/bash


# Declare a string array with type
declare -a ALGORITHMS=("bfs" "articulation_points" "bridges")

declare -a ALGORITHMS=("articulation_points")

SEEDS_TO_CONSIDER=($(seq 1 1 1)) # start step stop

SEEDS_TO_CONSIDER=(10 12 24 52 36)

# for ((seed=1; seed <= SEEDS_TO_CONSIDER; seed++));
# do
#     echo $seed
# done

TRAIN_STEPS=10000
TEST_FILE=\'\' # default value is the empty string

HINT_MODE="none"

EARLY_STOPPING=20

FORCE=0

TEST_SIZE=-1

while getopts ":o:e:t:m:n:f:s:g:" opt; do
    case $opt in
        o)
            OUTPUT_PREFIX=$OPTARG;;
            
        e)
            # number of epochs
            TRAIN_STEPS=$OPTARG;;

        t)
            TEST_FILE=$OPTARG;;

        m)
            HINT_MODE=$OPTARG;;

        s)
            TEST_SIZE=$OPTARG;;
        
        g) 
            SEEDS_TO_CONSIDER=$OPTARG;;

        n)
            EARLY_STOPPING=$OPTARG;;
        f)
            FORCE=$OPTARG;;

        \?)
            echo "Invalid parameter!"
            exit;;
    esac
done


if [[ ${OUTPUT_PREFIX: -1} == "/" ]] # delete last "/" sign
then
    OUTPUT_PREFIX=${OUTPUT_PREFIX::-1}
fi


# launch single task learning for every algorithm
for algo in "${ALGORITHMS[@]}"; 
do
    for seed in "${SEEDS_TO_CONSIDER[@]}";
    do
        # seed=$RANDOM

        echo "Training the model for $algo with seed $seed"
        output_path="${OUTPUT_PREFIX}/${algo}/seed_${seed}"
        # sleep 1

        

        CLRS_OPTIONS=("--algorithms" $algo 
                    "--train_steps" $TRAIN_STEPS 
                    "--test_from_file" $TEST_FILE 
                    "--checkpoint_path" $output_path
                    "--hint_mode" $HINT_MODE
                    "--seed" $seed
                    "--test_size" $TEST_SIZE
                    )

        if [[ $FORCE -eq 1 ]]
        then 
            CLRS_OPTIONS+=("--force")
        fi

        echo "${CLRS_OPTIONS[@]}"

        python3 clrs/examples/run.py "${CLRS_OPTIONS[@]}"

        echo "Completed training the model for $algo"
        # sleep 1
    done
done


# if only test - run algorithms with provided model parameters for each of the algorithm

# accumulate logs in single file - will be stored at $OUTPUT_PREFIX in .csv format

PATTERN="${OUTPUT_PREFIX}/*/*/val_test_dump.json"
# echo $PATTERN
python3 clrs/examples/join_dumps_from_multiple_single_tasks.py --files $PATTERN --outdir $OUTPUT_PREFIX