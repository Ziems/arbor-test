FROM python:3.11-slim

# Install git and curl
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install any additional requirements if they exist
RUN if [ -f requirements.txt ]; then uv pip install --system -r requirements.txt; fi

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["python", "test_script.py"]