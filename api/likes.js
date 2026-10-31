// Vercel serverless function for shared like counts.
// Needs a free Upstash Redis database. Add these two env vars in
// Vercel -> Project -> Settings -> Environment Variables:
//   UPSTASH_REDIS_REST_URL
//   UPSTASH_REDIS_REST_TOKEN
// Without them this returns 503 and the site quietly falls back to
// per-browser likes.

const URL_ = process.env.UPSTASH_REDIS_REST_URL
const TOKEN = process.env.UPSTASH_REDIS_REST_TOKEN
const keyFor = (id) => `bulletin:likes:${id}`
const validId = (id) => typeof id === 'string' && /^[\w-]{1,100}$/.test(id)

async function redis(cmd) {
  const r = await fetch(URL_, {
    method: 'POST',
    headers: { Authorization: `Bearer ${TOKEN}` },
    body: JSON.stringify(cmd),
  })
  const j = await r.json()
  return j.result
}

export default async function handler(req, res) {
  if (!URL_ || !TOKEN) return res.status(503).json({ error: 'Likes storage not configured' })

  try {
    if (req.method === 'GET') {
      const ids = String(req.query.ids || '').split(',').filter(validId).slice(0, 200)
      if (!ids.length) return res.status(200).json({ counts: {} })
      const vals = await redis(['MGET', ...ids.map(keyFor)])
      const counts = {}
      ids.forEach((id, i) => { counts[id] = Math.max(0, parseInt(vals[i] || '0', 10) || 0) })
      return res.status(200).json({ counts })
    }

    if (req.method === 'POST') {
      const { id, action } = req.body || {}
      if (!validId(id)) return res.status(400).json({ error: 'Bad id' })
      let count = await redis([action === 'unlike' ? 'DECR' : 'INCR', keyFor(id)])
      if (count < 0) {
        await redis(['SET', keyFor(id), '0'])
        count = 0
      }
      return res.status(200).json({ count })
    }

    return res.status(405).json({ error: 'Method not allowed' })
  } catch {
    return res.status(500).json({ error: 'Server error' })
  }
}
