#!/bin/bash

# Script: Train YOLOv8 models on a specified dataset with default or user-provided settings.
# Usage: bash tools/val.sh \ 
# --dataset <datase_name> \
# --img-size <image_size> \
# --batch <batch_size> \
# --save-json \
# --save-hybrid \    # save model in ONNX and TorchScript formats
# --conf <conf_thresh> \
# --iou <iou_thresh> \
# --max-det <max_detections> \
# --half \
# --device <device> \
# --dnn \
# --plots \
# --rect \
# --split <split_name> \

dataset=ap10k
imgsz=640
batch=16
device=None
save_json=False
save_hybrid=False
conf=0.001
iou=0.6
max_det=300
half=True
device=None
dnn=False
plots=False
rect=False
split=test

# Ensure a dataset name is provided
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 [--dataset <datase_name> --img-size <image_size> --batch <batch_size> --save-json --save-hybrid --conf <conf_thresh> --iou <iou_thresh> --max-det <max_detections> --half --device <device> --dnn --plots --rect --split <split_name>]"
    exit 1
fi

# Parse optional arguments
while [[ $# -gt 1 ]]; do
    key="$1"
    case $key in
        --dataset)
            dataset="$2"
            shift # past argument
            ;;
        --img-size)
            imgsz="$2"
            shift # past argument
            ;;
        --batch)
            batch="$2"
            shift # past argument
            ;;
        --save-json)
            save_json=True
            ;;
        --save-hybrid)
            save_hybrid=True
            ;;
        --conf)
            conf="$2"
            shift # past argument
            ;;
        --iou)
            iou="$2"
            shift # past argument
            ;;
        --max-det)
            max_det="$2"
            shift # past argument
            ;;
        --half)
            half=True
            ;;
        --device)
            device="$2"
            shift # past argument
            ;;
        --dnn)
            dnn=True
            ;;
        --plots)
            plots=True
            ;;
        --rect)
            rect=True
            ;;
        --split)
            split="$2"
            shift # past argument
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
    
    model_name="${default_dataset}-${model_yaml%.yaml}"
    output_dir="./runs/pose/$default_dataset"
    model=$output_dir/weights/best.pt

    # Launch YOLOv8 pose evaluation command
    echo "Evaluating  $model_yaml on $dataset..."
    yolo pose val \
        model=$model \
        data=./configs/data/"$dataset".yaml \
        imgsz=$imgsz \
        batch=$batch \
        project=$output_dir \
        name=$model_name \
        device=$device \
        conf=$conf \
        iou=$iou \
        max_det=$max_det \
        half=$half \
        save_json=$save_json \
        save_hybrid=$save_hybrid \
        dnn=$dnn \
        plots=$plots \
        rect=$rect \
        split=$split \
done