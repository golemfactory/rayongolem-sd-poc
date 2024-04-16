ARG BASE
FROM ${BASE}

WORKDIR /app
COPY ray-sd-image/ray-sd.requirements.txt .
RUN pip install -r ray-sd.requirements.txt

RUN GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/runwayml/stable-diffusion-v1-5
WORKDIR stable-diffusion-v1-5
RUN git lfs pull -I "safety_checker/pytorch_model.bin,text_encoder/pytorch_model.bin,unet/diffusion_pytorch_model.bin,vae/diffusion_pytorch_model.bin,v1-5-pruned-emaonly.ckpt"
RUN rm v1-5-pruned.ckpt v1-5-pruned-emaonly.safetensors v1-5-pruned.safetensors \
  safety_checker/model.fp16.safetensors safety_checker/model.safetensors safety_checker/pytorch_model.fp16.bin \
  text_encoder/model.fp16.safetensors text_encoder/model.safetensors text_encoder/pytorch_model.fp16.bin \
  unet/diffusion_pytorch_model.fp16.bin unet/diffusion_pytorch_model.fp16.safetensors unet/diffusion_pytorch_model.non_ema.bin \
  unet/diffusion_pytorch_model.non_ema.safetensors unet/diffusion_pytorch_model.safetensors \
  vae/diffusion_pytorch_model.fp16.bin vae/diffusion_pytorch_model.fp16.safetensors vae/diffusion_pytorch_model.safetensors
RUN rm -r .git .gitattributes

WORKDIR /root