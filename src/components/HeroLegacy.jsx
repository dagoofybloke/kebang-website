import { useEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import './HeroLegacy.css'

const BASE = '/assets/legacy'

// sparks spread across the whole width (fixed values, so nothing flickers on re-render)
const EMBERS = Array.from({ length: 24 }, (_, i) => ({
  x: 2 + ((i * 41) % 96),
  s: 3 + (i % 4),
  d: 9 + (i % 6) * 1.7,
  dl: -((i * 2.3) % 14),
  dx: (i % 2 ? 1 : -1) * (14 + (i % 4) * 14),
}))

// four faded banners hanging across the hero: big at the edges, small further in
const BANNERS = [
  { id: 'lw', slot: 'lg-b-lw', kind: 'warrior', img: 'abotani' },
  { id: 'ls', slot: 'lg-b-ls', kind: 'swords', img: 'yoksaerkok' },
  { id: 'rs', slot: 'lg-b-rs', kind: 'swords', img: 'yoksaerkok' },
  { id: 'rw', slot: 'lg-b-rw', kind: 'warrior', img: 'abotani' },
]

/* everything decorative lives across the WHOLE hero, behind the text and flag */
function Decor(){
  return (
    <div className="lg-decor" aria-hidden="true">
      {BANNERS.map(b => (
        <div className={`lg-layer lg-banner-slot ${b.slot}`} key={b.id}>
          <div className={`lg-banner lg-banner--${b.kind}`}>
            <div className="lg-cloth">
              <img src={`${BASE}/${b.img}.webp`} alt="" decoding="async" />
              <span className="lg-shine"></span>
            </div>
          </div>
        </div>
      ))}

      <div className="lg-embers">
        {EMBERS.map((e, i) => (
          <i
            className="lg-ember"
            key={i}
            style={{
              '--x': `${e.x}%`,
              '--s': `${e.s}px`,
              '--d': `${e.d}s`,
              '--dl': `${e.dl}s`,
              '--dx': `${e.dx}px`,
            }}
          ></i>
        ))}
      </div>

      {/* the two portraits keep marching in their own corner of the hero */}
      <div className="lg-walker lg-walker--a">
        <div className="lg-step">
          <img src={`${BASE}/portrait-1.webp`} alt="" decoding="async" />
        </div>
      </div>
      <div className="lg-walker lg-walker--b">
        <div className="lg-step">
          <img src={`${BASE}/portrait-2.webp`} alt="" decoding="async" />
        </div>
      </div>
    </div>
  )
}

/* the TMSK flag: the main thing, in the centre */
export default function HeroLegacy(){
  const rootRef = useRef(null)
  const [heroEl, setHeroEl] = useState(null)

  useEffect(() => {
    const hero = rootRef.current ? rootRef.current.closest('.hero') : null
    if (!hero) return undefined
    setHeroEl(hero)

    // gentle depth: layers drift a little as the mouse moves (computers only)
    const fine = window.matchMedia('(hover: hover) and (pointer: fine)').matches
    const calm = window.matchMedia('(prefers-reduced-motion: reduce)').matches
    if (!fine || calm) return undefined

    let raf = 0
    const onMove = (e) => {
      cancelAnimationFrame(raf)
      raf = requestAnimationFrame(() => {
        const r = hero.getBoundingClientRect()
        hero.style.setProperty('--px', (((e.clientX - r.left) / r.width - 0.5) * 2).toFixed(3))
        hero.style.setProperty('--py', (((e.clientY - r.top) / r.height - 0.5) * 2).toFixed(3))
      })
    }
    const onLeave = () => {
      hero.style.setProperty('--px', '0')
      hero.style.setProperty('--py', '0')
    }
    hero.addEventListener('pointermove', onMove)
    hero.addEventListener('pointerleave', onLeave)
    return () => {
      cancelAnimationFrame(raf)
      hero.removeEventListener('pointermove', onMove)
      hero.removeEventListener('pointerleave', onLeave)
    }
  }, [])

  return (
    <div className="hero-flag lg-root" ref={rootRef}>
      <div className="lg-flagstage">
        <div className="lg-sun" aria-hidden="true"></div>
        <div className="lg-flagcard">
          <div className="lg-flag">
            <div className="lg-flagpic">
              <img src="/assets/flag.jpg" alt="Flag of Takam Mising Sí:sang Kébang" />
              <span className="lg-shine"></span>
            </div>
            <span className="lg-badge">
              <span>EST.</span>
              <strong>2026</strong>
            </span>
          </div>
        </div>
      </div>
      {heroEl ? createPortal(<Decor />, heroEl) : null}
    </div>
  )
}
