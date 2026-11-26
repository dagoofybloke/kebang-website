#!/bin/bash
# =====================================================================
# TMSK mobile fix v2
#
# HOW TO USE (from /workspaces/kebang-website)
#   1. Put this file in the project folder
#   2. Run:   bash fix-mobile-v2.sh path/to/your-cover-image.jpg
#      (the image path is optional - see "EVENT COVER" below)
#   3. Look:  npm run dev -- --host   (check on a phone-sized window)
#   4. Happy? git add . && git commit -m "Mobile fix v2" && git push
#
# WHAT IT DOES (phones only, screens 700px and narrower)
#   Hero       : tighter spacing, smaller title/quote gaps, quieter banners,
#                fewer embers, full-width buttons, so nothing feels crowded.
#   Two portraits : they stand still (no marching / hopping) and are bigger.
#   "-- A MISING YOUTH-LED MOVEMENT" : centred, one line, dash lined up
#                with the text.
#   Events (Home + Events page) : phone-friendly cover and details.
#   EVENT COVER: the dark cover panel becomes your picture, with the tag
#                and status shown on top of it. Desktop gets it too.
#                Give the image when you run the script, OR save it as
#                public/assets/event-cover.jpg (.png / .webp also work)
#                and run the script again. If there is no image yet, the
#                old dark cover stays - nothing breaks.
#
# SAFE: backups go to /tmp/mobile-fix-v2-backup-<time>. Running it twice
# just replaces its own marked blocks. Nothing is committed or pushed.
# =====================================================================

COVER_ARG="${1:-}"

for f in src/components/HeroLegacy.css src/pages/Home.jsx src/pages/Events.jsx src/pages/Home.css src/pages/Events.css; do
  if [ ! -f "$f" ]; then
    echo "Run this from /workspaces/kebang-website ($f not found here)."
    exit 1
  fi
done

BACKUP_DIR="/tmp/mobile-fix-v2-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in src/components/HeroLegacy.css src/pages/Home.jsx src/pages/Events.jsx src/pages/Home.css src/pages/Events.css; do
  mkdir -p "$BACKUP_DIR/$(dirname "$f")"
  cp "$f" "$BACKUP_DIR/$f"
done
echo "Backups saved in: $BACKUP_DIR"

python3 - "$COVER_ARG" << 'PYEOF'
import os, re, sys, shutil, glob

cover_arg = sys.argv[1] if len(sys.argv) > 1 else ''

def read(p):
    return open(p, encoding='utf-8').read()

def write(p, s):
    os.makedirs(os.path.dirname(p) or '.', exist_ok=True)
    open(p, 'w', encoding='utf-8').write(s)

def put_block(path, name, css):
    """append a marked CSS block; if it is already there, replace it"""
    s = read(path)
    start, end = f'/* >>> {name} */', f'/* <<< {name} */'
    s = re.sub(re.escape(start) + r'.*?' + re.escape(end) + r'\n?', '', s, flags=re.S)
    s = s.rstrip('\n') + f'\n\n{start}\n{css.strip()}\n{end}\n'
    write(path, s)
    print(f'UPDATED: {path} ({name})')

# ------------------------------------------------------------------
# 1) HERO on phones: spacing, eyebrow dash, still + bigger portraits
# ------------------------------------------------------------------
HERO_CSS = r'''
@media (max-width:700px){

  /* ---- less crowded: tighter, calmer spacing ---- */
  .app-shell .hero{padding:34px 0 200px;}
  .hero .hero-inner .hero-title{margin:0 0 22px; line-height:1;}
  .hero .hero-inner .lg-root{margin:0 0 34px;}
  .hero .hero-inner .hero-quotes{max-width:100%; margin:0 auto 28px; gap:16px; padding:0 2px;}
  .hero .hero-quotes p{font-size:19px; line-height:1.45;}
  .hero .hero-quotes p::before{margin-bottom:10px;}
  .hero .hero-inner .hero-actions{width:100%; gap:12px;}
  .lg-flagstage{width:min(100%, 430px);}

  /* quieter background so the text stays easy to read */
  .lg-b-lw, .lg-b-rs{--bw:18vw; --o:0.14;}
  .lg-ember:nth-child(n+9){display:none;}

  /* ---- "-- A MISING YOUTH-LED MOVEMENT": centred, one line, dash lined up ---- */
  .hero .hero-inner .eyebrow{
    display:flex;
    align-items:center;
    justify-content:center;
    gap:10px;
    max-width:100%;
    margin:0 0 18px;
    font-size:clamp(9.5px, 2.9vw, 12px);
    letter-spacing:0.16em;
    line-height:1;
    text-align:center;
    white-space:nowrap;
  }
  .hero .hero-inner .eyebrow::before{
    width:clamp(18px, 6vw, 30px);
    flex:none;
    margin:0;
  }

  /* ---- the two portraits: standing still, and bigger ---- */
  .lg-walker{--span:0px;}
  .lg-walker--a{
    --ww:92px;
    left:4vw;
    animation:lgFade 1.4s ease 1.2s both;
  }
  .lg-walker--b{
    --ww:100px;
    right:4vw;
    animation:lgFade 1.4s ease 1.5s both;
  }
  .lg-step{animation:none; transform:none;}
}
'''
put_block('src/components/HeroLegacy.css', 'mobile-fix-v2 hero', HERO_CSS)

# ------------------------------------------------------------------
# 2) EVENT COVER: a small component + the picture's location
# ------------------------------------------------------------------
write('src/components/EventVisual.jsx', '''import { useState } from 'react'
import { EVENT_COVER } from '../data/eventCover.js'
import './EventVisual.css'

/* The event cover panel. Shows the cover picture when there is one,
   and quietly falls back to the dark panel when there is not. */
export default function EventVisual({ className = '', children }){
  const [failed, setFailed] = useState(false)
  const has = Boolean(EVENT_COVER) && !failed

  return (
    <div className={`${className}${has ? ' has-cover' : ''}`}>
      {has && (
        <>
          <img
            className="event-cover-img"
            src={EVENT_COVER}
            alt=""
            decoding="async"
            onError={() => setFailed(true)}
          />
          <span className="event-cover-shade" aria-hidden="true"></span>
        </>
      )}
      {children}
    </div>
  )
}
''')
print('CREATED: src/components/EventVisual.jsx')

write('src/components/EventVisual.css', '''/* event cover picture (used on Home and on the Events page) */
.event-preview-visual.has-cover,
.event-card-visual.has-cover{background:var(--charcoal);}

/* the decorative rings are only for the plain dark panel */
.event-preview-visual.has-cover::before,
.event-preview-visual.has-cover::after,
.event-card-visual.has-cover::before,
.event-card-visual.has-cover::after{display:none;}

.event-cover-img{
  position:absolute;
  inset:0;
  width:100%;
  height:100%;
  object-fit:cover;
  object-position:center;
  z-index:0;
}
/* soft shade so the tag and the status stay readable on any picture */
.event-cover-shade{
  position:absolute;
  inset:0;
  z-index:1;
  pointer-events:none;
  background:linear-gradient(180deg, rgba(20,17,14,0.62) 0%, rgba(20,17,14,0) 38%, rgba(20,17,14,0) 62%, rgba(20,17,14,0.58) 100%);
}
.has-cover > *:not(.event-cover-img):not(.event-cover-shade){position:relative; z-index:2;}

/* the big outlined "01" would sit on top of the picture */
.event-card-visual.has-cover .event-card-num{display:none;}

/* ---- phones and tablets: a neat picture-shaped cover ---- */
@media (max-width:900px){
  .event-preview-visual.has-cover{min-height:0; aspect-ratio:4 / 3; padding:20px;}
}
@media (max-width:980px){
  .event-card-visual.has-cover{min-height:0; aspect-ratio:4 / 3; padding:22px 20px;}
}
''')
print('CREATED: src/components/EventVisual.css')

# which picture? (given on the command line, or already in public/assets)
os.makedirs('public/assets', exist_ok=True)
cover_path = None
if cover_arg:
    if os.path.isfile(cover_arg):
        ext = os.path.splitext(cover_arg)[1].lower() or '.jpg'
        if ext == '.jpeg':
            ext = '.jpg'
        for old in glob.glob('public/assets/event-cover.*'):
            if old != f'public/assets/event-cover{ext}':
                os.remove(old)
        shutil.copy(cover_arg, f'public/assets/event-cover{ext}')
        cover_path = f'/assets/event-cover{ext}'
        print(f'COPIED : your picture -> public/assets/event-cover{ext}')
    else:
        print(f'WARNING: image "{cover_arg}" not found - cover picture not changed.')
if cover_path is None:
    found = sorted(glob.glob('public/assets/event-cover.*'))
    if found:
        cover_path = '/' + found[0].split('public/', 1)[1]
    elif os.path.isfile('src/data/eventCover.js'):
        m = re.search(r"EVENT_COVER\s*=\s*'([^']*)'", read('src/data/eventCover.js'))
        cover_path = m.group(1) if m else '/assets/event-cover.jpg'
    else:
        cover_path = '/assets/event-cover.jpg'
write('src/data/eventCover.js',
      "// Cover picture for the event cards (Home + Events page).\n"
      "// Put the image in public/assets/ and keep this path in sync.\n"
      f"export const EVENT_COVER = '{cover_path}'\n")
print(f'CREATED: src/data/eventCover.js  ({cover_path})')

# ------------------------------------------------------------------
# 3) Home.jsx + Events.jsx use the new cover panel
# ------------------------------------------------------------------
h = read('src/pages/Home.jsx')
if 'EventVisual' not in h:
    h = h.replace("import HeroLegacy from '../components/HeroLegacy.jsx'\n",
                  "import HeroLegacy from '../components/HeroLegacy.jsx'\nimport EventVisual from '../components/EventVisual.jsx'\n", 1)
    h, n1 = re.subn(r'<div className="event-preview-visual">', '<EventVisual className="event-preview-visual">', h, count=1)
    h, n2 = re.subn(r'(</span>\s*)</div>(\s*<div className="event-preview-body">)', r'\1</EventVisual>\2', h, count=1)
    if n1 and n2:
        write('src/pages/Home.jsx', h)
        print('UPDATED: src/pages/Home.jsx')
    else:
        print('WARNING: could not patch Home.jsx automatically (backup is safe).')
else:
    print('Home.jsx already patched')

e = read('src/pages/Events.jsx')
if 'EventVisual' not in e:
    e = e.replace("import Reveal from '../components/Reveal.jsx'\n",
                  "import Reveal from '../components/Reveal.jsx'\nimport EventVisual from '../components/EventVisual.jsx'\n", 1)
    e, n1 = re.subn(r'<div className="event-card-visual">', '<EventVisual className="event-card-visual">', e, count=1)
    e, n2 = re.subn(r'(</span>\s*)</div>(\s*<div className="event-card-body">)', r'\1</EventVisual>\2', e, count=1)
    if n1 and n2:
        write('src/pages/Events.jsx', e)
        print('UPDATED: src/pages/Events.jsx')
    else:
        print('WARNING: could not patch Events.jsx automatically (backup is safe).')
else:
    print('Events.jsx already patched')

# ------------------------------------------------------------------
# 4) Events on phones: tidy overview card (Home) and Events page
# ------------------------------------------------------------------
HOME_EVENTS_CSS = r'''
@media (max-width:700px){
  .events-preview{padding-top:64px; padding-bottom:72px;}
  .events-preview .section-head{margin-bottom:32px;}
  .event-preview-visual{min-height:170px; padding:20px;}
  .event-preview-tag{font-size:10px; letter-spacing:0.2em; line-height:1.5;}
  .event-preview-visual .status-pill{font-size:10px; letter-spacing:0.18em;}
  .event-preview-body{padding:26px 20px 28px; gap:18px;}
  .event-preview-body h3{font-size:30px;}
  .event-preview-body p{font-size:16px; line-height:1.7;}
  .event-preview-meta{grid-template-columns:1fr 1fr; gap:16px 12px; padding:18px 0;}
  .event-preview-meta div:first-child{grid-column:1 / -1;}
  .event-preview-meta span{font-size:10px; letter-spacing:0.14em;}
  .event-preview-meta strong{font-size:23px;}
  .event-preview-body .btn{align-self:stretch; width:100%;}
}
'''
put_block('src/pages/Home.css', 'mobile-fix-v2 events', HOME_EVENTS_CSS)

EVENTS_PAGE_CSS = r'''
@media (max-width:700px){
  .event-card-visual{padding:22px 20px;}
  .event-card-tag{font-size:10px; letter-spacing:0.2em; line-height:1.5;}
  .event-card-body{padding:28px 20px 28px; gap:22px;}
  .event-blurb{font-size:16px; line-height:1.7;}
  .event-detail-value{font-size:22px;}
  .prize-pill{padding:18px 6px;}
  .event-note{font-size:18px;}
  .event-actions{flex-direction:column; align-items:stretch; gap:14px;}
  .event-actions .btn{width:100%;}
  .event-credit{text-align:center;}
}
'''
put_block('src/pages/Events.css', 'mobile-fix-v2 events page', EVENTS_PAGE_CSS)
PYEOF

echo ""
echo "Done. Now run:  npm run dev -- --host   and open it on a phone-sized window."
if [ ! -f public/assets/event-cover.jpg ] && [ ! -f public/assets/event-cover.png ] && [ ! -f public/assets/event-cover.webp ]; then
  echo ""
  echo "NOTE: no event cover picture yet. To use yours, run:"
  echo "      bash fix-mobile-v2.sh path/to/your-image.jpg"
fi
