#!/bin/bash
# =====================================================================
# TMSK luxury redesign
#
# HOW TO USE
#   1. Put this file in /workspaces/kebang-website
#   2. Run:      bash redesign-luxury.sh
#   3. Look:     npm run dev -- --host
#   4. Happy?    git add . && git commit -m "Luxury redesign" && git push
#      Not happy? bash revert-design.sh   (works as long as it is not pushed)
#
# WHAT IT CHANGES
#   Look    : ivory + black + TMSK red, with a little antique gold for fine
#             details. Cormorant Garamond (serif) for headings, Jost for text.
#   Header  : centred emblem with links either side; full-screen menu on phones.
#   Home    : new hero (flag animation kept), scrolling facts ribbon, editorial
#             "Who we are" timeline, dark statement band, objectives list,
#             event card whose status updates itself by date.
#   Pages   : Objectives, Events (adds a Register button while open),
#             Leadership, Donate, Not Found and the Footer are all redone.
#   Motion  : slow fade-and-rise on scroll, page fade between pages, line
#             draws, orbiting rings behind the flag, button fills, marquee.
#             All of it switches off for people who prefer reduced motion.
#
# SAFETY
#   Your current files are copied to /tmp/redesign-backup-<time> first.
#   If the site fails to build, they are restored automatically.
#   This script does NOT commit or push anything.
# =====================================================================

if [ ! -f src/App.jsx ] || [ ! -f src/index.css ] || [ ! -f src/components/Header.jsx ]; then
  echo "Run this from /workspaces/kebang-website (src/App.jsx not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/redesign-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
FILES="index.html src/App.jsx src/index.css \
src/components/Header.jsx src/components/Header.css \
src/components/Footer.jsx src/components/Footer.css \
src/components/DonationBanner.css src/components/RazorpayButton.css \
src/pages/Home.jsx src/pages/Home.css src/pages/Events.jsx src/pages/Events.css \
src/pages/Objectives.css src/pages/Leadership.jsx src/pages/Leadership.css \
src/pages/NotFound.css src/pages/Donate.jsx src/pages/Donate.css \
src/data/eventStatus.js"
for f in $FILES; do
  if [ -f "$f" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$f")"
    cp "$f" "$BACKUP_DIR/$f"
  fi
done
echo "Backups saved in: $BACKUP_DIR"
echo ""

mkdir -p src/data src/pages src/components

put() {
  mkdir -p "$(dirname "$1")"
  cat > "$1"
  echo "WROTE: $1"
}

restore_all() {
  echo "Restoring your files from the backup..."
  for f in $FILES; do
    if [ -f "$BACKUP_DIR/$f" ]; then
      cp "$BACKUP_DIR/$f" "$f"
    elif [ "$f" = "src/data/eventStatus.js" ]; then
      rm -f "$f"
    fi
  done
}

# =====================================================================
# index.html : fonts + theme colour
# =====================================================================
python3 - << 'PYHTML'
import re, sys
p = 'index.html'
s = open(p, encoding='utf-8').read()
s = re.sub(r'[ \t]*<link[^>]*api\.fontshare\.com[^>]*>[ \t]*\n', '', s)
s = re.sub(r'[ \t]*<link[^>]*fonts\.googleapis\.com/css2[^>]*>[ \t]*\n', '', s)
new = ('  <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600'
       '&family=Jost:wght@300;400;500;600&display=swap" rel="stylesheet">\n')
m = re.search(r'[ \t]*<link rel="preconnect" href="https://fonts\.gstatic\.com"[^>]*>[ \t]*\n', s)
if m:
    s = s[:m.end()] + new + s[m.end():]
elif '</head>' in s:
    s = s.replace('</head>', new + '</head>', 1)
else:
    print('PROBLEM: could not find <head> in index.html'); sys.exit(1)
s = re.sub(r'(<meta name="theme-color" content=")#[0-9a-fA-F]{6}(")', r'\1#C8102E\2', s)
open(p, 'w', encoding='utf-8').write(s)
print('UPDATED: index.html (new fonts, theme colour)')
PYHTML
if [ $? -ne 0 ]; then restore_all; exit 1; fi

# =====================================================================
# App.jsx : adds a soft fade between pages
# =====================================================================
put src/App.jsx << '__TMSK_FILE_END__'
import { Routes, Route, useLocation } from 'react-router-dom'
import ScrollToTop from './components/ScrollToTop.jsx'
import Header from './components/Header.jsx'
import Footer from './components/Footer.jsx'
import Home from './pages/Home.jsx'
import Objectives from './pages/Objectives.jsx'
import Events from './pages/Events.jsx'
import Leadership from './pages/Leadership.jsx'
import NotFound from './pages/NotFound.jsx'
import Donate from './pages/Donate.jsx'
import DonationBanner from './components/DonationBanner.jsx'

export default function App(){
  const location = useLocation()

  return (
    <div className="app-shell">
      <ScrollToTop />
      <Header />
      <main>
        <div className="page-fade" key={location.pathname}>
          <Routes location={location}>
            <Route path="/" element={<Home />} />
            <Route path="/objectives" element={<Objectives />} />
            <Route path="/events" element={<Events />} />
            <Route path="/leadership" element={<Leadership />} />
            <Route path="/donate" element={<Donate />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </div>
      </main>
      <Footer />
      <DonationBanner />
    </div>
  )
}
__TMSK_FILE_END__

# =====================================================================
# Event status (updates itself by date)
# =====================================================================
put src/data/eventStatus.js << '__TMSK_FILE_END__'
// The Art Competition status changes by itself on these dates.
// For a new event, change the dates below (year-month-day, India time).
const REGISTRATION_CLOSES = new Date('2026-08-31T23:59:59+05:30')
const EVENT_ENDS = new Date('2026-09-13T23:59:59+05:30')

export function getEventStatus(now = new Date()) {
  if (now <= REGISTRATION_CLOSES) {
    return { key: 'open', label: 'Registration open', headline: 'Currently open', closesLabel: 'Registration closes' }
  }
  if (now <= EVENT_ENDS) {
    return { key: 'running', label: 'In progress', headline: 'In progress', closesLabel: 'Registration closed' }
  }
  return { key: 'ended', label: 'Concluded', headline: 'Recent event', closesLabel: 'Registration closed' }
}
__TMSK_FILE_END__

# =====================================================================
# index.css : design system
# =====================================================================
put src/index.css << '__TMSK_FILE_END__'
:root{
  /* ---- Colour: white, black and TMSK red, softened with ivory and gold ---- */
  --red:#C8102E;
  --red-deep:#9E0C24;
  --red-light:#E5485B;
  --black:#14110E;
  --white:#FFFFFF;
  --ivory:#FAF7F2;
  --sand:#F1EBE0;
  --charcoal:#1D1916;
  --gold:#B8935A;
  --grey:#F1EBE0;
  --grey-line:#E4DCCE;

  --ink:var(--black);
  --ink-soft:rgba(20,17,14,0.70);
  --ink-faint:rgba(20,17,14,0.48);
  --line:rgba(20,17,14,0.12);
  --line-strong:rgba(20,17,14,0.26);

  /* ---- Type ---- */
  --f-display:'Cormorant Garamond','Cormorant',Georgia,'Times New Roman',serif;
  --f-body:'Jost','Helvetica Neue',Arial,sans-serif;

  --max:1240px;
  --header-h:96px;

  /* ---- Motion ---- */
  --ease:cubic-bezier(0.16,1,0.3,1);
  --ease-soft:cubic-bezier(0.4,0,0.2,1);
}

*{box-sizing:border-box;}
html{scroll-behavior:smooth; scroll-padding-top:var(--header-h);}
html, body{min-height:100%;}
body{
  margin:0;
  background:var(--ivory);
  color:var(--ink);
  font-family:var(--f-body);
  font-size:17px;
  font-weight:400;
  line-height:1.7;
  -webkit-font-smoothing:antialiased;
  -moz-osx-font-smoothing:grayscale;
  text-rendering:optimizeLegibility;
}
.app-shell{
  display:flex;
  flex-direction:column;
  min-height:100vh;
  overflow-x:clip;
}
.app-shell main{flex:1 0 auto;}
h1,h2,h3,h4{
  margin:0;
  font-family:var(--f-display);
  font-weight:500;
  letter-spacing:-0.01em;
  line-height:1.05;
  color:var(--ink);
  font-variant-numeric:lining-nums;
}
h1 em, h2 em, h3 em, h4 em, p em.serif{font-style:italic; color:var(--red);}
p{margin:0;}
a{color:inherit; text-decoration:none;}
img{max-width:100%; display:block;}
button{font-family:inherit;}
ul, ol{margin:0; padding:0; list-style:none;}

::selection{background:var(--red); color:var(--white);}
:focus-visible{outline:2px solid var(--red); outline-offset:4px;}

.wrap{max-width:var(--max); margin:0 auto; padding:0 48px;}
@media (max-width:860px){ .wrap{padding:0 24px;} }

/* ---------- Primitives ---------- */
.eyebrow{
  display:inline-flex;
  align-items:center;
  gap:14px;
  margin-bottom:22px;
  font-family:var(--f-body);
  font-size:12px;
  font-weight:500;
  letter-spacing:0.26em;
  text-transform:uppercase;
  color:var(--red);
}
.eyebrow::before{
  content:'';
  width:36px; height:1px;
  background:currentColor;
  flex-shrink:0;
}
.eyebrow.on-dark{color:var(--gold);}

.btn{
  position:relative;
  isolation:isolate;
  overflow:hidden;
  display:inline-flex;
  align-items:center;
  justify-content:center;
  gap:10px;
  padding:17px 38px;
  border:1px solid var(--black);
  border-radius:0;
  background:var(--black);
  color:var(--white);
  font-family:var(--f-body);
  font-size:12.5px;
  font-weight:500;
  letter-spacing:0.18em;
  text-transform:uppercase;
  white-space:nowrap;
  cursor:pointer;
  transition:color .45s var(--ease), border-color .45s var(--ease);
}
.btn::before{
  content:'';
  position:absolute;
  inset:0;
  z-index:-1;
  background:var(--red);
  transform:translateY(101%);
  transition:transform .55s var(--ease);
}
.btn:hover{border-color:var(--red);}
.btn:hover::before{transform:translateY(0);}
.btn:disabled{opacity:0.5; cursor:default;}

.btn.ghost{background:transparent; color:var(--black); border-color:var(--line-strong);}
.btn.ghost::before{background:var(--black);}
.btn.ghost:hover{color:var(--white); border-color:var(--black);}

.btn.on-dark{background:var(--ivory); color:var(--black); border-color:var(--ivory);}
.btn.on-dark::before{background:var(--red);}
.btn.on-dark:hover{color:var(--white); border-color:var(--red);}

.btn.ghost.on-dark{background:transparent; color:var(--ivory); border-color:rgba(250,247,242,0.4);}
.btn.ghost.on-dark::before{background:var(--ivory);}
.btn.ghost.on-dark:hover{color:var(--black); border-color:var(--ivory);}

/* thin tri-tone rule echoing the flag bands */
.stripe-rule{display:flex; height:3px; width:100%;}
.stripe-rule span{flex:1;}
.stripe-rule span:nth-child(1){background:var(--black); flex:0 0 34%;}
.stripe-rule span:nth-child(2){background:transparent; flex:0 0 4%;}
.stripe-rule span:nth-child(3){background:var(--black); flex:0 0 6%;}
.stripe-rule span:nth-child(4){background:transparent; flex:0 0 4%;}
.stripe-rule span:nth-child(5){background:var(--red);}

.ghost-num{
  font-family:var(--f-display);
  font-style:italic;
  font-weight:500;
  color:transparent;
  -webkit-text-stroke:1px rgba(20,17,14,0.24);
  line-height:1;
  font-variant-numeric:lining-nums;
  transition:-webkit-text-stroke-color .6s var(--ease);
}

.page-head{padding:96px 0 64px;}
.page-head h1{
  font-size:clamp(52px,8vw,112px);
  line-height:0.94;
  letter-spacing:-0.015em;
}
.page-head-lede{
  max-width:640px;
  margin-top:30px;
  font-size:19px;
  line-height:1.75;
  color:var(--ink-soft);
}
@media (max-width:860px){
  .page-head{padding:56px 0 40px;}
  .page-head-lede{font-size:17px; margin-top:22px;}
}

/* event status pill (used on dark panels) */
.status-pill{
  display:inline-flex;
  align-items:center;
  gap:10px;
  font-size:11px;
  font-weight:500;
  letter-spacing:0.24em;
  text-transform:uppercase;
}
.status-pill i{width:7px; height:7px; border-radius:50%; background:currentColor;}
.status-pill[data-status="open"], .status-pill[data-status="running"]{color:var(--red-light);}
.status-pill[data-status="open"] i, .status-pill[data-status="running"] i{animation:pillPulse 2.4s ease-in-out infinite;}
.status-pill[data-status="ended"]{color:rgba(250,247,242,0.6);}
@keyframes pillPulse{
  0%, 100%{box-shadow:0 0 0 0 rgba(229,72,91,0.55);}
  50%{box-shadow:0 0 0 8px rgba(229,72,91,0);}
}

/* ---------- Motion ---------- */
.reveal{
  opacity:0;
  transform:translateY(26px);
  transition:opacity 1.1s var(--ease-soft), transform 1.2s var(--ease);
  will-change:opacity, transform;
}
.reveal.is-visible{opacity:1; transform:none;}

.page-fade{animation:pageIn .8s var(--ease-soft) both;}
@keyframes pageIn{from{opacity:0;} to{opacity:1;}}

@media (prefers-reduced-motion: reduce){
  *, *::before, *::after{
    animation-duration:0.01ms !important;
    animation-iteration-count:1 !important;
    transition-duration:0.01ms !important;
    scroll-behavior:auto !important;
  }
  .reveal{opacity:1; transform:none;}
}
__TMSK_FILE_END__

# =====================================================================
# Header
# =====================================================================
put src/components/Header.jsx << '__TMSK_FILE_END__'
import { useEffect, useState } from 'react'
import { NavLink } from 'react-router-dom'
import './Header.css'

const LEFT_ITEMS = [
  { to: '/', label: 'Home' },
  { to: '/objectives', label: 'Objectives' },
  { to: '/events', label: 'Events' },
]
const RIGHT_ITEMS = [
  { to: '/leadership', label: 'Leadership' },
  { to: '/donate', label: 'Donate' },
]
const NAV_ITEMS = [...LEFT_ITEMS, ...RIGHT_ITEMS]

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

function NavItems({ items }){
  return items.map(item => (
    <NavLink
      key={item.to}
      to={item.to}
      end={item.to === '/'}
      className={({ isActive }) => isActive ? 'is-active' : ''}
    >
      {item.label}
    </NavLink>
  ))
}

export default function Header(){
  const [open, setOpen] = useState(false)
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 24)
    onScroll()
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  useEffect(() => {
    document.body.style.overflow = open ? 'hidden' : ''
    return () => { document.body.style.overflow = '' }
  }, [open])

  useEffect(() => {
    if (!open) return undefined
    const onKey = (e) => { if (e.key === 'Escape') setOpen(false) }
    document.addEventListener('keydown', onKey)
    return () => document.removeEventListener('keydown', onKey)
  }, [open])

  return (
    <header className={`site-header ${scrolled ? 'is-scrolled' : ''} ${open ? 'menu-open' : ''}`}>
      <div className="header-inner">
        <nav className="site-nav nav-left" aria-label="Main">
          <NavItems items={LEFT_ITEMS} />
        </nav>

        <NavLink to="/" className="brand" onClick={() => setOpen(false)}>
          <img src="/logo.png" alt="TMSK emblem" className="brand-mark" />
          <span className="brand-text">
            <span className="brand-abbr">TMSK</span>
            <span className="brand-full">Takam Mising Sí:sang Kébang</span>
          </span>
        </NavLink>

        <div className="nav-right-wrap">
          <nav className="site-nav nav-right" aria-label="More">
            <NavItems items={RIGHT_ITEMS} />
          </nav>
          <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn header-cta">
            Join
          </a>
        </div>

        <button
          type="button"
          className={`nav-toggle ${open ? 'is-open' : ''}`}
          aria-label={open ? 'Close menu' : 'Open menu'}
          aria-expanded={open}
          onClick={() => setOpen(o => !o)}
        >
          <span></span>
          <span></span>
        </button>
      </div>

      <div className={`mobile-menu ${open ? 'is-open' : ''}`} aria-hidden={!open}>
        <nav aria-label="Mobile">
          {NAV_ITEMS.map((item, i) => (
            <NavLink
              key={item.to}
              to={item.to}
              end={item.to === '/'}
              className={({ isActive }) => isActive ? 'is-active' : ''}
              onClick={() => setOpen(false)}
              style={{ transitionDelay: open ? `${120 + i * 70}ms` : '0ms' }}
              tabIndex={open ? 0 : -1}
            >
              {item.label}
            </NavLink>
          ))}
        </nav>
        <div className="mobile-foot">
          <a
            href={JOIN_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="btn mobile-cta"
            onClick={() => setOpen(false)}
            tabIndex={open ? 0 : -1}
          >
            Join TMSK
          </a>
          <p>Takam Mising Sí:sang Kébang</p>
        </div>
      </div>
    </header>
  )
}
__TMSK_FILE_END__

put src/components/Header.css << '__TMSK_FILE_END__'
.site-header{
  position:sticky;
  top:0;
  z-index:300;
  border-bottom:1px solid transparent;
  transition:border-color .5s var(--ease-soft);
  animation:headerIn 1s var(--ease-soft) both;
}
@keyframes headerIn{from{opacity:0; transform:translateY(-14px);} to{opacity:1; transform:none;}}

/* blurred background lives on a pseudo-element so the mobile menu can sit
   on top of the whole screen */
.site-header::before{
  content:'';
  position:absolute;
  inset:0;
  z-index:-1;
  background:rgba(250,247,242,0.78);
  backdrop-filter:blur(14px) saturate(140%);
  -webkit-backdrop-filter:blur(14px) saturate(140%);
  transition:background .5s var(--ease-soft);
}
.site-header.is-scrolled{border-bottom-color:var(--line);}
.site-header.is-scrolled::before{background:rgba(250,247,242,0.95);}

.header-inner{
  position:relative;
  z-index:2;
  display:grid;
  grid-template-columns:1fr auto 1fr;
  align-items:center;
  gap:32px;
  height:var(--header-h);
  max-width:var(--max);
  margin:0 auto;
  padding:0 48px;
  transition:height .5s var(--ease);
}
.site-header.is-scrolled .header-inner{height:72px;}

/* BRAND (centre) */
.brand{
  display:flex;
  align-items:center;
  gap:14px;
  justify-self:center;
}
.brand-mark{
  width:50px; height:50px;
  border-radius:50%;
  object-fit:cover;
  flex-shrink:0;
  transition:width .5s var(--ease), height .5s var(--ease), transform .8s var(--ease);
}
.brand:hover .brand-mark{transform:rotate(8deg);}
.site-header.is-scrolled .brand-mark{width:40px; height:40px;}
.brand-text{display:flex; flex-direction:column; line-height:1;}
.brand-abbr{
  font-family:var(--f-display);
  font-weight:600;
  font-size:30px;
  letter-spacing:0.2em;
  color:var(--black);
}
.brand-full{
  margin-top:7px;
  font-size:9px;
  font-weight:500;
  letter-spacing:0.3em;
  text-transform:uppercase;
  color:var(--ink-faint);
  white-space:nowrap;
}

/* DESKTOP NAV */
.site-nav{display:flex; align-items:center; gap:34px;}
.nav-left{justify-self:start;}
.nav-right-wrap{justify-self:end; display:flex; align-items:center; gap:34px;}

.site-nav a{
  position:relative;
  padding:8px 0;
  font-size:12px;
  font-weight:500;
  letter-spacing:0.22em;
  text-transform:uppercase;
  color:var(--ink-soft);
  transition:color .35s var(--ease-soft);
}
.site-nav a::after{
  content:'';
  position:absolute;
  left:0; right:0; bottom:2px;
  height:1px;
  background:var(--red);
  transform:scaleX(0);
  transform-origin:right;
  transition:transform .6s var(--ease);
}
.site-nav a:hover,
.site-nav a.is-active{color:var(--black);}
.site-nav a:hover::after,
.site-nav a.is-active::after{transform:scaleX(1); transform-origin:left;}

.header-cta{padding:12px 28px; font-size:11.5px;}

/* MOBILE TOGGLE */
.nav-toggle{
  display:none;
  position:relative;
  justify-self:end;
  width:44px; height:44px;
  border:none;
  background:transparent;
  cursor:pointer;
}
.nav-toggle span{
  position:absolute;
  left:9px; right:9px;
  height:1px;
  background:var(--black);
  transition:transform .6s var(--ease), top .6s var(--ease);
}
.nav-toggle span:nth-child(1){top:18px;}
.nav-toggle span:nth-child(2){top:26px;}
.nav-toggle.is-open span:nth-child(1){top:22px; transform:rotate(45deg);}
.nav-toggle.is-open span:nth-child(2){top:22px; transform:rotate(-45deg);}

/* MOBILE MENU */
.mobile-menu{display:none;}

@media (max-width:1320px){
  .site-nav, .nav-right-wrap{gap:26px;}
  .brand-full{letter-spacing:0.22em;}
}

@media (max-width:1180px){
  .header-inner{
    grid-template-columns:1fr auto;
    height:76px;
    padding:0 24px;
    gap:16px;
  }
  .site-header.is-scrolled .header-inner{height:64px;}
  .brand{justify-self:start; gap:12px;}
  .brand-mark{width:42px; height:42px;}
  .site-header.is-scrolled .brand-mark{width:36px; height:36px;}
  .brand-abbr{font-size:24px;}
  .brand-full{font-size:8px; letter-spacing:0.22em;}
  .nav-left, .nav-right-wrap{display:none;}
  .nav-toggle{display:block;}

  .mobile-menu{
    position:fixed;
    inset:0;
    z-index:1;
    display:flex;
    flex-direction:column;
    justify-content:space-between;
    padding:120px 32px 40px;
    background:var(--ivory);
    opacity:0;
    visibility:hidden;
    overflow-y:auto;
    transition:opacity .5s var(--ease-soft), visibility 0s linear .5s;
  }
  .mobile-menu.is-open{
    opacity:1;
    visibility:visible;
    transition:opacity .5s var(--ease-soft), visibility 0s;
  }
  .mobile-menu nav{display:flex; flex-direction:column; gap:4px;}
  .mobile-menu nav a{
    font-family:var(--f-display);
    font-size:clamp(40px,11vw,60px);
    font-weight:500;
    line-height:1.15;
    color:var(--black);
    opacity:0;
    transform:translateY(26px);
    transition:opacity .8s var(--ease), transform .9s var(--ease), color .3s ease;
  }
  .mobile-menu.is-open nav a{opacity:1; transform:none;}
  .mobile-menu nav a.is-active{color:var(--red); font-style:italic;}
  .mobile-foot{margin-top:40px; border-top:1px solid var(--line); padding-top:28px;}
  .mobile-cta{width:100%;}
  .mobile-foot p{
    margin-top:22px;
    font-size:11px;
    letter-spacing:0.24em;
    text-transform:uppercase;
    color:var(--ink-faint);
  }
}
__TMSK_FILE_END__

# =====================================================================
# Footer
# =====================================================================
put src/components/Footer.jsx << '__TMSK_FILE_END__'
import { Link, NavLink } from 'react-router-dom'
import Reveal from './Reveal.jsx'
import './Footer.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

export default function Footer(){
  const year = new Date().getFullYear()

  return (
    <footer className="site-footer">
      <div className="wrap footer-cta">
        <Reveal as="span" className="eyebrow on-dark">Stand with your people</Reveal>
        <Reveal as="h2" delay={80}>
          Preserve our culture.<br /><em>Together.</em>
        </Reveal>
        <Reveal delay={160} className="footer-cta-actions">
          <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn on-dark">Join TMSK</a>
          <Link to="/donate" className="btn ghost on-dark">Donate</Link>
        </Reveal>
      </div>

      <div className="wrap footer-inner">
        <div className="footer-brand">
          <img src="/logo.png" alt="TMSK emblem" className="footer-mark" />
          <div>
            <p className="footer-name">Takam Mising Sí:sang Kébang</p>
            <p className="footer-tag">TMSK</p>
          </div>
        </div>

        <nav className="footer-nav" aria-label="Footer">
          <span className="footer-col-label">Navigate</span>
          <NavLink to="/" end>Home</NavLink>
          <NavLink to="/objectives">Objectives</NavLink>
          <NavLink to="/events">Events</NavLink>
          <NavLink to="/leadership">Leadership</NavLink>
          <NavLink to="/donate">Donate</NavLink>
        </nav>

        <div className="footer-contact">
          <span className="footer-col-label">Get in touch</span>

          <a href="mailto:tmskyouthorg@gmail.com" className="footer-link">
            <span className="footer-link-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.4">
                <rect x="2.5" y="4.5" width="19" height="15" rx="1"/>
                <path d="M3 6.5l9 6.5 9-6.5"/>
              </svg>
            </span>
            <span className="footer-link-text">
              <span className="footer-link-label">Email</span>
              <span className="footer-link-value">tmskyouthorg@gmail.com</span>
            </span>
          </a>

          <a href="https://www.instagram.com/tmskyouthorg/" target="_blank" rel="noopener noreferrer" className="footer-link">
            <span className="footer-link-icon" aria-hidden="true">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.4">
                <rect x="3" y="3" width="18" height="18" rx="5"/>
                <circle cx="12" cy="12" r="4.2"/>
                <circle cx="17.4" cy="6.6" r="1.1" fill="currentColor" stroke="none"/>
              </svg>
            </span>
            <span className="footer-link-text">
              <span className="footer-link-label">Instagram</span>
              <span className="footer-link-value">@tmskyouthorg</span>
            </span>
          </a>
        </div>
      </div>

      <div className="wrap footer-bottom">
        <p>&copy; {year} TMSK &mdash; Takam Mising Sí:sang Kébang. Non-profit &amp; non-partisan.</p>
        <p>Established 9 May 2026</p>
      </div>
    </footer>
  )
}
__TMSK_FILE_END__

put src/components/Footer.css << '__TMSK_FILE_END__'
.site-footer{
  margin-top:auto;
  background:var(--charcoal);
  color:var(--ivory);
}

.footer-cta{
  display:flex;
  flex-direction:column;
  align-items:center;
  text-align:center;
  padding-top:140px;
  padding-bottom:110px;
}
.footer-cta .eyebrow{margin-bottom:28px;}
.footer-cta h2{
  color:var(--ivory);
  font-size:clamp(44px,7vw,104px);
  line-height:0.98;
}
.footer-cta h2 em{color:var(--red-light);}
.footer-cta-actions{
  display:flex;
  flex-wrap:wrap;
  justify-content:center;
  gap:16px;
  margin-top:48px;
}

.footer-inner{
  display:grid;
  grid-template-columns:1.4fr 1fr 1.3fr;
  gap:48px;
  padding-top:72px;
  padding-bottom:56px;
  border-top:1px solid rgba(250,247,242,0.14);
}

.footer-brand{display:flex; align-items:center; gap:16px; align-self:start;}
.footer-mark{
  width:52px; height:52px;
  border-radius:50%;
  object-fit:cover;
  flex-shrink:0;
}
.footer-name{
  font-family:var(--f-display);
  font-size:24px;
  font-weight:500;
  line-height:1.15;
  color:var(--ivory);
}
.footer-tag{
  margin-top:6px;
  font-size:11px;
  letter-spacing:0.3em;
  text-transform:uppercase;
  color:var(--gold);
}

.footer-col-label{
  display:block;
  margin-bottom:20px;
  font-size:11px;
  font-weight:500;
  letter-spacing:0.28em;
  text-transform:uppercase;
  color:var(--gold);
}

.footer-nav{display:flex; flex-direction:column; align-items:flex-start; gap:10px;}
.footer-nav a{
  position:relative;
  font-family:var(--f-display);
  font-size:22px;
  line-height:1.3;
  color:rgba(250,247,242,0.78);
  transition:color .35s var(--ease-soft), transform .5s var(--ease);
}
.footer-nav a:hover,
.footer-nav a.active{color:var(--ivory); transform:translateX(6px);}

.footer-contact{display:flex; flex-direction:column; gap:18px;}
.footer-link{display:flex; align-items:center; gap:16px; color:rgba(250,247,242,0.78); transition:color .35s ease;}
.footer-link:hover{color:var(--ivory);}
.footer-link-icon{
  display:flex;
  align-items:center;
  justify-content:center;
  width:44px; height:44px;
  border:1px solid rgba(250,247,242,0.22);
  border-radius:50%;
  flex-shrink:0;
  transition:border-color .4s ease, background .4s ease;
}
.footer-link:hover .footer-link-icon{border-color:var(--red-light); background:rgba(200,16,46,0.18);}
.footer-link-icon svg{width:19px; height:19px;}
.footer-link-text{display:flex; flex-direction:column; line-height:1.3; min-width:0;}
.footer-link-label{font-size:11px; letter-spacing:0.22em; text-transform:uppercase; color:rgba(250,247,242,0.5);}
.footer-link-value{font-size:16px; overflow-wrap:anywhere;}

.footer-bottom{
  display:flex;
  flex-wrap:wrap;
  justify-content:space-between;
  gap:10px 24px;
  padding-top:26px;
  padding-bottom:34px;
  border-top:1px solid rgba(250,247,242,0.1);
  font-size:13px;
  letter-spacing:0.04em;
  color:rgba(250,247,242,0.5);
}

@media (max-width:900px){
  .footer-cta{padding-top:96px; padding-bottom:80px;}
  .footer-inner{grid-template-columns:1fr; gap:44px; padding-top:56px;}
}
__TMSK_FILE_END__

# =====================================================================
# Home
# =====================================================================
put src/pages/Home.jsx << '__TMSK_FILE_END__'
import { Link } from 'react-router-dom'
import Reveal from '../components/Reveal.jsx'
import { getEventStatus } from '../data/eventStatus.js'
import './Home.css'

const JOIN_URL = 'https://docs.google.com/forms/u/1/d/e/1FAIpQLSe3uWpxPY-DMIcs8fLODpYrJ1CSRZRk3hPPhDPm20932-tPvg/viewform'

const FACTS = [
  'Established 9 May 2026',
  'Independent',
  'Non-profit',
  'Non-partisan',
  'A Mising youth movement',
]

const OBJECTIVES_PREVIEW = [
  { n: '01', title: 'De-Mipakification of Mising Culture' },
  { n: '02', title: "Voice for Mising People's Development" },
  { n: '03', title: 'Documentation & Research of Mising Heritage' },
  { n: '04', title: 'Encouragement of Mising Agom' },
]

export default function Home(){
  const status = getEventStatus()

  return (
    <>
      {/* ---------------- HERO ---------------- */}
      <section className="hero">
        <div className="hero-ornament" aria-hidden="true">
          <span></span><span></span><span></span>
        </div>

        <div className="wrap hero-inner">
          <div className="hero-copy">
            <Reveal as="span" className="eyebrow">A Mising youth-led movement</Reveal>

            <Reveal as="h1" delay={80} className="hero-title">
              Takam Mising<br />
              Sí:sang <span className="hero-title-red">Kébang</span>
            </Reveal>

            <Reveal delay={180} className="hero-quotes">
              <p>&ldquo;We are here for our people, not for any political party&rdquo;</p>
              <p>&ldquo;We are here to preserve our culture, identity, and history.&rdquo;</p>
            </Reveal>

            <Reveal delay={280} className="hero-actions">
              <a href={JOIN_URL} target="_blank" rel="noopener noreferrer" className="btn">
                Join TMSK
              </a>
              <Link to="/objectives" className="btn ghost">Our Objectives</Link>
            </Reveal>
          </div>

          <Reveal delay={220} className="hero-flag">
            <div className="hero-flag-frame">
              <img src="/assets/flag.jpg" alt="Flag of Takam Mising Sí:sang Kébang" />
              <span className="hero-flag-badge">
                <span>EST.</span>
                <strong>2026</strong>
              </span>
            </div>
          </Reveal>
        </div>

        <a href="#about" className="hero-scroll" aria-label="Scroll to read about TMSK">
          <span>Scroll</span>
        </a>
      </section>

      {/* ---------------- FACTS RIBBON ---------------- */}
      <div className="facts" aria-label="About TMSK in brief">
        <div className="facts-track">
          {[0, 1].map(group => (
            <div className="facts-group" key={group} aria-hidden={group === 1 ? 'true' : undefined}>
              {[...FACTS, ...FACTS].map((text, i) => (
                <span className="facts-item" key={`${group}-${i}`}>
                  {text}<i></i>
                </span>
              ))}
            </div>
          ))}
        </div>
      </div>

      {/* ---------------- ABOUT ---------------- */}
      <section className="about" id="about">
        <div className="wrap about-inner">
          <div className="about-intro">
            <Reveal as="span" className="eyebrow">Who we are</Reveal>
            <Reveal as="h2" delay={80}>
              Unregistered,<br /><em>unmistakably</em> real.
            </Reveal>
            <Reveal as="p" delay={160} className="about-lede">
              TMSK is unregistered but unmistakably real &mdash; a group of Mising youth
              who found each other online and decided the dilution of their
              culture was worth organising against.
            </Reveal>
          </div>

          <ol className="timeline">
            <Reveal as="li" delay={100}>
              <span className="tl-num">01</span>
              <h3>How it began</h3>
              <p>
                All founding members were brought together through an online
                group created by an anonymous user, <em>&ldquo;Apongrizz /
                Tokutaato&rdquo;</em>, where they shared ideas, concerns, and
                visions for the tribe.
              </p>
            </Reveal>

            <Reveal as="li" delay={140}>
              <span className="tl-num">02</span>
              <h3>Why we exist</h3>
              <p>
                Frustrated by the declining progress of the tribe and the
                growing dilution of Mising culture, we chose to build an
                organisation to address it directly. TMSK was officially
                established on <strong>9th May 2026</strong>.
              </p>
            </Reveal>

            <Reveal as="li" delay={180}>
              <span className="tl-num">03</span>
              <h3>How we&rsquo;re run</h3>
              <p>
                On <strong>12th July 2026</strong>, TMSK held its first
                election for a six-month term, filling all required positions.
                The Board of Directors now oversees the organisation&rsquo;s vision,
                decisions, and operations.
              </p>
            </Reveal>
          </ol>
        </div>
      </section>

      {/* ---------------- STATEMENT ---------------- */}
      <section className="statement">
        <div className="wrap">
          <Reveal as="span" className="eyebrow on-dark">Our promise</Reveal>
          <Reveal as="p" delay={100} className="statement-text">
            We speak for no government and no political party &mdash;{' '}
            <em>we speak only for our people.</em>
          </Reveal>
        </div>
      </section>

      {/* ---------------- OBJECTIVES preview ---------------- */}
      <section className="objectives-preview">
        <div className="wrap">
          <div className="section-head">
            <Reveal as="span" className="eyebrow">What we stand for</Reveal>
            <Reveal as="h2" delay={80}>Seven objectives.<br /><em>One direction.</em></Reveal>
          </div>

          <div className="obj-preview-list">
            {OBJECTIVES_PREVIEW.map((o, i) => (
              <Reveal
                as={Link}
                to="/objectives"
                delay={i * 90}
                key={o.n}
                className="obj-preview-row"
              >
                <span className="ghost-num">{o.n}</span>
                <h4>{o.title}</h4>
                <span className="obj-preview-arrow" aria-hidden="true">&rarr;</span>
              </Reveal>
            ))}
          </div>

          <Reveal delay={160} className="objectives-cta">
            <Link to="/objectives" className="btn ghost">
              See all seven objectives
            </Link>
          </Reveal>
        </div>
      </section>

      {/* ---------------- EVENTS preview ---------------- */}
      <section className="wrap events-preview">
        <div className="section-head">
          <Reveal as="span" className="eyebrow">What&rsquo;s happening</Reveal>
          <Reveal as="h2" delay={80}>{status.headline}</Reveal>
        </div>

        <Reveal delay={140} className="event-preview-card">
          <div className="event-preview-visual">
            <span className="event-preview-tag">Visual Art Competition</span>
            <span className="status-pill" data-status={status.key}>
              <i></i>{status.label}
            </span>
          </div>
          <div className="event-preview-body">
            <h3>TMSK Art Online Competition</h3>
            <p>
              An online visual art competition open to all. AI-generated art
              will be rejected &mdash; submissions must be genuinely made.
            </p>
            <div className="event-preview-meta">
              <div><span>{status.closesLabel}</span><strong>31 Aug 2026</strong></div>
              <div><span>Entry fee</span><strong>₹75</strong></div>
              <div><span>Top prize</span><strong>₹1,000</strong></div>
            </div>
            <Link to="/events" className="btn">View Event Details</Link>
          </div>
        </Reveal>
      </section>
    </>
  )
}
__TMSK_FILE_END__

put src/pages/Home.css << '__TMSK_FILE_END__'
/* ==================== HERO ==================== */
.hero{
  position:relative;
  min-height:calc(100svh - var(--header-h));
  display:flex;
  flex-direction:column;
  justify-content:center;
  padding:72px 0 110px;
  overflow:hidden;
  background:
    radial-gradient(900px 520px at 88% 18%, rgba(200,16,46,0.06), transparent 62%),
    radial-gradient(700px 420px at 0% 100%, rgba(184,147,90,0.10), transparent 60%),
    var(--ivory);
}

/* slow orbiting rings: sun and moon */
.hero-ornament{
  position:absolute;
  right:-14vw;
  top:50%;
  width:min(80vw,880px);
  aspect-ratio:1;
  transform:translateY(-50%);
  pointer-events:none;
  z-index:0;
}
.hero-ornament span{
  position:absolute;
  border-radius:50%;
  border:1px solid rgba(20,17,14,0.09);
}
.hero-ornament span:nth-child(1){inset:0; animation:ringTurn 150s linear infinite;}
.hero-ornament span:nth-child(2){inset:13%; border:1px dashed rgba(200,16,46,0.22); animation:ringTurn 110s linear infinite reverse;}
.hero-ornament span:nth-child(3){inset:28%; border-color:rgba(184,147,90,0.4); animation:ringTurn 80s linear infinite;}
.hero-ornament span::after{
  content:'';
  position:absolute;
  top:-4px; left:50%;
  width:8px; height:8px;
  margin-left:-4px;
  border-radius:50%;
}
.hero-ornament span:nth-child(1)::after{background:var(--red);}
.hero-ornament span:nth-child(2)::after{background:var(--black);}
.hero-ornament span:nth-child(3)::after{background:var(--gold);}
@keyframes ringTurn{to{transform:rotate(360deg);}}

.hero-inner{
  position:relative;
  z-index:1;
  display:grid;
  grid-template-columns:1.1fr 0.9fr;
  gap:80px;
  align-items:center;
}

.hero-title{
  margin:0 0 38px;
  font-size:clamp(54px,8.2vw,128px);
  line-height:0.92;
  letter-spacing:-0.02em;
}
.hero-title-red{color:var(--red); font-style:italic;}

.hero-quotes{
  display:flex;
  flex-direction:column;
  gap:14px;
  max-width:500px;
  margin-bottom:44px;
}
.hero-quotes p{
  padding-left:22px;
  border-left:1px solid var(--red);
  font-family:var(--f-display);
  font-size:23px;
  font-style:italic;
  line-height:1.4;
  color:var(--ink-soft);
}

.hero-actions{display:flex; flex-wrap:wrap; gap:16px;}

/* ---- Flag (animation kept) ---- */
.hero-flag{position:relative; display:flex; justify-content:center;}
.hero-flag-frame{
  position:relative;
  width:100%;
  max-width:470px;
  padding:14px;
  background:var(--white);
  border:1px solid var(--line);
  box-shadow:0 50px 90px -30px rgba(20,17,14,0.38);
  animation:flagFloat 6.5s ease-in-out infinite;
  transform:rotate(1.4deg);
}
.hero-flag-frame img{width:100%; aspect-ratio:5/3; object-fit:cover;}
.hero-flag-badge{
  position:absolute;
  right:-28px; bottom:-28px;
  width:108px; height:108px;
  display:flex;
  flex-direction:column;
  align-items:center;
  justify-content:center;
  border-radius:50%;
  background:var(--red);
  color:var(--white);
  line-height:1;
  box-shadow:0 0 0 7px var(--ivory);
}
.hero-flag-badge span{
  font-size:10px;
  font-weight:500;
  letter-spacing:0.26em;
  text-transform:uppercase;
  opacity:0.85;
  margin-bottom:5px;
}
.hero-flag-badge strong{
  font-family:var(--f-display);
  font-size:30px;
  font-weight:600;
  letter-spacing:0;
}

@keyframes flagFloat{
  0%, 100%{ transform:rotate(1.4deg) translateY(0); }
  50%{ transform:rotate(-0.6deg) translateY(-14px); }
}

/* scroll cue */
.hero-scroll{
  position:absolute;
  left:50%; bottom:26px;
  z-index:1;
  display:flex;
  flex-direction:column;
  align-items:center;
  gap:12px;
  transform:translateX(-50%);
  font-size:10.5px;
  font-weight:500;
  letter-spacing:0.3em;
  text-transform:uppercase;
  color:var(--ink-faint);
}
.hero-scroll::after{
  content:'';
  width:1px; height:46px;
  background:linear-gradient(var(--red), transparent);
  transform-origin:top;
  animation:scrollLine 2.6s var(--ease-soft) infinite;
}
@keyframes scrollLine{
  0%{transform:scaleY(0); opacity:1;}
  60%{transform:scaleY(1); opacity:1;}
  100%{transform:scaleY(1); opacity:0;}
}

@media (prefers-reduced-motion: reduce){
  .hero-flag-frame{animation:none;}
  .hero-ornament span{animation:none;}
  .facts-track{animation:none;}
}

@media (max-width:980px){
  .hero{padding:48px 0 72px;}
  .hero-inner{grid-template-columns:1fr; gap:64px;}
  .hero-flag{order:-1;}
  .hero-flag-frame{max-width:360px;}
  .hero-flag-badge{width:92px; height:92px; right:-12px; bottom:-22px;}
  .hero-flag-badge strong{font-size:26px;}
  .hero-scroll{display:none;}
  .hero-ornament{right:-40vw; width:120vw;}
}
@media (max-width:560px){
  .hero-quotes p{font-size:20px;}
  .hero-actions{flex-direction:column; align-items:stretch;}
  .hero-actions .btn{width:100%;}
}

/* ==================== FACTS RIBBON ==================== */
.facts{
  overflow:hidden;
  background:var(--white);
  border-top:1px solid var(--line);
  border-bottom:1px solid var(--line);
}
.facts-track{
  display:flex;
  width:max-content;
  animation:marquee 60s linear infinite;
}
.facts:hover .facts-track{animation-play-state:paused;}
.facts-group{display:flex; align-items:center; flex-shrink:0;}
.facts-item{
  display:flex;
  align-items:center;
  padding:24px 0;
  font-family:var(--f-display);
  font-size:24px;
  font-style:italic;
  white-space:nowrap;
  color:var(--ink);
}
.facts-item i{
  width:6px; height:6px;
  margin:0 44px;
  border-radius:50%;
  background:var(--red);
  flex-shrink:0;
}
@keyframes marquee{to{transform:translateX(-50%);}}

/* ==================== ABOUT ==================== */
.about{padding:150px 0 140px;}
.about-inner{
  display:grid;
  grid-template-columns:0.9fr 1.1fr;
  gap:110px;
  align-items:start;
}
.about-intro{position:sticky; top:150px;}
.about-intro h2{
  margin-bottom:30px;
  font-size:clamp(42px,5.4vw,80px);
  line-height:0.98;
}
.about-lede{
  max-width:480px;
  font-size:19px;
  line-height:1.8;
  color:var(--ink-soft);
}

.timeline{border-left:1px solid var(--line-strong);}
.timeline li{position:relative; padding:0 0 72px 52px;}
.timeline li:last-child{padding-bottom:0;}
.timeline li::before{
  content:'';
  position:absolute;
  left:-5px; top:14px;
  width:9px; height:9px;
  border-radius:50%;
  background:var(--red);
  box-shadow:0 0 0 6px var(--ivory);
}
.tl-num{
  display:block;
  font-family:var(--f-display);
  font-size:22px;
  font-style:italic;
  font-variant-numeric:lining-nums;
  color:var(--gold);
}
.timeline h3{margin:6px 0 16px; font-size:clamp(30px,3.2vw,44px);}
.timeline p{max-width:540px; line-height:1.85; color:var(--ink-soft);}
.timeline strong{font-weight:500; color:var(--ink);}
.timeline em{font-style:normal; font-weight:500; color:var(--ink);}

@media (max-width:980px){
  .about{padding:96px 0;}
  .about-inner{grid-template-columns:1fr; gap:64px;}
  .about-intro{position:static;}
  .timeline li{padding-left:32px; padding-bottom:56px;}
}

/* ==================== STATEMENT ==================== */
.statement{
  position:relative;
  padding:170px 0 150px;
  overflow:hidden;
  background:var(--charcoal);
  color:var(--ivory);
  text-align:center;
}
.statement::before{
  content:'';
  position:absolute;
  left:50%; top:0;
  width:1px; height:84px;
  background:linear-gradient(var(--gold), transparent);
}
.statement .eyebrow{margin-bottom:34px;}
.statement-text{
  max-width:1000px;
  margin:0 auto;
  font-family:var(--f-display);
  font-size:clamp(36px,5.6vw,82px);
  font-weight:500;
  line-height:1.06;
  letter-spacing:-0.01em;
  color:var(--ivory);
}
.statement-text em{font-style:italic; color:var(--red-light);}
@media (max-width:860px){ .statement{padding:110px 0 96px;} }

/* ==================== OBJECTIVES preview ==================== */
.objectives-preview{padding:140px 0; background:var(--sand);}
.section-head{margin-bottom:64px;}
.section-head h2{font-size:clamp(42px,5.4vw,80px); line-height:0.98;}

.obj-preview-list{border-bottom:1px solid var(--line-strong);}
.obj-preview-row{
  display:grid;
  grid-template-columns:120px 1fr 40px;
  align-items:center;
  gap:24px;
  padding:36px 0;
  border-top:1px solid var(--line-strong);
}
.obj-preview-row .ghost-num{font-size:60px;}
.obj-preview-row h4{
  font-size:clamp(25px,3vw,40px);
  font-weight:500;
  line-height:1.1;
  transition:transform .7s var(--ease), color .4s ease;
}
.obj-preview-arrow{
  font-size:28px;
  color:var(--red);
  opacity:0;
  transform:translateX(-14px);
  transition:opacity .5s ease, transform .7s var(--ease);
}
.obj-preview-row:hover h4{transform:translateX(18px);}
.obj-preview-row:hover .ghost-num{-webkit-text-stroke-color:var(--red);}
.obj-preview-row:hover .obj-preview-arrow{opacity:1; transform:none;}
.objectives-cta{margin-top:52px;}

@media (max-width:860px){
  .objectives-preview{padding:88px 0;}
  .obj-preview-row{grid-template-columns:64px 1fr 24px; gap:14px; padding:26px 0;}
  .obj-preview-row .ghost-num{font-size:40px;}
  .obj-preview-arrow{opacity:1; transform:none; font-size:22px;}
}

/* ==================== EVENTS preview ==================== */
.events-preview{padding-top:140px; padding-bottom:150px;}
.event-preview-card{
  display:grid;
  grid-template-columns:0.85fr 1.15fr;
  background:var(--white);
  border:1px solid var(--line);
}
.event-preview-visual{
  position:relative;
  min-height:440px;
  padding:38px;
  display:flex;
  flex-direction:column;
  justify-content:space-between;
  overflow:hidden;
  background:var(--charcoal);
  color:var(--ivory);
}
.event-preview-visual::before,
.event-preview-visual::after{
  content:'';
  position:absolute;
  border-radius:50%;
  border:1px solid rgba(184,147,90,0.45);
}
.event-preview-visual::before{right:-110px; bottom:-110px; width:360px; height:360px;}
.event-preview-visual::after{right:-40px; bottom:-40px; width:220px; height:220px; border-color:rgba(200,16,46,0.55);}
.event-preview-tag{
  position:relative;
  font-size:11px;
  font-weight:500;
  letter-spacing:0.26em;
  text-transform:uppercase;
  color:var(--gold);
}
.event-preview-visual .status-pill{position:relative;}

.event-preview-body{
  display:flex;
  flex-direction:column;
  gap:24px;
  padding:56px 52px;
}
.event-preview-body h3{font-size:clamp(32px,3.6vw,50px); line-height:1.02;}
.event-preview-body p{max-width:520px; color:var(--ink-soft); line-height:1.8;}
.event-preview-meta{
  display:grid;
  grid-template-columns:repeat(3,1fr);
  gap:20px;
  padding:22px 0;
  border-top:1px solid var(--line-strong);
  border-bottom:1px solid var(--line);
}
.event-preview-meta div{display:flex; flex-direction:column; gap:4px;}
.event-preview-meta span{
  font-size:10.5px;
  letter-spacing:0.2em;
  text-transform:uppercase;
  color:var(--ink-faint);
}
.event-preview-meta strong{
  font-family:var(--f-display);
  font-size:26px;
  font-weight:500;
  font-variant-numeric:lining-nums;
}
.event-preview-body .btn{align-self:flex-start;}

@media (max-width:900px){
  .events-preview{padding-top:88px; padding-bottom:96px;}
  .event-preview-card{grid-template-columns:1fr;}
  .event-preview-visual{min-height:200px;}
  .event-preview-body{padding:36px 24px;}
  .event-preview-meta{grid-template-columns:1fr 1fr;}
}
__TMSK_FILE_END__

# =====================================================================
# Events
# =====================================================================
put src/pages/Events.jsx << '__TMSK_FILE_END__'
import Reveal from '../components/Reveal.jsx'
import { getEventStatus } from '../data/eventStatus.js'
import './Events.css'

const EVENTS = [
  {
    n: '01',
    tag: 'Visual Art Competition',
    title: 'TMSK Art Online Competition',
    blurb: `An online visual art competition open to all. The topic will be shared with registered participants on 1st September 2026. AI-generated art will be rejected.`,
    details: [
      { label: 'Registration closes', value: '31 August 2026' },
      { label: 'Submission window', value: '4 – 13 September 2026' },
      { label: 'Entry fee', value: '₹75/-' },
      { label: 'Contact', value: '+91 70858 80388' },
    ],
    prizes: [
      { place: '1st', amount: '₹1000/-' },
      { place: '2nd', amount: '₹500/-' },
      { place: '3rd', amount: '₹300/-' },
    ],
    note: `Prize money is subject to increase depending on the total number of participants. Winners get free participation in the Creators Pop-up Program in Pasighat.`,
    registerUrl: 'https://docs.google.com/forms/d/1mbJFR53KfgaMFuwOZ7NbxB3_t9-_45dYc51Xy_QvIE8/edit',
    credit: 'Sumyo Doley, President of TMSK',
  },
]

export default function Events(){
  const status = getEventStatus()

  return (
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">What&rsquo;s happening</Reveal>
        <Reveal as="h1" delay={80}>Events</Reveal>
      </header>

      <section className="wrap events-list">
        {EVENTS.map((ev, i) => (
          <Reveal as="article" delay={i * 100} className="event-card" key={ev.n}>
            <div className="event-card-visual">
              <div className="event-card-top">
                <span className="event-card-tag">{ev.tag}</span>
                <span className="status-pill" data-status={status.key}>
                  <i></i>{status.label}
                </span>
              </div>
              <span className="ghost-num event-card-num">{ev.n}</span>
            </div>

            <div className="event-card-body">
              <h2>{ev.title}</h2>
              <p className="event-blurb">{ev.blurb}</p>

              <div className="event-details">
                {ev.details.map(d => (
                  <div className="event-detail" key={d.label}>
                    <span className="event-detail-label">{d.label}</span>
                    <span className="event-detail-value">{d.value}</span>
                  </div>
                ))}
              </div>

              <div className="event-prizes">
                {ev.prizes.map(p => (
                  <div className="prize-pill" key={p.place}>
                    <span>{p.place}</span>
                    <strong>{p.amount}</strong>
                  </div>
                ))}
              </div>

              <p className="event-note">{ev.note}</p>

              <div className="event-actions">
                {status.key === 'open' && (
                  <a href={ev.registerUrl} target="_blank" rel="noopener noreferrer" className="btn">
                    Register now
                  </a>
                )}
                <span className="event-credit">&mdash; {ev.credit}</span>
              </div>
            </div>
          </Reveal>
        ))}
      </section>
    </>
  )
}
__TMSK_FILE_END__

put src/pages/Events.css << '__TMSK_FILE_END__'
.events-list{padding-bottom:150px;}

.event-card{
  display:grid;
  grid-template-columns:0.75fr 1.25fr;
  background:var(--white);
  border:1px solid var(--line);
}

.event-card-visual{
  position:relative;
  min-height:520px;
  padding:40px;
  display:flex;
  flex-direction:column;
  justify-content:space-between;
  overflow:hidden;
  background:var(--charcoal);
  color:var(--ivory);
}
.event-card-visual::before,
.event-card-visual::after{
  content:'';
  position:absolute;
  border-radius:50%;
  border:1px solid rgba(184,147,90,0.45);
}
.event-card-visual::before{right:-120px; bottom:-120px; width:400px; height:400px;}
.event-card-visual::after{right:-45px; bottom:-45px; width:250px; height:250px; border-color:rgba(200,16,46,0.55);}

.event-card-top{position:relative; display:flex; flex-direction:column; gap:18px; align-items:flex-start;}
.event-card-tag{
  font-size:11px;
  font-weight:500;
  letter-spacing:0.26em;
  text-transform:uppercase;
  color:var(--gold);
}
.event-card-num{
  position:relative;
  font-size:clamp(120px,14vw,200px);
  -webkit-text-stroke:1px rgba(250,247,242,0.3);
}

.event-card-body{
  display:flex;
  flex-direction:column;
  gap:30px;
  padding:60px 56px 52px;
}
.event-card-body h2{font-size:clamp(34px,4vw,58px); line-height:1;}
.event-blurb{max-width:620px; font-size:18px; line-height:1.8; color:var(--ink-soft);}

.event-details{
  display:grid;
  grid-template-columns:1fr 1fr;
  border-top:1px solid var(--line-strong);
}
.event-detail{
  display:flex;
  flex-direction:column;
  gap:4px;
  padding:18px 20px 18px 0;
  border-bottom:1px solid var(--line);
}
.event-detail-label{
  font-size:10.5px;
  letter-spacing:0.22em;
  text-transform:uppercase;
  color:var(--ink-faint);
}
.event-detail-value{
  font-family:var(--f-display);
  font-size:25px;
  font-variant-numeric:lining-nums;
}

.event-prizes{
  display:grid;
  grid-template-columns:repeat(3,1fr);
  border:1px solid var(--line);
}
.prize-pill{
  display:flex;
  flex-direction:column;
  align-items:center;
  gap:4px;
  padding:24px 12px;
  text-align:center;
  border-right:1px solid var(--line);
}
.prize-pill:last-child{border-right:none;}
.prize-pill span{
  font-size:10.5px;
  letter-spacing:0.24em;
  text-transform:uppercase;
  color:var(--ink-faint);
}
.prize-pill strong{
  font-family:var(--f-display);
  font-size:34px;
  font-weight:500;
  font-variant-numeric:lining-nums;
}
.prize-pill:first-child strong{color:var(--red);}

.event-note{
  max-width:620px;
  font-family:var(--f-display);
  font-size:20px;
  font-style:italic;
  line-height:1.5;
  color:var(--ink-soft);
}
.event-actions{display:flex; flex-wrap:wrap; align-items:center; gap:24px;}
.event-credit{font-size:13px; letter-spacing:0.06em; color:var(--ink-faint);}

@media (max-width:980px){
  .events-list{padding-bottom:96px;}
  .event-card{grid-template-columns:1fr;}
  .event-card-visual{min-height:280px; padding:30px 24px;}
  .event-card-num{font-size:110px;}
  .event-card-body{padding:36px 24px 32px;}
}
@media (max-width:560px){
  .event-details{grid-template-columns:1fr;}
  .prize-pill strong{font-size:26px;}
}
__TMSK_FILE_END__

# =====================================================================
# Objectives (page code unchanged, new styling)
# =====================================================================
put src/pages/Objectives.css << '__TMSK_FILE_END__'
.obj-list{padding-bottom:150px;}

.obj-item{
  display:grid;
  grid-template-columns:200px 1fr;
  gap:36px;
  padding:60px 0;
  border-top:1px solid var(--line-strong);
}
.obj-item:last-child{border-bottom:1px solid var(--line-strong);}

.obj-num{font-size:clamp(70px,9vw,132px);}
.obj-item:hover .obj-num{-webkit-text-stroke-color:var(--red);}

.obj-body h3{
  max-width:760px;
  margin-bottom:20px;
  font-size:clamp(30px,3.6vw,50px);
  line-height:1.06;
}
.obj-body p{
  max-width:700px;
  font-size:18px;
  line-height:1.85;
  color:var(--ink-soft);
}

@media (max-width:860px){
  .obj-list{padding-bottom:96px;}
  .obj-item{grid-template-columns:1fr; gap:6px; padding:40px 0;}
  .obj-num{font-size:64px;}
}
__TMSK_FILE_END__

# =====================================================================
# Leadership
# =====================================================================
put src/pages/Leadership.jsx << '__TMSK_FILE_END__'
import { useState } from 'react';
import Reveal from '../components/Reveal.jsx';
import { leadershipTerms } from '../data/leadership';
import './Leadership.css';

function getInitials(name) {
  return name
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join('');
}

function MemberCard({ member, termId, index }) {
  const src = `/images/leadership/${termId}/${member.image}`;
  const [failedSrc, setFailedSrc] = useState(null);
  const imageFailed = failedSrc === src;

  return (
    <article className="leader-card" style={{ '--i': index }}>
      <div className="leader-photo">
        {imageFailed ? (
          <span className="leader-initials">{getInitials(member.name)}</span>
        ) : (
          <img
            src={src}
            alt={member.name}
            loading="lazy"
            onError={() => setFailedSrc(src)}
          />
        )}
      </div>
      <p className="leader-role">{member.role}</p>
      <h3 className="leader-name">{member.name}</h3>
      {member.note && <p className="leader-note">{member.note}</p>}
    </article>
  );
}

export default function Leadership() {
  const [activeId, setActiveId] = useState(leadershipTerms[0].id);
  const activeTerm = leadershipTerms.find((t) => t.id === activeId);

  return (
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">Our people</Reveal>
        <Reveal as="h1" delay={80}>Leadership</Reveal>
        <Reveal as="p" delay={160} className="page-head-lede">
          The office bearers who have guided TMSK through each term.
        </Reveal>
      </header>

      <div className="wrap leadership-body">
        <nav className="term-tabs" aria-label="Leadership terms">
          {leadershipTerms.map((term) => (
            <button
              key={term.id}
              type="button"
              className={term.id === activeId ? 'term-tab active' : 'term-tab'}
              onClick={() => setActiveId(term.id)}
            >
              {term.title}
            </button>
          ))}
        </nav>

        <section
          className="term-section"
          key={activeTerm.id}
          aria-labelledby={`${activeTerm.id}-title`}
        >
          <h2 id={`${activeTerm.id}-title`} className="term-title">
            {activeTerm.title}
          </h2>
          <div className="leader-grid">
            {activeTerm.members.map((member, index) => (
              <MemberCard
                key={`${activeTerm.id}-${member.role}`}
                member={member}
                termId={activeTerm.id}
                index={index}
              />
            ))}
          </div>
        </section>
      </div>
    </>
  );
}
__TMSK_FILE_END__

put src/pages/Leadership.css << '__TMSK_FILE_END__'
.leadership-body{padding-bottom:150px;}

.term-tabs{
  display:flex;
  flex-wrap:wrap;
  gap:8px 44px;
  margin-bottom:56px;
  border-bottom:1px solid var(--line);
}
.term-tab{
  position:relative;
  padding:14px 0;
  border:none;
  background:none;
  font-family:var(--f-display);
  font-size:28px;
  font-weight:500;
  color:var(--ink-faint);
  cursor:pointer;
  transition:color .4s var(--ease-soft);
}
.term-tab::after{
  content:'';
  position:absolute;
  left:0; right:0; bottom:-1px;
  height:2px;
  background:var(--red);
  transform:scaleX(0);
  transform-origin:left;
  transition:transform .6s var(--ease);
}
.term-tab:hover{color:var(--ink);}
.term-tab.active{color:var(--ink);}
.term-tab.active::after{transform:scaleX(1);}

.term-section{animation:termIn .8s var(--ease-soft) both;}
@keyframes termIn{from{opacity:0;} to{opacity:1;}}

.term-title{
  margin-bottom:40px;
  font-size:clamp(32px,4vw,52px);
  font-style:italic;
  color:var(--ink-soft);
}

.leader-grid{
  display:grid;
  grid-template-columns:repeat(auto-fill,minmax(240px,1fr));
  gap:56px 32px;
}

.leader-card{
  animation:cardIn 1s var(--ease) both;
  animation-delay:calc(var(--i, 0) * 110ms + 100ms);
}
@keyframes cardIn{
  from{opacity:0; transform:translateY(28px);}
  to{opacity:1; transform:none;}
}

.leader-photo{
  position:relative;
  aspect-ratio:4/5;
  margin-bottom:22px;
  overflow:hidden;
  display:flex;
  align-items:center;
  justify-content:center;
  background:var(--sand);
  border:1px solid var(--line);
}
.leader-photo::after{
  content:'';
  position:absolute;
  left:0; bottom:0;
  width:100%; height:3px;
  background:var(--red);
  transform:scaleX(0);
  transform-origin:left;
  transition:transform .8s var(--ease);
}
.leader-card:hover .leader-photo::after{transform:scaleX(1);}
.leader-photo img{
  width:100%; height:100%;
  object-fit:cover;
  filter:grayscale(0.25);
  transition:transform 1.2s var(--ease), filter .8s var(--ease-soft);
}
.leader-card:hover .leader-photo img{transform:scale(1.04); filter:grayscale(0);}
.leader-initials{
  font-family:var(--f-display);
  font-size:80px;
  font-style:italic;
  color:var(--gold);
  letter-spacing:0.04em;
}

.leader-role{
  margin-bottom:8px;
  font-size:11px;
  font-weight:500;
  letter-spacing:0.24em;
  text-transform:uppercase;
  color:var(--red);
}
.leader-name{font-size:30px; line-height:1.1;}
.leader-note{margin-top:10px; font-size:15px; line-height:1.6; color:var(--ink-soft);}

@media (max-width:860px){
  .leadership-body{padding-bottom:96px;}
  .term-tab{font-size:24px;}
  .leader-grid{grid-template-columns:repeat(2,1fr); gap:40px 18px;}
  .leader-name{font-size:24px;}
  .leader-initials{font-size:56px;}
}
@media (max-width:420px){
  .leader-grid{grid-template-columns:1fr;}
}
__TMSK_FILE_END__

# =====================================================================
# Not found
# =====================================================================
put src/pages/NotFound.css << '__TMSK_FILE_END__'
.not-found{
  display:flex;
  flex-direction:column;
  align-items:center;
  text-align:center;
  padding-top:110px;
  padding-bottom:150px;
}
.not-found-code{
  font-family:var(--f-display);
  font-size:clamp(130px,24vw,300px);
  font-style:italic;
  font-weight:500;
  line-height:0.85;
  color:transparent;
  -webkit-text-stroke:1px var(--red);
  margin-bottom:24px;
}
.not-found h1{font-size:clamp(36px,5vw,64px); margin-bottom:16px;}
.not-found p{max-width:440px; margin-bottom:40px; color:var(--ink-soft);}
__TMSK_FILE_END__

# =====================================================================
# Donate
# =====================================================================
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
        <Reveal as="p" delay={140} className="page-head-lede">{TAGLINE}</Reveal>
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
.donate-body{padding-bottom:150px;}

.donate-card{
  padding:64px 48px 44px;
  background:var(--white);
  border:1px solid var(--line);
  border-top:3px solid var(--red);
  text-align:center;
}
.donate-heart{display:inline-block; margin-bottom:18px; color:var(--red);}
.donate-card h2{margin:0 0 16px; font-size:clamp(34px,4vw,54px);}
.donate-card > p{
  max-width:620px;
  margin:0 auto 32px;
  line-height:1.85;
  color:var(--ink-soft);
}
.donate-card > .donate-secure{
  margin:24px 0 0;
  font-size:11px;
  letter-spacing:0.24em;
  text-transform:uppercase;
  color:var(--ink-faint);
}

.donate-block{margin-top:100px;}

.donate-steps{
  display:grid;
  grid-template-columns:repeat(3,1fr);
  gap:0 40px;
  margin-top:8px;
}
.donate-steps li{padding:32px 0; border-top:1px solid var(--line-strong);}
.donate-step-num{display:block; margin-bottom:16px; font-size:64px;}
.donate-steps h3{margin-bottom:10px; font-size:30px;}
.donate-steps p{line-height:1.8; color:var(--ink-soft);}

.donate-faq{display:grid; margin-top:8px;}
.donate-faq-item{padding:32px 0; border-top:1px solid var(--line-strong);}
.donate-faq-item:last-child{border-bottom:1px solid var(--line-strong);}
.donate-faq-item h3{margin-bottom:10px; font-size:30px;}
.donate-faq-item p{max-width:660px; line-height:1.8; color:var(--ink-soft);}

@media (max-width:860px){
  .donate-body{padding-bottom:96px;}
  .donate-card{padding:44px 22px 30px;}
  .donate-block{margin-top:72px;}
  .donate-steps{grid-template-columns:1fr;}
}
__TMSK_FILE_END__

put src/components/RazorpayButton.css << '__TMSK_FILE_END__'
.rzp-wrap{
  display:flex;
  flex-direction:column;
  align-items:center;
  gap:14px;
}
.rzp-holder{
  display:flex;
  justify-content:center;
  min-height:52px;
  width:100%;
}
.rzp-holder form{display:flex; justify-content:center; margin:0;}
.rzp-status{
  margin:0;
  font-size:13px;
  letter-spacing:0.08em;
  text-align:center;
  color:var(--ink-faint);
}
.rzp-help{
  width:100%;
  max-width:500px;
  padding:18px 20px;
  border-left:3px solid var(--red);
  background:var(--sand);
  color:var(--ink);
  font-size:15px;
  line-height:1.6;
  text-align:left;
}
.rzp-help p{margin:0 0 14px;}
.rzp-help-actions{display:flex; flex-wrap:wrap; gap:10px;}

.rzp-retry,
.rzp-fallback{
  display:inline-flex;
  align-items:center;
  min-height:44px;
  padding:11px 24px;
  border:1px solid var(--black);
  border-radius:0;
  background:var(--black);
  color:var(--white);
  font-family:var(--f-body);
  font-size:11.5px;
  font-weight:500;
  letter-spacing:0.18em;
  text-transform:uppercase;
  text-decoration:none;
  cursor:pointer;
  transition:background .4s var(--ease), border-color .4s var(--ease), color .4s var(--ease);
}
.rzp-fallback{background:transparent; color:var(--black); border-color:var(--line-strong);}
.rzp-retry:hover{background:var(--red); border-color:var(--red);}
.rzp-fallback:hover{background:var(--black); color:var(--white); border-color:var(--black);}
__TMSK_FILE_END__

put src/components/DonationBanner.css << '__TMSK_FILE_END__'
.donation-banner{
  position:fixed;
  top:var(--banner-top, 12px);
  left:50%;
  z-index:900;
  box-sizing:border-box;
  display:flex;
  align-items:center;
  gap:16px;
  width:min(600px, calc(100vw - 20px));
  padding:16px 14px 16px 20px;
  background:var(--ivory);
  border:1px solid var(--line-strong);
  border-left:3px solid var(--red);
  border-radius:0;
  box-shadow:0 22px 50px -18px rgba(20,17,14,0.35);
  transform:translate(-50%, -170%);
  opacity:0;
  visibility:hidden;
  pointer-events:none;
  transition:transform .8s var(--ease), opacity .4s ease, visibility 0s linear .8s;
}
.donation-banner.is-visible{
  transform:translate(-50%, 0);
  opacity:1;
  visibility:visible;
  pointer-events:auto;
  transition:transform .8s var(--ease), opacity .4s ease, visibility 0s;
}

.donation-banner-icon{flex-shrink:0; display:flex; color:var(--red);}

.donation-banner-text{
  flex:1;
  min-width:0;
  display:flex;
  flex-direction:column;
  gap:3px;
  font-size:14px;
  line-height:1.45;
  color:var(--ink-soft);
}
.donation-banner-text strong{
  font-family:var(--f-display);
  font-size:21px;
  font-weight:600;
  line-height:1.1;
  color:var(--black);
}

.donation-banner-cta{
  flex-shrink:0;
  display:inline-flex;
  align-items:center;
  min-height:44px;
  padding:10px 24px;
  border:1px solid var(--black);
  background:var(--black);
  color:var(--white);
  font-size:11.5px;
  font-weight:500;
  letter-spacing:0.18em;
  text-transform:uppercase;
  transition:background .4s var(--ease), border-color .4s var(--ease);
}
.donation-banner-cta:hover{background:var(--red); border-color:var(--red);}

.donation-banner-close{
  flex-shrink:0;
  width:36px; height:36px;
  border:none;
  background:transparent;
  color:var(--ink-soft);
  font-size:1.5rem;
  line-height:1;
  cursor:pointer;
  transition:color .3s ease, transform .5s var(--ease);
}
.donation-banner-close:hover{color:var(--red); transform:rotate(90deg);}

@media (max-width:480px){
  .donation-banner{gap:10px; padding:12px 6px 12px 14px;}
  .donation-banner-icon, .donation-banner-text span{display:none;}
  .donation-banner-cta{padding:10px 18px;}
}
@media (prefers-reduced-motion: reduce){
  .donation-banner, .donation-banner.is-visible{transition:none;}
}
__TMSK_FILE_END__

# =====================================================================
# make sure the site still builds
# =====================================================================
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
echo "1) Look:      npm run dev -- --host"
echo "   Check: Home (scroll all the way down), Objectives, Events, Leadership,"
echo "   Donate, and the menu on a phone-sized window."
echo "2) Keep it:   git add . && git commit -m \"Luxury redesign\" && git push"
echo "3) Undo it:   bash revert-design.sh      (only works before you push)"
echo ""
echo "Easy edits later:"
echo "   Colours and fonts:    src/index.css (top of the file)"
echo "   Home page words:      src/pages/Home.jsx"
echo "   Event dates/status:   src/data/eventStatus.js"
echo "Backups: $BACKUP_DIR"
