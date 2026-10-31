#!/bin/bash
# TMSK Bulletin installer.
# Run from /workspaces/kebang-website:   bash install-bulletin.sh
# Replaces the Documents sub page with the Bulletin sub page.
# Every file it replaces or removes is copied to /tmp/bulletin-install-backup-<time> first.

if [ ! -f src/App.jsx ] || [ ! -d src/pages ]; then
  echo "Run this from /workspaces/kebang-website (src/App.jsx not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/bulletin-install-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in src/App.jsx src/components/Header.jsx src/pages/Bulletin.jsx src/pages/Bulletin.css \
         src/pages/Documents.jsx src/pages/Documents.css src/data/documents.js src/data/bulletins.js \
         src/data/loadBulletins.js src/lib/likes.js scripts/add-document.sh scripts/add-bulletin.sh; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done
[ -d public/documents ] && cp -r public/documents "$BACKUP_DIR/public_documents"
echo "Backups saved in: $BACKUP_DIR"
echo ""

mkdir -p src/data src/lib src/bulletins src/components public/bulletin scripts supabase

# ---------- rescue real files from the old Documents folders ----------
if [ -d public/documents ]; then
  for sdir in public/documents/*/; do
    [ -d "$sdir" ] || continue
    sname=$(basename "$sdir")
    for f in "$sdir"*; do
      [ -f "$f" ] || continue
      base=$(basename "$f")
      case "$base" in .gitkeep|README.txt) continue ;; esac
      dest="public/bulletin/$base"
      if [ -e "$dest" ]; then dest="public/bulletin/$sname-$base"; fi
      cp "$f" "$dest" && echo "MOVED FILE: $f -> $dest"
    done
  done
fi

# ---------- remove the old Documents sub page ----------
rm -f src/pages/Documents.jsx src/pages/Documents.css src/data/documents.js scripts/add-document.sh
rm -rf public/documents
rm -f src/data/bulletins.js
echo "REMOVED: old Documents page (and any old bulletins.js)"
echo ""

put() {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  echo "WROTE: $1"
}

keep() {
  if [ -e "$1" ]; then
    echo "KEPT (already exists, not overwritten): $1"
    cat > /dev/null
  else
    mkdir -p "$(dirname "$1")"
    cat > "$1"
    echo "CREATED: $1"
  fi
}

# ===== src/App.jsx =====
put src/App.jsx << '__TMSK_FILE_END__'
import { Routes, Route } from 'react-router-dom'
import ScrollToTop from './components/ScrollToTop.jsx'
import Header from './components/Header.jsx'
import Footer from './components/Footer.jsx'
import Home from './pages/Home.jsx'
import Objectives from './pages/Objectives.jsx'
import Events from './pages/Events.jsx'
import Leadership from './pages/Leadership.jsx'
import Bulletin from './pages/Bulletin.jsx'
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
          <Route path="/bulletin" element={<Bulletin />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}
__TMSK_FILE_END__

# ===== src/components/Header.jsx =====
put src/components/Header.jsx << '__TMSK_FILE_END__'
import { useEffect, useState } from 'react'
import { NavLink } from 'react-router-dom'
import './Header.css'

const NAV_ITEMS = [
  { to: '/', label: 'Home' },
  { to: '/objectives', label: 'Objectives' },
  { to: '/events', label: 'Events' },
  { to: '/leadership', label: 'Leadership' },
  { to: '/bulletin', label: 'Bulletin' },
]

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

export default function Header(){
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [open])

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''} ${open ? 'menu-open' : ''}`}>
      <div className="header-inner">
        <NavLink to="/" className="brand" onClick={() => setOpen(false)}>
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" />
          <span className="brand-text">
            <span className="brand-abbr">TMSK</span>
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
          </span>
        </NavLink>

        <nav className="site-nav">
          {NAV_ITEMS.map(item => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn header-cta">
          Join TMSK
        </a>

        <button
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen(o => !o)}
        >
          <span></span>
          <span></span>
          <span></span>
        </button>
      </div>

      <div className={`mobile-menu ${open ? 'is-open' : ''}`}>
        <nav>
          {NAV_ITEMS.map((item, i) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={() => setOpen(false)}
              style={{ transitionDelay: `${i * 60}ms` }}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn mobile-cta" onClick={() => setOpen(false)}>
          Join TMSK
        </a>
      </div>
    </header>
  )
}
__TMSK_FILE_END__

# ===== src/pages/Bulletin.jsx =====
put src/pages/Bulletin.jsx << '__TMSK_FILE_END__'
import { useEffect, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { loadBulletins } from '../data/loadBulletins'
import { bulletinCategories } from '../data/bulletinCategories'
import { LIKES_ENABLED, fetchLikeCounts, changeLike } from '../lib/likes'
import './Bulletin.css'

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]
const MONTHS_SHORT = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

const LIKES_KEY = 'tmsk-bulletin-likes'
const COMMENTS_KEY = 'tmsk-bulletin-comments'
const NAME_KEY = 'tmsk-bulletin-name'
const DEFAULT_COLOR = '#8b1e1e'

const CATEGORIES = bulletinCategories.map((c) =>
  typeof c === 'string'
    ? { name: c, color: DEFAULT_COLOR }
    : { name: c.name, color: c.color || DEFAULT_COLOR },
)

function hexToRgba(hex, alpha) {
  let h = String(hex || '').trim().replace('#', '')
  if (h.length === 3) h = h.split('').map((ch) => ch + ch).join('')
  if (!/^[0-9a-fA-F]{6}$/.test(h)) return `rgba(139, 30, 30, ${alpha})`
  const n = parseInt(h, 16)
  return `rgba(${(n >> 16) & 255}, ${(n >> 8) & 255}, ${n & 255}, ${alpha})`
}

function findCategory(name) {
  const wanted = String(name || '').trim().toLowerCase()
  return CATEGORIES.find((c) => c.name.toLowerCase() === wanted)
}

function catStyle(name) {
  const found = findCategory(name)
  const color = found ? found.color : DEFAULT_COLOR
  return { '--cat': color, '--cat-bg': hexToRgba(color, 0.12) }
}

const BULLETINS = loadBulletins().map((b) => {
  const found = findCategory(b.category)
  return { ...b, category: found ? found.name : b.category }
})

function readStore(key, fallback) {
  try {
    const raw = window.localStorage.getItem(key)
    return raw ? JSON.parse(raw) : fallback
  } catch {
    return fallback
  }
}

function writeStore(key, value) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value))
  } catch {
    /* storage not available: ignore */
  }
}

function dateParts(value) {
  const [y, m, d] = String(value || '').split('-').map(Number)
  if (!y || !m || !d || m < 1 || m > 12) {
    return { day: '', mon: '', year: '', long: String(value || ''), monthKey: 'undated', monthLabel: 'Undated' }
  }
  return {
    day: String(d),
    mon: MONTHS_SHORT[m - 1],
    year: String(y),
    long: `${d} ${MONTHS[m - 1]} ${y}`,
    monthKey: `${y}-${String(m).padStart(2, '0')}`,
    monthLabel: `${MONTHS[m - 1]} ${y}`,
  }
}

function formatCommentDate(ts) {
  return new Date(ts).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' })
}

function HeartIcon({ filled }) {
  return (
    <svg className="b-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <path
        d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
        fill={filled ? 'currentColor' : 'none'}
        stroke="currentColor"
        strokeWidth="2"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function CommentIcon() {
  return (
    <svg className="b-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <path
        d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function ShareIcon() {
  return (
    <svg className="b-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <g fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="18" cy="5" r="3" />
        <circle cx="6" cy="12" r="3" />
        <circle cx="18" cy="19" r="3" />
        <line x1="8.59" y1="13.51" x2="15.42" y2="17.49" />
        <line x1="15.41" y1="6.51" x2="8.59" y2="10.49" />
      </g>
    </svg>
  )
}

function ClipIcon() {
  return (
    <svg className="b-icon" viewBox="0 0 24 24" width="18" height="18" aria-hidden="true">
      <path
        d="M21.44 11.05l-9.19 9.19a6 6 0 0 1-8.49-8.49l9.19-9.19a4 4 0 0 1 5.66 5.66l-9.2 9.19a2 2 0 0 1-2.83-2.83l8.49-8.48"
        fill="none"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  )
}

function EyeIcon() {
  return (
    <svg className="b-icon" viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
      <g fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
        <circle cx="12" cy="12" r="3" />
      </g>
    </svg>
  )
}

function Lightbox({ src, title, onClose }) {
  const closeRef = useRef(onClose)
  closeRef.current = onClose

  useEffect(() => {
    const onKey = (e) => {
      if (e.key === 'Escape') closeRef.current()
    }
    document.addEventListener('keydown', onKey)
    const previous = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    return () => {
      document.removeEventListener('keydown', onKey)
      document.body.style.overflow = previous
    }
  }, [])

  return (
    <div className="b-lightbox" role="dialog" aria-modal="true" aria-label={title} onClick={onClose}>
      <div className="b-lightbox-inner" onClick={(e) => e.stopPropagation()}>
        <button type="button" className="b-lightbox-close" onClick={onClose} aria-label="Close">
          &times;
        </button>
        <img src={src} alt={title} />
        <div className="b-lightbox-bar">
          <strong>{title}</strong>
          <a href={src} target="_blank" rel="noopener noreferrer">
            Open full size
          </a>
        </div>
      </div>
    </div>
  )
}

function BulletinCard({
  item,
  index,
  liked,
  likeCount,
  comments,
  savedName,
  highlighted,
  onToggleLike,
  onAddComment,
  onDeleteComment,
}) {
  const [expanded, setExpanded] = useState(false)
  const [showComments, setShowComments] = useState(false)
  const [shareOpen, setShareOpen] = useState(false)
  const [copied, setCopied] = useState(false)
  const [lightbox, setLightbox] = useState(false)
  const [imageFailed, setImageFailed] = useState(false)
  const [name, setName] = useState(savedName || '')
  const [text, setText] = useState('')
  const shareRef = useRef(null)

  const d = dateParts(item.date)
  const summary = item.paragraphs[0] || ''
  const more = item.paragraphs.slice(1)
  const isImagePost = item.display === 'image'
  const fileHref = item.file ? `/bulletin/${encodeURIComponent(item.file)}` : ''
  const imageSrc = item.image ? encodeURI(`/bulletin/${item.image}`) : ''
  const showImage = Boolean(imageSrc) && !imageFailed
  const viewLabel = item.button || 'View achievement'
  const shareUrl = typeof window !== 'undefined' ? `${window.location.origin}/bulletin#${item.id}` : ''

  useEffect(() => {
    if (!shareOpen) return undefined
    const onDown = (e) => {
      if (shareRef.current && !shareRef.current.contains(e.target)) setShareOpen(false)
    }
    const onKey = (e) => {
      if (e.key === 'Escape') setShareOpen(false)
    }
    document.addEventListener('mousedown', onDown)
    document.addEventListener('touchstart', onDown)
    document.addEventListener('keydown', onKey)
    return () => {
      document.removeEventListener('mousedown', onDown)
      document.removeEventListener('touchstart', onDown)
      document.removeEventListener('keydown', onKey)
    }
  }, [shareOpen])

  async function handleShare() {
    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({ title: item.title, text: summary || item.title, url: shareUrl })
      } catch {
        /* share was cancelled */
      }
      return
    }
    setShareOpen((open) => !open)
  }

  async function copyLink() {
    try {
      await navigator.clipboard.writeText(shareUrl)
    } catch {
      const area = document.createElement('textarea')
      area.value = shareUrl
      area.style.position = 'fixed'
      area.style.opacity = '0'
      document.body.appendChild(area)
      area.select()
      try {
        document.execCommand('copy')
      } catch {
        /* ignore */
      }
      document.body.removeChild(area)
    }
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  function submitComment(e) {
    e.preventDefault()
    const clean = text.trim()
    if (!clean) return
    onAddComment(item.id, name.trim() || 'Guest', clean)
    setText('')
  }

  const imageButton = showImage ? (
    <button
      type="button"
      className={isImagePost ? 'b-hero-image' : 'b-hero-image is-inline'}
      onClick={() => setLightbox(true)}
      aria-label={`Enlarge image: ${item.title}`}
    >
      <img
        src={imageSrc}
        alt={item.title}
        loading="lazy"
        onError={() => {
          console.warn(`Bulletin image not found: ${imageSrc}`)
          setImageFailed(true)
        }}
      />
    </button>
  ) : null

  return (
    <article
      id={`b-${item.id}`}
      className={highlighted ? 'b-card is-highlighted' : 'b-card'}
      style={{ ...catStyle(item.category), '--i': index }}
    >
      <div className="b-date" aria-label={d.long}>
        <span className="b-date-day">{d.day}</span>
        <span className="b-date-mon">{d.mon}</span>
        <span className="b-date-year">{d.year}</span>
      </div>

      <div className="b-main">
        <div className="b-meta">
          <span className="b-flair">{item.category}</span>
          {item.pinned && <span className="b-pin">Pinned</span>}
        </div>

        <h3 className="b-title">{item.title}</h3>

        {isImagePost && imageButton}
        {summary && <p className="b-summary">{summary}</p>}
        {!isImagePost && imageButton}

        {expanded && more.length > 0 && (
          <div className="b-body">
            {more.map((p, i) => (
              <p key={i}>{p}</p>
            ))}
          </div>
        )}

        {(more.length > 0 || fileHref || (isImagePost && showImage)) && (
          <div className="b-links">
            {isImagePost && showImage && (
              <button type="button" className="b-view-btn" onClick={() => setLightbox(true)}>
                <EyeIcon />
                <span>{viewLabel}</span>
              </button>
            )}
            {more.length > 0 && (
              <button
                type="button"
                className="b-readmore"
                aria-expanded={expanded}
                onClick={() => setExpanded((v) => !v)}
              >
                {expanded ? 'Show less' : 'Read more'}
              </button>
            )}
            {fileHref && (
              <a className="b-attach" href={fileHref} target="_blank" rel="noopener noreferrer">
                <ClipIcon />
                <span>View attachment</span>
              </a>
            )}
          </div>
        )}

        <div className="b-actions">
          <button
            type="button"
            className={liked ? 'b-action like-btn liked' : 'b-action like-btn'}
            onClick={() => onToggleLike(item.id)}
            aria-pressed={liked}
          >
            <HeartIcon filled={liked} />
            <span>{liked ? 'Liked' : 'Like'}</span>
            {LIKES_ENABLED && likeCount > 0 && <span className="b-like-count">{likeCount}</span>}
          </button>

          <button
            type="button"
            className={showComments ? 'b-action is-on' : 'b-action'}
            onClick={() => setShowComments((v) => !v)}
            aria-expanded={showComments}
          >
            <CommentIcon />
            <span>Comment{comments.length > 0 ? ` (${comments.length})` : ''}</span>
          </button>

          <div className="b-share-wrap" ref={shareRef}>
            <button
              type="button"
              className={shareOpen ? 'b-action is-on' : 'b-action'}
              onClick={handleShare}
              aria-expanded={shareOpen}
            >
              <ShareIcon />
              <span>Share</span>
            </button>

            {shareOpen && (
              <div className="b-share-menu" role="menu">
                <a
                  role="menuitem"
                  href={`https://wa.me/?text=${encodeURIComponent(`${item.title} ${shareUrl}`)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => setShareOpen(false)}
                >
                  WhatsApp
                </a>
                <a
                  role="menuitem"
                  href={`https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(shareUrl)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => setShareOpen(false)}
                >
                  Facebook
                </a>
                <button type="button" role="menuitem" onClick={copyLink}>
                  {copied ? 'Link copied!' : 'Copy link'}
                </button>
              </div>
            )}
          </div>
        </div>

        {showComments && (
          <div className="b-comments">
            {comments.length === 0 ? (
              <p className="b-no-comments">No comments yet. Be the first to comment.</p>
            ) : (
              <ul className="b-comment-list">
                {comments.map((c) => (
                  <li key={c.id} className="b-comment">
                    <div className="b-comment-head">
                      <strong>{c.name}</strong>
                      <span>{formatCommentDate(c.ts)}</span>
                    </div>
                    <p>{c.text}</p>
                    <button
                      type="button"
                      className="b-comment-delete"
                      onClick={() => onDeleteComment(item.id, c.id)}
                    >
                      Delete
                    </button>
                  </li>
                ))}
              </ul>
            )}

            <form className="b-comment-form" onSubmit={submitComment}>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                placeholder="Your name (optional)"
                maxLength={40}
                aria-label="Your name"
              />
              <textarea
                value={text}
                onChange={(e) => setText(e.target.value)}
                placeholder="Write a comment..."
                maxLength={500}
                rows={3}
                aria-label="Your comment"
              />
              <button type="submit" className="b-post">
                Post comment
              </button>
            </form>
            <p className="b-local-note">Comments are saved on this device only.</p>
          </div>
        )}
      </div>

      {lightbox && showImage && createPortal(
        <Lightbox src={imageSrc} title={item.title} onClose={() => setLightbox(false)} />,
        document.body,
      )}
    </article>
  )
}

export default function Bulletin() {
  const [active, setActive] = useState('All')
  const [likes, setLikes] = useState(() => readStore(LIKES_KEY, {}))
  const [likeCounts, setLikeCounts] = useState({})
  const [comments, setComments] = useState(() => readStore(COMMENTS_KEY, {}))
  const [savedName, setSavedName] = useState(() => readStore(NAME_KEY, ''))
  const [highlightId, setHighlightId] = useState(null)
  const feedRef = useRef(null)
  const pendingLikes = useRef(new Set())

  // Load the shared like counts
  useEffect(() => {
    if (!LIKES_ENABLED) return undefined
    let cancelled = false
    fetchLikeCounts()
      .then((counts) => {
        if (!cancelled) setLikeCounts((prev) => ({ ...counts, ...prev }))
      })
      .catch(() => {
        /* counts stay hidden if the service is unreachable */
      })
    return () => {
      cancelled = true
    }
  }, [])

  // Open a specific bulletin when the link ends with #its-id
  useEffect(() => {
    const id = decodeURIComponent(window.location.hash.replace('#', ''))
    if (!id || !BULLETINS.some((b) => b.id === id)) return undefined
    setHighlightId(id)
    const t1 = setTimeout(() => {
      const el = document.getElementById(`b-${id}`)
      if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' })
    }, 400)
    const t2 = setTimeout(() => setHighlightId(null), 4200)
    return () => {
      clearTimeout(t1)
      clearTimeout(t2)
    }
  }, [])

  function selectCategory(cat) {
    setActive(cat)
    if (window.innerWidth <= 820) {
      setTimeout(() => {
        if (feedRef.current) {
          const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches
          feedRef.current.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'start' })
        }
      }, 60)
    }
  }

  function jumpToMonth(key) {
    const el = document.getElementById(`month-${key}`)
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
  }

  function applyLike(id, isLiked, delta) {
    setLikes((prev) => {
      const next = { ...prev }
      if (isLiked) next[id] = true
      else delete next[id]
      writeStore(LIKES_KEY, next)
      return next
    })
    setLikeCounts((prev) => ({ ...prev, [id]: Math.max((prev[id] || 0) + delta, 0) }))
  }

  async function toggleLike(id) {
    if (pendingLikes.current.has(id)) return
    const wasLiked = !!likes[id]
    const delta = wasLiked ? -1 : 1
    applyLike(id, !wasLiked, delta)
    if (!LIKES_ENABLED) return

    pendingLikes.current.add(id)
    try {
      const total = await changeLike(id, delta)
      if (typeof total === 'number') {
        setLikeCounts((prev) => ({ ...prev, [id]: total }))
      }
    } catch {
      applyLike(id, wasLiked, -delta)
    } finally {
      pendingLikes.current.delete(id)
    }
  }

  function addComment(id, name, text) {
    const entry = {
      id: `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
      name,
      text,
      ts: Date.now(),
    }
    setComments((prev) => {
      const next = { ...prev, [id]: [...(prev[id] || []), entry] }
      writeStore(COMMENTS_KEY, next)
      return next
    })
    if (name !== 'Guest') {
      setSavedName(name)
      writeStore(NAME_KEY, name)
    }
  }

  function deleteComment(id, commentId) {
    setComments((prev) => {
      const next = { ...prev, [id]: (prev[id] || []).filter((c) => c.id !== commentId) }
      writeStore(COMMENTS_KEY, next)
      return next
    })
  }

  const sorted = [...BULLETINS].sort((a, b) => {
    if (!!b.pinned !== !!a.pinned) return b.pinned ? 1 : -1
    return String(b.date).localeCompare(String(a.date))
  })
  const visible = sorted.filter((b) => active === 'All' || b.category === active)

  const groups = []
  visible.forEach((item) => {
    const parts = dateParts(item.date)
    const key = item.pinned ? 'pinned' : parts.monthKey
    const label = item.pinned ? 'Pinned' : parts.monthLabel
    let group = groups.find((g) => g.key === key)
    if (!group) {
      group = { key, label, items: [] }
      groups.push(group)
    }
    group.items.push(item)
  })

  return (
    <div className="bulletin-page">
      <header className="bulletin-hero">
        <h1>Bulletin</h1>
        <p>Notices, announcements, events, projects and updates from TMSK.</p>
      </header>

      <div className="bulletin-layout">
        <aside className="bulletin-sidebar">
          <p className="bulletin-side-label">Categories</p>
          <ul className="bulletin-menu">
            {['All', ...CATEGORIES.map((c) => c.name)].map((cat, index) => {
              const count =
                cat === 'All' ? BULLETINS.length : BULLETINS.filter((b) => b.category === cat).length
              const isActive = cat === active
              return (
                <li key={cat} className="bulletin-menu-item" style={{ '--i': index }}>
                  <button
                    type="button"
                    className={isActive ? 'bulletin-menu-btn active' : 'bulletin-menu-btn'}
                    style={catStyle(cat)}
                    onClick={() => selectCategory(cat)}
                    aria-pressed={isActive}
                  >
                    <span className="bulletin-dot" aria-hidden="true"></span>
                    <span className="bulletin-menu-text">{cat}</span>
                    <span className="bulletin-count">{count}</span>
                  </button>
                </li>
              )
            })}
          </ul>

          {groups.length > 0 && (
            <div className="bulletin-timeline">
              <p className="bulletin-side-label">Timeline</p>
              <ul className="bulletin-timeline-list">
                {groups.map((g) => (
                  <li key={g.key}>
                    <button type="button" className="bulletin-timeline-btn" onClick={() => jumpToMonth(g.key)}>
                      <span>{g.label}</span>
                      <span className="bulletin-count">{g.items.length}</span>
                    </button>
                  </li>
                ))}
              </ul>
            </div>
          )}
        </aside>

        <section className="bulletin-feed" key={active} ref={feedRef}>
          <div className="bulletin-feed-head">
            <h2>{active === 'All' ? 'All bulletins' : active}</h2>
            <span>
              {visible.length} {visible.length === 1 ? 'bulletin' : 'bulletins'}
            </span>
          </div>

          {visible.length === 0 ? (
            <p className="bulletin-empty">No bulletins in this category yet.</p>
          ) : (
            groups.map((group) => (
              <div className="bulletin-group" key={group.key}>
                <h2 className="bulletin-month" id={`month-${group.key}`}>
                  {group.label}
                </h2>
                <div className="bulletin-list">
                  {group.items.map((item, i) => (
                    <BulletinCard
                      key={item.id}
                      item={item}
                      index={i}
                      liked={!!likes[item.id]}
                      likeCount={likeCounts[item.id] || 0}
                      comments={comments[item.id] || []}
                      savedName={savedName}
                      highlighted={highlightId === item.id}
                      onToggleLike={toggleLike}
                      onAddComment={addComment}
                      onDeleteComment={deleteComment}
                    />
                  ))}
                </div>
              </div>
            ))
          )}
        </section>
      </div>
    </div>
  )
}
__TMSK_FILE_END__

# ===== src/pages/Bulletin.css =====
put src/pages/Bulletin.css << '__TMSK_FILE_END__'
.bulletin-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 48px 20px 80px;
}

.bulletin-hero {
  text-align: center;
  margin-bottom: 40px;
}

.bulletin-hero h1 {
  margin: 0 0 8px;
  font-size: clamp(1.8rem, 6vw, 3rem);
  animation: bulletin-fade-up 0.5s ease both;
}

.bulletin-hero p {
  margin: 0 auto;
  max-width: 560px;
  color: #666;
  animation: bulletin-fade-up 0.5s ease 0.1s both;
}

/* ---------- category colors (set from JavaScript; this is the fallback) ---------- */
.b-card,
.bulletin-menu-btn {
  --cat: #8b1e1e;
  --cat-bg: #f6e7e7;
}

/* ---------- layout ---------- */
.bulletin-layout {
  display: grid;
  grid-template-columns: 270px minmax(0, 1fr);
  gap: 36px;
  align-items: start;
}

/* ---------- sidebar ---------- */
.bulletin-sidebar {
  position: sticky;
  top: 110px;
  max-height: calc(100vh - 130px);
  overflow-y: auto;
  padding: 20px 14px;
  background: #fff;
  border-radius: 18px;
  box-shadow: 0 4px 18px rgba(0, 0, 0, 0.08);
  animation: bulletin-sidebar-in 0.5s ease both;
  scrollbar-width: thin;
}

.bulletin-side-label {
  margin: 0 0 10px 12px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 1.5px;
  text-transform: uppercase;
  color: #8b1e1e;
}

.bulletin-menu,
.bulletin-timeline-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 6px;
}

.bulletin-menu-item {
  animation: bulletin-slide-in 0.5s ease both;
  animation-delay: calc(var(--i) * 60ms + 150ms);
}

.bulletin-menu-btn {
  position: relative;
  width: 100%;
  min-height: 46px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 14px;
  border: none;
  border-radius: 12px;
  background: transparent;
  color: #333;
  font-size: 0.95rem;
  font-weight: 600;
  text-align: left;
  cursor: pointer;
  transition: background 0.25s, color 0.25s, transform 0.25s;
}

.bulletin-menu-btn:hover {
  background: var(--cat-bg);
  transform: translateX(4px);
}

.bulletin-menu-btn.active {
  background: var(--cat);
  color: #fff;
  transform: translateX(6px);
}

.bulletin-menu-btn:focus-visible,
.bulletin-timeline-btn:focus-visible,
.b-action:focus-visible,
.b-readmore:focus-visible {
  outline: 3px solid #e3a3a3;
  outline-offset: 2px;
}

.bulletin-dot {
  flex-shrink: 0;
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: var(--cat);
  transition: background 0.25s, transform 0.25s;
}

.bulletin-menu-btn.active .bulletin-dot {
  background: #fff;
  transform: scale(1.2);
}

.bulletin-menu-text {
  flex: 1;
  min-width: 0;
  overflow-wrap: anywhere;
}

.b-icon {
  flex-shrink: 0;
}

.bulletin-count {
  flex-shrink: 0;
  min-width: 24px;
  padding: 2px 8px;
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.07);
  font-size: 0.8rem;
  text-align: center;
}

.bulletin-menu-btn.active .bulletin-count {
  background: rgba(255, 255, 255, 0.25);
  color: #fff;
}

.bulletin-timeline {
  margin-top: 22px;
  padding-top: 18px;
  border-top: 1px solid #eee;
  animation: bulletin-fade-up 0.5s ease 0.5s both;
}

.bulletin-timeline-btn {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 9px 14px;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: #555;
  font-size: 0.9rem;
  text-align: left;
  cursor: pointer;
  transition: background 0.2s, color 0.2s;
}

.bulletin-timeline-btn:hover {
  background: #f6e7e7;
  color: #8b1e1e;
}

/* ---------- feed ---------- */
.bulletin-feed {
  min-width: 0;
  scroll-margin-top: 90px;
}

.bulletin-feed-head {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
  gap: 12px;
  margin-bottom: 6px;
  animation: bulletin-fade-up 0.4s ease both;
}

.bulletin-feed-head h2 {
  margin: 0;
  font-size: 1.7rem;
}

.bulletin-feed-head span {
  color: #888;
  font-size: 0.9rem;
}

.bulletin-month {
  display: flex;
  align-items: center;
  gap: 14px;
  margin: 28px 0 16px;
  font-size: 0.95rem;
  letter-spacing: 1px;
  text-transform: uppercase;
  color: #8b1e1e;
  scroll-margin-top: 100px;
  animation: bulletin-fade-up 0.4s ease both;
}

.bulletin-month::after {
  content: '';
  flex: 1;
  height: 1px;
  background: #e6d3d3;
}

.bulletin-list {
  display: grid;
  gap: 18px;
}

.bulletin-empty {
  padding: 48px 20px;
  border: 2px dashed #ddd;
  border-radius: 16px;
  color: #888;
  text-align: center;
}

/* ---------- bulletin card ---------- */
.b-card {
  display: flex;
  gap: 18px;
  padding: 20px;
  background: #fff;
  border-radius: 16px;
  border-left: 5px solid var(--cat);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08);
  animation: bulletin-fade-up 0.5s ease both;
  animation-delay: calc(var(--i) * 70ms + 100ms);
  transition: transform 0.2s, box-shadow 0.2s;
}

.b-card:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.b-card.is-highlighted {
  animation: bulletin-highlight 2.6s ease 0.3s both;
}

.b-date {
  flex-shrink: 0;
  width: 68px;
  display: flex;
  flex-direction: column;
  align-items: center;
  align-self: flex-start;
  padding: 10px 4px;
  border-radius: 12px;
  background: var(--cat-bg);
  color: var(--cat);
  text-align: center;
  line-height: 1.1;
}

.b-date-day {
  font-size: 1.7rem;
  font-weight: 800;
}

.b-date-mon {
  margin-top: 2px;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 1px;
  text-transform: uppercase;
}

.b-date-year {
  margin-top: 2px;
  font-size: 0.72rem;
  opacity: 0.8;
}

.b-main {
  flex: 1;
  min-width: 0;
}

.b-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 8px;
}

.b-flair {
  padding: 3px 12px;
  border-radius: 999px;
  background: var(--cat-bg);
  color: var(--cat);
  font-size: 0.78rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.b-pin {
  padding: 3px 10px;
  border-radius: 999px;
  background: #222;
  color: #fff;
  font-size: 0.72rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  text-transform: uppercase;
}

.b-title {
  margin: 0 0 8px;
  font-size: 1.25rem;
  line-height: 1.3;
  overflow-wrap: anywhere;
}

.b-summary {
  margin: 0;
  color: #444;
  line-height: 1.6;
}

.b-body {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 1px dashed #ddd;
  animation: bulletin-fade-down 0.35s ease both;
}

.b-body p {
  margin: 0 0 12px;
  color: #444;
  line-height: 1.7;
}

.b-body p:last-child {
  margin-bottom: 0;
}

.b-links {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 10px 18px;
  margin-top: 14px;
}

.b-readmore {
  padding: 6px 0;
  border: none;
  background: transparent;
  color: var(--cat);
  font-size: 0.92rem;
  font-weight: 700;
  cursor: pointer;
}

.b-readmore:hover {
  text-decoration: underline;
}

.b-attach {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  min-height: 38px;
  padding: 6px 14px;
  border: 2px solid var(--cat);
  border-radius: 999px;
  color: var(--cat);
  font-size: 0.88rem;
  font-weight: 700;
  text-decoration: none;
  transition: background 0.2s, color 0.2s;
}

.b-attach:hover {
  background: var(--cat);
  color: #fff;
}

/* ---------- picture on a bulletin ---------- */
.b-hero-image {
  position: relative;
  display: block;
  width: 100%;
  margin: 12px 0 4px;
  padding: 0;
  border: none;
  border-radius: 14px;
  overflow: hidden;
  background: var(--cat-bg);
  cursor: zoom-in;
}

.b-hero-image img {
  display: block;
  width: 100%;
  height: auto;
  max-height: 560px;
  object-fit: contain;
  transition: transform 0.4s ease;
}

.b-hero-image:hover img {
  transform: scale(1.02);
}

.b-hero-image.is-inline {
  margin-top: 14px;
}

.b-hero-image.is-inline img {
  max-height: 380px;
  object-fit: cover;
}

.b-hero-image:focus-visible {
  outline: 3px solid var(--cat);
  outline-offset: 3px;
}

.b-view-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 42px;
  padding: 8px 18px;
  border: none;
  border-radius: 999px;
  background: var(--cat);
  color: #fff;
  font-size: 0.92rem;
  font-weight: 700;
  cursor: pointer;
  transition: filter 0.2s, transform 0.15s;
}

.b-view-btn:hover {
  filter: brightness(0.9);
}

.b-view-btn:active {
  transform: scale(0.97);
}

/* ---------- full-screen picture viewer ---------- */
.b-lightbox {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  background: rgba(0, 0, 0, 0.88);
  animation: bulletin-lightbox-in 0.25s ease both;
}

.b-lightbox-inner {
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 12px;
  max-width: min(96vw, 1100px);
  max-height: 94vh;
  animation: bulletin-lightbox-zoom 0.3s ease both;
}

.b-lightbox-inner img {
  display: block;
  max-width: 100%;
  max-height: 78vh;
  margin: 0 auto;
  border-radius: 10px;
  object-fit: contain;
  background: #111;
}

.b-lightbox-close {
  position: absolute;
  top: -12px;
  right: -4px;
  z-index: 1;
  width: 44px;
  height: 44px;
  border: none;
  border-radius: 50%;
  background: #fff;
  color: #222;
  font-size: 1.7rem;
  line-height: 1;
  cursor: pointer;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.4);
}

.b-lightbox-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 14px;
  color: #fff;
  font-size: 0.95rem;
}

.b-lightbox-bar a {
  color: #fff;
  font-weight: 600;
  text-decoration: underline;
  white-space: nowrap;
}

/* ---------- like / comment / share ---------- */
.b-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 16px;
  padding-top: 14px;
  border-top: 1px solid #eee;
}

.b-action {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 42px;
  padding: 8px 16px;
  border: 1px solid #ddd;
  border-radius: 999px;
  background: #fff;
  color: #444;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s, color 0.2s, border-color 0.2s, transform 0.15s;
}

.b-action:hover {
  background: #f6e7e7;
  border-color: #e3b5b5;
}

.b-action:active {
  transform: scale(0.96);
}

.b-action.is-on {
  background: #f6e7e7;
  border-color: #8b1e1e;
  color: #8b1e1e;
}

.like-btn.liked {
  border-color: #d6284a;
  background: #fdecef;
  color: #d6284a;
}

.like-btn.liked .b-icon {
  animation: bulletin-pop 0.45s ease;
}

.b-like-count {
  min-width: 22px;
  padding: 1px 8px;
  border-radius: 999px;
  background: rgba(0, 0, 0, 0.08);
  font-size: 0.8rem;
  line-height: 1.5;
  text-align: center;
}

.like-btn.liked .b-like-count {
  background: rgba(214, 40, 74, 0.15);
}

.b-share-wrap {
  position: relative;
}

.b-share-menu {
  position: absolute;
  top: calc(100% + 8px);
  left: 0;
  z-index: 20;
  min-width: 170px;
  display: grid;
  padding: 6px;
  border-radius: 14px;
  background: #fff;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.18);
  animation: bulletin-pop-in 0.2s ease both;
}

.b-share-menu a,
.b-share-menu button {
  display: block;
  width: 100%;
  padding: 11px 14px;
  border: none;
  border-radius: 10px;
  background: transparent;
  color: #333;
  font-size: 0.92rem;
  font-weight: 600;
  text-align: left;
  text-decoration: none;
  cursor: pointer;
}

.b-share-menu a:hover,
.b-share-menu button:hover {
  background: #f6e7e7;
  color: #8b1e1e;
}

/* ---------- comments ---------- */
.b-comments {
  margin-top: 16px;
  padding: 16px;
  border-radius: 14px;
  background: #faf6f6;
  animation: bulletin-fade-down 0.35s ease both;
}

.b-no-comments {
  margin: 0 0 14px;
  color: #888;
  font-size: 0.92rem;
}

.b-comment-list {
  list-style: none;
  margin: 0 0 16px;
  padding: 0;
  display: grid;
  gap: 12px;
}

.b-comment {
  padding: 12px 14px;
  border-radius: 12px;
  background: #fff;
  animation: bulletin-fade-up 0.3s ease both;
}

.b-comment-head {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  font-size: 0.88rem;
}

.b-comment-head span {
  color: #999;
}

.b-comment p {
  margin: 6px 0 4px;
  line-height: 1.5;
  overflow-wrap: anywhere;
}

.b-comment-delete {
  padding: 4px 0;
  border: none;
  background: transparent;
  color: #b33;
  font-size: 0.8rem;
  cursor: pointer;
}

.b-comment-delete:hover {
  text-decoration: underline;
}

.b-comment-form {
  display: grid;
  gap: 10px;
}

.b-comment-form input,
.b-comment-form textarea {
  width: 100%;
  padding: 11px 14px;
  border: 1px solid #ddd;
  border-radius: 12px;
  background: #fff;
  font: inherit;
  font-size: 16px;
  box-sizing: border-box;
}

.b-comment-form textarea {
  resize: vertical;
  min-height: 80px;
}

.b-comment-form input:focus,
.b-comment-form textarea:focus {
  outline: 2px solid #e3a3a3;
  border-color: #8b1e1e;
}

.b-post {
  justify-self: start;
  min-height: 42px;
  padding: 10px 22px;
  border: none;
  border-radius: 999px;
  background: #8b1e1e;
  color: #fff;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.2s, transform 0.15s;
}

.b-post:hover {
  background: #6f1717;
}

.b-post:active {
  transform: scale(0.97);
}

.b-local-note {
  margin: 10px 0 0;
  font-size: 0.78rem;
  color: #999;
}

/* ---------- animations ---------- */
@keyframes bulletin-fade-up {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes bulletin-fade-down {
  from { opacity: 0; transform: translateY(-8px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes bulletin-slide-in {
  from { opacity: 0; transform: translateX(-24px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes bulletin-sidebar-in {
  from { opacity: 0; transform: translateX(-30px); }
  to { opacity: 1; transform: translateX(0); }
}

@keyframes bulletin-pop {
  0% { transform: scale(1); }
  40% { transform: scale(1.5); }
  100% { transform: scale(1); }
}

@keyframes bulletin-pop-in {
  from { opacity: 0; transform: scale(0.92) translateY(-4px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}

@keyframes bulletin-highlight {
  0% { box-shadow: 0 0 0 0 rgba(139, 30, 30, 0.5); }
  40% { box-shadow: 0 0 0 8px rgba(139, 30, 30, 0.25); }
  100% { box-shadow: 0 4px 16px rgba(0, 0, 0, 0.08); }
}

@keyframes bulletin-lightbox-in {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes bulletin-lightbox-zoom {
  from { opacity: 0; transform: scale(0.94); }
  to { opacity: 1; transform: scale(1); }
}

/* ---------- tablets and phones ---------- */
@media (max-width: 820px) {
  .bulletin-page {
    padding: 32px 14px 60px;
  }

  .bulletin-hero {
    margin-bottom: 24px;
  }

  .bulletin-layout {
    grid-template-columns: minmax(0, 1fr);
    gap: 22px;
  }

  .bulletin-sidebar {
    position: static;
    max-height: none;
    overflow: visible;
    padding: 14px 12px 16px;
    animation: none;
  }

  .bulletin-side-label {
    margin: 0 0 10px 4px;
  }

  .bulletin-menu {
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 8px;
  }

  .bulletin-menu-item {
    animation: bulletin-fade-up 0.4s ease both;
    animation-delay: calc(var(--i) * 50ms + 80ms);
  }

  .bulletin-menu-btn {
    min-height: 52px;
    gap: 4px;
    padding: 10px 8px 10px 12px;
    background: var(--cat-bg);
    font-size: 0.78rem;
    line-height: 1.2;
  }

  .bulletin-dot {
    display: none;
  }

  .bulletin-menu-btn .bulletin-count {
    min-width: 18px;
    padding: 1px 6px;
    font-size: 0.72rem;
  }

  .bulletin-menu-btn:hover,
  .bulletin-menu-btn.active {
    transform: none;
  }

  .bulletin-timeline {
    display: none;
  }

  .bulletin-feed-head h2 {
    font-size: 1.4rem;
  }

  .b-card {
    flex-direction: column;
    gap: 12px;
    padding: 16px;
  }

  .b-card:hover {
    transform: none;
  }

  .b-date {
    width: auto;
    flex-direction: row;
    align-items: baseline;
    gap: 6px;
    padding: 6px 14px;
    border-radius: 999px;
  }

  .b-date-day {
    font-size: 1.05rem;
  }

  .b-date-mon,
  .b-date-year {
    margin-top: 0;
    font-size: 0.8rem;
  }

  .b-title {
    font-size: 1.15rem;
  }
}

@media (max-width: 560px) {
  .b-actions {
    gap: 8px;
  }

  .b-action {
    flex: 1 1 0;
    min-width: 0;
    padding: 8px 10px;
    font-size: 0.85rem;
  }

  .b-share-wrap {
    flex: 1 1 0;
    min-width: 0;
  }

  .b-share-wrap .b-action {
    width: 100%;
  }

  .b-share-menu {
    right: 0;
    left: auto;
  }

  .b-post {
    width: 100%;
    justify-self: stretch;
  }

  .b-view-btn {
    width: 100%;
  }

  .b-links {
    width: 100%;
  }
}

@media (max-width: 330px) {
  .bulletin-menu {
    grid-template-columns: minmax(0, 1fr);
  }
}

/* ---------- respect "reduce motion" ---------- */
@media (prefers-reduced-motion: reduce) {
  .bulletin-hero h1,
  .bulletin-hero p,
  .bulletin-sidebar,
  .bulletin-menu-item,
  .bulletin-timeline,
  .bulletin-feed-head,
  .bulletin-month,
  .b-card,
  .b-body,
  .b-comments,
  .b-comment,
  .b-share-menu,
  .b-lightbox,
  .b-lightbox-inner,
  .like-btn.liked .b-icon {
    animation: none;
  }

  .bulletin-menu-btn,
  .b-card,
  .b-action,
  .b-post,
  .b-view-btn,
  .b-hero-image img {
    transition: none;
  }
}
__TMSK_FILE_END__

# ===== src/data/loadBulletins.js =====
put src/data/loadBulletins.js << '__TMSK_FILE_END__'
// Reads every .txt file in src/bulletins (except files starting with "_")
// and turns each one into a bulletin. You never need to edit this file.

const files = import.meta.glob('../bulletins/*.txt', __GLOB_OPTS__)

function yes(value) {
  return /^(yes|y|true|1|pin|pinned)$/i.test(String(value || '').trim())
}

function parseBulletin(raw, filename) {
  const lines = String(raw).replace(/^\uFEFF/, '').replace(/\r\n?/g, '\n').split('\n')
  const meta = {}
  let i = 0

  for (; i < lines.length; i++) {
    const line = lines[i]
    const trimmed = line.trim()
    if (trimmed.startsWith('#')) continue
    if (trimmed === '') {
      if (Object.keys(meta).length > 0) {
        i++
        break
      }
      continue
    }
    const m = line.match(/^([A-Za-z ]+):\s*(.*)$/)
    if (!m) break
    meta[m[1].trim().toLowerCase()] = m[2].trim()
  }

  const body = lines.slice(i).join('\n').trim()
  const paragraphs = body
    ? body
        .split(/\n\s*\n/)
        .map((p) => p.replace(/\s*\n\s*/g, ' ').trim())
        .filter(Boolean)
    : []

  const base = filename.replace(/\.[^.]+$/, '')
  const id =
    base
      .replace(/[^A-Za-z0-9_-]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .toLowerCase() || 'bulletin'

  return {
    id,
    title: meta.title || base,
    date: meta.date || '',
    category: meta.category || 'Notice',
    display: /^image$/i.test(meta.display || '') ? 'image' : 'text',
    image: meta.image || '',
    file: meta.file || '',
    pinned: yes(meta.pinned),
    button: meta.button || '',
    paragraphs,
  }
}

export function loadBulletins() {
  return Object.entries(files)
    .filter(([path]) => !path.split('/').pop().startsWith('_'))
    .map(([path, raw]) => parseBulletin(String(raw), path.split('/').pop()))
}
__TMSK_FILE_END__

# ===== src/lib/likes.js =====
put src/lib/likes.js << '__TMSK_FILE_END__'
// Shared like counts. Works only after Supabase is set up (see supabase/bulletin-likes.sql).
// Without it, likes still work on the visitor's device but no number is shown.

const BASE = String(import.meta.env.VITE_SUPABASE_URL || '').replace(/\/+$/, '')
const KEY = String(import.meta.env.VITE_SUPABASE_ANON_KEY || '')

export const LIKES_ENABLED = Boolean(BASE && KEY)

function authHeaders() {
  const headers = { apikey: KEY }
  if (KEY.startsWith('eyJ')) headers.Authorization = `Bearer ${KEY}`
  return headers
}

export async function fetchLikeCounts() {
  const res = await fetch(`${BASE}/rest/v1/bulletin_likes?select=bulletin_id,likes`, {
    headers: authHeaders(),
  })
  if (!res.ok) throw new Error(`Could not load likes (${res.status})`)
  const rows = await res.json()
  const counts = {}
  rows.forEach((row) => {
    counts[row.bulletin_id] = row.likes
  })
  return counts
}

export async function changeLike(id, delta) {
  const res = await fetch(`${BASE}/rest/v1/rpc/change_like`, {
    method: 'POST',
    headers: { ...authHeaders(), 'Content-Type': 'application/json' },
    body: JSON.stringify({ bid: id, delta }),
  })
  if (!res.ok) throw new Error(`Could not update like (${res.status})`)
  return res.json()
}
__TMSK_FILE_END__

# ===== supabase/bulletin-likes.sql =====
put supabase/bulletin-likes.sql << '__TMSK_FILE_END__'
-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.
-- (If your editor drops lines when pasting, run it in three pieces.)

create table if not exists public.bulletin_likes (
  bulletin_id text primary key check (char_length(bulletin_id) <= 120),
  likes integer not null default 0 check (likes >= 0)
);

alter table public.bulletin_likes enable row level security;

drop policy if exists "Anyone can read likes" on public.bulletin_likes;
create policy "Anyone can read likes"
  on public.bulletin_likes
  for select
  to anon, authenticated
  using (true);

grant select on public.bulletin_likes to anon, authenticated;

create or replace function public.change_like(bid text, delta integer)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  if bid is null or char_length(bid) = 0 or char_length(bid) > 120 then
    raise exception 'invalid bulletin id';
  end if;
  if delta not in (1, -1) then
    raise exception 'delta must be 1 or -1';
  end if;

  insert into public.bulletin_likes (bulletin_id, likes)
  values (bid, greatest(delta, 0))
  on conflict (bulletin_id)
  do update set likes = greatest(public.bulletin_likes.likes + delta, 0)
  returning likes into new_count;

  return new_count;
end;
$$;

revoke all on function public.change_like(text, integer) from public;
grant execute on function public.change_like(text, integer) to anon, authenticated;
__TMSK_FILE_END__

# ===== src/bulletins/_template.txt =====
put src/bulletins/_template.txt << '__TMSK_FILE_END__'
# HOW TO POST A BULLETIN
# 1. Copy this file (Ctrl+C, Ctrl+V in the explorer) and rename the copy,
#    for example:  2026-11-15-annual-meeting.txt   (it must end in .txt)
# 2. Fill in the lines below and write your text. Save with Ctrl+S.
# Lines that start with # are ignored. Keep the blank line before your text.
#
# Category must be one of: Notice, Project, Event, Election, Announcement, Insights
# Display:  text   = normal post
#           image  = shows the picture instead of text, with a "View" button
# Image:    a picture file you put in public/bulletin/   (example: poster.jpg)
# File:     a PDF or other file you put in public/bulletin/   (example: notice.pdf)
# Pinned:   yes = stays at the top
# Button:   label for the picture button (default: View achievement)
Title: Your title here
Date: 2026-11-15
Category: Notice
Display: text
Image:
File:
Pinned: no
Button:

Write your first paragraph here. It is the short text shown in the feed.

Write more paragraphs here. They appear when someone taps "Read more".
Leave a blank line between paragraphs.
__TMSK_FILE_END__

# ===== public/bulletin/README.txt =====
put public/bulletin/README.txt << '__TMSK_FILE_END__'
Put pictures and files for your bulletins in this folder.
Use simple names: lowercase, hyphens instead of spaces, no accents or brackets.
Examples: opin-kinsulai.pdf   award-photo.jpg

Then write the file name in the bulletin's text file in src/bulletins/:
   Image: award-photo.jpg
   File: opin-kinsulai.pdf

Anything in this folder is PUBLIC once the site is deployed.
__TMSK_FILE_END__

# ===== scripts/add-bulletin.sh =====
put scripts/add-bulletin.sh << '__TMSK_FILE_END__'
#!/bin/bash
cd "$(dirname "$0")/.." || exit 1

if [ ! -f src/data/bulletinCategories.js ]; then
  echo "Bulletin setup not found. Run the Bulletin setup first."
  exit 1
fi
mkdir -p src/bulletins public/bulletin

mapfile -t CATS < <(grep -o "name: *'[^']*'" src/data/bulletinCategories.js | sed -E "s/name: *'([^']*)'/\1/")
if [ ${#CATS[@]} -eq 0 ]; then
  echo "No categories found in src/data/bulletinCategories.js"
  exit 1
fi

echo "Category:"
for i in "${!CATS[@]}"; do
  echo "  $((i+1))) ${CATS[$i]}"
done
read -rp "Enter number: " cnum
if ! [[ "$cnum" =~ ^[0-9]+$ ]] || [ "$cnum" -lt 1 ] || [ "$cnum" -gt "${#CATS[@]}" ]; then
  echo "Please enter a number from the list."
  exit 1
fi
category="${CATS[$((cnum-1))]}"

read -rp "Title: " title
if [ -z "$title" ]; then
  echo "Title cannot be empty."
  exit 1
fi

today=$(date +%F)
read -rp "Date (YYYY-MM-DD) [$today]: " bdate
bdate="${bdate:-$today}"
if ! [[ "$bdate" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Date must look like 2026-11-15."
  exit 1
fi

echo "Show as:  1) Text post   2) Image post (picture instead of text)"
read -rp "Enter 1 or 2 [1]: " kind
display="text"
[ "$kind" = "2" ] && display="image"

safe_name() {
  basename "$1" | tr 'A-Z' 'a-z' | sed -E 's/[[:space:]]+/-/g; s/[^a-z0-9._-]//g'
}

copy_asset() {
  local src="$1"
  src="${src%\"}"; src="${src#\"}"; src="${src%\'}"; src="${src#\'}"
  if [ ! -f "$src" ]; then
    echo "File not found: $src" >&2
    return 1
  fi
  local name
  name=$(safe_name "$src")
  local dest="public/bulletin/$name"
  if [ -e "$dest" ] && [ "$(realpath "$src")" != "$(realpath "$dest")" ]; then
    echo "NOTE: public/bulletin/$name already exists, using that file." >&2
  elif [ "$(realpath "$src")" != "$(realpath -m "$dest")" ]; then
    cp "$src" "$dest" && echo "COPIED: $dest" >&2
  fi
  echo "$name"
}

image=""
if [ "$display" = "image" ]; then
  read -rp "Path to the image (upload it to the Codespace first): " ipath
  if [ -z "$ipath" ]; then
    echo "An image post needs an image."
    exit 1
  fi
  image=$(copy_asset "$ipath") || exit 1
else
  read -rp "Picture to show inside the post (press Enter to skip): " ipath
  if [ -n "$ipath" ]; then
    image=$(copy_asset "$ipath") || exit 1
  fi
fi

read -rp "Attach a PDF or other file (press Enter to skip): " fpath
file=""
if [ -n "$fpath" ]; then
  file=$(copy_asset "$fpath") || exit 1
fi

read -rp "Pin to the top? (y/N): " pin
pinned="no"
[[ "$pin" =~ ^[Yy] ]] && pinned="yes"

button=""
if [ "$display" = "image" ]; then
  read -rp "Button label [View achievement]: " button
fi

echo ""
echo "Now type the text. The first paragraph is the short summary shown in the feed."
echo "Leave a blank line between paragraphs. When finished, type END on a line by itself."
echo "(For an image post you can type just END to skip the text.)"
body=""
while IFS= read -r line; do
  [ "$line" = "END" ] && break
  body+="$line"$'\n'
done

slug=$(echo "$title" | tr 'A-Z' 'a-z' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g' | cut -c1-50)
[ -z "$slug" ] && slug="bulletin"
out="src/bulletins/$bdate-$slug.txt"
if [ -e "$out" ]; then
  echo "$out already exists. Change the title or date."
  exit 1
fi

{
  echo "Title: $title"
  echo "Date: $bdate"
  echo "Category: $category"
  echo "Display: $display"
  echo "Image: $image"
  echo "File: $file"
  echo "Pinned: $pinned"
  echo "Button: $button"
  echo ""
  printf '%s' "$body"
} > "$out"

echo ""
echo "CREATED: $out"
echo "Check it at /bulletin, then push:"
echo "  git add -A && git commit -m \"Add bulletin: $title\" && git push origin main"
__TMSK_FILE_END__

# ===== src/data/bulletinCategories.js =====
keep src/data/bulletinCategories.js << '__TMSK_FILE_END__'
// The categories shown in the Bulletin sidebar, and the color of each one.
// To add a category: add a new line with a name and a color (hex code).
// To change a color: edit the color on that line.
export const bulletinCategories = [
  { name: 'Notice', color: '#8b1e1e' },
  { name: 'Project', color: '#1d5fa8' },
  { name: 'Event', color: '#1e7a46' },
  { name: 'Election', color: '#6a3fa0' },
  { name: 'Announcement', color: '#b36b00' },
  { name: 'Insights', color: '#0f7c80' },
]
__TMSK_FILE_END__

# ===== src/bulletins/2026-10-26-opin-kinsulai.txt =====
keep src/bulletins/2026-10-26-opin-kinsulai.txt << '__TMSK_FILE_END__'
Title: Opín Kinsulai – Genealogy Project Notification
Date: 2026-10-26
Category: Project
Display: text
Image:
File: opin-kinsulai.pdf
Pinned: no
Button:

TMSK is initiating a new project, “Opín Kinsulai”, to trace, document and preserve the genealogical heritage of the Mising community.

Notification No. TMSK/PROJECT/2026/02, dated 26 October 2026.

Under this initiative, TMSK intends to establish contact and collaborate with the staff members and representatives of various Ope: Kebang to trace and document their respective clan genealogies. The project also aims to establish effective coordination among different Ope: Kebang to facilitate the exchange of genealogical information, identify missing ancestral links, and reconstruct genealogical connections that remain undocumented or require further verification.

TMSK also intends to collaborate with Ope: Kebang, community elders, knowledgeable individuals and other relevant organisations to raise awareness about the genealogies of different Mising clans. Verified genealogical information will be shared through the TMSK page and other appropriate platforms.

All concerned Ope: Kebang, their staff members, community elders, researchers and individuals possessing relevant genealogical knowledge are requested to extend their cooperation and support to this initiative.
__TMSK_FILE_END__

# ===== .env.example =====
keep .env.example << '__TMSK_FILE_END__'
# Copy these two lines into a file named .env.local and fill in your real values.
VITE_SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR-ANON-PUBLIC-KEY
__TMSK_FILE_END__


chmod +x scripts/add-bulletin.sh
touch public/bulletin/.gitkeep

# ---------- pick the right way to read text files for this Vite version ----------
VITE_MAJOR=$(node -e "
let v='';
try { v=require('./node_modules/vite/package.json').version } catch(e) {}
if(!v){ try { const p=require('./package.json'); v=(p.devDependencies&&p.devDependencies.vite)||(p.dependencies&&p.dependencies.vite)||'' } catch(e) {} }
const m=String(v).match(/\d+/);
console.log(m?m[0]:'5');
" 2>/dev/null)
[ -z "$VITE_MAJOR" ] && VITE_MAJOR=5
if [ "$VITE_MAJOR" -ge 5 ]; then
  GLOB_OPTS="{ query: '?raw', import: 'default', eager: true }"
else
  GLOB_OPTS="{ as: 'raw', eager: true }"
fi
sed -i "s|__GLOB_OPTS__|$GLOB_OPTS|" src/data/loadBulletins.js
echo "Detected Vite version $VITE_MAJOR"

# ---------- keep the private settings file out of git ----------
if [ -f .gitignore ]; then
  if ! grep -qE '(^\*\.local$|^\.env\.local$)' .gitignore; then
    echo ".env.local" >> .gitignore
    echo "UPDATED: .gitignore (.env.local added)"
  fi
else
  echo ".env.local" > .gitignore
  echo "CREATED: .gitignore"
fi

echo ""
echo "================ CHECKS ================"
echo "Bulletin files:"
ls src/bulletins
echo ""
if [ -f public/bulletin/opin-kinsulai.pdf ]; then
  echo "OK: public/bulletin/opin-kinsulai.pdf is in place"
else
  echo "NOTE: public/bulletin/opin-kinsulai.pdf is missing. Drag the PDF into public/bulletin/"
fi
echo ""
echo "Leftover references to the old Documents page (should say none found):"
grep -rn -i -E "documents\.js|/documents|Documents\.jsx|pages/Documents" src index.html 2>/dev/null || echo "  none found"
echo ""
echo "Done. Start the site with:  npm run dev -- --host   then open /bulletin"
echo "Backups: $BACKUP_DIR"
