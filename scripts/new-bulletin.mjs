// Usage:  npm run bulletin
//    or:  npm run bulletin -- "My title"
// Creates src/bulletin/<date>-<title>/post.json and copies in any
// images/files you drag into the terminal.

import fs from 'node:fs'
import path from 'node:path'
import readline from 'node:readline/promises'
import { stdin as input, stdout as output } from 'node:process'

const rl = readline.createInterface({ input, output })
const ask = async (q) => (await rl.question(q)).trim()

const slugify = (s) =>
  s.toLowerCase().normalize('NFKD').replace(/[^\w\s-]/g, '').trim().replace(/\s+/g, '-').slice(0, 50) || 'post'

function parsePaths(line) {
  const out = []
  const re = /"([^"]+)"|'([^']+)'|((?:\\ |\S)+)/g
  let m
  while ((m = re.exec(line))) out.push((m[1] || m[2] || m[3].replace(/\\ /g, ' ')).trim())
  return out
}

const today = new Date().toISOString().slice(0, 10)

const title = process.argv[2] || (await ask('Title: '))
if (!title) {
  console.log('A title is required.')
  rl.close()
  process.exit(1)
}

const date = (await ask(`Date (YYYY-MM-DD) [${today}]: `)) || today
const bodyRaw = await ask('Text (type \\n\\n for a new paragraph, Enter to skip): ')
const pinned = /^y/i.test(await ask('Pin to top? (y/N): '))
const filesLine = await ask('Drag images/files here, then press Enter (or just Enter to skip): ')
rl.close()

const folder = path.join('src', 'bulletin', `${date}-${slugify(title)}`)
fs.mkdirSync(folder, { recursive: true })

const post = { title, date, body: bodyRaw.replace(/\\n/g, '\n'), pinned }
fs.writeFileSync(path.join(folder, 'post.json'), JSON.stringify(post, null, 2) + '\n')
console.log(`CREATED: ${folder}/post.json`)

for (const src of parsePaths(filesLine)) {
  if (!fs.existsSync(src) || !fs.statSync(src).isFile()) {
    console.log(`SKIPPED (not found): ${src}`)
    continue
  }
  const { name, ext } = path.parse(src)
  let target = path.join(folder, name + ext)
  for (let i = 2; fs.existsSync(target); i++) target = path.join(folder, `${name}-${i}${ext}`)
  fs.copyFileSync(src, target)
  console.log(`COPIED: ${target}`)
}

console.log(`
Done. You can add more images or files any time by dropping them into:
  ${folder}/
Images show as images, everything else shows as a downloadable file.
`)
