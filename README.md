# Arbor + DSPy Test Environment

Docker setup for testing with [Arbor](https://github.com/Ziems/arbor) and [DSPy](https://github.com/stanfordnlp/dspy) libraries.

## Quick Start

1. **Setup local repositories:**
   ```bash
   ./scripts/setup_repos.sh
   ```

2. **Build and run:**
   ```bash
   docker build -t arbor-test .
   docker run -v $(pwd)/repos:/app/repos arbor-test
   ```

## Usage

**Run import test (default):**
```bash
docker run -v $(pwd)/repos:/app/repos arbor-test
```

**Run banking classification test:**
```bash
docker run -v $(pwd)/repos:/app/repos arbor-test python tests/test_banking_classification.py
```

**Run with Arbor server:**
```bash
docker run -e START_ARBOR=true -v $(pwd)/repos:/app/repos arbor-test python tests/test_banking_classification.py
```

**Run with custom Arbor config:**
```bash
docker run -e START_ARBOR=true -e ARBOR_CONFIG=/app/config.yaml \
  -v $(pwd)/repos:/app/repos \
  -v $(pwd)/arbor-config.yaml:/app/config.yaml \
  arbor-test python tests/test_banking_classification.py
```

**Update libraries:**
```bash
cd repos/arbor && git pull
cd ../dspy && git pull
```

## Structure

- `scripts/` - Setup and entrypoint scripts
- `tests/` - Test scripts for both libraries
- `repos/` - Local git repositories (created by setup script)
