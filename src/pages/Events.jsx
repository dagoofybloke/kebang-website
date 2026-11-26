import Reveal from '../components/Reveal.jsx'
import EventVisual from '../components/EventVisual.jsx'
import { getEventStatus } from '../data/eventStatus.js'
import './Events.css'

const EVENTS = [
  {
    n: '01',
    tag: 'Visual Art Competition',
    title: 'TMSK Art Online Competition',
    blurb: `An online visual art competition open to all. This event ended on 13th September 2026. AI-generated art was rejected.`,
    details: [
      { label: 'Event ended', value: '13 September 2026' },
      { label: 'Submission window', value: '4 – 13 September 2026' },
      { label: 'Registration closed', value: '31 August 2026' },
      { label: 'Entry fee was', value: '₹75/-' },
    ],
    prizes: [
      { place: '1st', amount: '₹1000/-', winner: 'krnsponge' },
      { place: '2nd', amount: '₹500/-', winner: 'Binanda Mili' },
      { place: '3rd', amount: '₹300/-', winner: 'Geetika Pegu' },
    ],
    registerUrl: 'https://docs.google.com/forms/d/1mbJFR53KfgaMFuwOZ7NbxB3_t9-_45dYc51Xy_QvIE8/edit',
  },
]

export default function Events(){
  const status = getEventStatus()

  return (
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">What&rsquo;s happening</Reveal>
        <Reveal as="h1" delay={80}>Events</Reveal>
      </header>

      <section className="wrap events-list">
        {EVENTS.map((ev, i) => (
          <Reveal as="article" delay={i * 100} className="event-card" key={ev.n}>
            <EventVisual className="event-card-visual">
              <div className="event-card-top">
                <span className="event-card-tag">{ev.tag}</span>
                <span className="status-pill" data-status={status.key}>
                  <i></i>{status.label}
                </span>
              </div>
              <span className="ghost-num event-card-num">{ev.n}</span>
            </EventVisual>

            <div className="event-card-body">
              <h2>{ev.title}</h2>
              <p className="event-blurb">{ev.blurb}</p>

              <div className="event-details">
                {ev.details.map(d => (
                  <div className="event-detail" key={d.label}>
                    <span className="event-detail-label">{d.label}</span>
                    <span className="event-detail-value">{d.value}</span>
                  </div>
                ))}
              </div>

              <div className="event-prizes">
                {ev.prizes.map(p => (
                  <div className="prize-pill" key={p.place}>
                    <span>{p.place}</span>
                    <strong>{p.amount}</strong>
                    {p.winner && <span className="prize-winner">{p.winner}</span>}
                  </div>
                ))}
              </div>

              {status.key === 'open' && (
                <div className="event-actions">
                  <a href={ev.registerUrl} target="_blank" rel="noopener noreferrer" className="btn">
                    Register now
                  </a>
                </div>
              )}
            </div>
          </Reveal>
        ))}
      </section>
    </>
  )
}
