import useInView from '../hooks/useInView.js'

/**
 * Wraps children in a fade/rise-on-scroll animation.
 * Usage: <Reveal delay={100}><h2>Title</h2></Reveal>
 */
export default function Reveal({ children, as: Tag = 'div', delay = 0, className = '', ...rest }){
  const [ref, inView] = useInView()

  return (
    <Tag
      ref={ref}
      className={`reveal ${inView ? 'is-visible' : ''} ${className}`}
      style={{ transitionDelay: inView ? `${delay}ms` : '0ms' }}
      {...rest}
    >
      {children}
    </Tag>
  )
}
