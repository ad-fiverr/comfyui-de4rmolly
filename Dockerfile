FROM ls250824/run-comfyui-image:01072026

ENV DEBIAN_FRONTEND=noninteractive
# ComfyUI ya esta en /ComfyUI en la imagen base
# setup_models.sh lo copiara a /workspace/ComfyUI al primer arranque

RUN apt-get update -qq && apt-get install -y -qq git wget && \
    pip install -q gdown && \
    rm -rf /var/lib/apt/lists/*

# Custom Nodes en /ComfyUI (se copian al workspace en el primer arranque)
RUN cd /ComfyUI/custom_nodes && \
    rm -rf rgthree-comfy ComfyUI-Impact-Pack ComfyUI_essentials ComfyUI-GGUF ComfyUI-Impact-Subpack cg-use-everywhere ComfyMath ComfyUI-mxToolkit comfyui-crystools ComfyUI_LayerStyle ComfyUI_Fill-Nodes ComfyUI-Image-Saver ComfyUI-AdvancedLivePortrait ComfyUI-WanVideoWrapper ComfyUI-Login ComfyUI-login && \
    git clone --depth=1 https://github.com/rgthree/rgthree-comfy && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Pack && \
    git clone --depth=1 https://github.com/cubiq/ComfyUI_essentials && \
    git clone --depth=1 https://github.com/city96/ComfyUI-GGUF && \
    git clone --depth=1 https://github.com/ltdrdata/ComfyUI-Impact-Subpack && \
    git clone --depth=1 https://github.com/evanspearman/ComfyMath && \
    git clone --depth=1 https://github.com/chrisgoringe/cg-use-everywhere && \
    git clone --depth=1 https://github.com/pythongosssss/ComfyUI-Custom-Scripts && \
    git clone --depth=1 https://github.com/Smirnov75/ComfyUI-mxToolkit && \
    git clone --depth=1 https://github.com/crystian/comfyui-crystools && \
    git clone --depth=1 https://github.com/chflame163/ComfyUI_LayerStyle && \
    git clone --depth=1 https://github.com/filliptm/ComfyUI_Fill-Nodes && \
    git clone --depth=1 https://github.com/farizrifqi/ComfyUI-Image-Saver && \
    git clone --depth=1 https://github.com/PowerHouseMan/ComfyUI-AdvancedLivePortrait && \
    git clone --depth=1 https://github.com/kijai/ComfyUI-WanVideoWrapper.git
    

RUN for dir in rgthree-comfy ComfyUI-Impact-Pack ComfyUI_essentials ComfyUI-GGUF ComfyUI-Impact-Subpack cg-use-everywhere ComfyMath ComfyUI-Custom-Scripts ComfyUI-mxToolkit comfyui-crystools ComfyUI_LayerStyle ComfyUI_Fill-Nodes ComfyUI-Image-Saver ComfyUI-AdvancedLivePortrait ComfyUI-WanVideoWrapper; do \
      REQ="/ComfyUI/custom_nodes/${dir}/requirements.txt"; \
      if [ -f "$REQ" ]; then pip install -q -r "$REQ"; fi; \
    done



RUN rm -rf /ComfyUI/custom_nodes/ComfyUI-Login /ComfyUI/custom_nodes/ComfyUI-login


RUN mkdir -p /ComfyUI/user/default/workflows
COPY dearmolly_SFW_Workflow_for_Instagram.json /ComfyUI/user/default/workflows/zimage-sfw-workflow.json
COPY krea2_de4rmolly-workflow.json /ComfyUI/user/default/workflows/Krea-nsfw-workflow.json
COPY SkinRefiner.json /ComfyUI/user/default/workflows/zimage-refiner-workflow.json
COPY SeedVR2_HD_Image_upscale.json /ComfyUI/user/default/workflows/zimage-upscaler-workflow.json



RUN apt-get update -qq && apt-get install -y -qq git wget dos2unix aria2 megatools && \
    pip install -q gdown huggingface_hub comfyui-manager && \
    rm -rf /var/lib/apt/lists/*

ARG HF_TOKEN
ENV HF_TOKEN=${HF_TOKEN}

COPY setup_models.sh /setup_models.sh
RUN dos2unix /setup_models.sh && chmod +x /setup_models.sh


EXPOSE 8188
CMD ["/setup_models.sh"]