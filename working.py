import asyncio
from flask import Flask, request, jsonify
import cloudinary
import cloudinary.uploader
from arabic_ocr_online import ocring
import re
import os
import urllib.request
import logging

app = Flask(__name__)

logging.basicConfig(level=logging.DEBUG)


def convert_arabic_to_english_numbers(text):
    arabic_to_english = {
        '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
        '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9'
    }
    return ''.join(arabic_to_english.get(char, char) for char in text)

# Function to extract date parts from a 10-digit string


def extract_date_parts(date_string):
    if len(date_string) == 10 and date_string.isdigit():
        year = date_string[:4]
        month = date_string[5:7]
        day = date_string[8:10]
        return [year, month, day]
    return None

# Async OCR processing function


async def async_process_ocr(image_url, out_image):
    loop = asyncio.get_event_loop()
    return await loop.run_in_executor(None, ocring, image_url, out_image)


@app.route('/ocr/working', methods=['POST'])
async def ocr():
    data = request.json
    logging.debug(f"Received data: {data}")
    image_url = data.get('image_url')
    output_dir = 'output'
    out_image = os.path.join(output_dir, 'out.jpg')
    if not image_url:
        logging.debug("Image URL is missing")
        return jsonify({'error': 'Image URL is required'}), 400

    try:
        # Run OCR asynchronously
        results = await async_process_ocr(image_url, out_image)
        logging.debug(f"OCR results: {results}")

        # Collect and process words
        words = [convert_arabic_to_english_numbers(
            result[1]) for result in results]
        ocr_text = '\n'.join(words)

        # Check for the presence of potential date strings
        date_array = []
        for result in results:
            box, text, confidence = result
            text = convert_arabic_to_english_numbers(text)
            # Try to extract date parts from the string
            # Remove non-digit characters
            date_parts = extract_date_parts(re.sub(r'\D', '', text))
            if date_parts:
                date_array = date_parts
                message = "OCR extraction successful and valid date found."
                break
        else:
            message = "OCR extraction failed. Missing or incorrect validity date. Please upload a clearer image."

        return jsonify({'message': message, 'ocr_text': ocr_text, 'date_array': date_array})

    except Exception as e:
        logging.error(f"Error processing OCR: {e}")
        return jsonify({'error': 'Error processing OCR'}), 500


@app.route("/")
def index():
    logging.debug("Home endpoint accessed")
    return jsonify({"Choo Choo": "Welcome to your Flask app 🚅"})


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True, use_reloader=False)
