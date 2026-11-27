// All text for the Projects page. Edit the words here.
// To add the Mising version of Project Do:ying, replace the empty list in doying.mising with paragraphs.

export const ui = {
  pageTitle: "Projects",
  pageIntro: "The cultural, historical and creative initiatives of Takam Mising S\u00ED:sang K\u00E9bang.",
  ongoingTitle: "Ongoing Projects",
  ongoingNote: "Projects that are active right now.",
  pastTitle: "Past Projects",
  pastNote: "Completed projects.",
  emptyPhotos: "Progress photos will appear here soon.",
  miSoon: "Mising version coming soon.",
};

export const odong = {
  name: "Odong Kinsulai",
  oldName: "Op\u00EDn Kinsulai",
  started: "26 October 2026",
  renamed: "22 November 2026",
  tagline: "An initiative for ancestral, genealogical, and cultural documentation.",
  intro: [
    "The project began on 26 October 2026 as the Op\u00EDn Kinsulai Project. It focused on documenting Mising Op\u00EDn (clans), ancestral lineages, and genealogical connections.",
    "On 22 November 2026, TMSK officially renamed it \u201COdong Kinsulai\u201D. The new name comes with a wider purpose: the project will now also document and explore the mythological genealogy that comes before Do:ni (Abotani), following the ancestral succession kept in traditional narratives and oral accounts.",
    "Odong Kinsulai aims to preserve, document, research, and explore Mising ancestral genealogies, mythological traditions, clan histories, and cultural knowledge passed down through generations, while keeping oral traditions, recorded sources, and research hypotheses clearly separate.",
  ],
  sequenceTitle: "Proposed mythological genealogical sequence",
  sequence: [
    "K\u00E9yum", "Yumkang", "Ka:si", "Siang/Siyan", "A:bo/Anbo", "Bomuk", "Mukseng",
    "Se:d\u00ED", "D\u00EDl\u00EDng", "L\u00ED:tung", "Tu:y\u00E9", "Y\u00E9p\u00E9", "P\u00E9dong", "Various descendants",
  ],
  sequenceNote: "According to this traditional account, P\u00E9dong had various descendants, among whom was Do:ni (Abotani), regarded as the youngest son of P\u00E9dong.",
  noticeUrl: "/documents/Odongkinsulaifinal.pdf",
  noticeLabel: "Read the official notice (PDF)",
  timeline: [
    { date: "26 Oct 2026", text: "Project started as Op\u00EDn Kinsulai" },
    { date: "22 Nov 2026", text: "Renamed Odong Kinsulai, with a wider scope" },
  ],
  galleryTitle: "Progress photos",
  galleryHelp: "",
};

export const doying = {
  name: "Project Do:ying",
  started: "22 November 2026",
  english: [
    "Takam Mising S\u00ED:sang K\u00E9bang (TMSK) has started a new cultural documentation project, Project Do:ying. It runs alongside the ongoing Odong Kinsulai project.",
    "Project Do:ying collects, documents, preserves, and shares the traditional folktales of the Mising people. TMSK will introduce a Folktale Submission Form, through which people can contribute folktales passed down through their families, elders, and communities.",
    "Folktales can be sent as recorded videos of storytelling, as surveys done with elders and knowledgeable people from your region, or as written submissions. Submissions are accepted in Mising, English, and Assamese.",
    "The collected folktales will be documented and published by TMSK for future generations. One of the main goals is to bring these stories to life through animations and comic adaptations, so Mising folklore is easier to enjoy for younger generations.",
    "Project Do:ying is not merely a collection of stories, but an effort to preserve the voices, imagination, wisdom, and cultural memory of the Mising people.",
  ],
  // Paste the Mising version here, one paragraph per line, inside quotes and separated by commas.
  mising: [],
  noticeUrl: "/documents/ProjectDoying.pdf",
  noticeLabel: "Read the official notice (PDF)",
  // When the Folktale Submission Form is ready, paste its link between the quotes.
  formUrl: "https://forms.gle/yEiJmx5jbE6YWwvU6",
  formLabel: "Doying Submission form",
  // YouTube links of storytelling videos, for example: "https://www.youtube.com/watch?v=XXXXXXXXXXX"
  // YouTube links for the MISING version videos.
  youtubeMising: [],
  // The list below is for the ENGLISH version videos.
  youtube: ["https://youtu.be/GJjsGS5DCZU?si=WUKfAPakpB7DzoXb"],
  photosTitle: "Photos",
  videosTitle: "Videos",
};

export const artComp = {
  name: "Project Mising Art Competition",
  started: "19 July 2026",
  ended: "13 September 2026",
  poster: "/assets/event-cover.webp",
  posterAlt: "Poster of the TMSK online visual art competition",
  paragraphs: [
    "Project Mising Art Competition began on 19 July 2026. It introduced an online visual art event for the Mising tribe, with the topic based on the Mising tribe of the Northeast.",
    "Registration ran from 10 to 31 August 2026, and artworks were submitted from 4 to 13 September 2026. The competition has ended and the prizes have been distributed. Winners also had free participation in the Creators Pop-Up Program in Pasighat.",
  ],
  prizes: ["1st \u20B91000", "2nd \u20B9500", "3rd \u20B9300"],
  prizeNote: "Prize money was subject to increase depending on the number of participants.",
  encourageTitle: "Why art matters to us",
  encourage: [
    "Every Mising pattern, every woven motif, every mural on a festival ground began as one person\u2019s imagination. Art is how our stories, our dress, our rivers and our festivals reach the eyes of the next generation.",
    "We believe every young Mising has something worth showing: a sketch in a notebook, a painting, a digital illustration, a comic panel. You do not need to be a professional. You only need to be honest about what you see and feel about our people.",
    "This competition was a first step. Keep drawing, keep painting, and keep sharing your work with us. Your art may become the animations and comics of Project Do:ying, and the faces of our culture for years to come.",
  ],
  callout: "Artists of the Mising community, we want to see your work. Stay with TMSK for the next call for art.",
};
