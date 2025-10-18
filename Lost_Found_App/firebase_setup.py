import os
import firebase_admin
from firebase_admin import credentials, firestore
 
def _init_firestore_client():
	sa_path = os.getenv('FIREBASE_SERVICE_ACCOUNT')
	default_path = os.path.join(os.path.dirname(__file__), 'firebase_config', 'serviceAccountKey.json')

	cred = None
	if sa_path and os.path.isfile(sa_path):
		print(f"Using service account from FIREBASE_SERVICE_ACCOUNT={sa_path}")
		cred = credentials.Certificate(sa_path)
	elif os.path.isfile(default_path):
		print(f"Using service account from {default_path}")
		cred = credentials.Certificate(default_path)
	else:
		print("No service account JSON found at FIREBASE_SERVICE_ACCOUNT or firebase_config/serviceAccountKey.json")
		print("Attempting to initialize Firebase with Application Default Credentials (ADC). If this fails, set the FIREBASE_SERVICE_ACCOUNT env var or place the service account JSON at firebase_config/serviceAccountKey.json")
		try:
			cred = credentials.ApplicationDefault()
		except Exception as e:
			print("Could not load Application Default Credentials:", e)
			cred = None

	if cred is not None:
		try:
			firebase_admin.initialize_app(cred)
			db = firestore.client()
			return db
		except Exception as e:
			print("Failed to initialize Firebase app:", e)
			return None
	else:
		return None


db = _init_firestore_client()

if db is None:
	print("Warning: Firestore client not initialized. Any code that depends on `db` will fail until credentials are provided.")
