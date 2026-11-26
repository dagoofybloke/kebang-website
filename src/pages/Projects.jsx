import { useState, useRef } from "react";
import { odong, doying, artComp, ui } from "../data/projects.js";
import "./Projects.css";

// pj-tabs-v2
const OPTS_NOTE = "Photos and videos are read from the folders in src/assets/projects/";

const toList = (m) => Object.keys(m).sort().map((k) => m[k]);

const odongPhotos = toList(
  import.meta.glob("../assets/projects/odong-kinsulai/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}", { eager: true, query: "?url", import: "default" })
);
const doyingPhotos = toList(
  import.meta.glob("../assets/projects/doying/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}", { eager: true, query: "?url", import: "default" })
);
const doyingVideos = toList(
  import.meta.glob("../assets/projects/doying/*.{mp4,webm,mov,MP4,WEBM,MOV}", { eager: true, query: "?url", import: "default" })
);

function ytEmbed(url) {
  const m = String(url).match(/(?:v=|youtu\.be\/|embed\/|shorts\/)([A-Za-z0-9_-]{11})/);
  return m ? "https://www.youtube.com/embed/" + m[1] : null;
}

const TABS = {
  ongoing: {
    label: ui.ongoingTitle,
    note: ui.ongoingNote,
    dot: "active",
    items: [
      { id: "odong", label: "Odong Kinsulai", sub: "Started 26 Oct 2026" },
      { id: "doying", label: "Project Do:ying", sub: "Started 22 Nov 2026" },
    ],
  },
  past: {
    label: ui.pastTitle,
    note: ui.pastNote,
    dot: "past",
    items: [{ id: "art", label: "Mising Art Competition", sub: "19 Jul \u2013 13 Sep 2026" }],
  },
};

function Gallery({ photos, alt }) {
  if (!photos.length) return <p className="pj-empty">{ui.emptyPhotos}</p>;
  return (
    <div className="pj-gallery">
      {photos.map((src, i) => (
        <a key={src} href={src} target="_blank" rel="noreferrer">
          <img src={src} alt={alt + " " + (i + 1)} loading="lazy" />
        </a>
      ))}
    </div>
  );
}

function OdongPanel() {
  return (
    <article className="pj-card">
      <div className="pj-card-top">
        <h3>Project {odong.name}</h3>
        <span className="pj-badge"><span className="pj-dot pj-dot-active"></span> Active</span>
      </div>
      <p className="pj-tagline">{odong.tagline}</p>
      <p className="pj-meta">Started on {odong.started} &middot; Formerly {odong.oldName} &middot; Renamed on {odong.renamed}</p>

      <ol className="pj-timeline">
        {odong.timeline.map((t) => (
          <li key={t.date}><strong>{t.date}</strong><span>{t.text}</span></li>
        ))}
      </ol>

      {odong.intro.map((p, i) => <p key={i}>{p}</p>)}

      <h4>{odong.sequenceTitle}</h4>
      <div className="pj-sequence">
        {odong.sequence.map((n, i) => (
          <span key={n} className="pj-seq-item">
            <span className="pj-seq-name">{n}</span>
            {i < odong.sequence.length - 1 && <span className="pj-seq-arrow">&rarr;</span>}
          </span>
        ))}
      </div>
      <p className="pj-note">{odong.sequenceNote}</p>

      <a className="pj-btn" href={odong.noticeUrl} target="_blank" rel="noreferrer">{odong.noticeLabel}</a>

      <h4>{odong.galleryTitle}</h4>
      <Gallery photos={odongPhotos} alt="Odong Kinsulai progress photo" />
    </article>
  );
}

// pj-vid-split
const videosEnglish = toList(
  import.meta.glob("../assets/projects/doying/*.{mp4,webm,mov,MP4,WEBM,MOV}", { eager: true, query: "?url", import: "default" })
).concat(
  toList(import.meta.glob("../assets/projects/doying/english-videos/*.{mp4,webm,mov,MP4,WEBM,MOV}", { eager: true, query: "?url", import: "default" }))
);
const videosMising = toList(
  import.meta.glob("../assets/projects/doying/mising-videos/*.{mp4,webm,mov,MP4,WEBM,MOV}", { eager: true, query: "?url", import: "default" })
);

function VideoList({ yt, files, empty }) {
  const embeds = (yt || []).map(ytEmbed).filter(Boolean);
  return (
    <div>
      {!files.length && !embeds.length && <p className="pj-empty">{empty}</p>}
      <div className="pj-videos">
        {embeds.map((src) => (
          <div className="pj-video" key={src}>
            <iframe src={src} title="Project Do:ying video" allowFullScreen loading="lazy"></iframe>
          </div>
        ))}
        {files.map((src) => (
          <div className="pj-video" key={src}>
            <video src={src} controls preload="metadata"></video>
          </div>
        ))}
      </div>
    </div>
  );
}

function DoyingPanel() {
  return (
    <article className="pj-card">
      <div className="pj-card-top">
        <h3>{doying.name}</h3>
        <span className="pj-badge"><span className="pj-dot pj-dot-active"></span> Active</span>
      </div>
      <p className="pj-meta">Started on {doying.started}</p>

      <h4>Description</h4>
      {doying.english.map((p, i) => <p key={i}>{p}</p>)}

      <div className="pj-btn-row">
        <a className="pj-btn" href={doying.noticeUrl} target="_blank" rel="noreferrer">{doying.noticeLabel}</a>
        {doying.formUrl && (
          <a className="pj-btn pj-btn-gold" href={doying.formUrl} target="_blank" rel="noreferrer">{doying.formLabel}</a>
        )}
      </div>

      <h4>{doying.photosTitle}</h4>
      <Gallery photos={doyingPhotos} alt="Project Do:ying photo" />

      <h4>{doying.videosTitle}</h4>
      <div className="pj-bilingual">
        <div className="pj-lang">
          <span className="pj-lang-label">English version</span>
          <VideoList yt={doying.youtube} files={videosEnglish} empty="English videos will appear here soon." />
        </div>
        <div className="pj-lang">
          <span className="pj-lang-label">Mising version</span>
          <VideoList yt={doying.youtubeMising} files={videosMising} empty="Mising videos will appear here soon." />
        </div>
      </div>
    </article>
  );
}

function ArtPanel() {
  return (
    <article className="pj-card">
      <div className="pj-card-top">
        <h3>{artComp.name}</h3>
        <span className="pj-badge"><span className="pj-dot pj-dot-past"></span> Completed</span>
      </div>
      <p className="pj-meta">Started on {artComp.started} &middot; Ended on {artComp.ended}</p>

      <div className="pj-art">
        <img className="pj-poster" src={artComp.poster} alt={artComp.posterAlt} loading="lazy" />
        <div>
          {artComp.paragraphs.map((p, i) => <p key={i}>{p}</p>)}
          <div className="pj-prizes">
            {artComp.prizes.map((p) => <span key={p}>{p}</span>)}
          </div>
          <p className="pj-note">{artComp.prizeNote}</p>
        </div>
      </div>

      <h4>{artComp.encourageTitle}</h4>
      {artComp.encourage.map((p, i) => <p key={i}>{p}</p>)}
      <p className="pj-callout">{artComp.callout}</p>
    </article>
  );
}

const PANELS = { odong: OdongPanel, doying: DoyingPanel, art: ArtPanel };

export default function Projects() {
  const [tab, setTab] = useState("ongoing");
  const [pick, setPick] = useState({ ongoing: "odong", past: "art" });
  const contentRef = useRef(null);

  const current = TABS[tab];
  const activeId = pick[tab];
  const Panel = PANELS[activeId];

  function choose(id) {
    setPick((p) => ({ ...p, [tab]: id }));
    if (typeof window !== "undefined" && window.innerWidth < 800 && contentRef.current) {
      const top = contentRef.current.getBoundingClientRect().top + window.scrollY - 80;
      window.scrollTo({ top, behavior: "smooth" });
    }
  }

  return (
    <main className="pj-page">
      <header className="pj-hero">
        <div className="pj-wrap">
          <h1>{ui.pageTitle}</h1>
          <p>{ui.pageIntro}</p>
        </div>
      </header>

      <nav className="pj-bar" aria-label="Project sections">
        <div className="pj-bar-inner" role="tablist">
          {Object.keys(TABS).map((key) => (
            <button
              key={key}
              type="button"
              role="tab"
              aria-selected={tab === key}
              className={"pj-bar-link" + (tab === key ? " is-active" : "")}
              onClick={() => setTab(key)}
            >
              <span className={"pj-dot pj-dot-" + TABS[key].dot} aria-hidden="true"></span> {TABS[key].label}
            </button>
          ))}
        </div>
      </nav>

      <section className={"pj-section" + (tab === "past" ? " pj-section-alt" : "")}>
        <div className="pj-wrap">
          <div className="pj-section-head">
            <span className={"pj-dot pj-dot-" + current.dot} aria-hidden="true"></span>
            <div>
              <h2>{current.label}</h2>
              <p>{current.note}</p>
            </div>
          </div>

          <div className="pj-layout">
            <nav className="pj-side" aria-label={current.label}>
              {current.items.map((it) => (
                <button
                  key={it.id}
                  type="button"
                  className={"pj-side-item" + (activeId === it.id ? " is-active" : "")}
                  onClick={() => choose(it.id)}
                >
                  <span className={"pj-dot pj-dot-" + current.dot} aria-hidden="true"></span>
                  <span className="pj-side-text">
                    <strong>{it.label}</strong>
                    <small>{it.sub}</small>
                  </span>
                </button>
              ))}
            </nav>

            <div className="pj-content" ref={contentRef} key={tab + activeId}>
              <Panel />
            </div>
          </div>
        </div>
      </section>
    </main>
  );
}
