import { useState } from 'react';
import Reveal from '../components/Reveal.jsx';
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

function MemberCard({ member, termId, index }) {
  const src = `/images/leadership/${termId}/${member.image}`;
  const [failedSrc, setFailedSrc] = useState(null);
  const imageFailed = failedSrc === src;

  return (
    <article className="leader-card" style={{ '--i': index }}>
      <div className="leader-photo">
        {imageFailed ? (
          <span className="leader-initials">{getInitials(member.name)}</span>
        ) : (
          <img
            src={src}
            alt={member.name}
            loading="lazy"
            onError={() => setFailedSrc(src)}
          />
        )}
      </div>
      <p className="leader-role">{member.role}</p>
      <h3 className="leader-name">{member.name}</h3>
      {member.note && <p className="leader-note">{member.note}</p>}
    </article>
  );
}

export default function Leadership() {
  const [activeId, setActiveId] = useState(leadershipTerms[0].id);
  const activeTerm = leadershipTerms.find((t) => t.id === activeId);

  return (
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">Our people</Reveal>
        <Reveal as="h1" delay={80}>Leadership</Reveal>
        <Reveal as="p" delay={160} className="page-head-lede">
          The office bearers who have guided TMSK through each term.
        </Reveal>
      </header>

      <div className="wrap leadership-body">
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

        <section
          className="term-section"
          key={activeTerm.id}
          aria-labelledby={`${activeTerm.id}-title`}
        >
          <h2 id={`${activeTerm.id}-title`} className="term-title">
            {activeTerm.title}
          </h2>
          <div className="leader-grid">
            {activeTerm.members.map((member, index) => (
              <MemberCard
                key={`${activeTerm.id}-${member.role}`}
                member={member}
                termId={activeTerm.id}
                index={index}
              />
            ))}
          </div>
        </section>
      </div>
    </>
  );
}
