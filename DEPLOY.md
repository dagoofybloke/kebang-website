# Deploying TMSK Website to Vercel

This is a Vite + React app (static site after build). Vercel supports this out of the box.

## Option A — Deploy via Vercel website (no terminal needed)

1. Unzip this folder somewhere on your computer.
2. Push it to a GitHub repository:
   - Create a new repo on GitHub (e.g. `tmsk-website`).
   - Upload the contents of this folder to that repo (GitHub's "upload files" button works fine, or use `git`).
3. Go to https://vercel.com and sign in (you can sign in with your GitHub account).
4. Click **"Add New… → Project"**.
5. Select the `tmsk-website` repo you just created.
6. Vercel will auto-detect the framework as **Vite**. Leave the defaults:
   - Build Command: `npm run build`
   - Output Directory: `dist`
   - Install Command: `npm install`
7. Click **Deploy**.
8. Wait ~1 minute — Vercel will give you a live URL like `tmsk-website.vercel.app`.

## Option B — Deploy via Vercel CLI (if you're comfortable with a terminal)

```bash
npm install -g vercel
cd tmsk
npm install
vercel
```

Follow the prompts (log in, confirm project settings, accept the defaults shown above). Then run:

```bash
vercel --prod
```

to push it live.

## Custom domain (optional)

Once deployed, go to your project on vercel.com → **Settings → Domains** → add your domain (e.g. `tmsk.org`) and follow the DNS instructions Vercel gives you.

## Notes

- The Google Search Console verification file (`googlee250293c3bc349fc.html`) is already in the `public/` folder, so it will be served at `yourdomain.com/googlee250293c3bc349fc.html` automatically after deploy — no extra setup needed.
- The Events page is intentionally left empty for now (no events added yet). You can update `src/pages/Events.jsx` any time and redeploy — Vercel auto-redeploys on every push to your repo once connected.
- No environment variables or backend are required; this is a fully static site.
