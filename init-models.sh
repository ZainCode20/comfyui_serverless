#!/usr/bin/env bash
set -euo pipefail

# This must match what RunPod Serverless tells you!
VOL="/runpod-volume"
COMFY="/comfyui"

if [ ! -d "$VOL" ]; then
  echo "ERROR: Network Volume not found at $VOL. Please attach the volume to the endpoint."
  exit 1
fi

# 1) Make ComfyUI use models from the volume
mkdir -p "$VOL/comfyui/models"/{clip,vae,diffusion_models,loras,checkpoints,controlnet,embeddings,upscale_models}

if [ ! -L "$COMFY/models" ]; then
  rm -rf "$COMFY/models"
  ln -s "$VOL/comfyui/models" "$COMFY/models"
fi

# 2) Make ComfyUI use controlnet_aux_ckpts from the volume
AUX_CKPTS="/comfyui/custom_nodes/comfyui_controlnet_aux/ckpts"
VOL_AUX="$VOL/comfyui/controlnet_aux_ckpts"
mkdir -p "$VOL_AUX"

if [ ! -L "$AUX_CKPTS" ]; then
  rm -rf "$AUX_CKPTS"
  ln -s "$VOL_AUX" "$AUX_CKPTS"
fi

# 3) Fallback: Download if missing (Will skip automatically if your Pod downloads finished!)
download_if_missing () {
  local url="$1"
  local relpath="$2"
  local filename="$3"
  local out="$COMFY/$relpath/$filename"

  if [ ! -f "$out" ]; then
    echo "Downloading: $out"
    comfy model download --url "$url" --relative-path "$relpath" --filename "$filename"
  else
    echo "Already present, skipping download: $out"
  fi
}

download_if_missing "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" "models/clip" "qwen_3_8b_fp8mixed.safetensors"
download_if_missing "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" "models/vae" "flux2-vae.safetensors"
download_if_missing "https://huggingface.co/wikeeyang/Flux2-Klein-9B-True-V1/resolve/main/Flux2-Klein-9B-True-bf16.safetensors" "models/diffusion_models" "Flux2-Klein-9B-True-bf16.safetensors"

mkdir -p "$AUX_CKPTS/yzd-v/DWPose" "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5"

if [ ! -f "$AUX_CKPTS/yzd-v/DWPose/yolox_l.onnx" ]; then
  wget -O "$AUX_CKPTS/yzd-v/DWPose/yolox_l.onnx" "https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_l.onnx"
fi

if [ ! -f "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5/dw-ll_ucoco_384_bs5.torchscript.pt" ]; then
  wget -O "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5/dw-ll_ucoco_384_bs5.torchscript.pt" "https://huggingface.co/hr16/DWPose-TorchScript-BatchSize5/resolve/main/dw-ll_ucoco_384_bs5.torchscript.pt"
fi





















# #!/usr/bin/env bash
# set -euo pipefail

# # Network Volume mount path
# VOL="/workspace"
# COMFY="/comfyui"

# if [ ! -d "$VOL" ]; then
#   echo "ERROR: Network Volume not found at $VOL. Please attach the volume to the endpoint."
#   exit 1
# fi

# # 1) Make ComfyUI use models from the volume
# mkdir -p "$VOL/comfyui/models"/{clip,vae,diffusion_models,loras,checkpoints,controlnet,embeddings,upscale_models}

# if [ ! -L "$COMFY/models" ]; then
#   rm -rf "$COMFY/models"
#   ln -s "$VOL/comfyui/models" "$COMFY/models"
# fi

# # 2) Make ComfyUI use controlnet_aux_ckpts from the volume
# AUX_CKPTS="/comfyui/custom_nodes/comfyui_controlnet_aux/ckpts"
# VOL_AUX="$VOL/comfyui/controlnet_aux_ckpts"
# mkdir -p "$VOL_AUX"

# if [ ! -L "$AUX_CKPTS" ]; then
#   rm -rf "$AUX_CKPTS"
#   ln -s "$VOL_AUX" "$AUX_CKPTS"
# fi

# # 3) Fallback: Download if missing (Skips if files already exist on the volume)
# download_if_missing () {
#   local url="$1"
#   local relpath="$2"
#   local filename="$3"
#   local out="$COMFY/$relpath/$filename"

#   if [ ! -f "$out" ]; then
#     echo "Downloading: $out"
#     comfy model download --url "$url" --relative-path "$relpath" --filename "$filename"
#   else
#     echo "Already present, skipping download: $out"
#   fi
# }

# download_if_missing "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" "models/clip" "qwen_3_8b_fp8mixed.safetensors"
# download_if_missing "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" "models/vae" "flux2-vae.safetensors"
# download_if_missing "https://huggingface.co/wikeeyang/Flux2-Klein-9B-True-V1/resolve/main/Flux2-Klein-9B-True-bf16.safetensors" "models/diffusion_models" "Flux2-Klein-9B-True-bf16.safetensors"

# mkdir -p "$AUX_CKPTS/yzd-v/DWPose" "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5"

# if [ ! -f "$AUX_CKPTS/yzd-v/DWPose/yolox_l.onnx" ]; then
#   wget -O "$AUX_CKPTS/yzd-v/DWPose/yolox_l.onnx" "https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_l.onnx"
# fi

# if [ ! -f "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5/dw-ll_ucoco_384_bs5.torchscript.pt" ]; then
#   wget -O "$AUX_CKPTS/hr16/DWPose-TorchScript-BatchSize5/dw-ll_ucoco_384_bs5.torchscript.pt" "https://huggingface.co/hr16/DWPose-TorchScript-BatchSize5/resolve/main/dw-ll_ucoco_384_bs5.torchscript.pt"
# fi
