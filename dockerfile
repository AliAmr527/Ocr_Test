FROM python:3.11-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/AliAmr527/Ocr_Test /app

# Set the working directory
WORKDIR /app

# Install Python dependencies
RUN pip install -r requirements.txt \
    Flask[async]

# Command to run your application
CMD ["python", "working.py"]