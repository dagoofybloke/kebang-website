#!/bin/bash
# =====================================================================
# TMSK design fix
#
# HOW TO USE
#   1. Put this file in /workspaces/kebang-website
#   2. Run:   bash design-fix.sh
#   3. Look:  npm run dev -- --host   (check /, /donate, /events and the footer)
#   4. Publish: git add . && git commit -m "Design fixes" && git push
#
# WHAT IT FIXES
#   - Footer: removes the empty block that left about 180px of blank black
#     space at the top, and adds the missing Leadership and Donate links.
#   - Donate page, home notification and Razorpay help box: restyled to match
#     the rest of the site (TMSK red, square corners, Clash Display), instead
#     of the maroon / rounded style they had.
#   - Donate page now uses the same heading layout as the Events page.
#   - Inner page headings: 172px of empty space above the title reduced to
#     88px (the sticky header already takes up room).
#   - Browser theme colour in index.html matched to the site red.
#
# Your old files are copied to /tmp/design-fix-backup-<time> first, and if
# the site fails to build, everything is restored automatically.
# =====================================================================

if [ ! -f src/index.css ] || [ ! -f src/components/Footer.jsx ]; then
  echo "Run this from /workspaces/kebang-website (src/index.css or Footer.jsx not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/design-fix-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
FILES="index.html src/index.css src/components/Footer.jsx src/components/DonationBanner.css \
src/components/RazorpayButton.css src/pages/Donate.jsx src/pages/Donate.css"
for f in $FILES; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done
echo "Backups saved in: $BACKUP_DIR"
echo ""

put() {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  echo "WROTE: $1"
}

restore_all() {
  echo "Restoring your original files from the backup..."
  for f in $FILES; do
    if [ -f "$BACKUP_DIR/$f" ]; then cp "$BACKUP_DIR/$f" "$f"; fi
  done
}

# ---------- small edits to existing files ----------
if [ -f index.html ]; then
  sed -i 's|<meta name="theme-color" content="#c4200f">|<meta name="theme-color" content="#C8102E">|' index.html
  echo "UPDATED: index.html (theme colour)"
fi

if grep -q '\.page-head{padding:172px 0 64px;}' src/index.css; then
  sed -i 's|\.page-head{padding:172px 0 64px;}|.page-head{padding:88px 0 56px;}|' src/index.css
  echo "UPDATED: src/index.css (page heading spacing)"
else
  echo "KEPT: src/index.css (page heading rule not found, left as is)"
fi

python3 - << 'PYPATCH'
import re, sys

path = 'src/components/Footer.jsx'
s = open(path, encoding='utf-8').read()
orig = s

# remove the empty call-to-action block (it only created blank space)
s = re.sub(r'[ \t]*<div className="wrap footer-cta">\s*</div>[ \t]*\n(\s*\n)?', '', s)

# add the missing links under "Navigate"
if 'to="/leadership"' not in s or 'to="/donate"' not in s:
    m = re.search(r'^([ \t]*)<NavLink to="/events">Events</NavLink>[ \t]*\n', s, re.M)
    if not m:
        print('PROBLEM: could not find the Events link in Footer.jsx')
        sys.exit(1)
    indent = m.group(1)
    extra = ''
    if 'to="/leadership"' not in s:
        extra += indent + '<NavLink to="/leadership">Leadership</NavLink>\n'
    if 'to="/donate"' not in s:
        extra += indent + '<NavLink to="/donate">Donate</NavLink>\n'
    s = s[:m.end()] + extra + s[m.end():]

if s != orig:
    open(path, 'w', encoding='utf-8').write(s)
    print('UPDATED: src/components/Footer.jsx (blank space removed, links added)')
else:
    print('KEPT: src/components/Footer.jsx already fixed')
PYPATCH
if [ $? -ne 0 ]; then restore_all; exit 1; fi

# ---------- Donate page in the site's own style ----------
put src/pages/Donate.jsx << '__TMSK_FILE_END__'
import Reveal from '../components/Reveal.jsx'
import RazorpayButton from '../components/RazorpayButton.jsx'
import './Donate.css'

// You can change the wording on this page here.
const TAGLINE = 'Support the work of TMSK for the Mising community.'
const INTRO =
  'Takam Mising Sí:sang Kébang (TMSK) works for the Mising community, including projects to preserve its historical and cultural identity. Your contribution helps us carry this work forward.'

const STEPS = [
  { title: 'Tap the payment button', text: 'Use the payment button in the card above.' },
  { title: 'Choose your amount', text: 'Razorpay opens a secure window where you enter the amount and your details.' },
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
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">Support the movement</Reveal>
        <Reveal as="h1" delay={80}>Donate</Reveal>
        <Reveal as="p" delay={140} className="donate-lede">{TAGLINE}</Reveal>
      </header>

      <section className="wrap donate-body">
        <Reveal delay={120} className="donate-card">
          <svg className="donate-heart" viewBox="0 0 24 24" width="30" height="30" aria-hidden="true">
            <path
              d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"
              fill="currentColor"
            />
          </svg>
          <h2>Make a donation</h2>
          <p>{INTRO}</p>
          <RazorpayButton />
          <p className="donate-secure">Secure payment by Razorpay</p>
        </Reveal>

        <div className="donate-block">
          <Reveal as="span" className="eyebrow">How it works</Reveal>
          <ol className="donate-steps">
            {STEPS.map((step, i) => (
              <Reveal as="li" delay={i * 90} key={step.title}>
                <span className="ghost-num donate-step-num">{String(i + 1).padStart(2, '0')}</span>
                <h3>{step.title}</h3>
                <p>{step.text}</p>
              </Reveal>
            ))}
          </ol>
        </div>

        <div className="donate-block">
          <Reveal as="span" className="eyebrow">Good to know</Reveal>
          <div className="donate-faq">
            {FAQ.map((item, i) => (
              <Reveal delay={i * 90} className="donate-faq-item" key={item.q}>
                <h3>{item.q}</h3>
                <p>{item.a}</p>
              </Reveal>
            ))}
          </div>
        </div>
      </section>
    </>
  )
}
__TMSK_FILE_END__

put src/pages/Donate.css << '__TMSK_FILE_END__'
.donate-lede {
  max-width: 620px;
  margin-top: 20px;
  color: var(--ink-soft);
  font-size: 18px;
  line-height: 1.6;
}

.donate-body {
  padding-bottom: 120px;
}

.donate-card {
  padding: 56px 40px 40px;
  border: 1px solid var(--line);
  border-top: 4px solid var(--red);
  background: var(--white);
  text-align: center;
}

.donate-heart {
  display: inline-block;
  margin-bottom: 16px;
  color: var(--red);
}

.donate-card h2 {
  margin: 0 0 14px;
  font-size: clamp(26px, 3.4vw, 38px);
  line-height: 1.1;
}

.donate-card > p {
  max-width: 600px;
  margin: 0 auto 28px;
  color: var(--ink-soft);
  line-height: 1.7;
}

.donate-card > .donate-secure {
  margin: 20px 0 0;
  color: var(--ink-faint);
  font-size: 13px;
  letter-spacing: 0.04em;
}

.donate-block {
  margin-top: 88px;
}

.donate-steps {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 0 32px;
  margin: 8px 0 0;
  padding: 0;
  list-style: none;
}

.donate-steps li {
  padding: 28px 0;
  border-top: 1px solid var(--line-strong);
}

.donate-step-num {
  display: block;
  margin-bottom: 14px;
  font-size: 48px;
}

.donate-steps h3 {
  margin: 0 0 8px;
  font-size: 20px;
}

.donate-steps p {
  color: var(--ink-soft);
  line-height: 1.65;
}

.donate-faq {
  display: grid;
  margin-top: 8px;
}

.donate-faq-item {
  padding: 28px 0;
  border-top: 1px solid var(--line-strong);
}

.donate-faq-item h3 {
  margin: 0 0 8px;
  font-size: 20px;
}

.donate-faq-item p {
  max-width: 640px;
  color: var(--ink-soft);
  line-height: 1.65;
}

@media (max-width: 860px) {
  .donate-card {
    padding: 40px 22px 28px;
  }

  .donate-block {
    margin-top: 64px;
  }

  .donate-steps {
    grid-template-columns: 1fr;
  }

  .donate-body {
    padding-bottom: 80px;
  }
}
__TMSK_FILE_END__

# ---------- Razorpay help box ----------
put src/components/RazorpayButton.css << '__TMSK_FILE_END__'
.rzp-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 12px;
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
  color: var(--ink-faint);
  font-size: 14px;
  text-align: center;
}

.rzp-help {
  width: 100%;
  max-width: 480px;
  padding: 16px 18px;
  border-left: 4px solid var(--red);
  background: var(--grey);
  color: var(--ink);
  font-size: 14.5px;
  line-height: 1.55;
  text-align: left;
}

.rzp-help p {
  margin: 0 0 12px;
}

.rzp-help-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.rzp-retry,
.rzp-fallback {
  display: inline-flex;
  align-items: center;
  min-height: 42px;
  padding: 10px 22px;
  border: 1.5px solid var(--black);
  border-radius: 2px;
  background: var(--black);
  color: var(--white);
  font-family: var(--f-body);
  font-size: 14px;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
  transition: background 0.25s ease, border-color 0.25s ease;
}

.rzp-fallback {
  background: transparent;
  color: var(--black);
  border-color: var(--line-strong);
}

.rzp-retry:hover {
  background: var(--red);
  border-color: var(--red);
}

.rzp-fallback:hover {
  background: var(--black);
  color: var(--white);
  border-color: var(--black);
}
__TMSK_FILE_END__

# ---------- home page notification ----------
put src/components/DonationBanner.css << '__TMSK_FILE_END__'
.donation-banner {
  position: fixed;
  top: var(--banner-top, 12px);
  left: 50%;
  z-index: 900;
  box-sizing: border-box;
  display: flex;
  align-items: center;
  gap: 14px;
  width: min(580px, calc(100vw - 20px));
  padding: 14px 12px 14px 18px;
  background: var(--white);
  border: 1px solid var(--line);
  border-left: 4px solid var(--red);
  border-radius: 2px;
  box-shadow: 0 14px 36px rgba(17, 17, 17, 0.16);
  transform: translate(-50%, -160%);
  opacity: 0;
  visibility: hidden;
  pointer-events: none;
  transition: transform 0.6s var(--ease), opacity 0.3s ease, visibility 0s linear 0.6s;
}

.donation-banner.is-visible {
  transform: translate(-50%, 0);
  opacity: 1;
  visibility: visible;
  pointer-events: auto;
  transition: transform 0.6s var(--ease), opacity 0.3s ease, visibility 0s;
}

.donation-banner-icon {
  flex-shrink: 0;
  display: flex;
  color: var(--red);
}

.donation-banner-text {
  flex: 1;
  min-width: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
  font-size: 13.5px;
  line-height: 1.4;
  color: var(--ink-soft);
}

.donation-banner-text strong {
  font-family: var(--f-display);
  font-size: 16px;
  font-weight: 600;
  letter-spacing: -0.01em;
  color: var(--black);
}

.donation-banner-cta {
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  min-height: 42px;
  padding: 10px 22px;
  border: 1.5px solid var(--black);
  border-radius: 2px;
  background: var(--black);
  color: var(--white);
  font-size: 14px;
  font-weight: 700;
  transition: background 0.25s ease, border-color 0.25s ease, transform 0.35s var(--ease);
}

.donation-banner-cta:hover {
  background: var(--red);
  border-color: var(--red);
  transform: translateY(-2px);
}

.donation-banner-close {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 2px;
  background: transparent;
  color: var(--ink-soft);
  font-size: 1.5rem;
  line-height: 1;
  cursor: pointer;
  transition: background 0.2s ease, color 0.2s ease;
}

.donation-banner-close:hover {
  background: var(--grey);
  color: var(--black);
}

@media (max-width: 480px) {
  .donation-banner {
    gap: 10px;
    padding: 10px 6px 10px 14px;
  }

  .donation-banner-icon,
  .donation-banner-text span {
    display: none;
  }

  .donation-banner-cta {
    padding: 10px 18px;
  }
}

@media (prefers-reduced-motion: reduce) {
  .donation-banner,
  .donation-banner.is-visible {
    transition: none;
  }
}
__TMSK_FILE_END__

# ---------- make sure the site still builds ----------
if [ -d node_modules ] && grep -q '"build"' package.json 2>/dev/null; then
  echo ""
  echo "Checking that the site builds (this takes a few seconds)..."
  BUILD_LOG=$(npm run build 2>&1)
  if [ $? -ne 0 ]; then
    echo "$BUILD_LOG" | tail -n 30
    echo ""
    echo "The build failed, so nothing was kept."
    restore_all
    echo "Copy the error above and paste it here and I will fix it."
    exit 1
  fi
  echo "Build OK."
fi

echo ""
echo "================ DONE ================"
echo "1) Look:     npm run dev -- --host   (check /, /donate, /events and the footer)"
echo "2) Publish:  git add . && git commit -m \"Design fixes\" && git push"
echo "Backups: $BACKUP_DIR"
echo ""
echo "NOT changed (content, your call):"
echo " - Home page 'Currently open' shows the Art Competition, but its registration"
echo "   closed on 31 Aug 2026 and submissions ended 13 Sep 2026."
echo " - Events page has a registration link in its data but no Register button."
echo " - src/components/EventPopup.css is not used by any page."
