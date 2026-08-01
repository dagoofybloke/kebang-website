import { NavLink } from 'react-router-dom'
import './Footer.css'

export default function Footer(){
  const year = new Date().getFullYear()

  return (
    <footer className="site-footer">
      <div className="lattice-rule"></div>
      <div className="wrap footer-inner">
        <div className="footer-brand">
          <img src="/logo.png" alt="TMSK logo" className="brand-mark" />
          <div>
            <p className="footer-name">Takam Mising Sí:sang Kébang</p>
            <p className="footer-tag mono-tag">TMSK</p>
          </div>
        </div>

        <nav className="footer-nav">
          <span className="eyebrow">Navigate</span>
          <NavLink to="/" end>Home</NavLink>
          <NavLink to="/objectives">Objectives</NavLink>
          <NavLink to="/events">Events</NavLink>
        </nav>

        <div className="footer-contact">
          <span className="eyebrow">Contact</span>
          <a href="mailto:tmskyouthorg@gmail.com" className="footer-email">tmskyouthorg@gmail.com</a>
          <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="footer-email">@tmskyouthorg</a>
        </div>
      </div>

      <div className="wrap footer-bottom">
        <p>&copy; {year} TMSK &mdash; Takam Mising Sí:sang Kébang. Non-profit &amp; non-partisan.</p>
        <p>Established 9 May 2026</p>
      </div>
    </footer>
  )
}
