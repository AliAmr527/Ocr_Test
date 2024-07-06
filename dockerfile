FROM python:3.11-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

RUN chmod -R 777 /app

# Install Python dependencies
RUN pip install -r requirements.txt \
    Flask[async]
# Create directory for EasyOCR models and download them using curl
RUN mkdir -p /app/easyocr_model && \
    cd /app/easyocr_model && \
    curl -L -o english_g2.zip https://github.com/JaidedAI/EasyOCR/releases/download/v1.3/english_g2.zip && \
    curl -L -o craft.zip https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/craft_mlt_25k.zip && \
    curl -L -o arabic.zip https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/arabic.zip && \
    unzip english_g2.zip && \
    unzip craft.zip && \
    unzip arabic.zip && \
    rm english_g2.zip craft.zip arabic.zip

# Set environment variable to fix EasyOCR permission issue
ENV HOME=/app

# Command to run your application
CMD ["python", "working.py"]
