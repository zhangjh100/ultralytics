#!/bin/bash

# Script: Train YOLOv8 models on a specified dataset with default or user-provided settings.
# Usage: bash tools/train.sh --dataset <dataset_name> 
# [optional: --epochs <num_epochs> --batch <batch_size> --img-size <image_size> --device <device> --models <model_list>] 

# Default training settings
dataset=ap10k
epochs=1000
batch_size=-1
imgsz=640
device=None
cos_lr=true
resume=true

# Ensure a dataset name is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [--dataset <dataset_name>] [--epochs <num_epochs>] [--batch <batch_size>] [--imgsz <image_size>] [--device <device>] [--models <model_list>]"
    exit 1
fi

# Parse optional arguments
while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
        --dataset)
            dataset="$2"
            shift
            ;;
        --epochs)
            epochs="$2"
            shift
            ;;
        --batch)
            batch_size="$2"
            shift
            ;;
        --imgsz)
            imgsz="$2"
            shift
            ;;
        --device)
            device="$2"
            shift
            ;;
        --models)
            IFS=',' read -ra selected_models <<< "$2"
            shift
            ;;
        *)  # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Set models based on selection
models=()
if [ -z "$selected_models" ]; then
    # If no specific models are selected, train all by default
    models=("yolov8n-pose.yaml" "yolov8s-pose.yaml" "yolov8m-pose.yaml" "yolov8l-pose.yaml" "yolov8x-pose.yaml")
else
    # Process selected models
    for model_code in "${selected_models[@]}"; do
        case $model_code in
            n)
                models+=("yolov8n-pose.yaml")
                ;;
            s)
                models+=("yolov8s-pose.yaml")
                ;;
            m)
                models+=("yolov8m-pose.yaml")
                ;;
            l)
                models+=("yolov8l-pose.yaml")
                ;;
            x)
                models+=("yolov8x-pose.yaml")
                ;;
            *)
                echo "Warning: Ignoring invalid model code in selection: $model_code. Valid codes are n, s, m, l, x."
                ;;
        esac
    done
fi

# Check if any valid models have been selected
if [ ${#models[@]} -eq 0 ]; then
    echo "Error: No valid model selected after processing input. Please choose from n, s, m, l, x, or leave empty to train all."
    exit 1
fi

# Loop through each model for the given dataset
for model_yaml in "${models[@]}"; do
    pretrained_model="${model_yaml%.yaml}.pt"
    model_name="${dataset}-${model_yaml%.yaml}"
    output_dir="./runs/pose/$dataset"

    # Ensure the pretrained model exists before attempting to train
    if [ ! -f "./weights/$pretrained_model" ]; then
        echo "Pretrained model $pretrained_model not found. Skipping..."
        pretrained_model=None
        continue
    fi

    # Launch YOLOv8 pose training command
    echo "Training $model_yaml on $dataset..."
    yolo pose train \
        data=./configs/data/"$dataset".yaml \
        model=./configs/models/"$dataset"/"$model_yaml" \
        pretrained=$pretrained_model \
        epochs=$epochs \
        imgsz=$imgsz \
        batch=$batch_size \
        project=$output_dir \
        name=$model_name \
        device=$device \
        cos_lr=$cos_lr \
        resume=$resume
done