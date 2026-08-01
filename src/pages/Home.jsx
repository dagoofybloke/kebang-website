import { Link } from 'react-router-dom'
import './Home.css'

export default function Home(){
  return (
    <>
      <section className="hero wrap">
        <span className="eyebrow">A Mising youth-led movement</span>
        <h1>
          Takam Mising<br />
          Sí:sang <span className="accent">Kébang</span>
        </h1>
        <p className="hero-lede">
          An independent, non-profit, non-partisan initiative of Gen Z, dedicated
          to preserving, promoting, and strengthening the Mising language,
          culture, identity, and community &mdash; for present and future generations.
        </p>
        <div className="hero-actions">
          <a href="https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform" target="_blank" rel="noopener noreferrer" className="btn">
            Join TMSK
          </a>
          <Link to="/objectives" className="btn ghost">Our Objectives</Link>
        </div>
        <p className="manifesto-tag">
          <span className="manifesto-tag-black">Not for any political party</span>
          <span className="manifesto-tag-red">— but for our people.</span>
        </p>
      </section>

      <section className="wrap about">
        <div className="about-col">
          <span className="eyebrow">Who we are</span>
          <p>
            TMSK is unregistered but unmistakably real: a group of Mising youth
            who found each other online and decided the dilution of their
            culture was worth organising against. We speak for no government
            and no party &mdash; only for the tribe.
          </p>
        </div>

        <div className="about-col">
          <span className="eyebrow">How it began</span>
          <p>
            All founding members were brought together through an online group
            created by an anonymous user, <span className="mono-inline">"Apongrizz / Tokutaato"</span>,
            where they shared ideas, concerns, and visions. Frustrated by the
            declining progress of the tribe and the growing dilution of Mising
            culture, they chose to build an organisation to address it. TMSK
            was officially established on <strong>9th May 2026</strong>.
          </p>
        </div>

        <div className="about-col">
          <span className="eyebrow">How we're run</span>
          <p>
            Following its establishment, reforms and structural developments
            led to a finalised organisational framework. On <strong>12th July
            2026</strong>, TMSK held its first election for a six-month term,
            filling all required positions. The Board of Directors now
            oversees the organisation's vision, decisions, and operations.
          </p>
        </div>
      </section>

      <section className="wrap contact-band">
        <div className="contact-band-inner">
          <div>
            <span className="eyebrow">Get in touch</span>
            <h2>Reach the movement</h2>
          </div>
          <div className="contact-links">
            <a href="mailto:tmskyouthorg@gmail.com" className="contact-link">
              <span className="contact-link-label mono-tag">Email</span>
              <span className="contact-link-value">tmskyouthorg@gmail.com</span>
            </a>
            <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="contact-link">
              <span className="contact-link-label mono-tag">Instagram</span>
              <span className="contact-link-value">@tmskyouthorg</span>
            </a>
          </div>
        </div>
      </section>
    </>
  )
}