import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import json
import os

# Configuration
PROJECT_ID = 'votingsystem2026-3cf4c'
JSON_FILE = 'users.json'
COLLECTION_NAME = 'realVoterList'
KEY_FILE = 'votingsystem2026-3cf4c-firebase-adminsdk-fbsvc-ae8d97ff02.json'

def initialize_firebase():
    """Initializes Firebase Admin SDK using a service account or default credentials."""
    if os.path.exists(KEY_FILE):
        print(f"Using service account key: {KEY_FILE}")
        cred = credentials.Certificate(KEY_FILE)
        firebase_admin.initialize_app(cred)
    else:
        print("Service account key not found. Attempting to use default credentials...")
        try:
            firebase_admin.initialize_app(options={'projectId': PROJECT_ID})
        except Exception as e:
            print(f"\n[ERROR] Could not initialize Firebase: {e}")
            print("\nTo fix this:")
            print(f"1. Go to Firebase Console -> Project Settings -> Service Accounts.")
            print(f"2. Click 'Generate new private key' and save it as '{KEY_FILE}' in this folder.")
            print(f"3. Run this script again.")
            exit(1)
    return firestore.client()

def upload_voters():
    db = initialize_firebase()
    
    if not os.path.exists(JSON_FILE):
        print(f"Error: {JSON_FILE} not found.")
        return

    with open(JSON_FILE, 'r', encoding='utf-8') as f:
        voters = json.load(f)

    print(f"Found {len(voters)} voters. Starting upload...")

    batch = db.batch()
    count = 0

    for voter in voters:
        # Generate a safe document ID from Voter ID (e.g., TN_24_145_678901)
        voter_id = voter.get('voterId')
        if not voter_id:
            continue
            
        doc_id = voter_id.replace('/', '_')
        doc_ref = db.collection(COLLECTION_NAME).document(doc_id)
        
        batch.set(doc_ref, voter)
        count += 1
        
        # Firestore batch limit is 500
        if count % 500 == 0:
            batch.commit()
            print(f"Committed {count} records...")
            batch = db.batch()

    # Final commit
    if count % 500 != 0:
        batch.commit()
        
    print(f"\nSuccess! Successfully uploaded {count} voters to '{COLLECTION_NAME}' collection.")

if __name__ == "__main__":
    upload_voters()
