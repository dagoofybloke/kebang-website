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
