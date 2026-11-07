import { Link } from 'react-router-dom'
import Reveal from '../components/Reveal.jsx'
import HeroLegacy from '../components/HeroLegacy.jsx'
import { getEventStatus } from '../data/eventStatus.js'
import './Home.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

const FACTS = [
  'Established 9 May 2026',
  'Independent',
  'Non-profit',
  'Non-partisan',
  'A Mising youth movement',
]

const OBJECTIVES_PREVIEW = [
  { n: '01', title: 'De-Mipakification of Mising Culture' },
  { n: '02', title: "Voice for Mising People's Development" },
  { n: '03', title: 'Documentation & Research of Mising Heritage' },
  { n: '04', title: 'Encouragement of Mising Agom' },
]

export default function Home(){
  const status = getEventStatus()

  return (
    <>
      {/* ---------------- HERO ---------------- */}
      <section className="hero">
        <div className="wrap hero-inner">
          <div className="hero-copy">
            <Reveal as="span" className="eyebrow">A Mising youth-led movement</Reveal>

            <Reveal as="h1" delay={80} className="hero-title">
              Takam Mising<br />
              Sí:sang <span className="hero-title-red">Kébang</span>
            </Reveal>

            <Reveal delay={180} className="hero-quotes">
              <p>&ldquo;We are here for our people, not for any political party&rdquo;</p>
              <p>&ldquo;We are here to preserve our culture, identity, and history.&rdquo;</p>
            </Reveal>

            <Reveal delay={280} className="hero-actions">
              <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn">
                Join TMSK
              </a>
              <Link to="/objectives" className="btn ghost">Our Objectives</Link>
            </Reveal>
          </div>

          <HeroLegacy />
        </div>

        <a href="#about" className="hero-scroll" aria-label="Scroll to read about TMSK">
          <span>Scroll</span>
        </a>
      </section>

      {/* ---------------- FACTS RIBBON ---------------- */}
      <div className="facts" aria-label="About TMSK in brief">
        <div className="facts-track">
          {[0, 1].map(group => (
            <div className="facts-group" key={group} aria-hidden={group === 1 ? 'true' : undefined}>
              {[...FACTS, ...FACTS].map((text, i) => (
                <span className="facts-item" key={`${group}-${i}`}>
                  {text}<i></i>
                </span>
              ))}
            </div>
          ))}
        </div>
      </div>

      {/* ---------------- ABOUT ---------------- */}
      <section className="about" id="about">
        <div className="wrap about-inner">
          <div className="about-intro">
            <Reveal as="span" className="eyebrow">Who we are</Reveal>
            <Reveal as="h2" delay={80}>
              Unregistered,<br /><em>unmistakably</em> real.
            </Reveal>
            <Reveal as="p" delay={160} className="about-lede">
              TMSK is unregistered but unmistakably real &mdash; a group of Mising youth
              who found each other online and decided the dilution of their
              culture was worth organising against.
            </Reveal>
          </div>

          <ol className="timeline">
            <Reveal as="li" delay={100}>
              <span className="tl-num">01</span>
              <h3>How it began</h3>
              <p>
                All founding members were brought together through an online
                group created by an anonymous user, <em>&ldquo;Apongrizz /
                Tokutaato&rdquo;</em>, where they shared ideas, concerns, and
                visions for the tribe.
              </p>
            </Reveal>

            <Reveal as="li" delay={140}>
              <span className="tl-num">02</span>
              <h3>Why we exist</h3>
              <p>
                Frustrated by the declining progress of the tribe and the
                growing dilution of Mising culture, we chose to build an
                organisation to address it directly. TMSK was officially
                established on <strong>9th May 2026</strong>.
              </p>
            </Reveal>

            <Reveal as="li" delay={180}>
              <span className="tl-num">03</span>
              <h3>How we&rsquo;re run</h3>
              <p>
                On <strong>12th July 2026</strong>, TMSK held its first
                election for a six-month term, filling all required positions.
                The Board of Directors now oversees the organisation&rsquo;s vision,
                decisions, and operations.
              </p>
            </Reveal>
          </ol>
        </div>
      </section>

      {/* ---------------- STATEMENT ---------------- */}
      <section className="statement">
        <div className="wrap">
          <Reveal as="span" className="eyebrow on-dark">Our promise</Reveal>
          <Reveal as="p" delay={100} className="statement-text">
            We speak for no government and no political party &mdash;{' '}
            <em>we speak only for our people.</em>
          </Reveal>
        </div>
      </section>

      {/* ---------------- OBJECTIVES preview ---------------- */}
      <section className="objectives-preview">
        <div className="wrap">
          <div className="section-head">
            <Reveal as="span" className="eyebrow">What we stand for</Reveal>
            <Reveal as="h2" delay={80}>Seven objectives.<br /><em>One direction.</em></Reveal>
          </div>

          <div className="obj-preview-list">
            {OBJECTIVES_PREVIEW.map((o, i) => (
              <Reveal
                as={Link}
                to="/objectives"
                delay={i * 90}
                key={o.n}
                className="obj-preview-row"
              >
                <span className="ghost-num">{o.n}</span>
                <h4>{o.title}</h4>
                <span className="obj-preview-arrow" aria-hidden="true">&rarr;</span>
              </Reveal>
            ))}
          </div>

          <Reveal delay={160} className="objectives-cta">
            <Link to="/objectives" className="btn ghost">
              See all seven objectives
            </Link>
          </Reveal>
        </div>
      </section>

      {/* ---------------- EVENTS preview ---------------- */}
      <section className="wrap events-preview">
        <div className="section-head">
          <Reveal as="span" className="eyebrow">What&rsquo;s happening</Reveal>
          <Reveal as="h2" delay={80}>{status.headline}</Reveal>
        </div>

        <Reveal delay={140} className="event-preview-card">
          <div className="event-preview-visual">
            <span className="event-preview-tag">Visual Art Competition</span>
            <span className="status-pill" data-status={status.key}>
              <i></i>{status.label}
            </span>
          </div>
          <div className="event-preview-body">
            <h3>TMSK Art Online Competition</h3>
            <p>
              An online visual art competition open to all. AI-generated art
              will be rejected &mdash; submissions must be genuinely made.
            </p>
            <div className="event-preview-meta">
              <div><span>{status.closesLabel}</span><strong>31 Aug 2026</strong></div>
              <div><span>Entry fee</span><strong>₹75</strong></div>
              <div><span>Top prize</span><strong>₹1,000</strong></div>
            </div>
            <Link to="/events" className="btn">View Event Details</Link>
          </div>
        </Reveal>
      </section>
    </>
  )
}
