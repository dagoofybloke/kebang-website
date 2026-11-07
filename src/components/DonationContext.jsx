import { createContext, useCallback, useContext, useMemo, useState } from 'react'

const DonationContext = createContext(null)

export function DonationProvider({ children }) {
  const [open, setOpen] = useState(false)
  const openDonation = useCallback(() => setOpen(true), [])
  const closeDonation = useCallback(() => setOpen(false), [])
  const value = useMemo(
    () => ({ open, openDonation, closeDonation }),
    [open, openDonation, closeDonation],
  )
  return <DonationContext.Provider value={value}>{children}</DonationContext.Provider>
}

export function useDonation() {
  const ctx = useContext(DonationContext)
  if (!ctx) throw new Error('useDonation must be used inside DonationProvider')
  return ctx
}
