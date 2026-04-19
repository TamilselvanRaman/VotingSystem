"use client";
import React, { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { collection, onSnapshot, query, limit } from 'firebase/firestore';
import { Search, Filter, ArrowRight, AlertCircle } from 'lucide-react';

export default function VoterDirectoryPage() {
  const [voters, setVoters] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [loading, setLoading] = useState(true);
  const [selectedVoter, setSelectedVoter] = useState(null);

  useEffect(() => {
    // Listen for Voter Total
    const q = query(collection(db, 'realVoterList'), limit(50));
    const unsub = onSnapshot(q, (snap) => {
      const data = snap.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      }));
      setVoters(data);
      setLoading(false);
    });

    return () => unsub();
  }, []);

  const filteredVoters = voters.filter(v => 
    v.name?.toLowerCase().includes(searchTerm.toLowerCase()) || 
    v.epicNumber?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    v.voterId?.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div style={{ animation: 'fadeIn 0.6s ease-out' }}>
      <div className="glass" style={{ padding: '32px', borderRadius: '24px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
          <div>
            <h3 style={{ fontSize: '20px', fontWeight: '800', marginBottom: '4px' }}>Master Voter Registry</h3>
            <p style={{ color: 'var(--text-secondary)', fontSize: '14px' }}>Managing {voters.length}+ official records</p>
          </div>
          
          <div style={{ display: 'flex', gap: '16px' }}>
             <div style={{ position: 'relative' }}>
                <Search style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} size={16} color="var(--text-secondary)" />
                <input 
                  type="text" 
                  placeholder="Fast search EPIC or Name..." 
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  style={{
                    padding: '12px 18px 12px 42px',
                    borderRadius: '12px',
                    border: '1px solid var(--navy-border)',
                    background: 'var(--navy-deep)',
                    color: 'white',
                    width: '300px',
                    outline: 'none'
                  }}
                />
             </div>
             <button style={{
               padding: '12px 20px',
               borderRadius: '12px',
               border: '1px solid var(--glass-border)',
               background: 'var(--navy-surface)',
               color: 'white',
               display: 'flex',
               alignItems: 'center',
               gap: '10px',
               cursor: 'pointer'
             }}>
               <Filter size={16} /> Filters
             </button>
          </div>
        </div>

        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--navy-border)' }}>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>VOTER NAME</th>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>EPIC NUMBER</th>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>CONSTITUENCY</th>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>GENDER</th>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>AGE</th>
                <th style={{ padding: '16px', color: 'var(--text-secondary)', fontSize: '13px', fontWeight: '700' }}>STATUS</th>
                <th style={{ padding: '16px' }}></th>
              </tr>
            </thead>
            <tbody>
              {filteredVoters.map((voter) => (
                <tr key={voter.id} className="voter-row" style={{ borderBottom: '1px solid rgba(255,255,255,0.05)', transition: 'background 0.2s' }}>
                  <td style={{ padding: '20px 16px' }}>
                    <div style={{ fontWeight: '700' }}>{voter.name}</div>
                    <div style={{ fontSize: '12px', color: 'var(--text-muted)' }}>{voter.voterId || voter.id}</div>
                  </td>
                  <td style={{ padding: '16px' }}>
                    <code style={{ background: 'rgba(37, 99, 235, 0.1)', color: 'var(--primary-blue)', padding: '4px 8px', borderRadius: '6px', fontSize: '13px', fontWeight: '800' }}>
                      {voter.epicNumber}
                    </code>
                  </td>
                  <td style={{ padding: '16px', fontWeight: '600', fontSize: '14px' }}>{voter.constituency}</td>
                  <td style={{ padding: '16px' }}>
                    <span style={{ 
                      fontSize: '12px', 
                      fontWeight: '700', 
                      padding: '4px 10px', 
                      borderRadius: '20px',
                      background: voter.gender === 'Female' ? 'rgba(236, 72, 153, 0.1)' : 'rgba(37, 99, 235, 0.1)',
                      color: voter.gender === 'Female' ? '#ec4899' : '#3b82f6'
                    }}>
                      {voter.gender?.toUpperCase()}
                    </span>
                  </td>
                  <td style={{ padding: '16px', fontWeight: '700' }}>{voter.age}</td>
                  <td style={{ padding: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: voter.hasVoted ? 'var(--success)' : 'var(--warning)' }}></div>
                      <span style={{ fontSize: '13px', fontWeight: '600', color: voter.hasVoted ? 'var(--success)' : 'var(--warning)' }}>
                        {voter.hasVoted ? 'Voted' : 'Not Voted'}
                      </span>
                    </div>
                  </td>
                  <td style={{ padding: '16px', textAlign: 'right' }}>
                    <button 
                      onClick={() => setSelectedVoter(voter)}
                      style={{ 
                        background: 'none', 
                        border: 'none', 
                        color: 'var(--primary-blue)', 
                        cursor: 'pointer',
                        display: 'flex',
                        alignItems: 'center',
                        gap: '4px',
                        fontWeight: '700',
                        marginLeft: 'auto'
                      }}
                    >
                      View Profile <ArrowRight size={14} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          
          {filteredVoters.length === 0 && !loading && (
            <div style={{ padding: '60px', textAlign: 'center', color: 'var(--text-muted)' }}>
               <AlertCircle size={40} style={{ marginBottom: '12px', opacity: 0.3 }} />
               <p>No voters found matching your search criteria.</p>
            </div>
          )}
        </div>
      </div>

      {/* Voter Profile Modal */}
      {selectedVoter && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(0,0,0,0.85)', zIndex: 2000, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '24px', backdropFilter: 'blur(8px)' }}>
           <div className="glass" style={{ maxWidth: '500px', width: '100%', padding: '40px', borderRadius: '32px', position: 'relative' }}>
              <button 
                onClick={() => setSelectedVoter(null)}
                style={{ position: 'absolute', top: '24px', right: '24px', background: 'none', border: 'none', color: 'var(--text-secondary)', cursor: 'pointer', fontSize: '18px' }}
              >
                ✕
              </button>
              
              <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '32px' }}>
                 <div style={{ width: '80px', height: '80px', borderRadius: '40px', background: 'var(--navy-surface)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '32px', color: 'var(--text-secondary)' }}>
                   {selectedVoter.name?.charAt(0)}
                 </div>
                 <div>
                    <h2 style={{ fontSize: '24px', fontWeight: '800', marginBottom: '4px' }}>{selectedVoter.name}</h2>
                    <code style={{ background: 'rgba(37, 99, 235, 0.1)', color: 'var(--primary-blue)', padding: '4px 8px', borderRadius: '6px', fontSize: '12px', fontWeight: '800' }}>
                      {selectedVoter.epicNumber}
                    </code>
                 </div>
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '24px' }}>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>CONSTITUENCY</p>
                    <p style={{ fontWeight: '600' }}>{selectedVoter.constituency || 'N/A'}</p>
                 </div>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>AGE & GENDER</p>
                    <p style={{ fontWeight: '600' }}>{selectedVoter.age || 'N/A'} • {selectedVoter.gender || 'N/A'}</p>
                 </div>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>VOTER ID (SYSTEM)</p>
                    <p style={{ fontWeight: '600', fontSize: '13px', color: 'var(--text-secondary)', wordBreak: 'break-all' }}>{selectedVoter.voterId || selectedVoter.id}</p>
                 </div>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>ACCOUNT STATUS</p>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                       <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: 'var(--success)' }}></div>
                       <p style={{ fontWeight: '600', color: 'var(--success)' }}>Verified</p>
                    </div>
                 </div>
                 
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>VOTING STATUS</p>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                       <div style={{ width: '8px', height: '8px', borderRadius: '4px', background: selectedVoter.hasVoted ? 'var(--success)' : 'var(--warning)' }}></div>
                       <p style={{ fontWeight: '600', color: selectedVoter.hasVoted ? 'var(--success)' : 'var(--warning)' }}>{selectedVoter.hasVoted ? 'Voted' : 'Not Voted'}</p>
                    </div>
                 </div>

                 {selectedVoter.hasVoted && selectedVoter.votedAt && (
                   <div style={{ gridColumn: '1 / -1' }}>
                      <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>VOTED AT</p>
                      <p style={{ fontWeight: '600', color: 'var(--text-secondary)' }}>
                        {selectedVoter.votedAt?.seconds 
                          ? new Date(selectedVoter.votedAt.seconds * 1000).toLocaleString() 
                          : new Date(selectedVoter.votedAt).toLocaleString() || 'N/A'}
                      </p>
                   </div>
                 )}

                 <div style={{ gridColumn: '1 / -1', height: '1px', background: 'var(--navy-border)', margin: '8px 0' }}></div>

                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>FATHER'S NAME</p>
                    <p style={{ fontWeight: '600' }}>{selectedVoter.fatherName || 'N/A'}</p>
                 </div>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>DATE OF BIRTH</p>
                    <p style={{ fontWeight: '600' }}>{selectedVoter.dateOfBirth || 'N/A'}</p>
                 </div>

                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>PHONE</p>
                    <p style={{ fontWeight: '600' }}>{selectedVoter.phone || 'N/A'}</p>
                 </div>
                 <div>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>POLLING STATION</p>
                    <p style={{ fontWeight: '600', color: 'var(--primary-blue)' }}>{selectedVoter.pollingStation || 'N/A'}</p>
                 </div>

                 <div style={{ gridColumn: '1 / -1' }}>
                    <p style={{ fontSize: '11px', color: 'var(--text-muted)', fontWeight: '800', letterSpacing: '1px', marginBottom: '8px' }}>ADDRESS</p>
                    <div style={{ fontWeight: '600', lineHeight: '1.5', background: 'rgba(255,255,255,0.02)', padding: '16px', borderRadius: '12px', border: '1px solid var(--navy-border)' }}>
                      {selectedVoter.address ? (
                        <>
                          {selectedVoter.address.doorNo && `${selectedVoter.address.doorNo}, `}
                          {selectedVoter.address.street && `${selectedVoter.address.street}, `}
                          {selectedVoter.address.village && `${selectedVoter.address.village}, `}<br />
                          {selectedVoter.address.district && `${selectedVoter.address.district}, `}
                          {selectedVoter.address.state && `${selectedVoter.address.state} - `}
                          {selectedVoter.address.pincode}
                        </>
                      ) : 'N/A'}
                    </div>
                 </div>
              </div>
           </div>
        </div>
      )}

      <style jsx>{`
        .voter-row:hover {
          background: rgba(255, 255, 255, 0.02);
        }
      `}</style>
    </div>
  );
}
