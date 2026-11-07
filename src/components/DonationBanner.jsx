import { useEffect, useState } from 'react'
import { Link, useLocation } from 'react-router-dom'
import './DonationBanner.css'

// ---- Easy settings ----
const SHOW_ON = ['/']          // pages that show the notification ('/' = home page)
const SHOW_DELAY_MS = 1200     // wait before sliding in
const AUTO_HIDE_MS = 20000     // hide by itself after this long (0 = stay until closed)
const STORAGE_KEY = 'tmsk-donation-banner-closed'
const MESSAGE_TITLE = 'Support TMSK'
const MESSAGE_TEXT = 'Your donation helps us carry our work for the Mising community forward.'

function wasClosed() {
  try {
    return sessionStorage.getItem(STORAGE_KEY) === '1'
  } catch {
    return false
  }
}

export default function DonationBanner() {
  const { pathname } = useLocation()
  const eligible = SHOW_ON.includes(pathname)
  const [visible, setVisible] = useState(false)
  const [top, setTop] = useState(12)

  // Slide in shortly after the home page opens; slide out when leaving it
  useEffect(() => {
    if (!eligible || wasClosed()) {
      setVisible(false)
      return undefined
    }
    const showTimer = setTimeout(() => setVisible(true), SHOW_DELAY_MS)
    const hideTimer =
      AUTO_HIDE_MS > 0 ? setTimeout(() => setVisible(false), SHOW_DELAY_MS + AUTO_HIDE_MS) : null
    return () => {
      clearTimeout(showTimer)
      if (hideTimer) clearTimeout(hideTimer)
      setVisible(false)
    }
  }, [eligible])

  // Keep it just under the site header
  useEffect(() => {
    if (!visible) return undefined
    const measure = () => {
      const header = document.querySelector('.site-header')
      const bottom = header ? Math.max(Math.round(header.getBoundingClientRect().bottom), 0) : 0
      setTop(bottom + 10)
    }
    measure()
    window.addEventListener('scroll', measure, { passive: true })
    window.addEventListener('resize', measure)
    return () => {
      window.removeEventListener('scroll', measure)
      window.removeEventListener('resize', measure)
    }
  }, [visible])

  const close = () => {
    try {
      sessionStorage.setItem(STORAGE_KEY, '1')
    } catch {
      /* ignore */
    }
    setVisible(false)
  }

  // Esc also closes it
  useEffect(() => {
    if (!visible) return undefined
    const onKey = (e) => {
      if (e.key === 'Escape') close()
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [visible])

  if (!eligible) return null

  return (
    <div
      className={visible ? 'donation-banner is-visible' : 'donation-banner'}
      style={{ '--banner-top': `${top}px` }}
      role="status"
      aria-live="polite"
      aria-hidden={!visible}
    >
      <span className="donation-banner-icon" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="22" height="22">
          <path
            d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
            fill="currentColor"
          />
        </svg>
      </span>
      <p className="donation-banner-text">
        <strong>{MESSAGE_TITLE}</strong>
        <span>{MESSAGE_TEXT}</span>
      </p>
      <Link to="/donate" className="donation-banner-cta" onClick={close}>
        Donate
      </Link>
      <button
        type="button"
        className="donation-banner-close"
        onClick={close}
        aria-label="Cancel and close this notification"
      >
        &times;
      </button>
    </div>
  )
}
