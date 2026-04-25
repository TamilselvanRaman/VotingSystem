const admin = require('firebase-admin');
const serviceAccount = require('../votingsystem2026-3cf4c-firebase-adminsdk-fbsvc-ae8d97ff02.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

const candidates = [
  {
    id: 'c1',
    name: 'Snekan M',
    party: 'Progressive Front',
    image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500&h=500&fit=crop', 
    symbolUrl: 'https://img.icons8.com/fluency/256/smartphone.png', // Smartphone Symbol
    logo: 'https://img.icons8.com/fluency/256/diversity.png', // Party Logo
    candidateId: 'CAN001'
  },
  {
    id: 'c2',
    name: 'C. Kandasamy',
    party: 'Democratic Front',
    image: 'https://images.unsplash.com/photo-1566492031773-4f4e44671857?w=500&h=500&fit=crop',
    symbolUrl: 'https://img.icons8.com/fluency/256/laptop.png', // Laptop Symbol
    logo: 'https://img.icons8.com/fluency/256/people-working-together.png', // Party Logo
    candidateId: 'CAN002'
  }
];

async function updateCandidates() {
  for (const cand of candidates) {
    const docId = cand.id;
    const data = { ...cand };
    delete data.id;
    
    await db.collection('candidates').doc(docId).set(data, { merge: true });
    console.log(`Updated candidate: ${cand.name}`);
  }
  console.log('All candidates updated successfully!');
  process.exit(0);
}

updateCandidates().catch(err => {
  console.error(err);
  process.exit(1);
});
