import { useEffect, useState } from 'react'
import './EventPopup.css'

const SEEN_KEY = 'tmsk_event_popup_seen'
const REGISTER_URL = 'https://docs.google.com/forms/d/1mbJFR53KfgaMFuwOZ7NbxB3_t9-_45dYc51Xy_QvIE8/edit'

export default function EventPopup(){
  const [visible, setVisible] = useState(false)

  useEffect(() => {
    if (sessionStorage.getItem(SEEN_KEY)) return
    const timer = setTimeout(() => setVisible(true), 900)
    return () => clearTimeout(timer)
  }, [])

  const dismiss = () => {
    setVisible(false)
    sessionStorage.setItem(SEEN_KEY, '1')
  }

  if (!visible) return null

  return (
    <div className="event-popup-overlay" onClick={dismiss}>
      <div className="event-popup" role="dialog" aria-label="Event registration" onClick={e => e.stopPropagation()}>
        <button className="event-popup-close" aria-label="Close" onClick={dismiss}>&times;</button>
        <span className="event-popup-tag mono-tag">Registration open</span>
        <p className="event-popup-title">TMSK Art Online Competition</p>
        <p className="event-popup-sub">Registration closes 31 Aug 2026 &middot; Entry fee ₹75</p>
        <a
          href={REGISTER_URL}
          target="_blank"
          rel="noopener noreferrer"
          className="btn event-popup-btn"
          onClick={dismiss}
        >
          Register Now
        </a>
      </div>
    </div>
  )
}