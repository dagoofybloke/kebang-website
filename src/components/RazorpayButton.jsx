import { useEffect, useRef, useState } from 'react'
import {
  RAZORPAY_PAYMENT_BUTTON_ID,
  RAZORPAY_SCRIPT_SRC,
  DONATION_FALLBACK_URL,
} from '../donationConfig.js'
import './RazorpayButton.css'

const GIVE_UP_AFTER_MS = 10000

export default function RazorpayButton() {
  const holderRef = useRef(null)
  const startedRef = useRef(-1)
  const scriptFailedRef = useRef(false)
  const [attempt, setAttempt] = useState(0)
  const [status, setStatus] = useState('loading') // loading | ready | slow | blocked

  // 1) Put the Razorpay script inside a real <form>, once per attempt.
  //    (The guard stops it being added twice in development mode.)
  useEffect(() => {
    const holder = holderRef.current
    if (!holder || startedRef.current === attempt) return
    startedRef.current = attempt
    scriptFailedRef.current = false

    holder.textContent = ''
    const form = document.createElement('form')
    holder.appendChild(form)

    const script = document.createElement('script')
    script.src = RAZORPAY_SCRIPT_SRC
    script.async = true
    script.setAttribute('data-payment_button_id', RAZORPAY_PAYMENT_BUTTON_ID)
    script.onerror = () => {
      scriptFailedRef.current = true
      setStatus('blocked')
    }
    form.appendChild(script)
  }, [attempt])

  // 2) Watch for the button to appear, and give help if it does not.
  useEffect(() => {
    const holder = holderRef.current
    if (!holder) return undefined

    const check = () => {
      const found = Array.from(holder.querySelectorAll('*')).some(
        (el) => el.tagName !== 'FORM' && el.tagName !== 'SCRIPT',
      )
      if (found) setStatus('ready')
      return found
    }

    const observer = new MutationObserver(check)
    observer.observe(holder, { childList: true, subtree: true })
    const timer = setTimeout(() => {
      if (!check()) setStatus(scriptFailedRef.current ? 'blocked' : 'slow')
    }, GIVE_UP_AFTER_MS)

    return () => {
      observer.disconnect()
      clearTimeout(timer)
    }
  }, [attempt])

  const retry = () => {
    setStatus('loading')
    setAttempt((a) => a + 1)
  }

  return (
    <div className="rzp-wrap">
      <div ref={holderRef} className="rzp-holder" />

      {status === 'loading' && <p className="rzp-status">Loading the payment button&hellip;</p>}

      {(status === 'slow' || status === 'blocked') && (
        <div className="rzp-help" role="alert">
          <p>
            {status === 'blocked'
              ? 'The payment button could not be loaded. An ad blocker, VPN or network setting may be blocking Razorpay.'
              : 'The payment button is taking longer than usual. Please check your internet connection.'}
          </p>
          <div className="rzp-help-actions">
            <button type="button" className="rzp-retry" onClick={retry}>
              Try again
            </button>
            {DONATION_FALLBACK_URL && (
              <a
                className="rzp-fallback"
                href={DONATION_FALLBACK_URL}
                target="_blank"
                rel="noopener noreferrer"
              >
                Open our other donation page
              </a>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
