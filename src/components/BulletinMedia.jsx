import { useEffect, useState } from 'react'
import './BulletinMedia.css'

// Accepts a string ('a.jpg') or an object ({ src: 'a.jpg', label: 'Poster' })
function toList(...values) {
  return values
    .flat()
    .filter(Boolean)
    .map((v) => (typeof v === 'string' ? { src: v, label: '' } : { src: v.src, label: v.label || '' }))
    .filter((v) => v.src)
}

const url = (name) => `/bulletin/${encodeURIComponent(name)}`

function extOf(name) {
  const m = /\.([a-z0-9]+)$/i.exec(name)
  return m ? m[1].toLowerCase() : ''
}

function prettyName(name) {
  return name
    .replace(/\.[^.]+$/, '')
    .replace(/[-_]+/g, ' ')
    .replace(/\b\w/g, (c) => c.toUpperCase())
}

const TYPE_LABELS = {
  pdf: 'PDF document',
  doc: 'Word document',
  docx: 'Word document',
  xls: 'Excel sheet',
  xlsx: 'Excel sheet',
  ppt: 'Presentation',
  pptx: 'Presentation',
  txt: 'Text file',
  csv: 'Spreadsheet (CSV)',
  zip: 'ZIP archive',
}

function typeLabel(ext) {
  return TYPE_LABELS[ext] || (ext ? `${ext.toUpperCase()} file` : 'File')
}

/* ------------------------------ IMAGES ------------------------------ */

export function BulletinImages({ item }) {
  const images = toList(item.image, item.images)
  const [failed, setFailed] = useState({})
  const [open, setOpen] = useState(null)
  const visible = images.filter((i) => !failed[i.src])

  useEffect(() => {
    if (open === null) return undefined
    const onKey = (e) => {
      if (e.key === 'Escape') setOpen(null)
      if (e.key === 'ArrowRight') setOpen((o) => (o + 1) % visible.length)
      if (e.key === 'ArrowLeft') setOpen((o) => (o - 1 + visible.length) % visible.length)
    }
    const previous = document.body.style.overflow
    document.body.style.overflow = 'hidden'
    window.addEventListener('keydown', onKey)
    return () => {
      window.removeEventListener('keydown', onKey)
      document.body.style.overflow = previous
    }
  }, [open, visible.length])

  if (visible.length === 0) return null
  const current = open !== null ? visible[open] : null

  return (
    <>
      <div className={`bm-images bm-count-${Math.min(visible.length, 4)}`}>
        {visible.map((img, i) => (
          <button
            type="button"
            key={img.src}
            className="bm-thumb"
            onClick={() => setOpen(i)}
            aria-label={`Open image ${i + 1} of ${visible.length}`}
          >
            <img
              src={url(img.src)}
              alt={img.label || item.title}
              loading="lazy"
              onError={() => setFailed((f) => ({ ...f, [img.src]: true }))}
            />
          </button>
        ))}
      </div>

      {current && (
        <div
          className="bm-lightbox"
          role="dialog"
          aria-modal="true"
          aria-label="Image viewer"
          onClick={() => setOpen(null)}
        >
          <button type="button" className="bm-close" aria-label="Close" onClick={() => setOpen(null)}>
            &times;
          </button>

          {visible.length > 1 && (
            <>
              <button
                type="button"
                className="bm-nav bm-prev"
                aria-label="Previous image"
                onClick={(e) => {
                  e.stopPropagation()
                  setOpen((open - 1 + visible.length) % visible.length)
                }}
              >
                &lsaquo;
              </button>
              <button
                type="button"
                className="bm-nav bm-next"
                aria-label="Next image"
                onClick={(e) => {
                  e.stopPropagation()
                  setOpen((open + 1) % visible.length)
                }}
              >
                &rsaquo;
              </button>
            </>
          )}

          <figure className="bm-figure" onClick={(e) => e.stopPropagation()}>
            <img src={url(current.src)} alt={current.label || item.title} />
            <figcaption>
              <span>{current.label || item.title}</span>
              <a href={url(current.src)} download>
                Download image
              </a>
            </figcaption>
          </figure>
        </div>
      )}
    </>
  )
}

/* ------------------------------- FILES ------------------------------ */

function FileCard({ file }) {
  const [preview, setPreview] = useState(false)
  const ext = extOf(file.src)
  const href = url(file.src)
  const label = file.label || prettyName(file.src)
  const canPreview = ext === 'pdf'

  return (
    <div className="bm-file">
      <div className="bm-file-row">
        <span className="bm-file-icon" aria-hidden="true">
          {ext ? ext.slice(0, 4).toUpperCase() : 'FILE'}
        </span>
        <span className="bm-file-text">
          <strong>{label}</strong>
          <small>{typeLabel(ext)}</small>
        </span>
        <span className="bm-file-actions">
          {canPreview && (
            <button
              type="button"
              className="bm-btn"
              aria-expanded={preview}
              onClick={() => setPreview((v) => !v)}
            >
              {preview ? 'Hide preview' : 'Preview'}
            </button>
          )}
          <a className="bm-btn" href={href} target="_blank" rel="noopener noreferrer">
            Open
          </a>
          <a className="bm-btn bm-btn-primary" href={href} download>
            Download
          </a>
        </span>
      </div>

      {preview && canPreview && (
        <>
          <iframe className="bm-pdf" src={`${href}#view=FitH`} title={label} loading="lazy" />
          <p className="bm-hint">If the preview does not load on your phone, tap Open.</p>
        </>
      )}
    </div>
  )
}

export function BulletinFiles({ item }) {
  const files = toList(item.file, item.files)
  if (files.length === 0) return null
  return (
    <div className="bm-files">
      {files.map((f) => (
        <FileCard key={f.src} file={f} />
      ))}
    </div>
  )
}
