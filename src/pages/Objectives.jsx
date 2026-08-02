import Reveal from '../components/Reveal.jsx'
import './Objectives.css'

const OBJECTIVES = [
  {
    n: '01',
    title: 'De-Mipakification of Mising Culture',
    body: `We will work towards removing non-Mising elements that have entered our
    culture over time and encourage new ideas that align with our authentic
    Mising identity, traditions, and values.`,
  },
  {
    n: '02',
    title: "Voice for Mising People's Development",
    body: `We will become a strong voice for the development, progress, and
    well-being of the Mising people, addressing issues that affect our
    community and working towards sustainable growth.`,
  },
  {
    n: '03',
    title: 'Documentation and Research of Mising Heritage',
    body: `We will work towards documenting and preserving Mising heritage
    through digitalisation. This includes preserving our books, oral
    traditions, folktales, genealogy, history, cultural practices, and other
    important aspects of Mising identity. We will also support the
    development of digital platforms and resources dedicated to the Mising
    tribe.`,
  },
  {
    n: '04',
    title: 'Encouragement of Mising Agom',
    body: `Many Misings who migrate to cities gradually lose connection with
    their mother tongue. This is not the fault of individuals but a result of
    the environment and systems they live in. We will work to strengthen the
    use and preservation of Mising Agom among younger generations. If given
    the opportunity to represent our people, we will also raise our voice for
    the inclusion of Mising language in the 8th Schedule of the Indian
    Constitution.`,
  },
  {
    n: '05',
    title: 'Preservation of Authentic Donyi-Poloism',
    body: `We will work towards preserving the original essence of
    Donyi-Poloism by identifying and removing external religious influences
    and modifications that do not belong to its traditional Tani roots.`,
  },
  {
    n: '06',
    title: 'Cultural Exchange with Other Tani Groups',
    body: `We will encourage cultural exchange and stronger connections
    between Misings and other Tani communities to preserve shared ancestry,
    traditions, and knowledge.`,
  },
  {
    n: '07',
    title: 'Raising Unanswered Questions for the Mising People',
    body: `We will bring forward unanswered questions, concerns, and issues of
    the Mising people and seek accountability and solutions from the
    concerned authorities.`,
  },
]

export default function Objectives(){
  return (
    <>
      <header className="page-head wrap">
        <Reveal as="span" className="eyebrow">What we stand for</Reveal>
        <Reveal as="h1" delay={80}>
          7 Golden Points<br />of TMSK
        </Reveal>
        <Reveal as="p" delay={160} className="page-head-lede">
          Each objective below is a standing commitment — not a slogan.
          Together they define what TMSK works towards, and what we hold
          ourselves accountable to.
        </Reveal>
      </header>

      <section className="wrap obj-list">
        {OBJECTIVES.map((o, i) => (
          <Reveal as="article" delay={Math.min(i * 60, 240)} className="obj-item" key={o.n}>
            <span className="ghost-num obj-num">{o.n}</span>
            <div className="obj-body">
              <h3>{o.title}</h3>
              <p>{o.body}</p>
            </div>
          </Reveal>
        ))}
      </section>
    </>
  )
}
