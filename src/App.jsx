import { Routes, Route } from 'react-router-dom'
import ScrollToTop from './components/ScrollToTop.jsx'
import Header from './components/Header.jsx'
import Footer from './components/Footer.jsx'
import EventPopup from './components/EventPopup.jsx'
import Home from './pages/Home.jsx'
import Objectives from './pages/Objectives.jsx'
import Events from './pages/Events.jsx'
import NotFound from './pages/NotFound.jsx'

export default function App(){
  return (
    <div className="app-shell">
      <ScrollToTop />
      <a href="#main-content" className="skip-link">Skip to content</a>
      <Header />
      <main id="main-content">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/objectives" element={<Objectives />} />
          <Route path="/events" element={<Events />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
      <Footer />
      <EventPopup />
    </div>
  )
}