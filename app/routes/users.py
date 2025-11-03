from typing import Optional
import firebase_admin
from firebase_admin import auth as firebase_auth, firestore
from Lost_Found_App.firebase_setup import db


def verify_and_create_user(id_token: str) -> Optional[dict]:
	"""
	Verify a Firebase ID token (from client) and create/update a user document in Firestore.

	Returns the user record dict on success, or None on failure.
	"""
	if db is None:
		print("Firestore client not initialized; cannot create user document.")
		return None

	try:
		decoded = firebase_auth.verify_id_token(id_token)
		uid = decoded.get('uid')
		email = decoded.get('email')
		if not uid:
			return None

		users_ref = db.collection('users')
		users_ref.document(uid).set({
			'email': email,
			'lastSeen': firestore.SERVER_TIMESTAMP,
		}, merge=True)

		return {'uid': uid, 'email': email}
	except Exception as e:
		print('Failed to verify token or create user:', e)
		return None

