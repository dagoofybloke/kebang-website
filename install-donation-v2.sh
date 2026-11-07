#!/bin/bash
# =====================================================================
# TMSK Donation installer, version 2
#
# HOW TO USE
#   1. Put this file in /workspaces/kebang-website (drag it into the
#      Codespaces file list, or paste it with: nano install-donation-v2.sh)
#   2. In the Codespaces terminal run:
#          cd /workspaces/kebang-website
#          bash install-donation-v2.sh
#      Optional: give the link of your other donation page. It is shown as a
#      backup link if the Razorpay button is blocked on someone's device:
#          bash install-donation-v2.sh https://your-other-site.com/donate
#   3. Test:   npm run dev -- --host     then open / and /donate
#   4. Publish: git add . && git commit -m "Donate page" && git push
#
# WHAT IT DOES
#   - /donate page: the Razorpay payment button sits right on the page
#     (no popup on this page).
#   - Home page: a small notification slides down from the top with a
#     Donate button and a close (cancel) button. It does not block the site.
#   - Safe to run again. Your old files are copied to
#     /tmp/donation-install-backup-<time> first, and if the site fails to
#     build, App.jsx and Header.jsx are restored automatically.
# =====================================================================

FALLBACK_URL="$1"

if [ ! -f src/App.jsx ] || [ ! -f src/components/Header.jsx ]; then
  echo "Run this from /workspaces/kebang-website (src/App.jsx or Header.jsx not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/donation-install-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in src/App.jsx src/components/Header.jsx src/donationConfig.js \
         src/components/DonationContext.jsx src/components/DonationPanel.jsx \
         src/components/DonationPanel.css src/components/DonationBanner.jsx \
         src/components/DonationBanner.css src/components/RazorpayButton.jsx \
         src/components/RazorpayButton.css src/pages/Donate.jsx src/pages/Donate.css; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done
echo "Backups saved in: $BACKUP_DIR"
echo ""

mkdir -p src/components src/pages

# Which router package does this project use?
ROUTER_PKG="react-router-dom"
if grep -q "from 'react-router'" src/App.jsx src/components/Header.jsx 2>/dev/null; then
  ROUTER_PKG="react-router"
fi
echo "Router package: $ROUTER_PKG"

put() {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  echo "WROTE: $1"
}

# ---------- settings (button id and optional backup link) ----------
if [ ! -f src/donationConfig.js ] || [ -n "$FALLBACK_URL" ]; then
  put src/donationConfig.js << __TMSK_CONFIG_END__
// Donation settings. Edit here.
export const RAZORPAY_PAYMENT_BUTTON_ID = 'pl_T8BCDbnyoQOfMM'
export const RAZORPAY_SCRIPT_SRC = 'https://checkout.razorpay.com/v1/payment-button.js'

// Optional: link of your other donation page. It appears as a backup link
// under the button if Razorpay cannot load. Leave '' to hide it.
export const DONATION_FALLBACK_URL = '$FALLBACK_URL'
__TMSK_CONFIG_END__
else
  echo "KEPT: src/donationConfig.js (already exists)"
fi

# ---------- Razorpay button (loads reliably, shows help if it fails) ----------
put src/components/RazorpayButton.jsx << '__TMSK_FILE_END__'
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
__TMSK_FILE_END__

put src/components/RazorpayButton.css << '__TMSK_FILE_END__'
.rzp-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.rzp-holder {
  display: flex;
  justify-content: center;
  min-height: 52px;
  width: 100%;
}

.rzp-holder form {
  display: flex;
  justify-content: center;
  margin: 0;
}

.rzp-status {
  margin: 0;
  color: #888;
  font-size: 0.9rem;
  text-align: center;
}

.rzp-help {
  width: 100%;
  max-width: 460px;
  padding: 12px 14px;
  border-radius: 12px;
  background: #fdf0db;
  color: #7a4a00;
  font-size: 0.92rem;
  line-height: 1.5;
  text-align: center;
}

.rzp-help p {
  margin: 0 0 10px;
}

.rzp-help-actions {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
  gap: 10px;
}

.rzp-retry,
.rzp-fallback {
  min-height: 40px;
  padding: 8px 20px;
  border: 2px solid #8b1e1e;
  border-radius: 999px;
  background: transparent;
  color: #8b1e1e;
  font-size: 0.9rem;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
}

.rzp-retry:hover,
.rzp-fallback:hover {
  background: #f6e7e7;
}
__TMSK_FILE_END__

# ---------- Home page notification (slides in from the top) ----------
put src/components/DonationBanner.jsx << '__TMSK_FILE_END__'
import { useEffect, useState } from 'react'
import { Link, useLocation } from '__ROUTER_PKG__'
import './DonationBanner.css'

// ---- Easy settings ----
const SHOW_ON = ['/']          // pages that show the notification ('/' = home page)
const SHOW_DELAY_MS = 1200     // wait before sliding in
const AUTO_HIDE_MS = 20000     // hide by itself after this long (0 = stay until closed)
const STORAGE_KEY = 'tmsk-donation-banner-closed'
const MESSAGE_TITLE = 'Support TMSK'
const MESSAGE_TEXT = 'Your donation helps us carry our work for the Mising community forward.'

function wasClosed() {
  try {
    return sessionStorage.getItem(STORAGE_KEY) === '1'
  } catch {
    return false
  }
}

export default function DonationBanner() {
  const { pathname } = useLocation()
  const eligible = SHOW_ON.includes(pathname)
  const [visible, setVisible] = useState(false)
  const [top, setTop] = useState(12)

  // Slide in shortly after the home page opens; slide out when leaving it
  useEffect(() => {
    if (!eligible || wasClosed()) {
      setVisible(false)
      return undefined
    }
    const showTimer = setTimeout(() => setVisible(true), SHOW_DELAY_MS)
    const hideTimer =
      AUTO_HIDE_MS > 0 ? setTimeout(() => setVisible(false), SHOW_DELAY_MS + AUTO_HIDE_MS) : null
    return () => {
      clearTimeout(showTimer)
      if (hideTimer) clearTimeout(hideTimer)
      setVisible(false)
    }
  }, [eligible])

  // Keep it just under the site header
  useEffect(() => {
    if (!visible) return undefined
    const measure = () => {
      const header = document.querySelector('.site-header')
      const bottom = header ? Math.max(Math.round(header.getBoundingClientRect().bottom), 0) : 0
      setTop(bottom + 10)
    }
    measure()
    window.addEventListener('scroll', measure, { passive: true })
    window.addEventListener('resize', measure)
    return () => {
      window.removeEventListener('scroll', measure)
      window.removeEventListener('resize', measure)
    }
  }, [visible])

  const close = () => {
    try {
      sessionStorage.setItem(STORAGE_KEY, '1')
    } catch {
      /* ignore */
    }
    setVisible(false)
  }

  // Esc also closes it
  useEffect(() => {
    if (!visible) return undefined
    const onKey = (e) => {
      if (e.key === 'Escape') close()
    }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [visible])

  if (!eligible) return null

  return (
    <div
      className={visible ? 'donation-banner is-visible' : 'donation-banner'}
      style={{ '--banner-top': `${top}px` }}
      role="status"
      aria-live="polite"
      aria-hidden={!visible}
    >
      <span className="donation-banner-icon" aria-hidden="true">
        <svg viewBox="0 0 24 24" width="22" height="22">
          <path
            d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
            fill="currentColor"
          />
        </svg>
      </span>
      <p className="donation-banner-text">
        <strong>{MESSAGE_TITLE}</strong>
        <span>{MESSAGE_TEXT}</span>
      </p>
      <Link to="/donate" className="donation-banner-cta" onClick={close}>
        Donate
      </Link>
      <button
        type="button"
        className="donation-banner-close"
        onClick={close}
        aria-label="Cancel and close this notification"
      >
        &times;
      </button>
    </div>
  )
}
__TMSK_FILE_END__
sed -i "s#__ROUTER_PKG__#$ROUTER_PKG#" src/components/DonationBanner.jsx

put src/components/DonationBanner.css << '__TMSK_FILE_END__'
.donation-banner {
  position: fixed;
  top: var(--banner-top, 12px);
  left: 50%;
  z-index: 900;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  gap: 12px;
  width: min(560px, calc(100vw - 20px));
  padding: 12px 12px 12px 14px;
  background: #fff;
  border-left: 5px solid #8b1e1e;
  border-radius: 16px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  transform: translate(-50%, -160%);
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
  transition: transform 0.45s cubic-bezier(0.22, 1, 0.36, 1), opacity 0.3s ease,
    visibility 0s linear 0.45s;
}

.donation-banner.is-visible {
  transform: translate(-50%, 0);
  opacity: 1;
  visibility: visible;
  pointer-events: auto;
  transition: transform 0.45s cubic-bezier(0.22, 1, 0.36, 1), opacity 0.3s ease, visibility 0s;
}

.donation-banner-icon {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: #f6e7e7;
  color: #8b1e1e;
}

.donation-banner-text {
  flex: 1;
  min-width: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 0.85rem;
  line-height: 1.35;
  color: #666;
}

.donation-banner-text strong {
  font-size: 0.98rem;
  color: #222;
}

.donation-banner-cta {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  min-height: 40px;
  padding: 8px 20px;
  border-radius: 999px;
  background: #8b1e1e;
  color: #fff;
  font-size: 0.92rem;
  font-weight: 700;
  text-decoration: none;
  transition: background 0.2s, transform 0.15s;
}

.donation-banner-cta:hover {
  background: #6f1717;
}

.donation-banner-cta:active {
  transform: scale(0.96);
}

.donation-banner-close {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 50%;
  background: transparent;
  color: #8b1e1e;
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  transition: background 0.2s;
}

.donation-banner-close:hover {
  background: #f6e7e7;
}

.donation-banner-cta:focus-visible,
.donation-banner-close:focus-visible {
  outline: 3px solid #e3a3a3;
  outline-offset: 2px;
}

@media (max-width: 480px) {
  .donation-banner {
    gap: 8px;
    padding: 10px 8px 10px 10px;
  }

  .donation-banner-icon {
    display: none;
  }

  .donation-banner-text span {
    display: none;
  }

  .donation-banner-text strong {
    font-size: 0.95rem;
  }
}

@media (prefers-reduced-motion: reduce) {
  .donation-banner,
  .donation-banner.is-visible {
    transition: none;
  }
}
__TMSK_FILE_END__

# ---------- Donate page (button sits on the page, no popup here) ----------
put src/pages/Donate.jsx << '__TMSK_FILE_END__'
import RazorpayButton from '../components/RazorpayButton.jsx'
import './Donate.css'

// You can change the wording on this page here.
const TAGLINE = 'Support the work of TMSK for the Mising community.'
const INTRO =
  'Takam Mising Sí:sang Kébang (TMSK) works for the Mising community, including projects to preserve its historical and cultural identity. Your contribution helps us carry this work forward.'

const STEPS = [
  { title: 'Tap the payment button', text: 'Use the payment button in the card above.' },
  { title: 'Choose your amount and details', text: 'Razorpay opens a secure window where you enter the amount and your details.' },
  { title: 'Complete your payment', text: 'Razorpay shows a confirmation when the payment is done.' },
]

const FAQ = [
  {
    q: 'Is my payment secure?',
    a: 'Payments are handled by Razorpay. TMSK does not see or store your card or bank details.',
  },
  {
    q: 'Can I cancel?',
    a: 'Yes. Close the Razorpay window before you pay and nothing is charged.',
  },
]

export default function Donate() {
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
        <RazorpayButton />
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

.donate-card > p {
  margin: 0 auto 22px;
  max-width: 560px;
  color: #555;
  line-height: 1.65;
}

.donate-card .donate-secure {
  margin: 16px 0 0;
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
}
__TMSK_FILE_END__


# ---------- connect everything to App.jsx and the menu ----------
python3 - << 'PYPATCH'
import re, sys

def fail(msg):
    print("PROBLEM: " + msg)
    print("App.jsx and Header.jsx will be restored. Paste src/App.jsx here and I will fix it.")
    sys.exit(1)

# ----- App.jsx -----
app_path = 'src/App.jsx'
s = open(app_path, encoding='utf-8').read()
original = s

# 1. Remove version 1 (the provider and the popup panel)
s = re.sub(r"^import \{ DonationProvider \} from [^\n]*\n", "", s, flags=re.M)
s = re.sub(r"^[ \t]*<DonationProvider>[ \t]*\n", "", s, flags=re.M)
s = re.sub(r"^[ \t]*</DonationProvider>[ \t]*(\n|$)", "", s, flags=re.M)
s = s.replace("import DonationPanel from './components/DonationPanel.jsx'",
              "import DonationBanner from './components/DonationBanner.jsx'")
s = s.replace("<DonationPanel />", "<DonationBanner />")
if 'DonationProvider' in s or 'DonationPanel' in s:
    fail('old donation code in src/App.jsx is not in the expected shape')

# 2. Imports
need_banner = 'DonationBanner' not in s
add = []
if 'pages/Donate.jsx' not in s:
    add.append("import Donate from './pages/Donate.jsx'")
if need_banner:
    add.append("import DonationBanner from './components/DonationBanner.jsx'")
if add:
    lines = s.split('\n')
    last = -1
    for i, line in enumerate(lines):
        if re.match(r"^import\b.*['\"];?\s*$", line) or re.match(r"^\}\s*from\s*['\"].*['\"];?\s*$", line):
            last = i
    if last == -1:
        fail('no import lines found in src/App.jsx')
    lines[last + 1:last + 1] = add
    s = '\n'.join(lines)

# 3. Donate route
if 'path="/donate"' not in s:
    m = re.search(r'^([ \t]*)<Route path="\*"', s, re.M)
    if not m:
        fail('could not find the <Route path="*" ...> line in src/App.jsx')
    s = s[:m.start()] + m.group(1) + '<Route path="/donate" element={<Donate />} />\n' + s[m.start():]

# 4. Place the notification (only when this is a fresh install)
if need_banner:
    idx = s.rfind('</div>')
    if idx == -1:
        fail('could not find the closing </div> in src/App.jsx')
    head = s[:idx].rstrip(' ')
    s = head + '      <DonationBanner />\n    </div>' + s[idx + len('</div>'):]

if s != original:
    open(app_path, 'w', encoding='utf-8').write(s)
    print('UPDATED: src/App.jsx (Donate route + home page notification)')
else:
    print('KEPT: src/App.jsx already up to date')

# ----- Header.jsx (menu link) -----
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

restore_originals() {
  echo "Restoring your original App.jsx and Header.jsx from the backup..."
  cp "$BACKUP_DIR/src/App.jsx" src/App.jsx
  cp "$BACKUP_DIR/src/components/Header.jsx" src/components/Header.jsx
}

if [ "$PATCH_STATUS" -ne 0 ]; then
  restore_originals
  exit 1
fi

# ---------- make sure the site still builds ----------
if [ -d node_modules ] && grep -q '"build"' package.json 2>/dev/null; then
  echo ""
  echo "Checking that the site builds (this takes a few seconds)..."
  BUILD_LOG=$(npm run build 2>&1)
  if [ $? -ne 0 ]; then
    echo "$BUILD_LOG" | tail -n 30
    echo ""
    echo "The build failed, so nothing was switched on."
    restore_originals
    echo "Copy the error above and paste it here and I will fix it."
    exit 1
  fi
  echo "Build OK."
fi

# ---------- tidy up version 1 files (they are in the backup) ----------
LEFTOVER=$(grep -rlE "DonationPanel|DonationProvider|DonationContext|useDonation" src 2>/dev/null \
  | grep -vE "src/components/Donation(Panel|Context)\.jsx$")
if [ -z "$LEFTOVER" ]; then
  rm -f src/components/DonationContext.jsx src/components/DonationPanel.jsx src/components/DonationPanel.css
  echo "Removed the old popup files (a copy is in the backup)."
else
  echo "Old popup files kept because these files still use them:"
  echo "$LEFTOVER"
fi

echo ""
echo "================ CHECKS ================"
grep -n "donate\|Donat" src/App.jsx src/components/Header.jsx
echo ""
echo "================ DONE ================"
echo "1) Test:     npm run dev -- --host"
echo "   - Home page (/):  a notification slides down from the top after about 1 second."
echo "     Close it with the x (or Esc). It stays closed until the next visit."
echo "   - /donate:        the Razorpay button is on the page. No popup."
echo "2) Publish:  git add . && git commit -m \"Donate page\" && git push"
echo ""
echo "Change things later:"
echo "   Notification text, delay, pages:  src/components/DonationBanner.jsx (top of the file)"
echo "   Page wording:                     src/pages/Donate.jsx (top of the file)"
echo "   Razorpay button id / backup link: src/donationConfig.js"
echo ""
echo "If the button does not show: open the browser console (F12) on /donate."
echo "   - 'payment-button.js' blocked / red in the Network tab = ad blocker or network."
echo "   - An error about the button id = check the id in src/donationConfig.js."
echo "   - Also check that this website's address is allowed in your Razorpay dashboard."
echo "Backups: $BACKUP_DIR"
