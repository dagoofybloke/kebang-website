import './Events.css'

const EVENTS = [
  {
    n: '01',
    tag: 'Visual Art Competition',
    title: 'TMSK Art Online Competition',
    blurb: `An online visual art competition open to all. The topic will be shared with registered participants on 1st September 2026. AI-generated art will be rejected.`,
    details: [
      { label: 'Registration closes', value: '31 August 2026' },
      { label: 'Submission window', value: '4 – 13 September 2026' },
      { label: 'Entry fee', value: '₹75/-' },
      { label: 'Contact', value: '+91 70858 80388' },
    ],
    prizes: [
      { place: '1st', amount: '₹1000/-' },
      { place: '2nd', amount: '₹500/-' },
      { place: '3rd', amount: '₹300/-' },
    ],
    note: `Prize money is subject to increase depending on the total number of participants. Winners get free participation in the Creators Pop-up Program in Pasighat.`,
    registerUrl: 'https://docs.google.com/forms/d/1mbJFR53KfgaMFuwOZ7NbxB3_t9-_45dYc51Xy_QvIE8/edit',
    credit: 'Sumyo Doley, President of TMSK',
  },
]

export default function Events(){
  return (
    <>
      <header className="page-head wrap">
        <span className="eyebrow">What's happening</span>
        <h1>Events</h1>
      </header>

      <section className="wrap events-list">
        {EVENTS.map(ev => (
          <article className="event-card" key={ev.n}>
            <div className="event-card-head">
              <span className="num-badge">{ev.n}</span>
              <div>
                <span className="eyebrow">{ev.tag}</span>
                <h2>{ev.title}</h2>
              </div>
            </div>

            <p className="event-blurb">{ev.blurb}</p>

            <div className="event-details">
              {ev.details.map(d => (
                <div className="event-detail" key={d.label}>
                  <span className="event-detail-label mono-tag">{d.label}</span>
                  <span className="event-detail-value">{d.value}</span>
                </div>
              ))}
            </div>

            <div className="event-prizes">
              {ev.prizes.map(p => (
                <div className="prize-pill" key={p.place}>
                  <span>{p.place}</span>
                  <strong>{p.amount}</strong>
                </div>
              ))}
            </div>

            <p className="event-note">{ev.note}</p>

            <div className="event-actions">
              <a href={ev.registerUrl} target="_blank" rel="noopener noreferrer" className="btn">
                Register Now
              </a>
              <span className="event-credit">— {ev.credit}</span>
            </div>
          </article>
        ))}
      </section>
    </>
  )
}
