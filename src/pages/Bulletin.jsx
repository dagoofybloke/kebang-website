import { useEffect, useRef, useState } from 'react'
import { bulletins, bulletinCategories } from '../data/bulletins'
import './Bulletin.css'
import { BulletinImages, BulletinFiles } from '../components/BulletinMedia.jsx'
import useLikeCounts from '../hooks/useLikeCounts.js'

const MONTHS = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
]
const MONTHS_SHORT = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

const LIKES_KEY = 'tmsk-bulletin-likes'
const COMMENTS_KEY = 'tmsk-bulletin-comments'
const NAME_KEY = 'tmsk-bulletin-name'

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

function toParagraphs(text) {
  if (!text) return []
  return String(text)
    .split(/\n\s*\n/)
    .map((p) => p.replace(/\s*\n\s*/g, ' ').trim())
    .filter(Boolean)
}

function catSlug(cat) {
  return String(cat || '').toLowerCase().replace(/[^a-z]/g, '')
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
  const [name, setName] = useState(savedName || '')
  const [text, setText] = useState('')
  const shareRef = useRef(null)

  const d = dateParts(item.date)
  const slug = catSlug(item.category)
  const paragraphs = toParagraphs(item.body)

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

  function getShareUrl() {
    return `${window.location.origin}/bulletin#${item.id}`
  }

  async function handleShare() {
    const url = getShareUrl()
    if (typeof navigator !== 'undefined' && navigator.share) {
      try {
        await navigator.share({ title: item.title, text: item.summary || item.title, url })
      } catch {
        /* share was cancelled */
      }
      return
    }
    setShareOpen((open) => !open)
  }

  async function copyLink() {
    const url = getShareUrl()
    try {
      await navigator.clipboard.writeText(url)
    } catch {
      const area = document.createElement('textarea')
      area.value = url
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

  const shareText = encodeURIComponent(`${item.title} ${typeof window !== 'undefined' ? `${window.location.origin}/bulletin#${item.id}` : ''}`)
  const shareLink = encodeURIComponent(typeof window !== 'undefined' ? `${window.location.origin}/bulletin#${item.id}` : '')

  return (
    <article
      id={`b-${item.id}`}
      className={`b-card cat-${slug}${highlighted ? ' is-highlighted' : ''}`}
      style={{ '--i': index }}
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
        {item.summary && <p className="b-summary">{item.summary}</p>}

        <BulletinImages item={item} />

        {expanded && paragraphs.length > 0 && (
          <div className="b-body">
            {paragraphs.map((p, i) => (
              <p key={i}>{p}</p>
            ))}
          </div>
        )}

        {paragraphs.length > 0 && (
          <div className="b-links">
            {paragraphs.length > 0 && (
              <button
                type="button"
                className="b-readmore"
                aria-expanded={expanded}
                onClick={() => setExpanded((v) => !v)}
              >
                {expanded ? 'Show less' : 'Read more'}
              </button>
            )}
          </div>
        )}

        <BulletinFiles item={item} />

        <div className="b-actions">
          <button
            type="button"
            className={liked ? 'b-action like-btn liked' : 'b-action like-btn'}
            onClick={() => onToggleLike(item.id)}
            aria-pressed={liked}
          >
            <HeartIcon filled={liked} />
            <span>
              {liked ? 'Liked' : 'Like'}
              {typeof likeCount === 'number' ? ` (${likeCount})` : ''}
            </span>
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
                  href={`https://wa.me/?text=${shareText}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  onClick={() => setShareOpen(false)}
                >
                  WhatsApp
                </a>
                <a
                  role="menuitem"
                  href={`https://www.facebook.com/sharer/sharer.php?u=${shareLink}`}
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
            <p className="b-local-note">Likes and comments are saved on this device only.</p>
          </div>
        )}
      </div>
    </article>
  )
}

export default function Bulletin() {
  const [active, setActive] = useState('All')
  const [likes, setLikes] = useState(() => readStore(LIKES_KEY, {}))
  const [comments, setComments] = useState(() => readStore(COMMENTS_KEY, {}))
  const [savedName, setSavedName] = useState(() => readStore(NAME_KEY, ''))
  const [highlightId, setHighlightId] = useState(null)
  const feedRef = useRef(null)
  const { counts, sendLike } = useLikeCounts()

  // Open a specific bulletin when the link ends with #its-id
  useEffect(() => {
    const id = decodeURIComponent(window.location.hash.replace('#', ''))
    if (!id || !bulletins.some((b) => b.id === id)) return undefined
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

  function toggleLike(id) {
    sendLike(id, !likes[id])
    setLikes((prev) => {
      const next = { ...prev }
      if (next[id]) delete next[id]
      else next[id] = true
      writeStore(LIKES_KEY, next)
      return next
    })
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

  const sorted = [...bulletins].sort((a, b) => {
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
            {['All', ...bulletinCategories].map((cat, index) => {
              const count =
                cat === 'All' ? bulletins.length : bulletins.filter((b) => b.category === cat).length
              const isActive = cat === active
              return (
                <li key={cat} className="bulletin-menu-item" style={{ '--i': index }}>
                  <button
                    type="button"
                    className={`bulletin-menu-btn cat-${catSlug(cat)}${isActive ? ' active' : ''}`}
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
                      likeCount={counts ? counts[item.id] || 0 : null}
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
