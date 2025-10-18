import json
from core.llm_client import generate_content

class ExtractorAgent:
    """
    Extracts structured info (item, location, time) from user messages
    after classification.
    Uses LLM first, then falls back to simple text parsing if needed.
    """

    @staticmethod
    def extract_details(message: str, category: str) -> dict:
        prompt = (
            "You are a precise data extraction assistant.\n"
            f"The user message is classified as '{category}'.\n"
            "Extract key information about the item, location, and time mentioned, if any.\n"
            "Return ONLY a valid JSON object in this exact format:\n"
            '{"item": "...", "location": "...", "time": "..."}\n'
            "Use null for any missing fields.\n"
            "Do not include any reasoning, explanation, or text before/after the JSON.\n\n"
            f"Message: '{message}'"
        )

        raw_response = generate_content(prompt)
        print(f"[DEBUG] Raw LLM response: {raw_response}")
 
        try:
            json_start = raw_response.find("{")
            json_end = raw_response.rfind("}") + 1
            if json_start != -1 and json_end != -1:
                json_str = raw_response[json_start:json_end]
                data = json.loads(json_str)
                print(f"[DEBUG] Parsed JSON: {data}")
                return {
                    "category": category,
                    "item": data.get("item"),
                    "location": data.get("location"),
                    "time": data.get("time"),
                }
        except Exception as e:
            print(f"[ERROR] JSON parsing failed: {e}")
 
        def parse_simple_text_fallback(raw_text: str):
            item = location = time = None
            for line in raw_text.splitlines():
                line = line.strip()
                if line.lower().startswith("item:"):
                    item = line.split(":", 1)[1].strip()
                elif line.lower().startswith("location:"):
                    location = line.split(":", 1)[1].strip()
                elif line.lower().startswith("time:"):
                    time = line.split(":", 1)[1].strip()
            return {"item": item or None, "location": location or None, "time": time or None}

        fallback_data = parse_simple_text_fallback(raw_response)
        print(f"[DEBUG] Fallback parsed data: {fallback_data}")

        return {"category": category, **fallback_data}
