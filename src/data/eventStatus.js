// The Art Competition status changes by itself on these dates.
// For a new event, change the dates below (year-month-day, India time).
const REGISTRATION_CLOSES = new Date('2026-08-31T23:59:59+05:30')
const EVENT_ENDS = new Date('2026-09-13T23:59:59+05:30')

export function getEventStatus(now = new Date()) {
  if (now <= REGISTRATION_CLOSES) {
    return { key: 'open', label: 'Registration open', headline: 'Currently open', closesLabel: 'Registration closes' }
  }
  if (now <= EVENT_ENDS) {
    return { key: 'running', label: 'In progress', headline: 'In progress', closesLabel: 'Registration closed' }
  }
  return { key: 'ended', label: 'Concluded', headline: 'Recent event', closesLabel: 'Registration closed' }
}
