"use client";
import React from 'react';
import { Search, Bell, UserCircle2 } from 'lucide-react';
import { usePathname } from 'next/navigation';

const Header = () => {
  const pathname = usePathname();
  
  const getPageTitle = (path) => {
    if (path.includes('/dashboard/live')) return 'Live Statistics';
    if (path.includes('/dashboard/voters')) return 'Voter Directory';
    if (path.includes('/dashboard/settings')) return 'System Settings';
    if (path === '/dashboard') return 'Admin Overview';
    return 'Admin Panel';
  };

  return (
    <header className="glass" style={{
      height: '80px',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 40px',
      position: 'sticky',
      top: 0,
      borderBottom: '1px solid var(--glass-border)',
      background: 'rgba(15, 23, 42, 0.5)',
      zIndex: 900
    }}>
      <div>
        <h2 style={{ fontSize: '24px', fontWeight: '800', margin: 0 }}>
          {getPageTitle(pathname)}
        </h2>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '32px' }}>
        <div style={{ position: 'relative' }}>
          <Search 
            style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)' }} 
            size={18} 
            color="var(--text-secondary)" 
          />
          <input 
            type="text" 
            placeholder="Search Voter ID or Candidate..." 
            style={{
              padding: '12px 18px 12px 48px',
              borderRadius: '12px',
              border: 'none',
              background: 'var(--navy-surface)',
              color: 'var(--text-primary)',
              width: '320px',
              fontSize: '14px',
              outline: 'none',
              border: '1px solid var(--navy-border)'
            }}
          />
        </div>

        <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
          <div style={{ position: 'relative', cursor: 'pointer' }}>
            <Bell size={22} color="var(--text-secondary)" />
            <div style={{
              position: 'absolute',
              top: '-2px',
              right: '-2px',
              width: '10px',
              height: '10px',
              background: 'var(--danger)',
              border: '2px solid var(--navy-deep)',
              borderRadius: '50%'
            }} />
          </div>
          
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px', background: 'var(--navy-surface)', padding: '6px 16px 6px 6px', borderRadius: '30px', cursor: 'pointer', border: '1px solid var(--navy-border)' }}>
            <div style={{ 
              width: '32px', 
              height: '32px', 
              borderRadius: '50%', 
              background: 'linear-gradient(135deg, var(--primary-blue), var(--accent-cyan))',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center'
            }}>
              <UserCircle2 color="white" size={20} />
            </div>
            <span style={{ fontSize: '14px', fontWeight: '600' }}>Voter Admin</span>
          </div>
        </div>
      </div>
    </header>
  );
};

export default Header;
