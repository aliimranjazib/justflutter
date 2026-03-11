import subprocess
import json
import os
from datetime import datetime

# Configuration
OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "qwen3.5:9b" # Corrected model name
OUTPUT_DIR = "assets/posts"
INDEX_FILE = "assets/posts.json"

def generate_blog_post():
    prompt = """
    Write a high-quality, technical Flutter blog post in Markdown format.
    The goal is to teach developers something new and useful.
    
    Structure:
    1. Title (H1)
    2. Introduction
    3. Technical Deep Dive with code snippets
    4. Best practices
    5. Conclusion
    
    Return ONLY the Markdown content. Do not include any conversational text like "Here is your blog post".
    """

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False
    }

    print(f"🚀 Asking {MODEL} to write a blog post via curl...")
    
    try:
        json_payload = json.dumps(payload)
        # Explicitly using localhost instead of 127.0.0.1 since that's what ollama typically listens on
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', OLLAMA_URL, '-d', json_payload],
            capture_output=True,
            text=True,
            timeout=600 # Extended timeout for 9B model
        )
        
        if result.returncode != 0:
            print(f"❌ Curl failed: {result.stderr}")
            return None
            
        if not result.stdout.strip():
            print("❌ Empty response from curl. Is Ollama running?")
            return None

        try:
            data = json.loads(result.stdout)
        except json.JSONDecodeError:
            print(f"❌ Failed to parse JSON response: {result.stdout[:200]}...")
            return None

        markdown_content = data.get("response", "")
        
        if not markdown_content:
            print(f"❌ No response content in JSON: {data}")
            return None

        # Extract title from H1
        title = "New Flutter Insight"
        for line in markdown_content.split('\n'):
            if line.startswith('# '):
                title = line.replace('# ', '').strip()
                break
        
        # Save to file
        timestamp = datetime.now()
        id_str = timestamp.strftime("%Y%m%d%H%M%S")
        filename = f"blog_{id_str}.md"
        
        if not os.path.exists(OUTPUT_DIR):
            os.makedirs(OUTPUT_DIR)
            
        filepath = os.path.join(OUTPUT_DIR, filename)
        with open(filepath, "w") as f:
            f.write(markdown_content)
            
        print(f"✅ Blog post saved to: {filepath}")
        
        # Update index
        update_index(id_str, title, markdown_content[:150].replace('\n', ' ') + "...", filename)
        
        return filepath

    except Exception as e:
        print(f"❌ Error: {e}")
        return None

def update_index(post_id, title, excerpt, filename):
    posts = []
    if os.path.exists(INDEX_FILE):
        try:
            with open(INDEX_FILE, "r") as f:
                content = f.read().strip()
                if content:
                    posts = json.loads(content)
        except Exception as e:
            print(f"⚠️ Could not read index file, starting fresh: {e}")
            posts = []
    
    new_post = {
        "id": post_id,
        "title": title,
        "excerpt": excerpt,
        "filename": filename,
        "date": datetime.now().isoformat()
    }
    
    posts.insert(0, new_post)
    
    with open(INDEX_FILE, "w") as f:
        json.dump(posts, f, indent=2)
    
    print(f"📄 Updated {INDEX_FILE}")

if __name__ == "__main__":
    generate_blog_post()
