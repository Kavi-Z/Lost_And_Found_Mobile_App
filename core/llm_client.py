import os
import requests
from dotenv import load_dotenv

load_dotenv()

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
if not GROQ_API_KEY:
    raise ValueError("GROQ_API_KEY not found in .env file")

GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions"


def generate_content(prompt: str, model: str = "openai/gpt-oss-20b") -> str:
    print(f"[DEBUG] Calling Groq API with model: {model}")
    print(f"[DEBUG] Prompt: {prompt}")

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 50,        
        "temperature": 0         
    }

    try:
        response = requests.post(GROQ_API_URL, headers=headers, json=data)
        print(f"[DEBUG] Raw API response: {response.text}")
        response.raise_for_status()
        result = response.json()
 
        message = result["choices"][0].get("message", {})
        content = (message.get("content") or "").strip()
        reasoning = (message.get("reasoning") or "").strip()
 
        raw_output = content or reasoning
 
        if not raw_output:
            print("[DEBUG] Empty content and reasoning — returning UNKNOWN")
            return "UNKNOWN"
 
        text_upper = raw_output.upper()
        for label in ["LOST","FOUND", "UNKNOWN"]:
            if label in text_upper:
                return label
 
        print(f"[DEBUG] No valid label found in response: {raw_output}")
        return "UNKNOWN"

    except Exception as e:
        print("Error in LLM call:", e)
        if 'response' in locals():
            print("[DEBUG] API response (error):", response.text)
        return "UNKNOWN"
def generate_content(prompt: str, model: str = "openai/gpt-oss-20b") -> str:
    print(f"[DEBUG] Calling Groq API with model: {model}")  
    print(f"[DEBUG] Prompt: {prompt}")

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": model,
        "messages": [{"role": "user", "content": prompt}],
        "max_tokens": 200
    }

    try:
        response = requests.post(GROQ_API_URL, headers=headers, json=data)
        print(f"[DEBUG] Raw API response: {response.text}")
        response.raise_for_status()
        result = response.json()
        choice = result["choices"][0]["message"]
         
        content = choice.get("content")
        if not content or content.strip() == "":
            content = choice.get("reasoning", "").strip()
        
        return content

    except Exception as e:
        print("Error in LLM call:", e)
        if 'response' in locals():
            print("[DEBUG] API response (error):", response.text)
        return ""
