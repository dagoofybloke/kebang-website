import { useState } from 'react'
import { NavLink } from 'react-router-dom'
import './Header.css'

const NAV_ITEMS = [
  { to: '/', label: 'Home' },
  { to: '/objectives', label: 'Objectives' },
  { to: '/events', label: 'Events' },
]

export default function Header(){
  const [open, setOpen] = useState(false)

  return (
    <header className="site-header">
      <div className="header-inner wrap">
        <NavLink to="/" className="brand" onClick={() => setOpen(false)}>
          <img src="/logo.png" alt="TMSK logo" className="brand-mark" />
          <span className="brand-text">
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
            <span className="brand-abbr mono-tag">TMSK</span>
          </span>
        </NavLink>

        <nav className={`site-nav ${open ? 'is-open' : ''}`}>
          {NAV_ITEMS.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={() => setOpen(false)}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <button
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen(o => !o)}
        >
          <span></span><span></span><span></span>
        </button>
      </div>
      <div className="lattice-rule"></div>
    </header>
  )
}
