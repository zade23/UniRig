FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && \
    apt-get install -y git wget curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy only requirements file first to leverage Docker layer caching
COPY requirements.txt ./

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir torch torchvision numpy==1.26.4 packaging

# Install all requirements except flash_attn
RUN grep -v "^flash_attn" requirements.txt > reqs.txt && \
    pip install --no-cache-dir -r reqs.txt && \
    rm reqs.txt

# Install flash_attn separately so errors surface clearly
RUN pip install --no-cache-dir flash_attn

# Copy the rest of the repository
COPY . .

# Additional packages that require CUDA specific wheels
# Uncomment and adjust CUDA/Torch versions if GPU support is needed
# RUN pip install --no-cache-dir spconv-cu117
# RUN pip install --no-cache-dir torch_scatter torch_cluster -f https://data.pyg.org/whl/torch-2.3.0+cu117.html

CMD ["bash", "launch/inference/generate_skeleton.sh", "--input", "examples/giraffe.glb", "--output", "results/giraffe_skeleton.fbx"]
