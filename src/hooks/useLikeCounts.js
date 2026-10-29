import { useCallback, useEffect, useState } from 'react'

const API = '/api/likes'

/**
 * Shared like counts (the number everybody sees).
 * counts is null while loading or when the like server is not set up,
 * in which case the page simply hides the numbers.
 */
export default function useLikeCounts() {
  const [counts, setCounts] = useState(null)

  useEffect(() => {
    let dead = false
    fetch(API, { cache: 'no-store' })
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error('no api'))))
      .then((data) => {
        if (!dead && data && typeof data.counts === 'object') setCounts(data.counts)
      })
      .catch(() => {})
    return () => {
      dead = true
    }
  }, [])

  const sendLike = useCallback((id, liked) => {
    setCounts((prev) =>
      prev ? { ...prev, [id]: Math.max(0, (prev[id] || 0) + (liked ? 1 : -1)) } : prev
    )
    fetch(API, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, liked }),
    })
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error('failed'))))
      .then((data) => {
        if (typeof data.count === 'number') {
          setCounts((prev) => (prev ? { ...prev, [id]: data.count } : prev))
        }
      })
      .catch(() => {})
  }, [])

  return { counts, sendLike }
}
