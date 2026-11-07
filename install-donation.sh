#!/bin/bash
# TMSK Donation installer.
# Run from /workspaces/kebang-website:   bash install-donation.sh
# Adds a Donate sub page and a donation panel that opens at the top of the page
# (it does not block the site and has a Cancel button). Uses the same Razorpay
# payment button as the other TMSK donation page.
# Files it changes are copied to /tmp/donation-install-backup-<time> first.

if [ ! -f src/App.jsx ] || [ ! -f src/components/Header.jsx ]; then
  echo "Run this from /workspaces/kebang-website (src/App.jsx or Header.jsx not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/donation-install-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in src/App.jsx src/components/Header.jsx src/components/DonationContext.jsx \
         src/components/DonationPanel.jsx src/components/DonationPanel.css \
         src/pages/Donate.jsx src/pages/Donate.css; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done
echo "Backups saved in: $BACKUP_DIR"
echo ""

mkdir -p src/components src/pages

put() {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  echo "WROTE: $1"
}

put src/components/DonationContext.jsx << '__TMSK_FILE_END__'
import { createContext, useCallback, useContext, useMemo, useState } from 'react'

const DonationContext = createContext(null)

export function DonationProvider({ children }) {
  const [open, setOpen] = useState(false)
  const openDonation = useCallback(() => setOpen(true), [])
  const closeDonation = useCallback(() => setOpen(false), [])
  const value = useMemo(
    () => ({ open, openDonation, closeDonation }),
    [open, openDonation, closeDonation],
  )
  return <DonationContext.Provider value={value}>{children}</DonationContext.Provider>
}

export function useDonation() {
  const ctx = useContext(DonationContext)
  if (!ctx) throw new Error('useDonation must be used inside DonationProvider')
  return ctx
}
__TMSK_FILE_END__

put src/components/DonationPanel.jsx << '__TMSK_FILE_END__'
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
__TMSK_FILE_END__

put src/components/DonationPanel.css << '__TMSK_FILE_END__'
.donation-panel {
  position: fixed;
  top: var(--donation-top, 96px);
  left: 50%;
  z-index: 900;
  box-sizing: border-box;
  width: min(520px, calc(100vw - 24px));
  max-height: calc(100vh - var(--donation-top, 96px) - 12px);
  overflow-y: auto;
  padding: 20px 22px 16px;
  background: #fff;
  border-top: 5px solid #8b1e1e;
  border-radius: 18px;
  box-shadow: 0 14px 40px rgba(0, 0, 0, 0.22);
  transform: translate(-50%, -24px);
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
  transition: transform 0.35s ease, opacity 0.35s ease, visibility 0s linear 0.35s;
}

.donation-panel.is-open {
  transform: translate(-50%, 0);
  opacity: 1;
  visibility: visible;
  pointer-events: auto;
  transition: transform 0.35s ease, opacity 0.35s ease, visibility 0s;
}

.donation-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
}

.donation-title {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #8b1e1e;
}

.donation-title h2 {
  margin: 0;
  font-size: 1.3rem;
  color: #222;
}

.donation-close {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 50%;
  background: #f6e7e7;
  color: #8b1e1e;
  font-size: 1.6rem;
  line-height: 1;
  cursor: pointer;
  transition: background 0.2s;
}

.donation-close:hover {
  background: #ecd0d0;
}

.donation-text {
  margin: 12px 0 14px;
  color: #555;
  line-height: 1.55;
}

.donation-form {
  display: flex;
  justify-content: center;
  min-height: 48px;
  margin: 0;
}

.donation-status {
  margin: 10px 0 0;
  color: #888;
  font-size: 0.9rem;
  text-align: center;
}

.donation-status.is-warn {
  padding: 10px 12px;
  border-radius: 10px;
  background: #fdf0db;
  color: #7a4a00;
}

.donation-actions {
  display: flex;
  justify-content: center;
  margin-top: 14px;
}

.donation-cancel {
  min-height: 44px;
  padding: 10px 28px;
  border: 2px solid #8b1e1e;
  border-radius: 999px;
  background: transparent;
  color: #8b1e1e;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: background 0.2s;
}

.donation-cancel:hover {
  background: #f6e7e7;
}

.donation-close:focus-visible,
.donation-cancel:focus-visible {
  outline: 3px solid #e3a3a3;
  outline-offset: 2px;
}

.donation-note {
  margin: 14px 0 0;
  color: #999;
  font-size: 0.78rem;
  text-align: center;
  line-height: 1.45;
}

@media (max-width: 560px) {
  .donation-panel {
    padding: 16px 16px 14px;
    border-radius: 16px;
  }

  .donation-cancel {
    width: 100%;
  }
}

@media (prefers-reduced-motion: reduce) {
  .donation-panel,
  .donation-panel.is-open {
    transition: none;
  }
}
__TMSK_FILE_END__

put src/pages/Donate.jsx << '__TMSK_FILE_END__'
import { useEffect } from 'react'
import { useDonation } from '../components/DonationContext.jsx'
import './Donate.css'

// You can change the wording on this page here.
const TAGLINE = 'Support the work of TMSK for the Mising community.'
const INTRO =
  'Takam Mising Sí:sang Kébang (TMSK) works for the Mising community, including projects to preserve its historical and cultural identity. Your contribution helps us carry this work forward.'

const STEPS = [
  { title: 'Tap Donate now', text: 'A small donation panel opens at the top of the page. You can keep browsing while it is open.' },
  { title: 'Use the payment button', text: 'Tap the payment button inside the panel to continue to Razorpay.' },
  { title: 'Complete your payment', text: 'Finish in the secure Razorpay window. Razorpay shows a confirmation when it is done.' },
]

const FAQ = [
  {
    q: 'Is my payment secure?',
    a: 'Payments are handled by Razorpay. TMSK does not see or store your card or bank details.',
  },
  {
    q: 'Can I cancel?',
    a: 'Yes. Use the Cancel button in the donation panel, or close the Razorpay window before you pay.',
  },
]

export default function Donate() {
  const { open, openDonation, closeDonation } = useDonation()

  // Show the donation panel shortly after this page opens, and hide it when leaving
  useEffect(() => {
    const timer = setTimeout(openDonation, 700)
    return () => {
      clearTimeout(timer)
      closeDonation()
    }
  }, [openDonation, closeDonation])

  return (
    <div className="donate-page">
      <header className="donate-hero">
        <h1>Donate</h1>
        <p>{TAGLINE}</p>
      </header>

      <section className="donate-card">
        <div className="donate-heart" aria-hidden="true">
          <svg viewBox="0 0 24 24" width="34" height="34">
            <path
              d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
              fill="currentColor"
            />
          </svg>
        </div>
        <h2>Make a donation</h2>
        <p>{INTRO}</p>
        <button type="button" className="donate-cta" onClick={openDonation} aria-expanded={open}>
          Donate now
        </button>
        <p className="donate-secure">Secure payment by Razorpay</p>
      </section>

      <section className="donate-block" aria-labelledby="donate-how">
        <h2 id="donate-how">How it works</h2>
        <ol className="donate-steps">
          {STEPS.map((step, i) => (
            <li key={step.title} style={{ '--i': i }}>
              <span className="donate-step-num">{i + 1}</span>
              <div>
                <h3>{step.title}</h3>
                <p>{step.text}</p>
              </div>
            </li>
          ))}
        </ol>
      </section>

      <section className="donate-block" aria-labelledby="donate-faq">
        <h2 id="donate-faq">Good to know</h2>
        <div className="donate-faq">
          {FAQ.map((item) => (
            <div className="donate-faq-item" key={item.q}>
              <h3>{item.q}</h3>
              <p>{item.a}</p>
            </div>
          ))}
        </div>
      </section>
    </div>
  )
}
__TMSK_FILE_END__

put src/pages/Donate.css << '__TMSK_FILE_END__'
.donate-page {
  max-width: 860px;
  margin: 0 auto;
  padding: 48px 20px 80px;
}

.donate-hero {
  text-align: center;
  margin-bottom: 36px;
}

.donate-hero h1 {
  margin: 0 0 8px;
  font-size: clamp(1.8rem, 6vw, 3rem);
  animation: donate-fade-up 0.5s ease both;
}

.donate-hero p {
  margin: 0 auto;
  max-width: 520px;
  color: #666;
  animation: donate-fade-up 0.5s ease 0.1s both;
}

.donate-card {
  padding: 34px 28px 28px;
  border-radius: 22px;
  background: #fff;
  border-top: 6px solid #8b1e1e;
  box-shadow: 0 8px 28px rgba(0, 0, 0, 0.1);
  text-align: center;
  animation: donate-fade-up 0.55s ease 0.15s both;
}

.donate-heart {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 68px;
  height: 68px;
  margin-bottom: 10px;
  border-radius: 50%;
  background: #f6e7e7;
  color: #8b1e1e;
  animation: donate-beat 2.4s ease-in-out infinite;
}

.donate-card h2 {
  margin: 0 0 10px;
  font-size: 1.6rem;
}

.donate-card p {
  margin: 0 auto 22px;
  max-width: 560px;
  color: #555;
  line-height: 1.65;
}

.donate-cta {
  min-height: 52px;
  padding: 14px 44px;
  border: none;
  border-radius: 999px;
  background: #8b1e1e;
  color: #fff;
  font-size: 1.05rem;
  font-weight: 700;
  cursor: pointer;
  box-shadow: 0 6px 18px rgba(139, 30, 30, 0.35);
  transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
}

.donate-cta:hover {
  background: #6f1717;
  box-shadow: 0 8px 22px rgba(139, 30, 30, 0.45);
}

.donate-cta:active {
  transform: scale(0.97);
}

.donate-cta:focus-visible {
  outline: 3px solid #e3a3a3;
  outline-offset: 3px;
}

.donate-card .donate-secure {
  margin: 14px 0 0;
  font-size: 0.85rem;
  color: #999;
}

.donate-block {
  margin-top: 44px;
}

.donate-block h2 {
  margin: 0 0 18px;
  font-size: 1.4rem;
  text-align: center;
}

.donate-steps {
  list-style: none;
  margin: 0;
  padding: 0;
  display: grid;
  gap: 14px;
}

.donate-steps li {
  display: flex;
  align-items: flex-start;
  gap: 16px;
  padding: 16px 18px;
  border-radius: 16px;
  background: #fff;
  box-shadow: 0 4px 14px rgba(0, 0, 0, 0.07);
  animation: donate-fade-up 0.5s ease both;
  animation-delay: calc(var(--i) * 90ms + 250ms);
}

.donate-step-num {
  flex-shrink: 0;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 50%;
  background: #8b1e1e;
  color: #fff;
  font-weight: 700;
}

.donate-steps h3 {
  margin: 0 0 4px;
  font-size: 1.05rem;
}

.donate-steps p {
  margin: 0;
  color: #666;
  line-height: 1.55;
}

.donate-faq {
  display: grid;
  gap: 14px;
}

.donate-faq-item {
  padding: 16px 18px;
  border-left: 4px solid #8b1e1e;
  border-radius: 12px;
  background: #faf6f6;
}

.donate-faq-item h3 {
  margin: 0 0 6px;
  font-size: 1.02rem;
}

.donate-faq-item p {
  margin: 0;
  color: #666;
  line-height: 1.55;
}

@keyframes donate-fade-up {
  from { opacity: 0; transform: translateY(16px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes donate-beat {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.08); }
}

@media (max-width: 560px) {
  .donate-page {
    padding: 32px 14px 60px;
  }

  .donate-card {
    padding: 26px 18px 22px;
  }

  .donate-cta {
    width: 100%;
    padding: 14px 20px;
  }

  .donate-steps li {
    padding: 14px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .donate-hero h1,
  .donate-hero p,
  .donate-card,
  .donate-heart,
  .donate-steps li {
    animation: none;
  }

  .donate-cta {
    transition: none;
  }
}
__TMSK_FILE_END__


# ---------- connect the new page to App.jsx and the menu ----------
python3 - << 'PYPATCH'
import re, sys

def fail(msg):
    print("PROBLEM: " + msg)
    print("Nothing was changed in App.jsx or Header.jsx. Paste that file here and I will fix it.")
    sys.exit(1)

# ----- App.jsx -----
app_path = 'src/App.jsx'
app = open(app_path, encoding='utf-8').read()
new_app = app

if 'DonationProvider' in new_app and 'pages/Donate.jsx' in new_app and '/donate' in new_app:
    print('KEPT: src/App.jsx already has the donation page')
else:
    if 'pages/Donate.jsx' not in new_app:
        imports = list(re.finditer(r'^import .*\n', new_app, re.M))
        if not imports:
            fail('no import lines found in src/App.jsx')
        last = imports[-1]
        add = ("import Donate from './pages/Donate.jsx'\n"
               "import DonationPanel from './components/DonationPanel.jsx'\n"
               "import { DonationProvider } from './components/DonationContext.jsx'\n")
        new_app = new_app[:last.end()] + add + new_app[last.end():]

    if 'path="/donate"' not in new_app:
        m = re.search(r'^([ \t]*)<Route path="\*"', new_app, re.M)
        if not m:
            fail('could not find the <Route path="*" ...> line in src/App.jsx')
        route = m.group(1) + '<Route path="/donate" element={<Donate />} />\n'
        new_app = new_app[:m.start()] + route + new_app[m.start():]

    if 'DonationProvider>' not in new_app.split('export default')[-1]:
        m = re.search(r'return \(\s*\n([ \t]*)<div className="app-shell">', new_app)
        if not m:
            fail('could not find the app-shell <div> in src/App.jsx')
        new_app = (new_app[:m.start()] + 'return (\n    <DonationProvider>\n' + m.group(1) +
                   '<div className="app-shell">' + new_app[m.end():])
        idx = new_app.rfind('</div>')
        if idx == -1:
            fail('could not find the closing </div> in src/App.jsx')
        head = new_app[:idx].rstrip(' ')
        new_app = head + '      <DonationPanel />\n    </div>\n    </DonationProvider>' + new_app[idx + len('</div>'):]

    open(app_path, 'w', encoding='utf-8').write(new_app)
    print('UPDATED: src/App.jsx (Donate route and donation panel added)')

# ----- Header.jsx -----
hp = 'src/components/Header.jsx'
header = open(hp, encoding='utf-8').read()
if "'/donate'" in header or '"/donate"' in header:
    print('KEPT: src/components/Header.jsx already has the Donate link')
else:
    m = re.search(r'const NAV_ITEMS = \[(.*?)\n\]', header, re.S)
    if not m:
        fail('could not find NAV_ITEMS in src/components/Header.jsx')
    inner = m.group(1).rstrip()
    if not inner.endswith(','):
        inner += ','
    inner += "\n  { to: '/donate', label: 'Donate' },"
    header = header[:m.start(1)] + inner + header[m.end(1):]
    open(hp, 'w', encoding='utf-8').write(header)
    print('UPDATED: src/components/Header.jsx (Donate menu link added)')
PYPATCH
PATCH_STATUS=$?
if [ "$PATCH_STATUS" -ne 0 ]; then
  echo "Restoring your original files from the backup..."
  cp "$BACKUP_DIR/src/App.jsx" src/App.jsx
  cp "$BACKUP_DIR/src/components/Header.jsx" src/components/Header.jsx
  exit 1
fi

echo ""
echo "================ CHECKS ================"
echo "Donate route and menu link:"
grep -n "donate" src/App.jsx src/components/Header.jsx
echo ""
echo "Done. Start the site with:  npm run dev -- --host   then open /donate"
echo "Backups: $BACKUP_DIR"
