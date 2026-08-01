import { Link } from 'react-router-dom'
import Reveal from '../components/Reveal.jsx'
import './Home.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

const OBJECTIVES_PREVIEW = [
  { n: '01', title: 'De-Mipakification of Mising Culture' },
  { n: '02', title: "Voice for Mising People's Development" },
  { n: '03', title: 'Documentation & Research of Mising Heritage' },
  { n: '04', title: 'Encouragement of Mising Agom' },
]

export default function Home(){
  return (
    <>
      {/* ---------------- HERO ---------------- */}
      <section className="hero">
        <div className="hero-bg-stripes" aria-hidden="true">
          <span></span><span></span><span></span>
        </div>

        <div className="wrap hero-inner">
          <div className="hero-copy">
            <Reveal as="span" className="eyebrow">A Mising youth-led movement</Reveal>

            <Reveal as="h1" delay={80} className="hero-title">
              TAKAM MISING<br />
              SÍ:SANG <span className="hero-title-red">KÉBANG</span>
            </Reveal>

            <Reveal delay={160} className="hero-quotes">
              <p>&ldquo;We are here for our people, not for any political party.&rdquo;</p>
              <p>&ldquo;We are here to preserve our culture, identity, and history.&rdquo;</p>
            </Reveal>

            <Reveal delay={240} className="hero-actions">
              <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn">
                Join TMSK
              </a>
              <Link to="/objectives" className="btn ghost">Our Objectives</Link>
            </Reveal>
          </div>

          <Reveal delay={200} className="hero-flag">
            <div className="hero-flag-frame">
              <img src="/assets/flag.jpg" alt="Flag of Takam Mising Sí:sang Kébang" />
              <span className="hero-flag-badge">
                <span>EST.</span>
                <strong>2026</strong>
              </span>
            </div>
          </Reveal>
        </div>

        <div className="stripe-rule" aria-hidden="true"><span></span><span></span><span></span><span></span><span></span></div>
      </section>

      {/* ---------------- ABOUT — editorial ---------------- */}
      <section className="wrap about">
        <Reveal as="span" className="eyebrow">Who we are</Reveal>

        <Reveal as="p" delay={80} className="about-lede">
          TMSK is unregistered but unmistakably real — a group of Mising youth
          who found each other online and decided the dilution of their
          culture was worth organising against.
        </Reveal>

        <div className="about-grid">
          <Reveal delay={120} className="about-block">
            <span className="about-block-num">01</span>
            <h3>How it began</h3>
            <p>
              All founding members were brought together through an online
              group created by an anonymous user, <em>&ldquo;Apongrizz /
              Tokutaato&rdquo;</em>, where they shared ideas, concerns, and
              visions for the tribe.
            </p>
          </Reveal>

          <Reveal delay={200} className="about-block">
            <span className="about-block-num">02</span>
            <h3>Why we exist</h3>
            <p>
              Frustrated by the declining progress of the tribe and the
              growing dilution of Mising culture, we chose to build an
              organisation to address it directly. TMSK was officially
              established on <strong>9th May 2026</strong>.
            </p>
          </Reveal>

          <Reveal delay={280} className="about-block">
            <span className="about-block-num">03</span>
            <h3>How we're run</h3>
            <p>
              On <strong>12th July 2026</strong>, TMSK held its first
              election for a six-month term, filling all required positions.
              The Board of Directors now oversees the organisation's vision,
              decisions, and operations.
            </p>
          </Reveal>
        </div>

        <Reveal delay={120} className="about-statement">
          <p>
            <span className="statement-black">We speak for no government and no political party</span>
            <span className="statement-red"> — only for our people.</span>
          </p>
        </Reveal>
      </section>

      {/* ---------------- OBJECTIVES preview ---------------- */}
      <section className="objectives-preview">
        <div className="wrap">
          <div className="section-head">
            <Reveal as="span" className="eyebrow">What we stand for</Reveal>
            <Reveal as="h2" delay={80}>Seven objectives.<br />One direction.</Reveal>
          </div>

          <div className="obj-preview-list">
            {OBJECTIVES_PREVIEW.map((o, i) => (
              <Reveal as="div" delay={i * 90} key={o.n} className="obj-preview-row">
                <span className="ghost-num">{o.n}</span>
                <h4>{o.title}</h4>
                <span className="obj-preview-arrow" aria-hidden="true">&rarr;</span>
              </Reveal>
            ))}
          </div>

          <Reveal delay={160}>
            <Link to="/objectives" className="btn ghost objectives-cta">
              See all seven objectives
            </Link>
          </Reveal>
        </div>
      </section>

      {/* ---------------- EVENTS preview ---------------- */}
      <section className="wrap events-preview">
        <div className="section-head">
          <Reveal as="span" className="eyebrow">What's happening</Reveal>
          <Reveal as="h2" delay={80}>Currently open</Reveal>
        </div>

        <Reveal delay={140} className="event-preview-card">
          <div className="event-preview-visual">
            <span className="event-preview-tag">Visual Art Competition</span>
          </div>
          <div className="event-preview-body">
            <h3>TMSK Online Art Competition</h3>
            <p>
              An online visual art competition open to all. AI-generated art
              will be rejected — submissions must be genuinely made.
            </p>
            <div className="event-preview-meta">
              <div><span>Registration closes</span><strong>31 Aug 2026</strong></div>
              <div><span>Entry fee</span><strong>₹75</strong></div>
              <div><span>Top prize</span><strong>₹1,000</strong></div>
            </div>
            <Link to="/events" className="btn">View Event Details</Link>
          </div>
        </Reveal>
      </section>

      {/* ---------------- CONTACT BAND ---------------- */}
      <section className="contact-band">
        <div className="wrap contact-band-inner">
          <Reveal>
            <span className="eyebrow">Get in touch</span>
            <h2>Reach the movement</h2>
          </Reveal>
          <Reveal delay={100} className="contact-links">
            <a href="mailto:tmskyouthorg@gmail.com" className="contact-link">
              <span className="contact-link-label">Email</span>
              <span className="contact-link-value">tmskyouthorg@gmail.com</span>
            </a>
            <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="contact-link">
              <span className="contact-link-label">Instagram</span>
              <span className="contact-link-value">@tmskyouthorg</span>
            </a>
          </Reveal>
        </div>
      </section>
    </>
  )
}
