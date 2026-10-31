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
