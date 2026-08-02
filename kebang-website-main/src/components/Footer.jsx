import { NavLink } from 'react-router-dom'
import './Footer.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

export default function Footer(){
  const year = new Date().getFullYear()

  return (
    <footer className="site-footer">
      <div className="wrap footer-cta">
        <h2>Join the movement.<br /><span>Not for any political party, but for our people.</span></h2>
        <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn on-dark">
          Join TMSK
        </a>
      </div>

      <div className="wrap footer-inner">
        <div className="footer-brand">
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" width="46" height="46" loading="lazy" decoding="async" />
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
          <span className="footer-col-label">Contact</span>
          <a href="mailto:tmskyouthorg@gmail.com" className="footer-link">tmskyouthorg@gmail.com</a>
          <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="footer-link">@tmskyouthorg</a>
        </div>
      </div>

      <div className="stripe-rule" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>

      <div className="wrap footer-bottom">
        <p>&copy; {year} TMSK &mdash; Takam Mising Sí:sang Kébang. Non-profit &amp; non-partisan.</p>
        <p>Established 9 May 2026</p>
      </div>
    </footer>
  )
}
