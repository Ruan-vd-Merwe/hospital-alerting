# Dev image for hospital-alerting
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    zip unzip curl jq make bash ca-certificates git \
 && rm -rf /var/lib/apt/lists/*

# AWS CLI
RUN pip install --no-cache-dir awscli

# Optional: project Python deps for local tools
COPY requirements.txt /tmp/requirements.txt
RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir -r /tmp/requirements.txt || true

WORKDIR /workspace
ENTRYPOINT ["/bin/bash"]
