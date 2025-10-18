import sys
import os 

project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if project_root not in sys.path:
    sys.path.insert(0, project_root)

from firebase_setup import db
 
data = {
    "category": "LOST",
    "item": "mobile phone",
    "location": "faculty canteen",
    "time": "yesterday",
    "contact": "0702851411"
}
 
doc_ref = db.collection("items").add(data)
print("Document added with ID:", doc_ref[1].id)
