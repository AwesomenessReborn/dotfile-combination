# nvtop: Build from Source

## Why

The apt-packaged `nvtop` crashes on this machine:

```
nvtop: ./src/extract_gpuinfo_amdgpu.c:964: parse_drm_fdinfo_amd: Assertion `!cache_entry_check && "We should not be processing a client id twice per update"' failed.
zsh: IOT instruction (core dumped)  nvtop
```

This is a known bug where the AMD GPU backend asserts even on NVIDIA-only systems.
The RTX 5070 Ti is too new for the packaged version to handle correctly.

## GPU on this machine

- NVIDIA GeForce RTX 5070 Ti (16GB)
- Driver: 580.126.09, CUDA 13.0
- `nvidia-smi` works fine as a stopgap

## Build instructions

```bash
# 1. Install build dependencies
sudo apt install -y cmake libdrm-dev libsystemd-dev libudev-dev libncurses-dev

# 2. Clone and build
git clone https://github.com/Syllo/nvtop.git /tmp/nvtop
cd /tmp/nvtop && mkdir build && cd build
cmake .. -DNVML_RETRIEVE_HEADER_ONLINE=ON
make

# 3. Install
sudo make install

# 4. Verify
nvtop
```

## Cleanup after

```bash
rm -rf /tmp/nvtop
sudo apt remove -y nvtop  # remove the broken apt version if still installed
```
