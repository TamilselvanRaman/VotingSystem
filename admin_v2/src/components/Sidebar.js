"use client";
import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  BarChart3, 
  Users, 
  Settings, 
  Activity, 
  ShieldCheck, 
  LogOut 
} from 'lucide-react';
import { auth } from '@/lib/firebase';
import { signOut } from 'firebase/auth';

const Sidebar = () => {
  const pathname = usePathname();

  const handleLogout = async () => {
    try {
      await signOut(auth);
      window.location.href = "/login";
    } catch (error) {
      console.error("Logout error:", error);
    }
  };

  return (
    <aside className="glass" style={{
      width: 'var(--sidebar-width)',
      height: '100vh',
      position: 'fixed',
      left: 0,
      top: 0,
      display: 'flex',
      flexDirection: 'column',
      padding: '40px 24px',
      zIndex: 1000,
      borderRight: '1px solid var(--glass-border)'
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '60px' }}>
        <div style={{
          width: '40px',
          height: '40px',
          backgroundColor: 'var(--primary-blue)',
          borderRadius: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 0 20px var(--primary-glow)'
        }}>
          <ShieldCheck color="white" size={24} />
        </div>
        <h1 style={{ fontSize: '20px', fontWeight: '800', letterSpacing: '-0.5px' }}>
          SmartVote <span style={{ color: 'var(--primary-blue)' }}>Admin</span>
        </h1>
      </div>

      <nav style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <NavItem href="/dashboard" icon={<BarChart3 size={20} />} label="Overview" active={pathname === '/dashboard'} />
        <NavItem href="/dashboard/live" icon={<Activity size={20} />} label="Live Results" active={pathname === '/dashboard/live'} />
        <NavItem href="/dashboard/voters" icon={<Users size={20} />} label="Voter Directory" active={pathname === '/dashboard/voters'} />
        <NavItem href="/dashboard/settings" icon={<Settings size={20} />} label="System Config" active={pathname === '/dashboard/settings'} />
      </nav>

      <div style={{ marginTop: 'auto', paddingTop: '24px', borderTop: '1px solid var(--glass-border)' }}>
        <button 
          onClick={handleLogout}
          style={{
            display: 'flex',
            alignItems: 'center',
            gap: '12px',
            width: '100%',
            padding: '12px',
            borderRadius: '12px',
            border: 'none',
            background: 'transparent',
            color: 'var(--danger)',
            fontWeight: '600',
            cursor: 'pointer',
            transition: 'all 0.2s ease'
          }}
        >
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </aside>
  );
};

const NavItem = ({ href, icon, label, active }) => (
  <Link 
    href={href} 
    style={{
      display: 'flex',
      alignItems: 'center',
      gap: '12px',
      padding: '14px 16px',
      borderRadius: '14px',
      color: active ? 'var(--text-primary)' : 'var(--text-secondary)',
      backgroundColor: active ? 'rgba(37, 99, 235, 0.15)' : 'transparent',
      transition: 'all 0.2s ease',
      position: 'relative',
      fontWeight: active ? '600' : '500'
    }}
  >
    {active && <div style={{ 
      position: 'absolute', 
      left: 0, 
      width: '4px', 
      height: '24px', 
      backgroundColor: 'var(--primary-blue)',
      borderRadius: '0 4px 4px 0'
    }} />}
    <span style={{ color: active ? 'var(--primary-blue)' : 'inherit' }}>{icon}</span>
    {label}
  </Link>
);

export default Sidebar;
