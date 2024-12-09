modelwrapper=mcdropout
model=roberta-base

for dataset in rte mrpc wic cola boolq; do
    for sample in 10; do
        for seed in 1 2 3; do
            name=$modelwrapper-$dataset-sample$sample-seed$seed
            python -m accelerate.commands.launch --num_processes=4 --gpu_ids="0,1,2,3" --main_process_port=29501 run/main.py --dataset-type bertds --dataset $dataset --model $model \
                --model-type seqcls --model $model --modelwrapper $modelwrapper \
                --lr 5e-4 --batch-size 32 \
                --opt adamw --warmup-ratio 0.06 \
                --max-seq-len 256 \
                --seed $seed \
                --wandb-name $name --wandb-project "MCD-roberta-all" \
                --apply-classhead-lora --lora-r 8 --lora-alpha 8 --lora-dropout 0.1 \
                --log-path $name \
                --max-train-steps 5000 \
                --eval-per-steps 6000 \
                --bayes-eval-n-samples $sample --bayes-eval-n-samples-final $sample
        done
    done
done
