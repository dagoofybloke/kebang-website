import { useEffect, useState } from 'react'
import { NavLink } from 'react-router-dom'
import './Header.css'

const LEFT_ITEMS = [
  { to: '/', label: 'Home' },
  { to: '/objectives', label: 'Objectives' },
  { to: '/events', label: 'Events' },
]
const RIGHT_ITEMS = [
  { to: '/leadership', label: 'Leadership' },
  { to: '/donate', label: 'Donate' },
]
const NAV_ITEMS = [...LEFT_ITEMS, ...RIGHT_ITEMS]

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

function NavItems({ items }){
  return items.map(item => (
    <NavLink
      key={item.to}
      to={item.to}
      end={item.to === '/'}
      className={({ isActive }) => isActive ? 'is-active' : ''}
    >
      {item.label}
    </NavLink>
  ))
}

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

  useEffect(() => {
    if (!open) return undefined
    const onKey = (e) => { if (e.key === 'Escape') setOpen(false) }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open])

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''} ${open ? 'menu-open' : ''}`}>
      <div className="header-inner">
        <nav className="site-nav nav-left" aria-label="Main">
          <NavItems items={LEFT_ITEMS} />
        </nav>

        <NavLink to="/" className="brand" onClick={() => setOpen(false)}>
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" />
          <span className="brand-text">
            <span className="brand-abbr">TMSK</span>
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
          </span>
        </NavLink>

        <div className="nav-right-wrap">
          <nav className="site-nav nav-right" aria-label="More">
            <NavItems items={RIGHT_ITEMS} />
          </nav>
          <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn header-cta">
            Join
          </a>
        </div>

        <button
          type="button"
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen(o => !o)}
        >
          <span></span>
          <span></span>
        </button>
      </div>

      <div className={`mobile-menu ${open ? 'is-open' : ''}`} aria-hidden={!open}>
        <nav aria-label="Mobile">
          {NAV_ITEMS.map((item, i) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={() => setOpen(false)}
              style={{ transitionDelay: open ? `${120 + i * 70}ms` : '0ms' }}
              tabIndex={open ? 0 : -1}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="mobile-foot">
          <a
            href={JOIN_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="btn mobile-cta"
            onClick={() => setOpen(false)}
            tabIndex={open ? 0 : -1}
          >
            Join TMSK
          </a>
          <p>Takam Mising Sí:sang Kébang</p>
        </div>
      </div>
    </header>
  )
}
