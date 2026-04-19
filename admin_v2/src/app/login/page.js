"use client";
import React, { useState, useEffect } from 'react';
import { auth } from '@/lib/firebase';
import { signInWithEmailAndPassword, onAuthStateChanged } from 'firebase/auth';
import { ShieldCheck, Lock, Mail, AlertCircle, Eye, EyeOff } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      if (user) {
        router.push('/dashboard');
      }
    });
    return () => unsubscribe();
  }, [router]);

  const handleLogin = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    
    try {
      await signInWithEmailAndPassword(auth, email, password);
      router.push('/dashboard');
    } catch (err) {
      setError('Invalid admin credentials. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{
      height: '100vh',
      width: '100vw',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'radial-gradient(circle at top right, #1e293b, #0f172a)',
      position: 'fixed',
      top: 0,
      left: 0,
      zIndex: 2000
    }}>
      <div className="glass" style={{
        width: '100%',
        maxWidth: '440px',
        padding: '48px',
        borderRadius: '32px',
        boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.5)',
        animation: 'fadeIn 0.8s ease-out'
      }}>
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <div style={{
            width: '64px',
            height: '64px',
            backgroundColor: 'var(--primary-blue)',
            borderRadius: '20px',
            display: 'inline-flex',
            alignItems: 'center',
            justifyContent: 'center',
            marginBottom: '24px',
            boxShadow: '0 0 30px var(--primary-glow)'
          }}>
            <ShieldCheck color="white" size={32} />
          </div>
          <h1 style={{ fontSize: '28px', fontWeight: '900', marginBottom: '8px' }}>SmartVote <span style={{ color: 'var(--primary-blue)' }}>Admin</span></h1>
          <p style={{ color: 'var(--text-secondary)', fontWeight: '500' }}>Terminal Access Authorization</p>
        </div>

        {error && (
          <div style={{
            padding: '12px 16px',
            background: 'rgba(239, 68, 68, 0.1)',
            border: '1px solid var(--danger)',
            borderRadius: '12px',
            color: 'var(--danger)',
            fontSize: '14px',
            fontWeight: '600',
            display: 'flex',
            alignItems: 'center',
            gap: '10px',
            marginBottom: '24px'
          }}>
            <AlertCircle size={18} />
            {error}
          </div>
        )}

        <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--primary-blue)', letterSpacing: '1px' }}>ADMIN EMAIL</label>
            <div style={{ position: 'relative' }}>
              <Mail style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} size={18} color="var(--text-secondary)" />
              <input 
                type="email" 
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@smartvote.gov" 
                style={{
                  width: '100%',
                  padding: '16px 16px 16px 48px',
                  borderRadius: '14px',
                  border: '1px solid var(--navy-border)',
                  background: 'var(--navy-surface)',
                  color: 'white',
                  outline: 'none'
                }}
              />
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <label style={{ fontSize: '12px', fontWeight: '800', color: 'var(--primary-blue)', letterSpacing: '1px' }}>SECURITY PASSPHRASE</label>
            <div style={{ position: 'relative' }}>
              <Lock style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} size={18} color="var(--text-secondary)" />
              <input 
                type={showPassword ? "text" : "password"} 
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••••••" 
                style={{
                  width: '100%',
                  padding: '16px 48px 16px 48px',
                  borderRadius: '14px',
                  border: '1px solid var(--navy-border)',
                  background: 'var(--navy-surface)',
                  color: 'white',
                  outline: 'none'
                }}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                style={{
                  position: 'absolute',
                  right: '16px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  background: 'none',
                  border: 'none',
                  cursor: 'pointer',
                  padding: '4px',
                  color: 'var(--text-secondary)',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          <button 
            type="submit" 
            disabled={loading}
            className="action-button-hover"
            style={{
              marginTop: '12px',
              padding: '18px',
              borderRadius: '14px',
              border: 'none',
              background: 'var(--primary-blue)',
              color: 'white',
              fontSize: '16px',
              fontWeight: '800',
              cursor: 'pointer',
              boxShadow: '0 10px 20px var(--primary-glow)',
              transition: 'all 0.3s ease'
            }}
          >
            {loading ? 'AUTHORIZING...' : 'SECURE LOGIN'}
          </button>
        </form>

        <p style={{ marginTop: '32px', textAlign: 'center', fontSize: '12px', color: 'var(--text-muted)' }}>
          Authorized Personnel Only. All access attempts are logged and monitored by the Sovereign Registry.
        </p>
      </div>
    </div>
  );
}
