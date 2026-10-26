#!/bin/bash
if [ ! -d src ]; then
  echo "No src folder here. cd /workspaces/kebang-website first."
  exit 1
fi

# ---------- src/App.jsx (complete file: adds the /leadership route) ----------
cat > src/App.jsx << 'EOF'
import { Routes, Route } from 'react-router-dom'
import ScrollToTop from './components/ScrollToTop.jsx'
import Header from './components/Header.jsx'
import Footer from './components/Footer.jsx'
import Home from './pages/Home.jsx'
import Objectives from './pages/Objectives.jsx'
import Events from './pages/Events.jsx'
import Leadership from './pages/Leadership.jsx'
import NotFound from './pages/NotFound.jsx'

export default function App(){
  return (
    <div className="app-shell">
      <ScrollToTop />
      <Header />
      <main>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/objectives" element={<Objectives />} />
          <Route path="/events" element={<Events />} />
          <Route path="/leadership" element={<Leadership />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}
EOF
echo "UPDATED: src/App.jsx"

# ---------- src/pages/Events.jsx (complete file: Register Now button removed) ----------
cat > src/pages/Events.jsx << 'EOF'
import Reveal from '../components/Reveal.jsx'
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
        <Reveal as="span" className="eyebrow">What's happening</Reveal>
        <Reveal as="h1" delay={80}>Events</Reveal>
      </header>

      <section className="wrap events-list">
        {EVENTS.map((ev, i) => (
          <Reveal as="article" delay={i * 100} className="event-card" key={ev.n}>
            <div className="event-card-visual">
              <span className="event-card-tag">{ev.tag}</span>
              <span className="ghost-num event-card-num">{ev.n}</span>
            </div>

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
                  </div>
                ))}
              </div>

              <p className="event-note">{ev.note}</p>

              <div className="event-actions">
                <span className="event-credit">&mdash; {ev.credit}</span>
              </div>
            </div>
          </Reveal>
        ))}
      </section>
    </>
  )
}
EOF
echo "UPDATED: src/pages/Events.jsx"

# ---------- src/pages/Leadership.jsx (complete file: <main> -> <div>, since App.jsx already has <main>) ----------
cat > src/pages/Leadership.jsx << 'EOF'
import { useState } from 'react';
import { leadershipTerms } from '../data/leadership';
import './Leadership.css';

function getInitials(name) {
  return name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join('');
}

function MemberCard({ member, termId }) {
  const [imageFailed, setImageFailed] = useState(false);
  const src = `/images/leadership/${termId}/${member.image}`;

  return (
    <article className="leader-card">
      <div className="leader-photo">
        {imageFailed ? (
          <span className="leader-initials">{getInitials(member.name)}</span>
        ) : (
          <img
            src={src}
            alt={member.name}
            loading="lazy"
            onError={() => setImageFailed(true)}
          />
        )}
      </div>
      <h3 className="leader-name">{member.name}</h3>
      <p className="leader-role">{member.role}</p>
      {member.note && <p className="leader-note">{member.note}</p>}
    </article>
  );
}

export default function Leadership() {
  const [activeId, setActiveId] = useState(leadershipTerms[0].id);
  const activeTerm = leadershipTerms.find((t) => t.id === activeId);

  return (
    <div className="leadership-page">
      <header className="leadership-hero">
        <h1>Leadership</h1>
        <p>The office bearers who have guided TMSK through each term.</p>
      </header>

      <nav className="term-tabs" aria-label="Leadership terms">
        {leadershipTerms.map((term) => (
          <button
            key={term.id}
            type="button"
            className={term.id === activeId ? 'term-tab active' : 'term-tab'}
            onClick={() => setActiveId(term.id)}
          >
            {term.title}
          </button>
        ))}
      </nav>

      <section className="term-section" aria-labelledby={`${activeTerm.id}-title`}>
        <h2 id={`${activeTerm.id}-title`} className="term-title">
          {activeTerm.title}
        </h2>
        <div className="leader-grid">
          {activeTerm.members.map((member) => (
            <MemberCard key={member.role} member={member} termId={activeTerm.id} />
          ))}
        </div>
      </section>
    </div>
  );
}
EOF
echo "UPDATED: src/pages/Leadership.jsx"

echo ""
echo "Done. Now run: npm run dev -- --host   then open /leadership and /events"
