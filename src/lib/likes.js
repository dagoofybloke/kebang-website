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
