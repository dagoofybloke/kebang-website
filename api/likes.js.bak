// Vercel serverless function: GET /api/likes  and  POST /api/likes
// Needs an Upstash Redis database connected to the Vercel project
// (Vercel dashboard -> Storage -> Upstash Redis). It reads these variables,
// which Vercel adds automatically when you connect the database:
//   UPSTASH_REDIS_REST_URL / UPSTASH_REDIS_REST_TOKEN
//   (or KV_REST_API_URL / KV_REST_API_TOKEN)
import { bulletins } from '../src/data/bulletins.js'

const REDIS_URL = process.env.UPSTASH_REDIS_REST_URL || process.env.KV_REST_API_URL
const REDIS_TOKEN = process.env.UPSTASH_REDIS_REST_TOKEN || process.env.KV_REST_API_TOKEN
const KEY = 'tmsk:bulletin:likes'
const VALID_IDS = new Set(bulletins.map((b) => b.id))

async function redis(command) {
  const res = await fetch(REDIS_URL, {
    method: 'POST',
    headers: { Authorization: `Bearer ${REDIS_TOKEN}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(command),
  })
  if (!res.ok) throw new Error(`Redis responded ${res.status}`)
  const data = await res.json()
  if (data.error) throw new Error(data.error)
  return data.result
}

export default async function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store')

  if (!REDIS_URL || !REDIS_TOKEN) {
    return res.status(503).json({ error: 'Like storage is not set up yet' })
  }

  try {
    if (req.method === 'GET') {
      const flat = (await redis(['HGETALL', KEY])) || []
      const counts = {}
      for (let i = 0; i < flat.length; i += 2) {
        if (VALID_IDS.has(flat[i])) counts[flat[i]] = Math.max(0, Number(flat[i + 1]) || 0)
      }
      return res.status(200).json({ counts })
    }

    if (req.method === 'POST') {
      const body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body || {}
      const { id, liked } = body
      if (typeof id !== 'string' || !VALID_IDS.has(id)) {
        return res.status(400).json({ error: 'Unknown bulletin' })
      }
      let count = await redis(['HINCRBY', KEY, id, liked ? 1 : -1])
      if (count < 0) {
        await redis(['HSET', KEY, id, 0])
        count = 0
      }
      return res.status(200).json({ count })
    }

    res.setHeader('Allow', 'GET, POST')
    return res.status(405).json({ error: 'Method not allowed' })
  } catch (err) {
    return res.status(500).json({ error: 'Could not reach like storage' })
  }
}
