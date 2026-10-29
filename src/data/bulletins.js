// =====================================================================
//  HOW TO POST A NEW BULLETIN
//
//  1. Find the first bulletin in the list below (it starts with "{" and
//     ends with "},").
//  2. Copy that whole block and paste it right above itself.
//  3. Change the text. Save the file (Ctrl+S). Done.
//
//  FIELDS
//    id        REQUIRED. Unique, lowercase, hyphens. Example: 'annual-meeting-2026'
//              Never use the same id twice, and do not change it later.
//    title     REQUIRED. The heading of the bulletin.
//    date      REQUIRED. Format YYYY-MM-DD. Example: '2026-10-26'
//    category  REQUIRED. Exactly one of the categories listed in bulletinCategories.
//    summary   REQUIRED. One or two lines shown in the feed.
//    body      OPTIONAL. The full text, shown when someone taps "Read more".
//              Leave a blank line between paragraphs. Do not use the ` character.
//    file      OPTIONAL. A file in public/bulletin/ (example: 'notice.pdf'). Shown as a file
//              card with Open and Download (PDF also gets a Preview button).
//    files     OPTIONAL. Several files:  files: ['a.pdf', 'b.docx'],
//    image     OPTIONAL. A picture in public/bulletin/ (example: 'poster.jpg'). Shown on the page.
//    images    OPTIONAL. Several pictures:  images: ['a.jpg', 'b.jpg'],
//    pinned    OPTIONAL. Write  pinned: true,  to keep it at the top of the page.
//
//  TIP: if your text contains an apostrophe ( ' ), wrap that text in
//  double quotes ( " ) or backticks ( ` ) instead of single quotes.
// =====================================================================

// The categories shown in the sidebar. To add a new one, add its name here
// and tell me so I can give it a color.
export const bulletinCategories = [
  'Notice',
  'Project',
  'Event',
  'Election',
  'Announcement',
  'Insights',
]

export const bulletins = [
  {
    id: 'opin-kinsulai-notification',
    title: 'Opín Kinsulai – Genealogy Project Notification',
    date: '2026-10-26',
    category: 'Project',
    pinned: false,
    summary: 'TMSK is initiating a new project, “Opín Kinsulai”, to trace, document and preserve the genealogical heritage of the Mising community.',
    body: `Notification No. TMSK/PROJECT/2026/02, dated 26 October 2026.

    TMSK is initiating a new project titled “Opín Kinsulai”, dedicated to tracing, documenting and preserving the genealogical heritage of the Mising community.

    Under this initiative, TMSK intends to establish contact and collaborate with the staff members and representatives of various Ope: Kebang to trace and document their respective clan genealogies. The project also aims to establish effective coordination among different Ope: Kebang to facilitate the exchange of genealogical information, identify missing ancestral links, and reconstruct genealogical connections that remain undocumented or require further verification.

    TMSK also intends to collaborate with Ope: Kebang, community elders, knowledgeable individuals and other relevant organisations to raise awareness about the genealogies of different Mising clans. Verified genealogical information will be shared through the TMSK page and other appropriate platforms.

    All concerned Ope: Kebang, their staff members, community elders, researchers and individuals possessing relevant genealogical knowledge are requested to extend their cooperation and support to this initiative.`,
    file: 'opin-kinsulai.pdf',
  },
]
