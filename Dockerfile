# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.7.1-base

# 1. UPDATE COMFYUI AND INSTALL NEW DEPENDENCIES (like comfy-aimdo!)
RUN git config --global --add safe.directory /comfyui && \
    cd /comfyui && \
    git fetch origin && \
    git reset --hard origin/master && \
    pip install -r requirements.txt

# install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
RUN comfy node install --exit-on-fail cg-use-everywhere@7.8.0 --mode remote
RUN comfy node install --exit-on-fail comfyui_essentials@1.1.0
RUN comfy node install --exit-on-fail comfyui_controlnet_aux@1.1.3
RUN comfy node install --exit-on-fail derfuu_comfyui_moddednodes@1.0.1
RUN comfy node install --exit-on-fail comfyui-easy-use@1.3.6

# 2. THE LANPAINT FIX (Install directly via GitHub URL)
RUN comfy node install --exit-on-fail https://github.com/scraed/LanPaint.git

# --- MODEL DOWNLOADS REMOVED ---
# Models are now safely loaded from the persistent Network Volume at runtime.

# 3. ADD STARTUP SCRIPTS FOR NETWORK VOLUME
COPY init-models.sh /opt/init-models.sh
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/init-models.sh /opt/entrypoint.sh

ENTRYPOINT ["/opt/entrypoint.sh"]
CMD ["python", "-u", "/rp_handler.py"]



















# # clean base image containing only comfyui, comfy-cli and comfyui-manager
# FROM runpod/worker-comfyui:5.7.1-base
# # 1. UPDATE COMFYUI AND INSTALL NEW DEPENDENCIES (like comfy-aimdo!)
# RUN git config --global --add safe.directory /comfyui && \
#     cd /comfyui && \
#     git fetch origin && \
#     git reset --hard origin/master && \
#     pip install -r requirements.txt
# # install custom nodes into comfyui (first node with --mode remote to fetch updated cache)
# RUN comfy node install --exit-on-fail cg-use-everywhere@7.8.0 --mode remote
# RUN comfy node install --exit-on-fail comfyui_essentials@1.1.0
# RUN comfy node install --exit-on-fail comfyui_controlnet_aux@1.1.3
# RUN comfy node install --exit-on-fail derfuu_comfyui_moddednodes@1.0.1
# RUN comfy node install --exit-on-fail comfyui-easy-use@1.3.6
# # RUN comfy node install --exit-on-fail lanpaint@1.5.0
# # 2. THE LANPAINT FIX (This guarantees the KSampler node will load!)
# # 2. THE LANPAINT FIX (Install directly via GitHub URL)
# RUN comfy node install --exit-on-fail https://github.com/scraed/LanPaint.git

# # download models into comfyui
# RUN comfy model download --url https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors --relative-path models/clip --filename qwen_3_8b_fp8mixed.safetensors
# RUN comfy model download --url https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors --relative-path models/vae --filename flux2-vae.safetensors
# RUN comfy model download --url https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_l.onnx --relative-path custom_nodes/comfyui_controlnet_aux/ckpts/yzd-v/DWPose --filename yolox_l.onnx
# RUN comfy model download --url https://huggingface.co/hr16/DWPose-TorchScript-BatchSize5/resolve/main/dw-ll_ucoco_384_bs5.torchscript.pt --relative-path custom_nodes/comfyui_controlnet_aux/ckpts/hr16/DWPose-TorchScript-BatchSize5 --filename dw-ll_ucoco_384_bs5.torchscript.pt
# RUN comfy model download --url https://huggingface.co/wikeeyang/Flux2-Klein-9B-True-V1/resolve/main/Flux2-Klein-9B-True-bf16.safetensors --relative-path models/diffusion_models --filename Flux2-Klein-9B-True-bf16.safetensors

# # copy all input data (like images or videos) into comfyui (uncomment and adjust if needed)
# # COPY input/ /comfyui/input/
