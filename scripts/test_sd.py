import argparse
from datetime import datetime, timezone

import ray

from diffusers import StableDiffusionPipeline


@ray.remote(num_gpus=1.0)
class Renderer:
    def __init__(self):
        pipe = StableDiffusionPipeline.from_pretrained("./stable-diffusion-v1-5")
        self.pipe = pipe.to("cuda")

    def render_image(self, i: int, prompt: str):
        img = self.pipe(prompt).images[0]
        return i, img


parser = argparse.ArgumentParser()
parser.add_argument("prompt")
parser.add_argument("-n", "--num-images", type=int, default=1)
args = parser.parse_args()

prompt: str = args.prompt

current_time_str = datetime.now(tz=timezone.utc).strftime("%Y%m%d_%H%M%S%z")
filename = f"{prompt.replace(' ', '-')}-{current_time_str}"

ray.init()

renderer = Renderer.remote()

results = [renderer.render_image.remote(i, args.prompt) for i in range(args.num_images)]

while results:
    ready, results = ray.wait(results, num_returns=1)
    for r in ready:
        i, img = ray.get(r)
        fn = f"{filename}-{i}.jpg"
        print(fn)
        img.save(fn)
