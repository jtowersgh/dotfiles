#!/bin/bash

cd ~/ai/comfyui
source venv/bin/activate

export HIP_VISIBLE_DEVICES=0
export ROCR_VISIBLE_DEVICES=0

python main.py --listen
