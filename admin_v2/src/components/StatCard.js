import React from 'react';

const StatCard = ({ title, value, icon, color, trend }) => {
  return (
    <div className="glass" style={{
      padding: '24px',
      borderRadius: '24px',
      flex: 1,
      minWidth: '240px',
      display: 'flex',
      flexDirection: 'column',
      gap: '16px',
      boxShadow: 'var(--card-shadow)',
      position: 'relative',
      overflow: 'hidden'
    }}>
      {/* Background Decor */}
      <div style={{
        position: 'absolute',
        right: '-10px',
        top: '-10px',
        opacity: 0.1,
        color: color
      }}>
        {React.cloneElement(icon, { size: 100 })}
      </div>

      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <div style={{
          width: '48px',
          height: '48px',
          borderRadius: '16px',
          backgroundColor: `${color}20`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          color: color
        }}>
          {React.cloneElement(icon, { size: 24 })}
        </div>
        
        {trend && (
          <div style={{
            fontSize: '12px',
            fontWeight: '700',
            color: trend.startsWith('+') ? 'var(--success)' : 'var(--danger)',
            background: trend.startsWith('+') ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
            padding: '4px 8px',
            borderRadius: '8px'
          }}>
            {trend}
          </div>
        )}
      </div>

      <div>
        <p style={{ color: 'var(--text-secondary)', fontSize: '14px', fontWeight: '600', marginBottom: '4px' }}>
          {title}
        </p>
        <h3 style={{ fontSize: '32px', fontWeight: '900', letterSpacing: '-1px' }}>
          {value}
        </h3>
      </div>
    </div>
  );
};

export default StatCard;
