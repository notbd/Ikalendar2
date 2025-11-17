set -euo pipefail

# Step 1: Generate GIF from input.mov (continue even if this fails)
ffmpeg -i input.mov \
  -vf "fps=40,scale=400:-1:flags=lanczos,split[s0][s1];\
[s0]palettegen=max_colors=64:stats_mode=diff[p];\
[s1][p]paletteuse=dither=none" \
  -loop 0 output.gif || echo "ffmpeg failed, skipping GIF generation"

# Step 2: Optimize the GIF (run regardless of ffmpeg success/failure)
if [ -f "output.gif" ]; then
  gifsicle output.gif -O3 -o output_optimized.gif
  echo "Optimization done → output_optimized.gif"
else
  echo "Warning: output.gif not found, skipping optimization."
fi
