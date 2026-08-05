import { NavLink } from 'react-router-dom'
import './Footer.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

export default function Footer(){
  const year = new Date().getFullYear()

  return (
    <footer className="site-footer">
      <div className="wrap footer-cta">
        
        
      </div>

      <div className="wrap footer-inner">
        <div className="footer-brand">
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" />
          <div>
            <p className="footer-name">Takam Mising Sí:sang Kébang</p>
            <p className="footer-tag">TMSK</p>
          </div>
        </div>

        <nav className="footer-nav">
          <span className="footer-col-label">Navigate</span>
          <NavLink to="/" end>Home</NavLink>
          <NavLink to="/objectives">Objectives</NavLink>
          <NavLink to="/events">Events</NavLink>
        </nav>

        <div className="footer-contact">
          <span className="footer-col-label">Get in touch</span>

          <a href="mailto:tmskyouthorg@gmail.com" className="footer-link">
            <span className="footer-link-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                <rect x="2.5" y="4.5" width="19" height="15" rx="2.5"/>
                <path d="M3 6.5l9 6.5 9-6.5"/>
              </svg>
            </span>
            <span className="footer-link-text">
              <span className="footer-link-label">Email</span>
              <span className="footer-link-value">tmskyouthorg@gmail.com</span>
            </span>
          </a>

          <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="footer-link">
            <span className="footer-link-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                <rect x="3" y="3" width="18" height="18" rx="5"/>
                <circle cx="12" cy="12" r="4.2"/>
                <circle cx="17.4" cy="6.6" r="1.1" fill="currentColor" stroke="none"/>
              </svg>
            </span>
            <span className="footer-link-text">
              <span className="footer-link-label">Instagram</span>
              <span className="footer-link-value">@tmskyouthorg</span>
            </span>
          </a>
        </div>
      </div>

      <div className="wrap footer-bottom">
        <p>&copy; {year} TMSK &mdash; Takam Mising Sí:sang Kébang. Non-profit &amp; non-partisan.</p>
        <p>Established 9 May 2026</p>
      </div>
    </footer>
  )
}