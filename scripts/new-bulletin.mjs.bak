#!/usr/bin/env node
// Post a new bulletin from the terminal:   npm run bulletin
// Asks a few questions, copies your image / file into public/bulletin/
// and adds the entry to src/data/bulletins.js.
import fs from 'node:fs'
import os from 'node:os'
import path from 'node:path'
import readline from 'node:readline'
import { pathToFileURL } from 'node:url'

const root = process.cwd()
const dataFile = path.join(root, 'src/data/bulletins.js')
const outDir = path.join(root, 'public/bulletin')
const IMAGE_EXT = new Set(['.jpg', '.jpeg', '.png', '.gif', '.webp', '.avif', '.svg'])

if (!fs.existsSync(dataFile)) {
  console.error('Run this from the project root (cd /workspaces/kebang-website).')
  process.exit(1)
}
fs.mkdirSync(outDir, { recursive: true })

const rl = readline.createInterface({ input: process.stdin })
const lines = rl[Symbol.asyncIterator]()
let ended = false

async function readLine(prompt) {
  process.stdout.write(prompt)
  const { value, done } = await lines.next()
  if (done) {
    ended = true
    return ''
  }
  return value
}

async function ask(question, fallback = '', required = false) {
  for (;;) {
    const hint = fallback ? ` [${fallback}]` : ''
    const answer = (await readLine(`${question}${hint}: `)).trim() || fallback
    if (answer || !required) return answer
    if (ended) fail('Input ended before a required answer was given.')
    console.log('  This one is required.')
  }
}

async function askBody() {
  console.log('\nFull text (optional). Leave a blank line between paragraphs.')
  console.log('Finish with a single "." on its own line. Press Enter now to skip.')
  const out = []
  for (;;) {
    const line = await readLine('> ')
    if (ended) break
    if (line.trim() === '.') break
    if (out.length === 0 && line.trim() === '') break
    out.push(line)
  }
  return out.join('\n').trim()
}

function fail(message) {
  console.error(`\n${message}`)
  process.exit(1)
}

function cleanPath(input) {
  let p = input.trim().replace(/^['"]|['"]$/g, '').replace(/\\ /g, ' ')
  if (p.startsWith('~')) p = path.join(os.homedir(), p.slice(1))
  return path.resolve(p)
}

function safeName(name) {
  const ext = path.extname(name).toLowerCase()
  const base = path
    .basename(name, path.extname(name))
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
  return `${base || 'file'}${ext}`
}

function copyIntoBulletin(source) {
  const resolved = path.resolve(source)
  if (path.dirname(resolved) === outDir) return path.basename(resolved)
  const wanted = safeName(resolved)
  const ext = path.extname(wanted)
  const stem = path.basename(wanted, ext)
  const data = fs.readFileSync(resolved)
  let target = wanted
  let n = 2
  while (fs.existsSync(path.join(outDir, target))) {
    if (fs.readFileSync(path.join(outDir, target)).equals(data)) return target
    target = `${stem}-${n}${ext}`
    n += 1
  }
  fs.writeFileSync(path.join(outDir, target), data)
  const mb = data.length / 1024 / 1024
  if (mb > 5) console.log(`  Note: ${target} is ${mb.toFixed(1)} MB. Smaller files load faster.`)
  return target
}

async function collect(kind) {
  const label = kind === 'image' ? 'image' : 'file'
  const done = []
  for (;;) {
    console.log(`\nDrag the ${label}(s) into this window, or type the path(s). Separate several with a comma.`)
    const raw = await ask(`Path to ${label}(s)`, '', true)
    for (const piece of raw.split(',')) {
      if (!piece.trim()) continue
      const p = cleanPath(piece)
      if (!fs.existsSync(p) || !fs.statSync(p).isFile()) {
        console.log(`  Not found: ${p}`)
        continue
      }
      const isImage = IMAGE_EXT.has(path.extname(p).toLowerCase())
      if (kind === 'image' && !isImage) {
        console.log(`  Skipped (not an image): ${path.basename(p)}`)
        continue
      }
      done.push(copyIntoBulletin(p))
      console.log(`  Added: ${done[done.length - 1]}`)
    }
    if (done.length > 0) return done
    if (ended) fail('No valid ' + label + ' was given.')
    console.log(`  No valid ${label} yet, try again.`)
  }
}

const quote = (s) => `'${String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\s*\n\s*/g, ' ')}'`
const template = (s) => '`' + s.replace(/\\/g, '\\\\').replace(/`/g, '\\`').replace(/\$\{/g, '\\${') + '`'
const slugify = (s) =>
  s
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 60)

async function loadData() {
  return import(`${pathToFileURL(dataFile).href}?v=${Date.now()}-${Math.random()}`)
}

// ------------------------------ questions ------------------------------
const data = await loadData()
const categories = data.bulletinCategories
const existingIds = new Set(data.bulletins.map((b) => b.id))

console.log('\n=== New TMSK bulletin ===\n')

const title = await ask('Title', '', true)
const today = new Date().toLocaleDateString('en-CA')
let date = await ask('Date (YYYY-MM-DD)', today)
while (!/^\d{4}-\d{2}-\d{2}$/.test(date)) {
  if (ended) fail('Invalid date.')
  date = await ask('  Please use YYYY-MM-DD', today)
}

console.log('\nCategories:')
categories.forEach((c, i) => console.log(`  ${i + 1}) ${c}`))
let category = ''
while (!category) {
  const pick = await ask('Category (number or name)', '', true)
  category = categories[Number(pick) - 1] || categories.find((c) => c.toLowerCase() === pick.toLowerCase()) || ''
  if (!category) {
    if (ended) fail('Invalid category.')
    console.log('  Not a valid category.')
  }
}

const summary = await ask('Short summary (1-2 lines)', '', true)
const body = await askBody()
const pinned = /^y/i.test(await ask('\nPin to the top? (y/N)', 'n'))

console.log('\nAttachment:')
console.log('  1) Image(s)  - shown on the page')
console.log('  2) File(s)   - shown as a file card (PDF can be previewed)')
console.log('  3) Both')
console.log('  4) None')
const choice = await ask('Choose 1-4', '4')

let images = []
let files = []
if (choice === '1' || choice === '3') images = await collect('image')
if (choice === '2' || choice === '3') files = await collect('file')

let id = slugify(title) || 'bulletin'
let n = 2
while (existingIds.has(id)) id = `${slugify(title) || 'bulletin'}-${n++}`

const fields = [
  `    id: ${quote(id)},`,
  `    title: ${quote(title)},`,
  `    date: ${quote(date)},`,
  `    category: ${quote(category)},`,
  `    pinned: ${pinned},`,
  `    summary: ${quote(summary)},`,
]
if (body) fields.push(`    body: ${template(body)},`)
if (images.length === 1) fields.push(`    image: ${quote(images[0])},`)
if (images.length > 1) fields.push(`    images: [${images.map(quote).join(', ')}],`)
if (files.length === 1) fields.push(`    file: ${quote(files[0])},`)
if (files.length > 1) fields.push(`    files: [${files.map(quote).join(', ')}],`)

const entry = `  {\n${fields.join('\n')}\n  },\n`

console.log('\n--- Preview ---')
console.log(entry)
const ok = /^y/i.test(await ask('Add this bulletin? (Y/n)', 'y'))
if (!ok) {
  console.log('Cancelled. Nothing was added to bulletins.js (copied attachments stay in public/bulletin).')
  process.exit(0)
}

const original = fs.readFileSync(dataFile, 'utf8')
const marker = /^export const bulletins = \[[ \t]*\r?\n/m
if (!marker.test(original)) fail('Could not find "export const bulletins = [" in bulletins.js.')
fs.writeFileSync(dataFile, original.replace(marker, (m) => m + entry))

try {
  const check = await loadData()
  if (!check.bulletins.some((b) => b.id === id)) throw new Error('entry missing')
} catch (err) {
  fs.writeFileSync(dataFile, original)
  fail('Something went wrong, so bulletins.js was restored. Nothing was added.')
}

console.log(`\nDone. Added "${title}" (id: ${id}).`)
console.log('\nNext:')
console.log('  npm run dev -- --host                 (preview it)')
console.log(`  git add -A && git commit -m "Add bulletin: ${title.replace(/"/g, '')}" && git push`)
process.exit(0)
