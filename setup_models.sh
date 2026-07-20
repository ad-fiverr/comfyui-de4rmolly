#!/bin/bash
# =============================================================================
# setup_models.sh - Configuración de Modelos AsmitB
# =============================================================================

# Token actualizado según tu solicitud
HF_TOKEN="${HF_TOKEN}"
HF_TOKEN_loras="${HF_TOKEN_loras}"
COMFYUI_DIR="/workspace/ComfyUI"

echo "================================================"
echo "  ComfyUI Model Setup — De4rmolly Edition"
echo "  THANKS FOR YOUR ORDER, ADRIANFIVERR"
echo "================================================"

# PASO 1: Persistencia de ComfyUI
if [ ! -f "${COMFYUI_DIR}/main.py" ]; then
    echo "[ Copiando ComfyUI base a /workspace... ]"
    mkdir -p ${COMFYUI_DIR}
    cp -rn /ComfyUI/. ${COMFYUI_DIR}/
fi

# PASO 2: Preparar Directorios
mkdir -p ${COMFYUI_DIR}/models/loras \
         ${COMFYUI_DIR}/models/checkpoints \
         ${COMFYUI_DIR}/models/diffusion_models \
         ${COMFYUI_DIR}/models/text_encoders \
         ${COMFYUI_DIR}/models/upscale_models \
         ${COMFYUI_DIR}/models/vae \
         ${COMFYUI_DIR}/models/ultralytics/bbox \
         ${COMFYUI_DIR}/models/ultralytics/segm \
         ${COMFYUI_DIR}/models/loras/
         ${COMFYUI_DIR}/models/sams \
         ${COMFYUI_DIR}/models/sam3 
         

# ── Funciones de descarga ─────────────────────────────────────────────────────

download_if_missing() {
    local url="$1" dest="$2" auth="$3"
    if [ -f "$dest" ] && [ -s "$dest" ]; then return 0; fi
    echo "  Descargando: $(basename $dest)"
    if [ -n "$auth" ]; then
        wget -q --show-progress --header="Authorization: Bearer $auth" -O "$dest" "$url"
    else
        wget -q --show-progress -O "$dest" "$url"
    fi
}

download_gdown_if_missing() {
    local file_id="$1" dest="$2"
    
    # Verifica si el archivo ya existe y pesa más de 5MB para no volver a descargarlo
    if [ -f "$dest" ] && [ $(find "$dest" -type f -size +5M 2>/dev/null) ]; then 
        return 0; 
    fi
    
    echo "  Descargando desde Drive: $(basename $dest)"
    gdown "$file_id" -O "$dest"
}

download_hf_repo() {
    local repo="$1" dest_dir="$2"
    echo "  Descargando repo HF: $repo en $dest_dir"
    HF_TOKEN=${HF_TOKEN} huggingface-cli download "$repo" --local-dir "$dest_dir" --local-dir-use-symlinks False
}

echo "Instalando huggingface_hub..."
pip install -U huggingface_hub

echo "Auth with Hugging Face..."
# Usamos el comando de Python para el login con el token proporcionado
python3 -c "from huggingface_hub import login; login(token='$HF_TOKEN')"

# ── SECCIÓN DE DESCARGAS (Nuevos Comandos Integrados) ─────────────────────────



# --- DIFFUSION MODELS ---
echo "[ ------- Downloading Diffusion Models -------]"
cd ${COMFYUI_DIR}/models/diffusion_models && rm -rf split_files/
download_if_missing "https://civitai.red/api/download/models/3138241?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "Selfora_krea2.safetensors" 

cd ${COMFYUI_DIR}/models/diffusion_models 
download_if_missing "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" \
    "z_image_turbo_bf16.safetensors" "$HF_TOKEN"

cd ${COMFYUI_DIR}/models/diffusion_models 
rm /workspace/ComfyUI/models/diffusion_models/flux-2-klein-9b-fp8.safetensors
download_if_missing "https://huggingface.co/black-forest-labs/FLUX.2-klein-9b-fp8/resolve/main/flux-2-klein-9b-fp8.safetensors" \
    "flux-2-klein-9b-fp8.safetensors" "$HF_TOKEN"





# --- TEXT ENCODERS ---
echo "[ Text Encoders ]"
cd ${COMFYUI_DIR}/models/text_encoders && rm -rf split_files/
download_if_missing "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
    "qwen_3_4b.safetensors" "$HF_TOKEN"
download_if_missing "https://huggingface.co/AlperKTS/Krea2_FP8/resolve/main/qwen3vl_4b_fp8_scaled.safetensors" \
    "qwen3vl_4b_fp8_scaled.safetensors" "$HF_TOKEN"


# ------------------------------ LORAS ---
echo "[ LoRAs ]"
cd ${COMFYUI_DIR}/models/loras && rm -rf split_files/
echo "Cleaning folder files..."
cd ${COMFYUI_DIR}/models/loras/

echo "START DOWNLOAD LORAS..."

# ── Z IMAGE DE4RMOLLY LORA FILE ──
download_if_missing "https://huggingface.co/exjadev/de4rmolly-zimage-v001/resolve/main/de4rmolly_v01/de4rmolly_v01_000001500.safetensors"  \
    "de4rmolly_v01/de4rmolly_v01_000001500.safetensors"
download_if_missing "https://huggingface.co/exjadev/de4rmolly-zimage-v001/resolve/main/de4rmolly_v01/de4rmolly_v01_000002550.safetensors"  \
    "de4rmolly_v01/de4rmolly_v01_000002550.safetensors"

# ── Krea 2 DE4RMOLLY LORA FILE ──
download_if_missing "https://huggingface.co/exjadev/de4rmolly-krea-v001/resolve/main/de4rmolly_krea_v002/de4rmolly_krea_v002_000001500.safetensors" \
    "de4rmolly_krea_v002_000001500.safetensors"
download_if_missing "https://huggingface.co/exjadev/de4rmolly-krea-v001/resolve/main/de4rmolly_krea_v002/de4rmolly_krea_v002_000002100.safetensors" \
    "de4rmolly_krea_v002/de4rmolly_krea_v002_000002100.safetensors"


# Civitai filters & loras
download_if_missing "https://civitai.red/api/download/models/3067151?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "krea2filterbypass3.safetensors"

download_if_missing "https://civitai.red/api/download/models/3113304?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "JPEGCompressionKrea2_c1-st5000.safetensors"



# --- VAE ---
echo "[ VAE ]"
cd ${COMFYUI_DIR}/models/vae && rm -rf split_files/
download_if_missing "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" \
    "ae.safetensors"
download_if_missing "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" \
    "flux2-vae.safetensors"
download_if_missing "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors" \
    "Wan2_1_VAE_bf16.safetensors"




(
# ── BBOX Ultralytics ──────────────────────────────────────────────────────────
echo ""
echo "[ ----------Downloading LoRas --------------]"

download_if_missing "https://civitai.red/api/download/models/2749020?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "NippleDiffusion.safetensors"

download_if_missing "https://civitai.red/api/download/models/2960754?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "PussyDiffusion.safetensors"

download_if_missing "https://civitai.red/api/download/models/2617751?type=Model&format=SafeTensor&token=e3a803e3831ec4832fd75d014b2d385e" \
    "Realistic_Nudes.safetensors"

download_if_missing "https://civitai.red/api/download/models/2617751?type=Model&format=SafeTensor&size=full&fp=fp16&token=e3a803e3831ec4832fd75d014b2d385e" \
    "realisticSnapshot.safetensors"



# ── BBOX Ultralytics ──────────────────────────────────────────────────────────
echo ""
echo "[ BBOX Ultralytics ]"
cd ${COMFYUI_DIR}/models/ultralytics/bbox && rm -rf split_files/
download_if_missing "https://huggingface.co/Bingsu/adetailer/resolve/main/face_yolov8m.pt" \
    "face_yolov8m.pt"
download_if_missing "https://huggingface.co/ashllay/YOLO_Models/resolve/main/bbox/female_breast-v4.2.pt" \
    "female_breast-v4.2.pt"
download_if_missing "https://huggingface.co/ashllay/YOLO_Models/resolve/main/bbox/vagina-v3.2.pt" \
    "vagina-v3.2.pt"
download_if_missing "https://huggingface.co/ashllay/YOLO_Models/resolve/main/bbox/full_eyes_detect_v1.pt" \
    "full_eyes_detect_v1.pt"
download_if_missing "https://huggingface.co/xingren23/comfyflow-models/resolve/976de8449674de379b02c144d0b3cfa2b61482f2/ultralytics/bbox/hand_yolov8s.pt" \
    "hand_yolov8s.pt"


echo "[-----------  Downloading BBOX Ultralytics SEGM -----------  ]"
cd ${COMFYUI_DIR}/models/ultralytics/segm
download_if_missing "https://huggingface.co/Bingsu/adetailer/resolve/main/person_yolov8m-seg.pt" \
    "person_yolov8m-seg.pt"


# ── Upscaler Models ──────────────────────────────────────────────────────────
echo ""
echo "[ -----------  Downloading Upscaler Models  ----------- ]"
cd ${COMFYUI_DIR}/models/upscale_models && rm -rf split_files/
download_if_missing "https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth" \
    "4x_foolhardy_Remacri.pth"

download_gdown_if_missing "1N3ysO2IWkouzy4aFONLgYUjaUMrLz8AB" "4xFFHQDAT.pth"

# --- SAM3 ---
echo "[ ----------- Downloading SAM3 -----------  ]"
cd ${COMFYUI_DIR}/models/sam3
download_if_missing "https://huggingface.co/facebook/sam3/resolve/main/sam3.pt" \
    "sam3.pt" "$HF_TOKEN"


    # ── SAMS (ReActor/Segment Anything) ──────────────────────────────────────────
echo "[ SAM3 ]"
cd ${COMFYUI_DIR}/models/sams
download_if_missing "https://huggingface.co/datasets/Gourieff/ReActor/resolve/main/models/sams/sam_vit_b_01ec64.pth" \
    "sam_vit_b_01ec64.pth" 

download_if_missing "https://huggingface.co/HCMUE-Research/SAM-vit-h/resolve/main/sam_vit_h_4b8939.pth" \
    "sam_vit_h_4b8939.pth" 

) &

# ── Lanzar ComfyUI ────────────────────────────────────────────────────────────
echo ""
echo "================================================"
echo "  Setup full. starting ComfyUI..."
echo "================================================"

chmod -R 777 /workspace/ComfyUI

exec python /workspace/ComfyUI/main.py --listen 0.0.0.0 --port 8188 --enable-manager