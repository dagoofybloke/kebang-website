import { useEffect } from 'react'
import { Routes, Route, useLocation } from 'react-router-dom'
import ScrollToTop from './components/ScrollToTop.jsx'
import Header from './components/Header.jsx'
import Footer from './components/Footer.jsx'
import Home from './pages/Home.jsx'
import Objectives from './pages/Objectives.jsx'
import Events from './pages/Events.jsx'
import Leadership from './pages/Leadership.jsx'
import NotFound from './pages/NotFound.jsx'
import Donate from './pages/Donate.jsx'
import DonationBanner from './components/DonationBanner.jsx'
import Projects from "./pages/Projects";

export default function App(){
  const location = useLocation()

  useEffect(() => {
    const link = document.querySelector('link[rel="canonical"]')
    if (link) {
      link.setAttribute('href', `https://sisangkebang.in${location.pathname}`)
    }
  }, [location.pathname])

  return (
    <div className="app-shell">
      <ScrollToTop />
      <Header />
      <main>
        <div className="page-fade" key={location.pathname}>
          <Routes location={location}>
            <Route path="/" element={<Home />} />
            <Route path="/objectives" element={<Objectives />} />
            <Route path="/events" element={<Events />} />
            <Route path="/projects" element={<Projects />} />
            <Route path="/leadership" element={<Leadership />} />
            <Route path="/donate" element={<Donate />} />
            <Route path="*" element={<NotFound />} />
          </Routes>
        </div>
      </main>
      <Footer />
      <DonationBanner />
    </div>
  )
}
