import { useState } from 'react'
import { EVENT_COVER } from '../data/eventCover.js'
import './EventVisual.css'

/* The event cover panel. Shows the cover picture when there is one,
   and quietly falls back to the dark panel when there is not. */
export default function EventVisual({ className = '', children }){
  const [failed, setFailed] = useState(false)
  const has = Boolean(EVENT_COVER) && !failed

  return (
    <div className={`${className}${has ? ' has-cover' : ''}`}>
      {has && (
        <>
          <img
            className="event-cover-img"
            src={EVENT_COVER}
            alt=""
            decoding="async"
            onError={() => setFailed(true)}
          />
          <span className="event-cover-shade" aria-hidden="true"></span>
        </>
      )}
      {children}
    </div>
  )
}
