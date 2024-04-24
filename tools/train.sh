#!/bin/bash

# Define default train settings
epochs=1000
batch=-1
imgsz=640
device="None"
cos_lr=true
resume=false

# Ensure a dataset name is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 dataset model1 [model2 ...]"
    exit 1
fi

dataset="$1" # The first argument is the dataset name
shift        # Shift arguments to left, so $@ now starts with model names

# Models are predefined
models=("yolov8n-pose.yaml" "yolov8s-pose.yaml" "yolov8m-pose.yaml" "yolov8l-pose.yaml" "yolov8x-pose.yaml" "yolov8x-pose-p6.yaml")

# Loop through each model for the given dataset
for model in "${models[@]}"; do
    # Derive the pre-trained model filename
    pretrained="${model%.yaml}.pt"
    # Construct the training run name
    name="${dataset}-${model%.yaml}"
    project="./runs/pose/$dataset"

    # Launch YOLO pose training command
    yolo pose train \
        data=./configs/data/"$dataset".yaml \
        model=./configs/models/"$dataset"/"$model" \
        pretrained=$pretrained \
        epochs=$epochs \
        imgsz=$imgsz \
        batch=$batch \
        project=$project \
        name=$name \
        device=$device \
        cos_lr=$cos_lr \
        resume=$resume
done