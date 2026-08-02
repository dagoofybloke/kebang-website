import { useEffect, useState } from 'react'
import { NavLink } from 'react-router-dom'
import './Header.css'

const NAV_ITEMS = [
  { to: '/', label: 'Home' },
  { to: '/objectives', label: 'Objectives' },
  { to: '/events', label: 'Events' },
]

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

export default function Header(){
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [open])

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''} ${open ? 'menu-open' : ''}`}>
      <div className="header-inner">
        <NavLink to="/" className="brand" onClick={() => setOpen(false)}>
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" />
          <span className="brand-text">
            <span className="brand-abbr">TMSK</span>
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
          </span>
        </NavLink>

        <nav className="site-nav">
          {NAV_ITEMS.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn header-cta">
          Join TMSK
        </a>

        <button
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen(o => !o)}
        >
          <span></span>
          <span></span>
          <span></span>
        </button>
      </div>

      <div className={`mobile-menu ${open ? 'is-open' : ''}`}>
        <nav>
          {NAV_ITEMS.map((item, i) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={() => setOpen(false)}
              style={{ transitionDelay: `${i * 60}ms` }}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn mobile-cta" onClick={() => setOpen(false)}>
          Join TMSK
        </a>
      </div>
    </header>
  )
}
