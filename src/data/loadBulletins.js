// Reads every .txt file in src/bulletins (except files starting with "_")
// and turns each one into a bulletin. You never need to edit this file.

const files = import.meta.glob('../bulletins/*.txt', { query: '?raw', import: 'default', eager: true })

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
