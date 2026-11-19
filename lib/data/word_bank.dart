// Intellectual property of Strauch Development. All rights reserved.
import '../models/word.dart';

/// (word, pronunciation, part of speech, definition, example)
typedef _Entry = (String, String, String, String, String);

/// Every word the app can teach, grouped by category and difficulty.
///
/// @invariant: Each category/difficulty pair has at least one word, so any
/// non-empty selection of categories and difficulties yields a non-empty pool.
final List<Word> wordBank = List.unmodifiable([
  ..._group(WordCategory.everyday, Difficulty.practical, _everydayPractical),
  ..._group(WordCategory.everyday, Difficulty.intermediate, _everydayIntermediate),
  ..._group(WordCategory.everyday, Difficulty.niche, _everydayNiche),
  ..._group(WordCategory.work, Difficulty.practical, _workPractical),
  ..._group(WordCategory.work, Difficulty.intermediate, _workIntermediate),
  ..._group(WordCategory.work, Difficulty.niche, _workNiche),
  ..._group(WordCategory.academic, Difficulty.practical, _academicPractical),
  ..._group(WordCategory.academic, Difficulty.intermediate, _academicIntermediate),
  ..._group(WordCategory.academic, Difficulty.niche, _academicNiche),
  ..._group(WordCategory.science, Difficulty.practical, _sciencePractical),
  ..._group(WordCategory.science, Difficulty.intermediate, _scienceIntermediate),
  ..._group(WordCategory.science, Difficulty.niche, _scienceNiche),
  ..._group(WordCategory.arts, Difficulty.practical, _artsPractical),
  ..._group(WordCategory.arts, Difficulty.intermediate, _artsIntermediate),
  ..._group(WordCategory.arts, Difficulty.niche, _artsNiche),
  ..._group(WordCategory.emotion, Difficulty.practical, _emotionPractical),
  ..._group(WordCategory.emotion, Difficulty.intermediate, _emotionIntermediate),
  ..._group(WordCategory.emotion, Difficulty.niche, _emotionNiche),
  ..._group(WordCategory.travel, Difficulty.practical, _travelPractical),
  ..._group(WordCategory.travel, Difficulty.intermediate, _travelIntermediate),
  ..._group(WordCategory.travel, Difficulty.niche, _travelNiche),
]);

Iterable<Word> _group(
  WordCategory category,
  Difficulty difficulty,
  List<_Entry> entries,
) => entries.map(
  (e) => Word(
    word: e.$1,
    pronunciation: e.$2,
    partOfSpeech: e.$3,
    definition: e.$4,
    example: e.$5,
    category: category,
    difficulty: difficulty,
  ),
);

// ---------------------------------------------------------------------------
// Everyday Life
// ---------------------------------------------------------------------------

const List<_Entry> _everydayPractical = [
  ('Procrastinate', 'proh-KRAS-tuh-nayt', 'verb',
      'To delay or put off doing something.',
      'I always procrastinate on laundry until I run out of socks.'),
  ('Chore', 'chor', 'noun',
      'A routine task, especially a household one.',
      'Washing the dishes is my least favorite chore.'),
  ('Errand', 'AIR-uhnd', 'noun',
      'A short trip to do a task, such as buying or collecting something.',
      'She ran a few errands before lunch.'),
  ('Tidy', 'TY-dee', 'adjective',
      'Neat and well arranged.',
      'He keeps his desk surprisingly tidy.'),
  ('Commute', 'kuh-MYOOT', 'noun',
      'The regular journey between home and work.',
      'Her commute takes forty minutes by train.'),
  ('Leftovers', 'LEFT-oh-verz', 'noun',
      'Food remaining after a meal, often eaten later.',
      'We had last night\'s leftovers for lunch.'),
];

const List<_Entry> _everydayIntermediate = [
  ('Frugal', 'FROO-guhl', 'adjective',
      'Careful and economical with money or resources.',
      'Living frugally helped them save for a house.'),
  ('Mundane', 'mun-DAYN', 'adjective',
      'Ordinary and lacking excitement.',
      'Even mundane tasks feel lighter with music on.'),
  ('Clutter', 'KLUT-er', 'noun',
      'An untidy collection of things lying about.',
      'The garage was full of clutter from the move.'),
  ('Punctual', 'PUNGK-choo-uhl', 'adjective',
      'Arriving or doing something at the agreed time.',
      'Be punctual — the tour leaves at nine sharp.'),
  ('Haphazard', 'hap-HAZ-erd', 'adjective',
      'Lacking order or planning; random.',
      'Books were stacked in a haphazard pile by the bed.'),
  ('Replenish', 'rih-PLEN-ish', 'verb',
      'To fill something up again.',
      'Remember to replenish the coffee supply.'),
];

const List<_Entry> _everydayNiche = [
  ('Quotidian', 'kwoh-TID-ee-uhn', 'adjective',
      'Of or occurring every day; ordinary.',
      'She found quiet beauty in quotidian routines.'),
  ('Hygge', 'HOO-guh', 'noun',
      'A cosy feeling of comfort and contentment (from Danish).',
      'Candles and blankets gave the cabin a sense of hygge.'),
  ('Kerfuffle', 'ker-FUF-uhl', 'noun',
      'A commotion or fuss, especially over a minor matter.',
      'There was a kerfuffle over who got the last slice.'),
  ('Lollygag', 'LOL-ee-gag', 'verb',
      'To spend time aimlessly; to dawdle.',
      'Stop lollygagging and grab your coat.'),
  ('Fug', 'fug', 'noun',
      'A warm, stuffy atmosphere in a crowded or closed room.',
      'The kitchen was a fug of steam and garlic.'),
  ('Slugabed', 'SLUG-uh-bed', 'noun',
      'A lazy person who stays in bed late.',
      'On Sundays I am an unapologetic slugabed.'),
];

// ---------------------------------------------------------------------------
// Business & Work
// ---------------------------------------------------------------------------

const List<_Entry> _workPractical = [
  ('Deadline', 'DED-lyne', 'noun',
      'The latest time by which something must be finished.',
      'The report deadline is Friday at noon.'),
  ('Agenda', 'uh-JEN-duh', 'noun',
      'A list of items to be discussed at a meeting.',
      'Let\'s stick to the agenda and finish on time.'),
  ('Colleague', 'KOL-eeg', 'noun',
      'A person you work with.',
      'A colleague kindly covered my shift.'),
  ('Delegate', 'DEL-ih-gayt', 'verb',
      'To give a task or responsibility to someone else.',
      'Good managers know when to delegate.'),
  ('Negotiate', 'nih-GOH-shee-ayt', 'verb',
      'To discuss something in order to reach an agreement.',
      'She negotiated a higher starting salary.'),
  ('Feedback', 'FEED-bak', 'noun',
      'Comments about how well someone has done something.',
      'Thanks for the honest, helpful feedback.'),
];

const List<_Entry> _workIntermediate = [
  ('Leverage', 'LEV-er-ij', 'verb',
      'To use something to its maximum advantage.',
      'We can leverage our existing customer base.'),
  ('Stakeholder', 'STAYK-hohl-der', 'noun',
      'A person with an interest or concern in a project or business.',
      'All stakeholders were invited to the review.'),
  ('Incentive', 'in-SEN-tiv', 'noun',
      'Something that motivates or encourages action.',
      'The bonus is an incentive to hit our targets.'),
  ('Synergy', 'SIN-er-jee', 'noun',
      'Combined effort that produces a greater result than the parts alone.',
      'The two teams found real synergy on the launch.'),
  ('Mitigate', 'MIT-ih-gayt', 'verb',
      'To make something less severe or serious.',
      'Regular backups mitigate the risk of data loss.'),
  ('Viable', 'VY-uh-buhl', 'adjective',
      'Capable of working successfully; feasible.',
      'Is this a viable business plan?'),
];

const List<_Entry> _workNiche = [
  ('Sinecure', 'SY-nih-kyoor', 'noun',
      'A position requiring little work but giving pay or status.',
      'His board seat was little more than a sinecure.'),
  ('Remuneration', 'rih-myoo-nuh-RAY-shuhn', 'noun',
      'Money paid for work or a service.',
      'Remuneration is reviewed every January.'),
  ('Emolument', 'ih-MOL-yuh-muhnt', 'noun',
      'A salary, fee or benefit from employment or office.',
      'The role\'s emoluments included a company car.'),
  ('Sedulous', 'SEJ-uh-luhs', 'adjective',
      'Showing dedication and diligence.',
      'A sedulous researcher, she checked every source twice.'),
  ('Factotum', 'fak-TOH-tuhm', 'noun',
      'An employee who does all kinds of work.',
      'He was the office factotum, fixing printers and booking travel.'),
  ('Pettifogging', 'PET-ee-fog-ing', 'adjective',
      'Placing undue emphasis on petty details.',
      'The meeting stalled over pettifogging objections.'),
];

// ---------------------------------------------------------------------------
// Academic & Ideas
// ---------------------------------------------------------------------------

const List<_Entry> _academicPractical = [
  ('Hypothesis', 'hy-POTH-uh-sis', 'noun',
      'A proposed explanation that can be tested.',
      'Her hypothesis was supported by the data.'),
  ('Analyze', 'AN-uh-lyze', 'verb',
      'To examine something in detail to understand it.',
      'We analyzed the survey results over coffee.'),
  ('Evidence', 'EV-ih-duhns', 'noun',
      'Facts or information showing whether something is true.',
      'There is little evidence to support that claim.'),
  ('Summarize', 'SUM-uh-ryze', 'verb',
      'To give a brief statement of the main points.',
      'Can you summarize the chapter in two sentences?'),
  ('Concept', 'KON-sept', 'noun',
      'An abstract idea or general notion.',
      'The concept of zero changed mathematics forever.'),
  ('Perspective', 'per-SPEK-tiv', 'noun',
      'A particular way of viewing or thinking about things.',
      'Travel gave him a fresh perspective on home.'),
];

const List<_Entry> _academicIntermediate = [
  ('Paradigm', 'PAIR-uh-dym', 'noun',
      'A typical model or pattern; a framework of ideas.',
      'The discovery triggered a paradigm shift in physics.'),
  ('Empirical', 'em-PEER-ih-kuhl', 'adjective',
      'Based on observation or experience rather than theory.',
      'We need empirical evidence, not just intuition.'),
  ('Nuance', 'NOO-ahns', 'noun',
      'A subtle difference in meaning, expression or tone.',
      'Translation often loses the nuance of the original.'),
  ('Pragmatic', 'prag-MAT-ik', 'adjective',
      'Dealing with things sensibly and realistically.',
      'She took a pragmatic approach to the budget.'),
  ('Ambiguous', 'am-BIG-yoo-uhs', 'adjective',
      'Open to more than one interpretation.',
      'The ending of the film is deliberately ambiguous.'),
  ('Corroborate', 'kuh-ROB-uh-rayt', 'verb',
      'To confirm or give support to a statement or theory.',
      'Two witnesses corroborated her account.'),
];

const List<_Entry> _academicNiche = [
  ('Epistemology', 'ih-pis-tuh-MOL-uh-jee', 'noun',
      'The branch of philosophy concerned with the nature of knowledge.',
      'Epistemology asks how we can know anything at all.'),
  ('Sesquipedalian', 'ses-kwih-pih-DAY-lee-uhn', 'adjective',
      'Characterized by long words; long-winded.',
      'His sesquipedalian lectures sent students reaching for dictionaries.'),
  ('Heuristic', 'hyoo-RIS-tik', 'noun',
      'A rule of thumb that helps solve problems quickly.',
      '"Measure twice, cut once" is a useful heuristic.'),
  ('Tendentious', 'ten-DEN-shuhs', 'adjective',
      'Promoting a particular cause or point of view; biased.',
      'The pamphlet offered a tendentious reading of history.'),
  ('Apophasis', 'uh-POF-uh-sis', 'noun',
      'Raising a subject by claiming you will not mention it.',
      '"I won\'t mention his lateness" is a classic apophasis.'),
  ('Sophistry', 'SOF-uh-stree', 'noun',
      'Clever but false or misleading argument.',
      'Beneath the eloquence, his case was pure sophistry.'),
];

// ---------------------------------------------------------------------------
// Science & Nature
// ---------------------------------------------------------------------------

const List<_Entry> _sciencePractical = [
  ('Habitat', 'HAB-ih-tat', 'noun',
      'The natural home of an animal or plant.',
      'Wetlands are a vital habitat for migrating birds.'),
  ('Erosion', 'ih-ROH-zhuhn', 'noun',
      'The gradual wearing away of land by wind or water.',
      'Coastal erosion has claimed several cliffside homes.'),
  ('Organism', 'OR-guh-niz-uhm', 'noun',
      'An individual living thing.',
      'Even a single drop of pond water holds countless organisms.'),
  ('Climate', 'KLY-mit', 'noun',
      'The typical weather conditions of a region over a long period.',
      'Olives thrive in a Mediterranean climate.'),
  ('Evaporate', 'ih-VAP-uh-rayt', 'verb',
      'To turn from liquid into vapor.',
      'The puddles evaporated within an hour of sunshine.'),
  ('Species', 'SPEE-sheez', 'noun',
      'A group of similar living things that can breed together.',
      'Scientists discover new species every year.'),
];

const List<_Entry> _scienceIntermediate = [
  ('Symbiosis', 'sim-bee-OH-sis', 'noun',
      'A close relationship between two different organisms, often benefiting both.',
      'Clownfish and anemones live in symbiosis.'),
  ('Photosynthesis', 'foh-toh-SIN-thuh-sis', 'noun',
      'The process by which plants use sunlight to make food from carbon dioxide and water.',
      'Photosynthesis releases the oxygen we breathe.'),
  ('Catalyst', 'KAT-uh-list', 'noun',
      'A substance that speeds up a reaction without being used up; anything that sparks change.',
      'The protest became a catalyst for reform.'),
  ('Dormant', 'DOR-muhnt', 'adjective',
      'Temporarily inactive, as if asleep.',
      'The volcano has been dormant for centuries.'),
  ('Nocturnal', 'nok-TER-nuhl', 'adjective',
      'Active at night.',
      'Owls and hedgehogs are nocturnal.'),
  ('Biodiversity', 'by-oh-dih-VER-sih-tee', 'noun',
      'The variety of life in a particular habitat or in the world.',
      'Coral reefs are hotspots of biodiversity.'),
];

const List<_Entry> _scienceNiche = [
  ('Petrichor', 'PET-rih-kor', 'noun',
      'The earthy scent produced when rain falls on dry soil.',
      'After the storm, the garden was heavy with petrichor.'),
  ('Crepuscular', 'krih-PUS-kyuh-ler', 'adjective',
      'Relating to twilight; (of animals) active at dawn and dusk.',
      'Deer are crepuscular, grazing in the half-light.'),
  ('Susurrus', 'soo-SUR-uhs', 'noun',
      'A soft whispering or rustling sound.',
      'We fell asleep to the susurrus of the pines.'),
  ('Komorebi', 'koh-moh-REH-bee', 'noun',
      'Sunlight filtering through the leaves of trees (from Japanese).',
      'The forest path glowed with komorebi.'),
  ('Apricity', 'uh-PRIS-ih-tee', 'noun',
      'The warmth of the sun in winter.',
      'We sat on the bench, soaking up the apricity.'),
  ('Sastrugi', 'sa-STROO-gee', 'noun',
      'Wave-like ridges of hard snow formed by the wind.',
      'The sled bounced across the frozen sastrugi.'),
];

// ---------------------------------------------------------------------------
// Arts & Literature
// ---------------------------------------------------------------------------

const List<_Entry> _artsPractical = [
  ('Metaphor', 'MET-uh-for', 'noun',
      'A figure of speech describing something as if it were something else.',
      '"Time is a thief" is a familiar metaphor.'),
  ('Narrator', 'NAIR-ay-ter', 'noun',
      'The person who tells a story.',
      'The narrator turns out to be unreliable.'),
  ('Genre', 'ZHAHN-ruh', 'noun',
      'A category of art, music or literature.',
      'Mystery is my favorite genre to read on holiday.'),
  ('Sketch', 'skech', 'noun',
      'A rough or unfinished drawing.',
      'She made a quick sketch of the harbor.'),
  ('Plot', 'plot', 'noun',
      'The main events of a story, film or play.',
      'The plot twists kept us guessing until the end.'),
  ('Melody', 'MEL-uh-dee', 'noun',
      'A sequence of musical notes that forms a tune.',
      'I can\'t get that melody out of my head.'),
];

const List<_Entry> _artsIntermediate = [
  ('Juxtaposition', 'juk-stuh-puh-ZISH-uhn', 'noun',
      'Placing two things side by side for contrasting effect.',
      'The photo\'s juxtaposition of old and new is striking.'),
  ('Allegory', 'AL-uh-gor-ee', 'noun',
      'A story with a hidden moral or political meaning.',
      'The fable works as an allegory of power.'),
  ('Protagonist', 'proh-TAG-uh-nist', 'noun',
      'The main character in a story.',
      'The protagonist must choose between duty and love.'),
  ('Aesthetic', 'es-THET-ik', 'adjective',
      'Concerned with beauty or the appreciation of beauty.',
      'The café was designed with real aesthetic care.'),
  ('Motif', 'moh-TEEF', 'noun',
      'A recurring idea, image or theme in a work.',
      'Water is a recurring motif throughout the novel.'),
  ('Satire', 'SAT-yre', 'noun',
      'The use of humor or exaggeration to criticize or mock.',
      'The show is a sharp satire of office life.'),
];

const List<_Entry> _artsNiche = [
  ('Ekphrasis', 'EK-fruh-sis', 'noun',
      'A vivid literary description of a work of visual art.',
      'The poem is an ekphrasis of a Dutch still life.'),
  ('Chiaroscuro', 'kee-ar-uh-SKOOR-oh', 'noun',
      'The strong contrast of light and shadow in art.',
      'Caravaggio was a master of chiaroscuro.'),
  ('Mellifluous', 'muh-LIF-loo-uhs', 'adjective',
      'Sweet or musical; pleasant to hear.',
      'Her mellifluous voice filled the small chapel.'),
  ('Sprezzatura', 'spret-suh-TOO-ruh', 'noun',
      'Studied carelessness; making difficult things look effortless.',
      'He played the sonata with dazzling sprezzatura.'),
  ('Palimpsest', 'PAL-imp-sest', 'noun',
      'Something reused or altered that still bears traces of its earlier form.',
      'The old city is a palimpsest of empires.'),
  ('Denouement', 'day-noo-MAHN', 'noun',
      'The final part of a story, where the plot strands are resolved.',
      'The denouement tied up every loose thread.'),
];

// ---------------------------------------------------------------------------
// Mind & Emotion
// ---------------------------------------------------------------------------

const List<_Entry> _emotionPractical = [
  ('Anxious', 'ANGK-shuhs', 'adjective',
      'Feeling worried or nervous about something uncertain.',
      'I always feel anxious before a job interview.'),
  ('Grateful', 'GRAYT-fuhl', 'adjective',
      'Feeling or showing thanks.',
      'We\'re grateful for all your help with the move.'),
  ('Confident', 'KON-fih-duhnt', 'adjective',
      'Feeling sure about yourself and your abilities.',
      'After months of practice, she felt confident on stage.'),
  ('Empathy', 'EM-puh-thee', 'noun',
      'The ability to understand and share another person\'s feelings.',
      'Good nurses combine skill with empathy.'),
  ('Frustrated', 'FRUS-tray-tid', 'adjective',
      'Annoyed at being unable to change or achieve something.',
      'He grew frustrated with the slow internet.'),
  ('Nostalgia', 'noh-STAL-juh', 'noun',
      'A sentimental longing for the past.',
      'The old song filled her with nostalgia.'),
];

const List<_Entry> _emotionIntermediate = [
  ('Resilience', 'rih-ZIL-yuhns', 'noun',
      'The ability to recover quickly from difficulties.',
      'The community showed remarkable resilience after the flood.'),
  ('Ambivalent', 'am-BIV-uh-luhnt', 'adjective',
      'Having mixed feelings about something.',
      'I\'m ambivalent about moving to the city.'),
  ('Melancholy', 'MEL-uhn-kol-ee', 'noun',
      'A deep, pensive and long-lasting sadness.',
      'A gentle melancholy settled over the empty house.'),
  ('Euphoria', 'yoo-FOR-ee-uh', 'noun',
      'A feeling of intense excitement and happiness.',
      'Crossing the finish line brought pure euphoria.'),
  ('Introspection', 'in-truh-SPEK-shuhn', 'noun',
      'Examining your own thoughts and feelings.',
      'Long walks are her time for introspection.'),
  ('Apathy', 'AP-uh-thee', 'noun',
      'Lack of interest, enthusiasm or concern.',
      'Voter apathy led to a record-low turnout.'),
];

const List<_Entry> _emotionNiche = [
  ('Sonder', 'SON-der', 'noun',
      'The realization that every passerby has a life as vivid and complex as your own.',
      'Watching the lit windows from the train, I felt a wave of sonder.'),
  ('Limerence', 'LIM-er-uhns', 'noun',
      'The state of being infatuated with another person.',
      'Their teenage limerence faded by the end of summer.'),
  ('Hiraeth', 'HEER-eyeth', 'noun',
      'A homesick longing for a home you cannot return to (from Welsh).',
      'The smell of sea air stirred a deep hiraeth.'),
  ('Schadenfreude', 'SHAH-duhn-froy-duh', 'noun',
      'Pleasure derived from another person\'s misfortune.',
      'He felt a flicker of schadenfreude when his rival tripped.'),
  ('Saudade', 'sow-DAH-duh', 'noun',
      'A deep, melancholic longing for someone or something absent (from Portuguese).',
      'The old fado song was full of saudade.'),
  ('Ennui', 'ahn-WEE', 'noun',
      'A feeling of listlessness and dissatisfaction arising from boredom.',
      'The long, grey afternoon filled him with ennui.'),
];

// ---------------------------------------------------------------------------
// Food & Travel
// ---------------------------------------------------------------------------

const List<_Entry> _travelPractical = [
  ('Itinerary', 'eye-TIN-uh-rair-ee', 'noun',
      'A planned route or schedule for a journey.',
      'Our itinerary includes three days in Kyoto.'),
  ('Cuisine', 'kwih-ZEEN', 'noun',
      'A style of cooking characteristic of a place.',
      'Thai cuisine balances sweet, sour, salty and spicy.'),
  ('Souvenir', 'soo-vuh-NEER', 'noun',
      'Something kept as a reminder of a place or event.',
      'She brought back a ceramic tile as a souvenir.'),
  ('Appetizer', 'AP-ih-ty-zer', 'noun',
      'A small dish served before the main meal.',
      'We shared garlic bread as an appetizer.'),
  ('Landmark', 'LAND-mark', 'noun',
      'A recognizable feature of a place, such as a famous building.',
      'The clock tower is the town\'s best-known landmark.'),
  ('Layover', 'LAY-oh-ver', 'noun',
      'A short stop between parts of a journey, especially flights.',
      'We had a six-hour layover in Doha.'),
];

const List<_Entry> _travelIntermediate = [
  ('Wanderlust', 'WON-der-lust', 'noun',
      'A strong desire to travel.',
      'Every postcard fed her wanderlust.'),
  ('Savory', 'SAY-vuh-ree', 'adjective',
      'Salty or spicy rather than sweet.',
      'I prefer a savory breakfast to pancakes.'),
  ('Artisanal', 'ar-TIZ-uh-nuhl', 'adjective',
      'Made in a traditional way by skilled craftspeople.',
      'The market sells artisanal cheese and bread.'),
  ('Expatriate', 'eks-PAY-tree-it', 'noun',
      'A person living outside their native country.',
      'The café is popular with expatriates.'),
  ('Gourmet', 'goor-MAY', 'noun',
      'A connoisseur of good food.',
      'A true gourmet, he could name every spice in the dish.'),
  ('Succulent', 'SUK-yuh-luhnt', 'adjective',
      'Tender, juicy and tasty.',
      'The roast chicken was wonderfully succulent.'),
];

const List<_Entry> _travelNiche = [
  ('Umami', 'oo-MAH-mee', 'noun',
      'A rich, savory taste; one of the five basic tastes.',
      'Parmesan and mushrooms add umami to the sauce.'),
  ('Peripatetic', 'pair-uh-puh-TET-ik', 'adjective',
      'Traveling from place to place; working in various places.',
      'Her peripatetic career took her across four continents.'),
  ('Mise en place', 'meez ahn PLAHS', 'noun',
      'Having all ingredients prepared and arranged before cooking.',
      'Good mise en place makes a busy service feel calm.'),
  ('Fernweh', 'FAIRN-vay', 'noun',
      'An ache for distant places you have never been (from German).',
      'Looking at the atlas filled him with fernweh.'),
  ('Flâneur', 'flah-NUR', 'noun',
      'A person who strolls idly, observing city life.',
      'Paris turns every visitor into a flâneur.'),
  ('Sobremesa', 'soh-breh-MEH-sah', 'noun',
      'Time spent lingering at the table talking after a meal (from Spanish).',
      'Lunch ended at two, but the sobremesa lasted until five.'),
];
