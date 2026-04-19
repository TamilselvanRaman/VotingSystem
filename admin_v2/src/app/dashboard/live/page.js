"use client";
import React, { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  Tooltip, 
  ResponsiveContainer,
  Cell
} from 'recharts';
import { Activity, Award, Users } from 'lucide-react';

export default function LiveResultsPage() {
  const [candidates, setCandidates] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // No orderBy in Firestore — sort client-side to avoid silent failure
    // when voteCount field is missing from some documents
    const q = query(collection(db, 'candidates'));
    const unsub = onSnapshot(q, (snap) => {
      const data = snap.docs
        .map(doc => ({ id: doc.id, ...doc.data() }))
        .sort((a, b) => (b.voteCount || 0) - (a.voteCount || 0));
      setCandidates(data);
      setLoading(false);
    }, (error) => {
      console.error('Live results error:', error);
      setLoading(false);
    });

    return () => unsub();
  }, []);

  const totalVotes = candidates.reduce((sum, c) => sum + (c.voteCount || 0), 0);
  
  const COLORS = ['#2563eb', '#06b6d4', '#8b5cf6', '#10b981', '#f59e0b', '#ef4444'];

  if (loading) {
    return (
      <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh', color: 'var(--text-secondary)' }}>
        <div className="loader"></div>
        <p style={{ marginLeft: '16px', fontWeight: '600' }}>Synchronizing with blockchain node...</p>
      </div>
    );
  }

  if (candidates.length === 0) {
    return (
      <div className="glass" style={{ padding: '60px', textAlign: 'center', borderRadius: '24px' }}>
        <Activity size={48} color="var(--primary-blue)" style={{ opacity: 0.3, marginBottom: '24px' }} />
        <h3 style={{ color: 'var(--text-secondary)' }}>No Election Data Found</h3>
        <p style={{ color: 'var(--text-muted)', maxWidth: '400px', margin: '12px auto' }}>
          It looks like no candidates have been registered in the system yet. 
          Please add candidates in the System Config to start tracking live results.
        </p>
      </div>
    );
  }

  return (
    <div style={{ animation: 'fadeIn 0.6s ease-out' }}>
      <div style={{ display: 'flex', gap: '24px', marginBottom: '32px' }}>
        <div className="glass" style={{ flex: 2, padding: '32px', borderRadius: '24px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
            <h3 style={{ display: 'flex', alignItems: 'center', gap: '12px', margin: 0 }}>
              <Activity color="var(--primary-blue)" />
              Real-time Candidate Standings
            </h3>
            <div style={{ background: 'var(--navy-surface)', padding: '8px 16px', borderRadius: '12px', fontSize: '14px', fontWeight: '700' }}>
              Total Verified Ballots: <span style={{ color: 'var(--primary-blue)' }}>{totalVotes.toLocaleString()}</span>
            </div>
          </div>

          <div style={{ height: '400px', width: '100%' }}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={candidates} layout="vertical" margin={{ left: 40, right: 40 }}>
                <XAxis type="number" hide />
                <YAxis 
                  dataKey="name" 
                  type="category" 
                  axisLine={false} 
                  tickLine={false} 
                  tick={{ fill: 'var(--text-secondary)', fontSize: 13, fontWeight: 600 }}
                  width={120}
                />
                <Tooltip 
                  cursor={{ fill: 'rgba(255,255,255,0.05)' }}
                  contentStyle={{ backgroundColor: 'var(--navy-surface)', border: '1px solid var(--glass-border)', borderRadius: '12px' }}
                />
                <Bar dataKey="voteCount" radius={[0, 8, 8, 0]} barSize={32}>
                  {candidates.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div className="glass" style={{ padding: '32px', borderRadius: '24px', flex: 1 }}>
             <h4 style={{ marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '10px' }}>
               <Award size={18} color="var(--accent-gold)" />
               Current Leader
             </h4>
             <div style={{ textAlign: 'center' }}>
                <img 
                  src={candidates[0].image || 'https://via.placeholder.com/100'} 
                  style={{ width: '100px', height: '100px', borderRadius: '50%', border: '4px solid var(--accent-gold)', marginBottom: '16px', objectFit: 'cover' }}
                  alt={candidates[0].name}
                />
                <h2 style={{ fontSize: '20px', fontWeight: '900', marginBottom: '4px' }}>{candidates[0].name}</h2>
                <p style={{ color: 'var(--text-secondary)', fontSize: '14px', fontWeight: '600' }}>{candidates[0].party}</p>
                <div style={{ marginTop: '20px', padding: '12px', background: 'rgba(245, 158, 11, 0.1)', borderRadius: '12px', color: 'var(--accent-gold)', fontWeight: '800' }}>
                  {((candidates[0].voteCount / (totalVotes || 1)) * 100).toFixed(1)}% OF TOTAL
                </div>
             </div>
          </div>

          <div className="glass" style={{ padding: '32px', borderRadius: '24px', flex: 1 }}>
             <h4 style={{ marginBottom: '16px', display: 'flex', alignItems: 'center', gap: '10px' }}>
               <Users size={18} color="var(--primary-blue)" />
               Quick Breakdown
             </h4>
             <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                {candidates.slice(0, 3).map((c, i) => (
                  <div key={c.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '14px', color: 'var(--text-secondary)' }}>{c.party}</span>
                    <span style={{ fontWeight: '700' }}>{c.voteCount || 0}</span>
                  </div>
                ))}
             </div>
          </div>
        </div>
      </div>

      <div className="glass" style={{ padding: '32px', borderRadius: '24px' }}>
         <h3 style={{ marginBottom: '32px' }}>Live Momentum (Recent 5m)</h3>
         <div style={{ height: '200px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-muted)' }}>
            <Activity size={32} opacity={0.2} style={{ marginRight: '16px' }} />
            Initializing live stream with regional polling stations...
         </div>
      </div>
    </div>
  );
}
