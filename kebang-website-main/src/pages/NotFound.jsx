import { Link } from 'react-router-dom'
import './NotFound.css'

export default function NotFound(){
  return (
    <section className="wrap not-found">
      <span className="not-found-code">404</span>
      <h1>Page not found</h1>
      <p>The page you're looking for doesn't exist, or has moved.</p>
      <Link to="/" className="btn">Back to Home</Link>
    </section>
  )
}
