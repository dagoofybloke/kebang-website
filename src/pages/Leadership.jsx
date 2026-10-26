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
  const src = `/images/leadership/${termId}/${member.image}`;
  const [failedSrc, setFailedSrc] = useState(null);
  const imageFailed = failedSrc === src;

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
            onError={() => setFailedSrc(src)}
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
            <MemberCard
              key={`${activeTerm.id}-${member.role}`}
              member={member}
              termId={activeTerm.id}
            />
          ))}
        </div>
      </section>
    </div>
  );
}
