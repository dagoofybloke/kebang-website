import { useEffect, useRef, useState } from 'react'
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
  const toggleRef = useRef(null)
  const firstMenuLinkRef = useRef(null)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  // Lock body scroll while the mobile menu is open (also freezes the
  // scroll position so iOS Safari can't rubber-band the page behind it).
  useEffect(() => {
    if (!open) return
    const scrollY = window.scrollY
    const { style } = document.body
    style.position = 'fixed'
    style.top = `-${scrollY}px`
    style.left = '0'
    style.right = '0'
    style.width = '100%'
    return () => {
      style.position = ''
      style.top = ''
      style.left = ''
      style.right = ''
      style.width = ''
      window.scrollTo(0, scrollY)
    }
  }, [open])

  // Close on Escape, move focus into the panel on open and back to
  // the toggle button on close, so keyboard users never get lost.
  useEffect(() => {
    if (open){
      firstMenuLinkRef.current?.focus()
      const onKeyDown = e => { if (e.key === 'Escape') setOpen(false) }
      document.addEventListener('keydown', onKeyDown)
      return () => document.removeEventListener('keydown', onKeyDown)
    }
  }, [open])

  const closeMenu = () => setOpen(false)

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''} ${open ? 'menu-open' : ''}`}>
      <div className="header-inner wrap">
        <NavLink to="/" className="brand" onClick={closeMenu}>
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" width="40" height="40" />
          <span className="brand-text">
            <span className="brand-abbr">TMSK</span>
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
          </span>
        </NavLink>

        <nav className="site-nav" aria-label="Primary">
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
          ref={toggleRef}
          type="button"
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          aria-controls="mobile-menu"
          onClick={() => setOpen(o => !o)}
        >
          <span aria-hidden="true"></span><span aria-hidden="true"></span>
        </button>
      </div>

      <div
        id="mobile-menu"
        className={`mobile-menu ${open ? 'is-open' : ''}`}
        aria-hidden={!open}
      >
        <nav aria-label="Mobile">
          {NAV_ITEMS.map((item, i) => (
            <NavLink
              key={item.to}
              ref={i === 0 ? firstMenuLinkRef : undefined}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={closeMenu}
              tabIndex={open ? 0 : -1}
              style={{ transitionDelay: `${i * 60}ms` }}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <a
          href={JOIN_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="btn mobile-cta"
          tabIndex={open ? 0 : -1}
          onClick={closeMenu}
        >
          Join TMSK
        </a>
      </div>
    </header>
  )
}
