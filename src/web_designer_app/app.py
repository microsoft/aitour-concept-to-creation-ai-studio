from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
from create_website_copy_request import get_response
import markdown
import re
import html

app = Flask(__name__)
CORS(app)

def sanitize_markdown(md_text):
    # Convert markdown to HTML first
    html_content = markdown.markdown(md_text)
    # Preserve line breaks and spacing
    text = html.unescape(html_content)
    # Remove HTML tags but preserve line breaks
    text = re.sub('<br\s*/?>', '\n', text)
    text = re.sub('<[^<]+?>', '', text)
    return text

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/generate', methods=['POST'])
def generate_copy():
    try:
        data = request.json
        question = data.get('question')
        
        if not question:
            return jsonify({'error': 'No question provided'}), 400
        
        result = get_response(question)
        
        if not result or 'answer' not in result:
            return jsonify({'error': 'Invalid response format'}), 500
            
        sanitized_answer = sanitize_markdown(result['answer'])
        
        response = {
            'answer': sanitized_answer,
            'context': result.get('context', ''),
            'raw_markdown': result['answer']
        }
        
        return jsonify(response)
        
    except Exception as e:
        print(f"Error: {str(e)}")  # For debugging
        return jsonify({'error': f'Server error: {str(e)}'}), 500

if __name__ == '__main__':
    app.run(debug=True, port=5000)