"use client";
import React, { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { doc, onSnapshot, updateDoc, setDoc, collection, getDocs, writeBatch } from 'firebase/firestore';
import { 
  ShieldAlert, 
  Power, 
  RotateCcw, 
  UserPlus, 
  Trash2, 
  Lock,
  Unlock,
  AlertTriangle
} from 'lucide-react';

export default function GlobalSettingsPage() {
  const [isVotingOpen, setIsVotingOpen] = useState(false);
  const [startTime, setStartTime] = useState('');
  const [endTime, setEndTime] = useState('');
  const [loading, setLoading] = useState(false);
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const [passphraseInput, setPassphraseInput] = useState('');
  const [passphraseError, setPassphraseError] = useState(false);

  useEffect(() => {
    const unsub = onSnapshot(doc(db, 'settings', 'global'), (snap) => {
      if (snap.exists()) {
        const data = snap.data();
        setIsVotingOpen(data.isVotingOpen);
        setStartTime(data.startTime || '');
        setEndTime(data.endTime || '');
      }
    });
    return () => unsub();
  }, []);

  const updateSchedule = async () => {
    setLoading(true);
    try {
      await setDoc(doc(db, 'settings', 'global'), {
        startTime,
        endTime
      }, { merge: true });
      alert("Election schedule updated successfully!");
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  const handleReset = async () => {
    // Challenge the user with the Master Security Passphrase
    if (passphraseInput !== process.env.NEXT_PUBLIC_SECURITY_PASSPHRASE) {
      setPassphraseError(true);
      return;
    }
    
    setLoading(true);
    
    try {
      const batch = writeBatch(db);

      // 1. Delete all votes
      const votesSnapshot = await getDocs(collection(db, 'votes'));
      votesSnapshot.forEach((document) => {
        batch.delete(doc(db, 'votes', document.id));
      });

      // 2. Reset hasVoted in users
      const usersSnapshot = await getDocs(collection(db, 'users'));
      usersSnapshot.forEach((document) => {
        batch.update(doc(db, 'users', document.id), { hasVoted: false });
      });

      // 3. Reset voteCount in candidates
      const candidatesSnapshot = await getDocs(collection(db, 'candidates'));
      candidatesSnapshot.forEach((document) => {
        batch.update(doc(db, 'candidates', document.id), { voteCount: 0 });
      });

      await batch.commit();

      setShowResetConfirm(false);
      setPassphraseInput('');
      alert("Election Data Reset Successfully");
    } catch (error) {
      console.error("Error resetting data:", error);
      alert("Failed to reset election data. See console for details.");
    } finally {
      setLoading(false);
    }
  };

  const forceDataSync = () => {
    alert("Data sync is already handled in real-time via Firestore listeners.");
  };

  const toggleElection = async () => {
    setLoading(true);
    try {
      await setDoc(doc(db, 'settings', 'global'), {
        isVotingOpen: !isVotingOpen
      }, { merge: true });
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ animation: 'fadeIn 0.6s ease-out', maxWidth: '1000px' }}>
      <div style={{ display: 'flex', gap: '32px' }}>
        
        {/* Election Status Control */}
        <div className="glass" style={{ 
          flex: 1, 
          padding: '40px', 
          borderRadius: '32px', 
          border: isVotingOpen ? '2px solid var(--success)' : '2px solid var(--danger)',
          transition: 'all 0.3s ease'
        }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '32px' }}>
             <div style={{
               width: '64px',
               height: '64px',
               borderRadius: '20px',
               background: isVotingOpen ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
               display: 'flex',
               alignItems: 'center',
               justifyContent: 'center',
               color: isVotingOpen ? 'var(--success)' : 'var(--danger)',
               transition: 'all 0.3s ease'
             }}>
               {isVotingOpen ? <Unlock size={32} /> : <Lock size={32} />}
             </div>
             <div style={{ textAlign: 'right' }}>
                <p style={{ color: 'var(--text-secondary)', fontSize: '14px', fontWeight: '700', textTransform: 'uppercase' }}>ELECTION STATUS</p>
                <h2 style={{ fontSize: '28px', fontWeight: '900', color: isVotingOpen ? 'var(--success)' : 'var(--danger)' }}>
                  {isVotingOpen ? 'ACTIVE' : 'PAUSED'}
                </h2>
             </div>
          </div>

          <p style={{ color: 'var(--text-secondary)', lineHeight: '1.6', marginBottom: '40px' }}>
            When the election is <strong>PAUSED</strong>, the mobile application will disable all "Give Vote" buttons and display a "Voting Suspended" message to all users.
          </p>

          <button 
            onClick={toggleElection}
            disabled={loading}
            style={{
              width: '100%',
              padding: '24px',
              borderRadius: '20px',
              border: 'none',
              background: isVotingOpen ? 'var(--danger)' : 'var(--success)',
              color: 'white',
              fontSize: '18px',
              fontWeight: '900',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '12px',
              cursor: 'pointer',
              boxShadow: '0 10px 20px rgba(0,0,0,0.2)',
              transition: 'all 0.2s ease'
            }}
          >
            <Power size={24} />
            {isVotingOpen ? 'HALT ELECTION NOW' : 'START ELECTION CYCLE'}
          </button>
        </div>

        {/* Temporal Schedule Config */}
        <div className="glass" style={{ flex: 1, padding: '40px', borderRadius: '32px' }}>
          <div style={{ marginBottom: '32px' }}>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px', fontWeight: '700', textTransform: 'uppercase' }}>ELECTION SCHEDULE</p>
            <h2 style={{ fontSize: '28px', fontWeight: '900', color: 'var(--accent-gold)' }}>Timeline Config</h2>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
             <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--primary-blue)', letterSpacing: '1px' }}>STARTING TIME</label>
                <input 
                  type="datetime-local" 
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  style={{
                    padding: '16px',
                    borderRadius: '14px',
                    border: '1px solid var(--navy-border)',
                    background: 'var(--navy-surface)',
                    color: 'white',
                    outline: 'none',
                    fontSize: '16px'
                  }}
                />
             </div>

             <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--primary-blue)', letterSpacing: '1px' }}>ENDING TIME</label>
                <input 
                  type="datetime-local" 
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  style={{
                    padding: '16px',
                    borderRadius: '14px',
                    border: '1px solid var(--navy-border)',
                    background: 'var(--navy-surface)',
                    color: 'white',
                    outline: 'none',
                    fontSize: '16px'
                  }}
                />
             </div>

             <button 
               onClick={updateSchedule}
               disabled={loading}
               style={{
                 marginTop: '12px',
                 padding: '18px',
                 borderRadius: '14px',
                 border: 'none',
                 background: 'linear-gradient(45deg, var(--primary-blue), #3b82f6)',
                 color: 'white',
                 fontSize: '16px',
                 fontWeight: '800',
                 cursor: 'pointer',
                 boxShadow: '0 10px 20px var(--primary-glow)'
               }}
             >
               {loading ? 'SYNCING SCHEDULE...' : 'APPLY TEMPORAL CONFIG'}
             </button>
          </div>
        </div>

        {/* Security & Danger Zone */}
        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '24px' }}>
           <div className="glass" style={{ padding: '32px', borderRadius: '24px' }}>
              <h4 style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '20px' }}>
                <ShieldAlert size={20} color="var(--accent-gold)" />
                Security Overrides
              </h4>
              <p style={{ fontSize: '14px', color: 'var(--text-secondary)', marginBottom: '20px' }}>Manual overrides for system synchronization and clearing caches.</p>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                 <button onClick={forceDataSync} style={{ padding: '14px', borderRadius: '12px', border: '1px solid var(--navy-border)', background: 'var(--navy-surface)', color: 'white', fontWeight: '700', cursor: 'pointer', display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <RotateCcw size={18} /> Forced Data Sync
                 </button>
                 <button style={{ padding: '14px', borderRadius: '12px', border: '1px solid var(--navy-border)', background: 'var(--navy-surface)', color: 'white', fontWeight: '700', cursor: 'pointer', display: 'flex', gap: '10px', alignItems: 'center' }}>
                    <UserPlus size={18} /> Manage Admin Access
                 </button>
              </div>
           </div>

           <div className="glass" style={{ padding: '32px', borderRadius: '24px', border: '1px solid rgba(239, 68, 68, 0.2)' }}>
              <h4 style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '16px', color: 'var(--danger)' }}>
                <AlertTriangle size={20} /> Danger Zone
              </h4>
              <button 
                 onClick={() => setShowResetConfirm(true)}
                 style={{ 
                   width: '100%', 
                   padding: '16px', 
                   borderRadius: '12px', 
                   background: 'rgba(239, 68, 68, 0.1)', 
                   border: '1px solid var(--danger)', 
                   color: 'var(--danger)', 
                   fontWeight: '800', 
                   cursor: 'pointer',
                   display: 'flex',
                   gap: '10px',
                   justifyContent: 'center',
                   alignItems: 'center'
                 }}
              >
                <Trash2 size={18} /> Reset All Election Data
              </button>
              <p style={{ fontSize: '11px', color: 'var(--text-muted)', marginTop: '12px', textAlign: 'center' }}>
                WARNING: This action is irreversible and will wipe all cast ballots.
              </p>
           </div>
        </div>
      </div>

      {/* Confirmation Modal */}
      {showResetConfirm && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.85)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px', backdropFilter: 'blur(8px)' }}>
           <div className="glass" style={{ maxWidth: '450px', width: '100%', padding: '40px', borderRadius: '32px', textAlign: 'center', border: '1px solid rgba(239, 68, 68, 0.3)' }}>
              <AlertTriangle size={64} color="var(--danger)" style={{ marginBottom: '24px' }} />
              <h2 style={{ fontSize: '24px', marginBottom: '12px' }}>Terminal Reset Required</h2>
              <p style={{ color: 'var(--text-secondary)', marginBottom: '24px', fontSize: '14px' }}>This will permanently DELETE all votes from the blockchain registry. This action is irreversible.</p>
              
              <div style={{ marginBottom: '24px', textAlign: 'left' }}>
                <label style={{ fontSize: '11px', fontWeight: '800', color: 'var(--danger)', letterSpacing: '1px', display: 'block', marginBottom: '8px' }}>ENTER SECURITY PASSPHRASE TO AUTHORIZE</label>
                <input 
                  type="password"
                  value={passphraseInput}
                  onChange={(e) => {
                    setPassphraseInput(e.target.value);
                    setPassphraseError(false);
                  }}
                  placeholder="••••••••••••"
                  style={{
                    width: '100%',
                    padding: '14px',
                    borderRadius: '12px',
                    background: 'var(--navy-surface)',
                    border: passphraseError ? '1px solid var(--danger)' : '1px solid var(--navy-border)',
                    color: 'white',
                    outline: 'none'
                  }}
                />
                {passphraseError && <p style={{ color: 'var(--danger)', fontSize: '11px', marginTop: '6px', fontWeight: 'bold' }}>Invalid Security Passphrase</p>}
              </div>

              <div style={{ display: 'flex', gap: '12px' }}>
                 <button onClick={() => {
                   setShowResetConfirm(false);
                   setPassphraseInput('');
                   setPassphraseError(false);
                 }} style={{ flex: 1, padding: '16px', borderRadius: '12px', border: 'none', background: 'var(--navy-surface)', color: 'white', fontWeight: '700', cursor: 'pointer' }}>Cancel</button>
                 <button 
                  onClick={handleReset}
                  disabled={loading || !passphraseInput}
                  style={{ 
                    flex: 1, 
                    padding: '16px', 
                    borderRadius: '12px', 
                    border: 'none', 
                    background: 'var(--danger)', 
                    color: 'white', 
                    fontWeight: '700', 
                    cursor: 'pointer',
                    opacity: (!passphraseInput || loading) ? 0.5 : 1
                  }}
                 >
                   {loading ? 'RESETTING...' : 'Authorize Wipe'}
                 </button>
              </div>
           </div>
        </div>
      )}
    </div>
  );
}
