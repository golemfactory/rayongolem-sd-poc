import argparse
from datetime import datetime, timezone

from diffusers import StableDiffusionPipeline

parser = argparse.ArgumentParser()
parser.add_argument("prompt")
args = parser.parse_args()

pipe = StableDiffusionPipeline.from_pretrained("./stable-diffusion-v1-5")
pipe = pipe.to("cuda")

img = pipe(args.prompt).images[0]

current_time_str = datetime.now(tz=timezone.utc).strftime("%Y%m%d_%H%M%S%z")
filename = f"out-{current_time_str}.jpg"

print(filename)
img.save(filename)
