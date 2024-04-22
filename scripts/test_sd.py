import argparse
from datetime import datetime, timezone

import ray

from diffusers import StableDiffusionPipeline


@ray.remote(num_gpus=1.0)
class Renderer:
    def __init__(self):
        pipe = StableDiffusionPipeline.from_pretrained("./stable-diffusion-v1-5")
        self.pipe = pipe.to("cuda")

    def render_image(self, idx: int, i: int, prompt: str):
        img = self.pipe(prompt).images[0]
        return idx, i, img


parser = argparse.ArgumentParser()
parser.add_argument("prompt")
parser.add_argument("-n", "--num-images", type=int, default=1)
args = parser.parse_args()

prompt: str = args.prompt

current_time_str = datetime.now(tz=timezone.utc).strftime("%Y%m%d_%H%M%S%z")
filename = f"{prompt.replace(' ', '-')}-{current_time_str}"

ray.init()

num_gpus = int(ray.cluster_resources().get("GPU"))
print("Available GPUs: ", num_gpus, "vs images to render: ", args.num_images)

renderers = [Renderer.remote() for _ in range(num_gpus)]
renderers_available = [i for i in range(len(renderers))]

img_cnt = 0
img_done = 0

results = []

while img_done < args.num_images:
    for ridx in renderers_available:
        renderers_available.remove(ridx)
        if img_cnt < args.num_images:
            print("scheduling: ", img_cnt, "on: ", ridx)
            results.append(renderers[ridx].render_image.remote(ridx, img_cnt, args.prompt))
        img_cnt += 1

    ready, results = ray.wait(results, num_returns=1)
    for r in ready:
        ridx, i, img = ray.get(r)
        renderers_available.append(ridx)
        fn = f"{filename}-{i}.jpg"
        print(fn)
        img.save(fn)
        img_done += 1
