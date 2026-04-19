"use client";
import React, { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, onSnapshot, doc } from 'firebase/firestore';
import { 
  Users, 
  Vote, 
  Clock, 
  MapPin,
  TrendingUp,
  Activity
} from 'lucide-react';
import StatCard from '@/components/StatCard';

export default function DashboardPage() {
  const [stats, setStats] = useState({
    totalVoters: 0,
    totalVotes: 0,
    isVotingOpen: false,
    startTime: null,
    endTime: null,
    voterTurnout: '0%'
  });
  const [timeLeft, setTimeLeft] = useState('');

  useEffect(() => {
    // Listen for Voter Total
    const unsubVoters = onSnapshot(collection(db, 'realVoterList'), (snap) => {
      setStats(prev => {
        const total = snap.size || 1232;
        return { 
          ...prev, 
          totalVoters: total,
          voterTurnout: prev.totalVotes > 0 ? ((prev.totalVotes / total) * 100).toFixed(1) + '%' : '0%'
        };
      });
    });

    // Listen for Cast Votes
    const unsubVotes = onSnapshot(collection(db, 'votes'), (snap) => {
      setStats(prev => {
        const votes = snap.size;
        return { 
          ...prev, 
          totalVotes: votes,
          voterTurnout: prev.totalVoters > 0 ? ((votes / prev.totalVoters) * 100).toFixed(1) + '%' : '0%'
        };
      });
    });

    // Listen for System Setting
    const unsubStatus = onSnapshot(doc(db, 'settings', 'global'), (snap) => {
      if (snap.exists()) {
        const data = snap.data();
        setStats(prev => ({ 
          ...prev, 
          isVotingOpen: data.isVotingOpen,
          startTime: data.startTime,
          endTime: data.endTime
        }));
      }
    });

    // Timer logic
    const timer = setInterval(() => {
      const now = new Date();
      if (stats.startTime && new Date(stats.startTime) > now) {
        const diff = new Date(stats.startTime) - now;
        setTimeLeft(`Starts in: ${Math.floor(diff / 3600000)}h ${Math.floor((diff % 3600000) / 60000)}m`);
      } else if (stats.endTime && new Date(stats.endTime) > now) {
        const diff = new Date(stats.endTime) - now;
        setTimeLeft(`Ends in: ${Math.floor(diff / 3600000)}h ${Math.floor((diff % 3600000) / 60000)}m`);
      } else {
        setTimeLeft('Cycle Completed');
      }
    }, 1000);

    return () => {
      unsubVoters();
      unsubVotes();
      unsubStatus();
      clearInterval(timer);
    };
  }, [stats.startTime, stats.endTime]);

  return (
    <div style={{ animation: 'fadeIn 0.6s ease-out' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '32px' }}>
        <div>
          <p style={{ color: 'var(--text-secondary)', fontWeight: '600', marginBottom: '4px' }}>Welcome back, Chief Commissioner</p>
          <h1 style={{ fontSize: '32px', fontWeight: '900', letterSpacing: '-1px' }}>Operation <span style={{ color: 'var(--primary-blue)' }}>Sovereign Vote</span></h1>
        </div>
        
        <div style={{ display: 'flex', gap: '12px' }}>
          {timeLeft && (
            <div className="glass" style={{
              padding: '10px 20px',
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              gap: '10px',
              color: 'var(--accent-gold)'
            }}>
              <Clock size={16} />
              <span style={{ fontSize: '14px', fontWeight: '800' }}>{timeLeft}</span>
            </div>
          )}
          
          <div className="glass" style={{
            padding: '10px 20px',
            borderRadius: '12px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            borderLeft: stats.isVotingOpen ? '4px solid var(--success)' : '4px solid var(--danger)'
          }}>
            <ActivityPulse active={stats.isVotingOpen} />
            <span style={{ fontSize: '14px', fontWeight: '700', color: stats.isVotingOpen ? 'var(--success)' : 'var(--danger)' }}>
              SYSTEM {stats.isVotingOpen ? 'LIVE' : 'OFFLINE'}
            </span>
          </div>
        </div>
      </div>

      {/* Primary Stats Grid */}
      <div style={{ display: 'flex', gap: '24px', flexWrap: 'wrap', marginBottom: '32px' }}>
        <StatCard 
          title="TOTAL REGISTERED" 
          value={stats.totalVoters.toLocaleString()} 
          icon={<Users />} 
          color="#3b82f6" 
        />
        <StatCard 
          title="VOTES CAST" 
          value={stats.totalVotes.toLocaleString()} 
          icon={<Vote />} 
          color="#10b981" 
          trend={stats.totalVotes > 0 ? "+100%" : "Waiting"}
        />
        <StatCard 
          title="VOTER TURNOUT" 
          value={stats.voterTurnout} 
          icon={<TrendingUp />} 
          color="#8b5cf6" 
        />
        <StatCard 
          title="POLLING STATIONS" 
          value="42" 
          icon={<MapPin />} 
          color="#f59e0b" 
        />
      </div>

      <div style={{ display: 'flex', gap: '24px' }}>
        {/* Main Feed Placeholder */}
        <div className="glass" style={{ flex: 2, padding: '32px', borderRadius: '24px', minHeight: '300px' }}>
          <h3 style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '24px', fontSize: '18px' }}>
            <Activity size={20} color="var(--primary-blue)" />
            Real-time Activity Stream
          </h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', justifyContent: 'center', alignItems: 'center', height: '100%', color: 'var(--text-secondary)' }}>
             <Clock size={40} opacity={0.3} />
             <p>Awaiting live connection to regional polling nodes...</p>
          </div>
        </div>

        {/* Quick Actions */}
        <div className="glass" style={{ flex: 1, padding: '32px', borderRadius: '24px' }}>
           <h4 style={{ marginBottom: '20px', fontSize: '16px', fontWeight: '800' }}>Admin Quick Actions</h4>
           <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <ActionButton label="Export Live Report" icon={<Activity size={18} />} primary />
              <ActionButton label="View Audit Logs" icon={<Users size={18} />} />
              <ActionButton label="Emergency System Pause" icon={<Clock size={18} />} color="var(--danger)" />
           </div>
        </div>
      </div>
    </div>
  );
}

const ActivityPulse = ({ active }) => (
  <div style={{
    width: '8px',
    height: '8px',
    borderRadius: '50%',
    background: active ? 'var(--success)' : 'var(--danger)',
    boxShadow: active ? '0 0 10px var(--success)' : 'none',
    animation: active ? 'pulse 2s infinite' : 'none'
  }} />
);

const ActionButton = ({ label, icon, primary, color }) => (
  <button style={{
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    padding: '14px',
    borderRadius: '12px',
    border: 'none',
    width: '100%',
    cursor: 'pointer',
    background: primary ? 'var(--primary-blue)' : 'var(--navy-surface)',
    color: color || 'white',
    fontSize: '14px',
    fontWeight: '700',
    transition: 'transform 0.2s ease',
    boxShadow: primary ? '0 4px 15px var(--primary-glow)' : 'none'
  }}>
    {icon}
    {label}
  </button>
);
