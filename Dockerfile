FROM python:3.11-slim

# Install git and curl
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:/root/.cargo/bin:$PATH"
RUN mv /root/.cargo/bin/uv /usr/local/bin/uv || mv /root/.local/bin/uv /usr/local/bin/uv || echo "uv location check"

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install any additional requirements if they exist
RUN if [ -f requirements.txt ]; then uv pip install --system -r requirements.txt; fi

# Copy entrypoint script
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "tests/test_imports.py"]