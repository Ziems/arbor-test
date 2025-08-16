FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    git \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set python3 as default python
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Copy entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["uv", "run", "tests/test_imports.py"]