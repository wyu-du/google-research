#!/bin/bash
#SBATCH --mem=0
#SBATCH --gres=gpu:1
#SBATCH --output=/tmp-network/user/zaemyung-kim/tmp/%j-disco.log
#SBATCH -p gpu

cd /tmp-network/user/zaemyung-kim/google-research/felix

. env/bin/activate

# Please update these paths.
export OUTPUT_DIR=/tmp-network/user/zaemyung-kim/projects/IteraTE/exp/31K
export BERT_BASE_DIR=/tmp-network/user/zaemyung-kim/models/BERT/uncased_L-12_H-768_A-12
export DISCOFUSE_DIR=/tmp-network/user/zaemyung-kim/projects/IteraTE/data/release
export FELIX_CONFIG_DIR=/tmp-network/user/zaemyung-kim/google-research/felix/discofuse
export PREDICTION_FILE=${OUTPUT_DIR}/pred.tsv
# If you wish to use another dataset please switch from input_format=discofuse
# to wikisplit. wikisplit expects tab seperated source target pairs.
# export INPUT_FORMAT="IteraTE_Intent"
export INPUT_FORMAT="IteraTE_Plain"

# If False FelixInsert is used.
export USE_POINTING='True'

# Need to clone: git clone https://github.com/tensorflow/models.git
export PYTHONPATH=$PYTHONPATH:/tmp-network/user/zaemyung-kim/google-models


# # Label map construction
# echo "Constructing vocabulary"
# python phrase_vocabulary_constructor_main.py \
# --output="${OUTPUT_DIR}/label_map.json" \
# --use_pointing="${USE_POINTING}" \
# --do_lower_case="True"

# Preprocess
# echo "Preprocessing data"
# python preprocess_main.py \
#   --input_file="${DISCOFUSE_DIR}/train_sent_for_generation_31K.json" \
#   --input_format="${INPUT_FORMAT}" \
#   --output_file="${OUTPUT_DIR}/train.tfrecord" \
#   --label_map_file="${OUTPUT_DIR}/label_map.json" \
#   --vocab_file="${BERT_BASE_DIR}/vocab.txt" \
#   --do_lower_case="True" \
#   --use_open_vocab="True" \
#   --max_seq_length="128" \
#   --use_pointing="${USE_POINTING}" \
#   --split_on_punc="True"
#
# python preprocess_main.py \
#   --input_file="${DISCOFUSE_DIR}/dev_sent_for_generation_31K.json" \
#   --input_format="${INPUT_FORMAT}" \
#   --output_file="${OUTPUT_DIR}/dev.tfrecord" \
#   --label_map_file="${OUTPUT_DIR}/label_map.json" \
#   --vocab_file="${BERT_BASE_DIR}/vocab.txt" \
#   --do_lower_case="True" \
#   --use_open_vocab="True" \
#   --max_seq_length="128" \
#   --use_pointing="${USE_POINTING}" \
#   --split_on_punc="True"

# Train
echo "Training tagging model"
rm -rf "${OUTPUT_DIR}/model_tagging"
mkdir -p "${OUTPUT_DIR}/model_tagging"
python run_felix.py \
    --train_file="${OUTPUT_DIR}/train.tfrecord" \
    --eval_file="${OUTPUT_DIR}/dev.tfrecord" \
    --model_dir_tagging="${OUTPUT_DIR}/model_tagging" \
    --bert_config_tagging="${FELIX_CONFIG_DIR}/felix_config.json" \
    --max_seq_length=128 \
    --num_train_epochs=20 \
    --train_batch_size="32" \
    --num_train_examples=141707 \
    --num_eval_examples=18404 \
    --eval_batch_size="32" \
    --log_steps="50" \
    --steps_per_loop="50" \
    --train_insertion="False" \
    --use_pointing="${USE_POINTING}" \
    --init_checkpoint="${BERT_BASE_DIR}/bert_model.ckpt" \
    --learning_rate="0.00006" \
    --pointing_weight="1" \
    --use_weighted_labels="True" \

# echo "Training insertion model"
# rm -rf "${OUTPUT_DIR}/model_insertion"
# mkdir "${OUTPUT_DIR}/model_insertion"
# python run_felix.py \
#     --train_file="${OUTPUT_DIR}/train.tfrecord.ins" \
#     --eval_file="${OUTPUT_DIR}/dev.tfrecord.ins" \
#     --model_dir_insertion="${OUTPUT_DIR}/model_insertion" \
#     --bert_config_insertion="${FELIX_CONFIG_DIR}/felix_config.json" \
#     --max_seq_length=128 \
#     --num_train_epochs=20 \
#     --num_train_examples=134683 \
#     --num_eval_examples=17325 \
#     --train_batch_size="32" \
#     --eval_batch_size="32" \
#     --log_steps="100" \
#     --steps_per_loop="100" \
#     --train_insertion="False" \
#     --init_checkpoint="${BERT_BASE_DIR}/bert_model.ckpt" \
#     --use_pointing="${USE_POINTING}" \
#     --learning_rate="0.00006" \
#     --pointing_weight="1" \
#     --train_insertion="True"

# # Predict
# echo "Generating predictions"
#
# python predict_main.py \
# --input_format="${INPUT_FORMAT}" \
# --predict_input_file="${DISCOFUSE_DIR}/test.tsv" \
# --predict_output_file="${PREDICTION_FILE}" \
# --label_map_file="${OUTPUT_DIR}/label_map.json" \
# --vocab_file="${BERT_BASE_DIR}/vocab.txt" \
# --max_seq_length=128 \
# --predict_batch_size=64 \
# --do_lower_case="True" \
# --use_open_vocab="True" \
# --bert_config_tagging="${FELIX_CONFIG_DIR}/felix_config.json" \
# --bert_config_insertion="${FELIX_CONFIG_DIR}/felix_config.json" \
# --model_tagging_filepath="${OUTPUT_DIR}/model_tagging" \
# --model_insertion_filepath="${OUTPUT_DIR}/model_insertion" \
# --use_pointing="${USE_POINTING}"
