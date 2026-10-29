// Images go in: public/images/leadership/<term-id>/<image file>
// If an image is missing, the page shows the person's initials instead.

export const leadershipTerms = [
  {
    id: 'term-1',
    title: '1st Term',
    members: [
      { role: 'President', name: 'Sumyo Doley', image: 'sumyo-doley.jpg' },
      { role: 'Vice President', name: 'Kung Pao', image: 'kung-pao.jpg' },
      { role: 'General Secretary & Treasurer', name: 'Abhinab Pegu', image: 'abhinab-pegu.jpg' },
      { role: 'Organisational Coordinator', name: 'Maetom Patir', image: 'maetom-patir.jpg' },
    ],
  },
  {
    id: 'term-2',
    title: '2nd Term',
    members: [
      { role: 'President', name: 'Name to be added', image: 'president.jpg' },
      { role: 'Vice President', name: 'Name to be added', image: 'vice-president.jpg' },
      { role: 'General Secretary', name: 'Name to be added', image: 'general-secretary.jpg' },
      { role: 'Treasurer', name: 'Name to be added', image: 'treasurer.jpg' },
    ],
  },
];
