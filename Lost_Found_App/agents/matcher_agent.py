import sys
import os

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from firebase_setup import db

class MatcherAgent:
    def __init__(self, collection_name="items"):
        self.collection_name = collection_name

    def match(self, extracted_data: dict) -> str:
        extracted_item = extracted_data.get("item")
        extracted_location = extracted_data.get("location")
        extracted_time = extracted_data.get("time")
        extracted_category = extracted_data.get("category")

        if not extracted_item:
            return "NO MATCH"

        docs = db.collection(self.collection_name).stream()

        for doc in docs:
            data = doc.to_dict()
            if (
                data.get("category") == extracted_category and
                data.get("item") == extracted_item and
                data.get("location") == extracted_location and
                data.get("time") == extracted_time 
                
            ):
                return "MATCH"

        return "NO MATCH"
