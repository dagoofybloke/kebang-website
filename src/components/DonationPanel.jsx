import { useEffect, useRef, useState } from 'react'
import { useDonation } from './DonationContext.jsx'
import './DonationPanel.css'

// The same Razorpay payment button that the other TMSK donation page uses.
const RAZORPAY_PAYMENT_BUTTON_ID = 'pl_T8BCDbnyoQOfMM'
const RAZORPAY_SCRIPT = 'https://checkout.razorpay.com/v1/payment-button.js'

export default function DonationPanel() {
  const { open, closeDonation } = useDonation()
  const formRef = useRef(null)
  const [wasOpened, setWasOpened] = useState(false)
  const [status, setStatus] = useState('loading')
  const [topOffset, setTopOffset] = useState(96)

  useEffect(() => {
    if (open) setWasOpened(true)
  }, [open])

  // Keep the panel just below the site header, wherever the header is
  useEffect(() => {
    if (!open) return undefined
    const measure = () => {
      const header = document.querySelector('.site-header')
      const bottom = header ? Math.max(Math.round(header.getBoundingClientRect().bottom), 0) : 0
      setTopOffset(bottom + 12)
    }
    measure()
    window.addEventListener('scroll', measure, { passive: true })
    window.addEventListener('resize', measure)
    return () => {
      window.removeEventListener('scroll', measure)
      window.removeEventListener('resize', measure)
    }
  }, [open])

  // Esc closes the panel
  useEffect(() => {
    if (!open) return undefined
    const onKey = (e) => {
      if (e.key === 'Escape') closeDonation()
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open, closeDonation])

  // Load the Razorpay payment button once, the first time the panel opens
  useEffect(() => {
    if (!wasOpened || !formRef.current) return
    if (formRef.current.querySelector('script')) return

    const script = document.createElement('script')
    script.src = RAZORPAY_SCRIPT
    script.dataset.payment_button_id = RAZORPAY_PAYMENT_BUTTON_ID
    script.async = true
    formRef.current.appendChild(script)
  }, [wasOpened])

  // Show a helpful message if the button does not appear
  useEffect(() => {
    if (!wasOpened || !formRef.current) return undefined
    const form = formRef.current
    const check = () => {
      if (form.querySelector('button, input[type="submit"], iframe')) setStatus('ready')
    }
    const observer = new MutationObserver(check)
    observer.observe(form, { childList: true, subtree: true })
    const timer = setTimeout(() => {
      setStatus((current) => (current === 'ready' ? current : 'slow'))
    }, 8000)
    check()
    return () => {
      observer.disconnect()
      clearTimeout(timer)
    }
  }, [wasOpened])

  return (
    <aside
      className={open ? 'donation-panel is-open' : 'donation-panel'}
      style={{ '--donation-top': `${topOffset}px` }}
      role="dialog"
      aria-modal="false"
      aria-label="Donate to TMSK"
      aria-hidden={!open}
    >
      <div className="donation-head">
        <div className="donation-title">
          <svg viewBox="0 0 24 24" width="22" height="22" aria-hidden="true">
            <path
              d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
              fill="currentColor"
            />
          </svg>
          <h2>Support TMSK</h2>
        </div>
        <button
          type="button"
          className="donation-close"
          onClick={closeDonation}
          aria-label="Close donation panel"
        >
          &times;
        </button>
      </div>

      <p className="donation-text">
        Tap the payment button below to continue to Razorpay&rsquo;s secure payment window. You can
        cancel at any time.
      </p>

      <form ref={formRef} className="donation-form" />

      {status === 'loading' && wasOpened && (
        <p className="donation-status">Loading the payment button&hellip;</p>
      )}
      {status === 'slow' && (
        <p className="donation-status is-warn">
          The payment button is taking longer than usual. Please check your internet connection,
          then close this panel and try again.
        </p>
      )}

      <div className="donation-actions">
        <button type="button" className="donation-cancel" onClick={closeDonation}>
          Cancel
        </button>
      </div>

      <p className="donation-note">
        Payments are processed securely by Razorpay. TMSK does not store your card or bank details.
      </p>
    </aside>
  )
}
