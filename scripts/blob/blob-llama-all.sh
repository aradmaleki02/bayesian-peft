modelwrapper=blob
model=meta-llama/Llama-2-7b-hf
eps=0.05
beta=0.2
kllr=0.01
gamma=8

for dataset in winogrande_s ARC-Challenge ARC-Easy winogrande_m obqa boolq
do
for sample in 10
do
for seed in 1 2 3
do 
    name=$modelwrapper-$dataset-sample$sample-eps$eps-kllr$kllr-beta$beta-gamma$gamma-seed$seed
    python -m accelerate.commands.launch --num_processes=2 --gpu_ids="0,1" --main_process_port=40000 run/main.py --dataset-type mcdataset --dataset $dataset \
    --model-type causallm --model $model --modelwrapper $modelwrapper \
    --lr 1e-4 --batch-size 4 \
    --opt adamw --warmup-ratio 0.06 \
    --max-seq-len 300 \
    --seed $seed \
    --wandb-name $name  --wandb-project "BLoB-llama-all"  \
    --apply-classhead-lora --lora-r 8 --lora-alpha 16 --lora-dropout 0 \
    --log-path $name \
    --max-train-steps 5000 \
    --eval-per-steps 6000 \
    --bayes-klreweighting \
    --bayes-eps $eps --bayes-beta $beta --bayes-gamma $gamma --bayes-kllr $kllr \
    --bayes-train-n-samples 1 --bayes-eval-n-samples $sample --bayes-eval-n-samples-final $sample
done
done
done