FROM python:3.11-slim

# Install required system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libgl1 \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/JaidedAI/EasyOCR/releases/download/v1.3/english_g2.zip
RUN wget https://github.com/JaidedAI/EasyOCR/releases/download/pre-v1.1.6/craft_mlt_25k.zip
RUN wget https://github.com/JaidedAl/EasyOCR/releases/download/pre-v1.1.6/arabic.zip
RUN mkdir ~/.EasyOCR
RUN mkdir ~/.EasyOCR/model
RUN unzip english_g2.zip -d ~/.EasyOCR/model
RUN unzip arabic_g1.zip -d ~/.EasyOCR/model
RUN unzip craft_mlt_25k.zip -d ~/.EasyOCR/model

WORKDIR /app

COPY . /app

RUN chmod -R 777 /app

# Install Python dependencies
RUN pip install -r requirements.txt \
    Flask[async]

# Command to run your application
CMD ["python", "working.py"]
