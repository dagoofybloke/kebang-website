import { useEffect, useRef, useState } from 'react'

/**
 * Lightweight scroll-reveal hook — no external dependency.
 * Returns a ref to attach and a boolean that flips to true once
 * the element crosses into the viewport, then stays true.
 */
export default function useInView(options = {}){
  const ref = useRef(null)
  const [inView, setInView] = useState(false)

  useEffect(() => {
    const node = ref.current
    if (!node) return

    if (typeof IntersectionObserver === 'undefined'){
      setInView(true)
      return
    }

    const observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting){
          setInView(true)
          observer.unobserve(node)
        }
      },
      { threshold: 0.15, rootMargin: '0px 0px -60px 0px', ...options }
    )

    observer.observe(node)
    return () => observer.disconnect()
  }, [])

  return [ref, inView]
}
