#!/bin/bash

# Script: Train YOLOv8 models on a specified dataset with default or user-provided settings.
# Usage: ./train_yolov8_models.sh <dataset_name> [optional: --epochs <num_epochs> --batch <batch_size> --img-size <image_size> --device <device>] 

# Default training settings
default_dataset=ap10k
default_epochs=1000
default_batch_size=-1
default_image_size=640
default_device=None
default_cosine_lr=true
default_resume_training=true

# Ensure a dataset name is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [--dataset <dataset_name>] [--epochs <num_epochs>] [--batch <batch_size>] [--img-size <image_size>] [--device <device>]"
    exit 1
fi

# Parse optional arguments
while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
        --dataset)
            default_dataset="$2"
            shift
            ;;
        --epochs)
            default_epochs="$2"
            shift
            ;;
        --batch)
            default_batch_size="$2"
            shift
            ;;
        --img-size)
            default_image_size="$2"
            shift
            ;;
        --device)
            default_device="$2"
            shift
            ;;
        *)  # unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
    shift
done

# Predefined models
models=("yolov8n-pose.yaml" "yolov8s-pose.yaml" "yolov8m-pose.yaml" "yolov8l-pose.yaml" "yolov8x-pose.yaml")
# models=("yolov8n-pose.yaml" "yolov8s-pose.yaml" "yolov8m-pose.yaml" "yolov8l-pose.yaml" "yolov8x-pose.yaml" "yolov8x-pose-p6.yaml")
# Loop through each model for the given dataset
for model_yaml in "${models[@]}"; do
    pretrained_model="${model_yaml%.yaml}.pt"
    model_name="${default_dataset}-${model_yaml%.yaml}"
    output_dir="./runs/pose/$default_dataset"

    # Ensure the pretrained model exists before attempting to train
    if [ ! -f "./weights/$pretrained_model" ]; then
        echo "Pretrained model $pretrained_model not found. Skipping..."
        pretrained_model=None
        continue
    fi

    # Launch YOLOv8 pose training command
    echo "Training $model_yaml on $default_dataset..."
    yolo pose train \
        data=./configs/data/"$default_dataset".yaml \
        model=./configs/models/"$default_dataset"/"$model_yaml" \
        pretrained=$pretrained_model \
        epochs=$default_epochs \
        imgsz=$default_image_size \
        batch=$default_batch_size \
        project=$output_dir \
        name=$model_name \
        device=$default_device \
        cos_lr=$default_cosine_lr \
        resume=$default_resume_training
done