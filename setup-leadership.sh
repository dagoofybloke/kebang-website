#!/bin/bash
if [ ! -d src ]; then
  echo "No src folder here. cd /workspaces/kebang-website first."
  exit 1
fi

mkdir -p src/pages src/data
mkdir -p public/images/leadership/term-1
mkdir -p public/images/leadership/term-2
touch public/images/leadership/term-1/.gitkeep
touch public/images/leadership/term-2/.gitkeep

write_file() {
  if [ -e "$1" ]; then
    echo "SKIPPED (already exists): $1"
    cat > /dev/null
  else
    cat > "$1"
    echo "CREATED: $1"
  fi
}

# ---------- src/data/leadership.js ----------
write_file src/data/leadership.js << 'EOF'
// Images go in: public/images/leadership/<term-id>/<image file>
// If an image is missing, the page shows the person's initials instead.

export const leadershipTerms = [
  {
    id: 'term-1',
    title: '1st Term',
    members: [
      { role: 'President', name: 'Sumyo Doley', image: 'sumyo-doley.jpg' },
      { role: 'Vice President', name: 'Kung Pao', image: 'kung-pao.jpg' },
      { role: '1st General Secretary', name: 'Abhinab Pegu', image: 'abhinab-pegu.jpg' },
      { role: '2nd General Secretary', name: 'Name to be added', image: '2nd-general-secretary.jpg' },
      { role: 'Treasurer', name: 'Maetom Patir', image: 'maetom-patir.jpg', note: 'Replaced Oiyir' },
    ],
  },
  {
    id: 'term-2',
    title: '2nd Term',
    members: [
      { role: 'President', name: 'Name to be added', image: 'president.jpg' },
      { role: 'Vice President', name: 'Name to be added', image: 'vice-president.jpg' },
      { role: 'General Secretary', name: 'Name to be added', image: 'general-secretary.jpg' },
      { role: 'Treasurer', name: 'Name to be added', image: 'treasurer.jpg' },
    ],
  },
];
EOF

# ---------- src/pages/Leadership.jsx ----------
write_file src/pages/Leadership.jsx << 'EOF'
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
    <main className="leadership-page">
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
    </main>
  );
}
EOF

# ---------- src/pages/Leadership.css ----------
write_file src/pages/Leadership.css << 'EOF'
.leadership-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 48px 20px 80px;
}

.leadership-hero {
  text-align: center;
  margin-bottom: 32px;
}

.leadership-hero h1 {
  font-size: clamp(2rem, 5vw, 3rem);
  margin: 0 0 8px;
}

.leadership-hero p {
  margin: 0;
  color: #666;
}

.term-tabs {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 10px;
  margin-bottom: 40px;
}

.term-tab {
  padding: 10px 24px;
  border: 2px solid #8b1e1e;
  border-radius: 999px;
  background: transparent;
  color: #8b1e1e;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}

.term-tab:hover {
  background: #f6e7e7;
}

.term-tab.active {
  background: #8b1e1e;
  color: #fff;
}

.term-title {
  text-align: center;
  margin: 0 0 28px;
  font-size: 1.6rem;
}

.leader-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(210px, 1fr));
  gap: 24px;
  justify-items: center;
}

.leader-card {
  width: 100%;
  max-width: 260px;
  background: #fff;
  border-radius: 16px;
  padding: 24px 16px;
  text-align: center;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  transition: transform 0.2s, box-shadow 0.2s;
}

.leader-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.leader-photo {
  width: 140px;
  height: 140px;
  margin: 0 auto 16px;
  border-radius: 50%;
  overflow: hidden;
  background: #8b1e1e;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 4px solid #f1d9d9;
}

.leader-photo img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.leader-initials {
  color: #fff;
  font-size: 2.2rem;
  font-weight: 700;
  letter-spacing: 2px;
}

.leader-name {
  margin: 0 0 4px;
  font-size: 1.15rem;
}

.leader-role {
  margin: 0;
  color: #8b1e1e;
  font-weight: 600;
  font-size: 0.95rem;
}

.leader-note {
  margin: 6px 0 0;
  font-size: 0.8rem;
  color: #888;
}

@media (max-width: 520px) {
  .leader-photo {
    width: 120px;
    height: 120px;
  }
}
EOF

# ---------- image folder guide ----------
write_file public/images/leadership/README.txt << 'EOF'
Put leader photos in the matching term folder:

  term-1/sumyo-doley.jpg
  term-1/kung-pao.jpg
  term-1/abhinab-pegu.jpg
  term-1/2nd-general-secretary.jpg
  term-1/maetom-patir.jpg

  term-2/president.jpg
  term-2/vice-president.jpg
  term-2/general-secretary.jpg
  term-2/treasurer.jpg

File names must match src/data/leadership.js. Square photos work best.
EOF

echo ""
echo "Done. Next: wire the route and nav link (see stage 2)."
