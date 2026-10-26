import { useState } from 'react'
import { documentSections } from '../data/documents'
import './Documents.css'

function getFileType(file) {
  const parts = file.split('.')
  return parts.length > 1 ? parts.pop().toUpperCase() : 'FILE'
}

function formatDate(value) {
  if (!value) return ''
  const date = new Date(value)
  if (isNaN(date)) return value
  return date.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })
}

function DocumentItem({ doc, sectionId, index }) {
  const href = `/documents/${sectionId}/${encodeURIComponent(doc.file)}`
  const date = formatDate(doc.date)

  return (
    <li className="doc-item" style={{ '--i': index }}>
      <span className="doc-type">{getFileType(doc.file)}</span>
      <div className="doc-info">
        <h3 className="doc-title">{doc.title}</h3>
        {date && <p className="doc-date">{date}</p>}
      </div>
      <div className="doc-actions">
        <a href={href} target="_blank" rel="noopener noreferrer" className="doc-link">
          View
        </a>
        <a href={href} download className="doc-link doc-link-solid">
          Download
        </a>
      </div>
    </li>
  )
}

export default function Documents() {
  const [activeId, setActiveId] = useState(documentSections[0].id)
  const active = documentSections.find((s) => s.id === activeId)

  return (
    <div className="documents-page">
      <header className="documents-hero">
        <h1>Official Documents</h1>
        <p>Official TMSK records, organised by category.</p>
      </header>

      <div className="docs-layout">
        <aside className="docs-sidebar">
          <p className="docs-sidebar-label">Sections</p>
          <nav aria-label="Document sections">
            <ul className="docs-menu">
              {documentSections.map((section, index) => {
                const isActive = section.id === activeId
                return (
                  <li key={section.id} className="docs-menu-item" style={{ '--i': index }}>
                    <button
                      type="button"
                      className={isActive ? 'docs-menu-btn active' : 'docs-menu-btn'}
                      onClick={() => setActiveId(section.id)}
                      aria-current={isActive ? 'true' : undefined}
                    >
                      <span className="docs-menu-text">{section.title}</span>
                      <span className="doc-count">{section.documents.length}</span>
                    </button>
                  </li>
                )
              })}
            </ul>
          </nav>
        </aside>

        <section className="docs-panel" key={active.id} aria-labelledby={`${active.id}-heading`}>
          <h2 id={`${active.id}-heading`} className="doc-section-title">
            {active.title}
          </h2>
          <p className="doc-section-desc">{active.description}</p>

          {active.documents.length === 0 ? (
            <p className="doc-empty">No documents have been uploaded to this section yet.</p>
          ) : (
            <ul className="doc-list">
              {active.documents.map((doc, index) => (
                <DocumentItem
                  key={`${active.id}-${doc.file}`}
                  doc={doc}
                  sectionId={active.id}
                  index={index}
                />
              ))}
            </ul>
          )}
        </section>
      </div>
    </div>
  )
}
