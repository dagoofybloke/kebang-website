#!/bin/bash
# =====================================================================
# TMSK mobile + footer fix
#
# HOW TO USE (from /workspaces/kebang-website)
#   1. Put this file in the project folder
#   2. Run:   bash fix-mobile.sh
#   3. Look:  npm run dev -- --host   (check on a phone-sized window)
#   4. Happy? git add . && git commit -m "Mobile + footer fix" && git push
#
# WHAT IT FIXES
#   Root cause : the .wrap rule set padding to "0 24px" on phones, which also
#                wiped the TOP and BOTTOM padding of the footer sections (and
#                any other section that uses .wrap). Now only left/right are set.
#   Footer     : space between the name/logo and the line above it, email and
#                Instagram sit a little higher, space between Instagram and the
#                line below, space under the line before the copyright text.
#   Mobile nav : tidy numbered list with dividers and arrows, Join button and
#                name pinned at the bottom, fits short screens, scrolls if needed.
#   Header     : long name wraps instead of overflowing on small phones.
#   Footer on phones: buttons stack full width, links in two columns.
#
# SAFE: it only edits index.css and APPENDS a marked block to Header.css and
# Footer.css (running it twice just replaces that block). Backups go to
# /tmp/mobile-fix-backup-<time>. Nothing is committed or pushed.
# =====================================================================

if [ ! -f src/index.css ] || [ ! -f src/components/Header.css ] || [ ! -f src/components/Footer.css ]; then
  echo "Run this from /workspaces/kebang-website (src/index.css etc. not found here)."
  exit 1
fi

BACKUP_DIR="/tmp/mobile-fix-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
for f in src/index.css src/components/Header.css src/components/Footer.css; do
  mkdir -p "$BACKUP_DIR/$(dirname "$f")"
  cp "$f" "$BACKUP_DIR/$f"
done
echo "Backups saved in: $BACKUP_DIR"

restore_all() {
  echo "Restoring your files from the backup..."
  for f in src/index.css src/components/Header.css src/components/Footer.css; do
    cp "$BACKUP_DIR/$f" "$f"
  done
}

# ---------------------------------------------------------------------
# 1) index.css : .wrap must only set left/right padding
# ---------------------------------------------------------------------
python3 - << 'PYWRAP'
import re
p = 'src/index.css'
s = open(p, encoding='utf-8').read()
a = s
s = re.sub(r'(\.wrap\{[^}]*?)padding:0 48px;', r'\1padding-left:48px; padding-right:48px;', s, count=1)
s = re.sub(r'(@media \(max-width:860px\)\{\s*\.wrap\{)padding:0 24px;', r'\1padding-left:24px; padding-right:24px;', s, count=1)
open(p, 'w', encoding='utf-8').write(s)
print('UPDATED: src/index.css (.wrap no longer wipes top/bottom padding)' if s != a else 'index.css: .wrap already fixed')
PYWRAP

# ---------------------------------------------------------------------
# helper: replace (or add) the marked block at the end of a CSS file
# ---------------------------------------------------------------------
apply_block() {
  FILE="$1" BLOCK_FILE="$2" python3 - << 'PYBLOCK'
import os, re
p = os.environ['FILE']
block = open(os.environ['BLOCK_FILE'], encoding='utf-8').read()
s = open(p, encoding='utf-8').read()
s = re.sub(r'\n*/\* TMSK-MOBILE-FIX:START \*/.*?/\* TMSK-MOBILE-FIX:END \*/\n*', '\n', s, flags=re.S)
s = s.rstrip() + '\n\n' + block.strip() + '\n'
open(p, 'w', encoding='utf-8').write(s)
print('UPDATED: ' + p)
PYBLOCK
}

# ---------------------------------------------------------------------
# 2) Header.css : mobile header + navigation menu
# ---------------------------------------------------------------------
HDR_BLOCK="$(mktemp)"
cat > "$HDR_BLOCK" << '__TMSK_FILE_END__'
/* TMSK-MOBILE-FIX:START */
@media (max-width:1180px){
  .mobile-menu{
    height:100vh;
    height:100dvh;
    justify-content:flex-start;
    padding:104px 24px calc(28px + env(safe-area-inset-bottom, 0px));
    overscroll-behavior:contain;
    -webkit-overflow-scrolling:touch;
  }
  .mobile-menu nav{
    counter-reset:mnav;
    gap:0;
    margin-bottom:32px;
    border-top:1px solid var(--line);
  }
  .mobile-menu nav a{
    counter-increment:mnav;
    display:flex;
    align-items:baseline;
    gap:16px;
    padding:18px 2px;
    border-bottom:1px solid var(--line);
    font-size:clamp(28px, 8vw, 38px);
    line-height:1.1;
  }
  .mobile-menu nav a::before{
    content:"0" counter(mnav);
    min-width:26px;
    font-family:var(--f-body);
    font-size:11px;
    font-style:normal;
    font-weight:500;
    letter-spacing:0.2em;
    color:var(--gold);
  }
  .mobile-menu nav a::after{
    content:"\2192";
    margin-left:auto;
    font-family:var(--f-body);
    font-size:18px;
    font-style:normal;
    color:var(--ink-faint);
  }
  .mobile-menu nav a.is-active::after{color:var(--red);}
  .mobile-foot{
    margin-top:auto;
    padding-top:0;
    border-top:0;
    text-align:center;
  }
  .mobile-cta{width:100%; padding:16px 24px;}
  .mobile-foot p{margin-top:18px; font-size:10px; letter-spacing:0.22em;}
}

@media (max-width:480px){
  .header-inner{padding:0 16px; gap:8px;}
  .brand{min-width:0; gap:10px;}
  .brand-text{min-width:0;}
  .brand-abbr{font-size:22px;}
  .brand-full{
    white-space:normal;
    margin-top:5px;
    font-size:7.5px;
    line-height:1.35;
    letter-spacing:0.14em;
  }
}

@media (max-height:620px) and (max-width:1180px){
  .mobile-menu{padding-top:88px;}
  .mobile-menu nav a{padding:12px 2px; font-size:26px;}
  .mobile-menu nav{margin-bottom:20px;}
}
/* TMSK-MOBILE-FIX:END */
__TMSK_FILE_END__
apply_block src/components/Header.css "$HDR_BLOCK"
rm -f "$HDR_BLOCK"

# ---------------------------------------------------------------------
# 3) Footer.css : spacing + mobile structure
#    (".site-footer" prefix makes these win over .wrap regardless of order)
# ---------------------------------------------------------------------
FTR_BLOCK="$(mktemp)"
cat > "$FTR_BLOCK" << '__TMSK_FILE_END__'
/* TMSK-MOBILE-FIX:START */
.site-footer .footer-cta{padding-top:140px; padding-bottom:110px;}
.site-footer .footer-inner{padding-top:72px; padding-bottom:64px;}
.site-footer .footer-bottom{padding-top:32px; padding-bottom:40px;}

@media (max-width:900px){
  .site-footer .footer-cta{padding-top:88px; padding-bottom:72px;}
  .site-footer .footer-inner{gap:36px; padding-top:56px; padding-bottom:52px;}
  .site-footer .footer-bottom{
    flex-direction:column;
    gap:8px;
    padding-top:28px;
    padding-bottom:calc(36px + env(safe-area-inset-bottom, 0px));
    line-height:1.6;
  }
  .footer-brand{gap:14px;}
  .footer-name{font-size:22px;}
  .footer-col-label{margin-bottom:14px;}
  .footer-nav{
    display:grid;
    grid-template-columns:1fr 1fr;
    gap:10px 24px;
  }
  .footer-nav .footer-col-label{grid-column:1 / -1; margin-bottom:6px;}
  .footer-contact{gap:20px;}
}

@media (max-width:480px){
  .site-footer .footer-cta-actions{
    flex-direction:column;
    align-items:stretch;
    width:100%;
    max-width:320px;
    gap:12px;
    margin-top:36px;
  }
  .site-footer .footer-cta-actions .btn{width:100%;}
}
/* TMSK-MOBILE-FIX:END */
__TMSK_FILE_END__
apply_block src/components/Footer.css "$FTR_BLOCK"
rm -f "$FTR_BLOCK"

# ---------------------------------------------------------------------
# 4) make sure the site still builds
# ---------------------------------------------------------------------
if [ -d node_modules ] && grep -q '"build"' package.json 2>/dev/null; then
  echo ""
  echo "Checking that the site builds..."
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
echo "1) Look:  npm run dev -- --host   (shrink the window or open on your phone)"
echo "   Check: footer spacing, the 2-line menu button, and every page on mobile."
echo "2) Keep:  git add . && git commit -m \"Mobile + footer fix\" && git push"
echo "3) Undo:  restore the 3 files from $BACKUP_DIR"
