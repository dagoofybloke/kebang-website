import { odong, doying, artComp, ui } from "../data/projects.js";
import "./Projects.css";

const toList = (m) => Object.keys(m).sort().map((k) => m[k]);

const odongPhotos = toList(
  import.meta.glob("../assets/projects/odong-kinsulai/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}", { eager: true, query: '?url', import: 'default' })
);
const doyingPhotos = toList(
  import.meta.glob("../assets/projects/doying/*.{jpg,jpeg,png,webp,JPG,JPEG,PNG,WEBP}", { eager: true, query: '?url', import: 'default' })
);
const doyingVideos = toList(
  import.meta.glob("../assets/projects/doying/*.{mp4,webm,mov,MP4,WEBM,MOV}", { eager: true, query: '?url', import: 'default' })
);

function ytEmbed(url) {
  const m = String(url).match(/(?:v=|youtu\.be\/|embed\/|shorts\/)([A-Za-z0-9_-]{11})/);
  return m ? "https://www.youtube.com/embed/" + m[1] : null;
}

function SectionHead({ kind, title, note }) {
  return (
    <div className="pj-section-head">
      <span className={"pj-dot pj-dot-" + kind} aria-hidden="true"></span>
      <div>
        <h2>{title}</h2>
        <p>{note}</p>
      </div>
    </div>
  );
}

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

export default function Projects() {
  const ytList = doying.youtube.map(ytEmbed).filter(Boolean);
  return (
    <main className="pj-page">
      <header className="pj-hero">
        <div className="pj-wrap">
          <h1>{ui.pageTitle}</h1>
          <p>{ui.pageIntro}</p>
        </div>
      </header>

      <section className="pj-section">
        <div className="pj-wrap">
          <SectionHead kind="active" title={ui.ongoingTitle} note={ui.ongoingNote} />

          {/* ---------- Odong Kinsulai ---------- */}
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

          {/* ---------- Do:ying ---------- */}
          <article className="pj-card">
            <div className="pj-card-top">
              <h3>{doying.name}</h3>
              <span className="pj-badge"><span className="pj-dot pj-dot-active"></span> Active</span>
            </div>
            <p className="pj-meta">Started on {doying.started} &middot; Runs alongside Odong Kinsulai</p>

            <div className="pj-bilingual">
              <div className="pj-lang">
                <span className="pj-lang-label">English</span>
                {doying.english.map((p, i) => <p key={i}>{p}</p>)}
              </div>
              <div className="pj-lang">
                <span className="pj-lang-label">Mising</span>
                {doying.mising.length
                  ? doying.mising.map((p, i) => <p key={i}>{p}</p>)
                  : <p className="pj-empty">{ui.miSoon}</p>}
              </div>
            </div>

            <div className="pj-btn-row">
              <a className="pj-btn" href={doying.noticeUrl} target="_blank" rel="noreferrer">{doying.noticeLabel}</a>
              {doying.formUrl && (
                <a className="pj-btn pj-btn-gold" href={doying.formUrl} target="_blank" rel="noreferrer">{doying.formLabel}</a>
              )}
            </div>

            <h4>{doying.photosTitle}</h4>
            <Gallery photos={doyingPhotos} alt="Project Do:ying photo" />

            <h4>{doying.videosTitle}</h4>
            {!doyingVideos.length && !ytList.length && <p className="pj-empty">Videos will appear here soon.</p>}
            <div className="pj-videos">
              {ytList.map((src) => (
                <div className="pj-video" key={src}>
                  <iframe src={src} title="Project Do:ying video" allowFullScreen loading="lazy"></iframe>
                </div>
              ))}
              {doyingVideos.map((src) => (
                <div className="pj-video" key={src}>
                  <video src={src} controls preload="metadata"></video>
                </div>
              ))}
            </div>
          </article>
        </div>
      </section>

      <section className="pj-section pj-section-alt">
        <div className="pj-wrap">
          <SectionHead kind="past" title={ui.pastTitle} note={ui.pastNote} />

          {/* ---------- Art competition ---------- */}
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
        </div>
      </section>
    </main>
  );
}
