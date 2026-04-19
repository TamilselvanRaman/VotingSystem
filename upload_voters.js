const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Configuration
const PROJECT_ID = 'votingsystem2026-3cf4c';
const JSON_FILE = 'users.json';
const COLLECTION_NAME = 'realVoterList';
const KEY_FILE = 'votingsystem2026-3cf4c-firebase-adminsdk-fbsvc-ae8d97ff02.json';

function initializeFirebase() {
  const keyPath = path.join(__dirname, KEY_FILE);
  
  if (fs.existsSync(keyPath)) {
    console.log(`Using service account key: ${KEY_FILE}`);
    const serviceAccount = require(keyPath);
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
  } else {
    console.log('Service account key not found. Attempting to use default credentials...');
    admin.initializeApp({
      projectId: PROJECT_ID
    });
  }
  return admin.firestore();
}

async function uploadVoters() {
  const db = initializeFirebase();
  const jsonPath = path.join(__dirname, JSON_FILE);

  if (!fs.existsSync(jsonPath)) {
    console.error(`Error: ${JSON_FILE} not found.`);
    return;
  }

  const voters = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
  console.log(`Found ${voters.length} voters. Starting upload...`);

  let batch = db.batch();
  let count = 0;

  for (const voter of voters) {
    if (!voter.voterId) continue;

    const docId = voter.voterId.replace(/\//g, '_');
    const docRef = db.collection(COLLECTION_NAME).doc(docId);

    batch.set(docRef, voter);
    count++;

    if (count % 500 === 0) {
      await batch.commit();
      console.log(`Committed ${count} records...`);
      batch = db.batch();
    }
  }

  if (count % 500 !== 0) {
    await batch.commit();
  }

  console.log(`\nSuccess! Successfully uploaded ${count} voters to '${COLLECTION_NAME}' collection.`);
}

uploadVoters().catch(err => {
  console.error('\n[ERROR] Upload failed:', err.message);
  if (err.message.includes('Could not load the default credentials')) {
    console.log('\nTo fix this:');
    console.log('1. Go to Firebase Console -> Project Settings -> Service Accounts.');
    console.log('2. Click "Generate new private key" and save it as "service-account.json" in this folder.');
    console.log('3. Run "node upload_voters.js" again.');
  }
});
