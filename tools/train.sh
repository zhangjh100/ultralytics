#!/bin/bash

# Define datasets and model directories
datasets=("aniposefly")  # Add more dataset names here
models=("yolov8n-pose.yaml" "yolov8s-pose.yaml" "yolov8m-pose.yaml" "yolov8l-pose.yaml" "yolov8x-pose.yaml" "yolov8x-pose-p6.yaml")

# Train settings
EPOCHS=100
BATCH=-1
IMGSZ=640
DEVICE=None
COS_LR=True
RESUME=False

# Traverse through the list of datasets and models
for dataset in "${datasets[@]}"; do
    for model in "${models[@]}"; do
        # Derive the pre-trained model filename
        pretrained="${model%.yaml}.pt"
        # Construct the training run name
        name="${dataset}-${model%.yaml}"
        project="./runs/pose/$dataset"

        # Launch YOLO pose training command in background
        yolo pose train \
            data=./configs/data/$dataset.yaml \
            model=./configs/models/$dataset/$model \
            pretrained=$pretrained \
            epochs=$EPOCHS \
            imgsz=$IMGSZ \
            batch=$BATCH \
            project=$project \
            name=$name \
            device=$DEVICE \
            cos_lr=$COS_LR \
            resume=$RESUME
    done
done