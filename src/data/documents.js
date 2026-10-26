// HOW TO ADD A DOCUMENT
// Easiest: run   bash scripts/add-document.sh
// By hand:
// 1. Put the file (PDF, DOCX, etc.) in: public/documents/<section id>/
// 2. Add a line to that section's "documents" list below, for example:
//    { title: 'Election Notice 2026', file: 'election-notice-2026.pdf', date: '2026-10-01' },
// The file name must match exactly (it is case-sensitive). "date" is optional (YYYY-MM-DD).

export const documentSections = [
  {
    id: 'election',
    title: 'Election Documents',
    description: 'Notices, schedules, nomination forms and results related to TMSK elections.',
    documents: [],
  },
  {
    id: 'administrative',
    title: 'Administration-related Documents',
    description: 'Letters, circulars, resolutions and other administrative records.',
    documents: [],
  },
  {
    id: 'funds',
    title: 'Use of Funds',
    description: 'Financial statements, fund records and related reports.',
    documents: [],
  },
  {
    id: 'projects',
    title: 'Projects',
    description: 'Proposals, plans and reports for TMSK projects.',
        documents: [
      { title: 'Opín Kinsulai – Project Notification', file: 'opin-kinsulai.pdf', date: '2026-10-26' },
    ],
  },
  {
    id: 'events',
    title: 'Events',
    description: 'Event notices, guidelines, forms and reports.',
    documents: [],
  },
  {
    id: 'organisational',
    title: 'Organisational Documents',
    description: 'Constitution, bylaws, registration and other core organisational papers.',
    documents: [],
  },
];
