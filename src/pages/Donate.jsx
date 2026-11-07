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
