import '../models/course.dart';
import '../models/exercise.dart';
import '../models/lesson.dart';

/// The seeded course catalogue.
///
/// Korean is fully playable; the others exist to make the onboarding choice
/// feel real and render as "coming soon" (see `docs/screens.md`).
List<Course> buildCourses() => [
  _korean,
  const Course(
    id: 'ja',
    name: 'Japanese',
    nativeName: '日本語',
    flag: '🇯🇵',
    wordCount: 1400,
    available: false,
  ),
  const Course(
    id: 'es',
    name: 'Spanish',
    nativeName: 'Español',
    flag: '🇪🇸',
    wordCount: 1600,
    available: false,
  ),
];

const Course _korean = Course(
  id: 'ko',
  name: 'Korean',
  nativeName: '한국어',
  flag: '🇰🇷',
  wordCount: 1200,
  units: [_unit1, _unit2, _unit3],
);

// ── Unit 1 ────────────────────────────────────────────────────────────────

const Unit _unit1 = Unit(
  id: 'u1',
  title: 'First words',
  subtitle: 'Greet people and be polite about it',
  lessons: [_l1, _l2, _l3],
);

const Lesson _l1 = Lesson(
  id: 'l1',
  title: 'Hello and thanks',
  subtitle: 'The two phrases you will use every single day',
  newWordIds: ['v_hello', 'v_thanks', 'v_yes', 'v_no'],
  exercises: [
    MatchPairsExercise(
      id: 'l1e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_hello', 'v_thanks', 'v_yes', 'v_no'],
      pairs: [
        MatchPair(source: 'hello', target: '안녕하세요'),
        MatchPair(source: 'thank you', target: '감사합니다'),
        MatchPair(source: 'yes', target: '네'),
        MatchPair(source: 'no', target: '아니요'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l1e2',
      prompt: 'What does this mean?',
      question: '안녕하세요',
      note: 'annyeonghaseyo',
      vocabIds: ['v_hello'],
      options: ['Hello', 'Goodbye', 'Thank you', "I'm sorry"],
      correctIndex: 0,
    ),
    ListeningExercise(
      id: 'l1e3',
      prompt: 'What did you hear?',
      spoken: '감사합니다',
      gloss: 'thank you',
      vocabIds: ['v_thanks'],
      options: ['감사합니다', '안녕하세요', '아니요', '네'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l1e4',
      prompt: 'Build the sentence',
      source: 'Yes, thank you.',
      vocabIds: ['v_yes', 'v_thanks'],
      bank: ['네', '감사합니다', '아니요', '안녕하세요'],
      solution: ['네', '감사합니다'],
    ),
    MultipleChoiceExercise(
      id: 'l1e5',
      prompt: 'Which one means "no"?',
      question: 'no',
      vocabIds: ['v_no'],
      options: ['아니요', '네', '감사합니다', '안녕하세요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l1e6',
      prompt: 'Fill in the blank',
      before: '',
      after: ', 감사합니다.',
      translation: 'No, thank you.',
      vocabIds: ['v_no'],
      options: ['아니요', '네', '안녕하세요', '감사합니다'],
      correctIndex: 0,
    ),
  ],
);

const Lesson _l2 = Lesson(
  id: 'l2',
  title: 'Introducing yourself',
  subtitle: 'Say who you are and ask who they are',
  newWordIds: ['v_i', 'v_name', 'v_nicetomeet'],
  exercises: [
    MatchPairsExercise(
      id: 'l2e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_i', 'v_name', 'v_nicetomeet', 'v_hello'],
      pairs: [
        MatchPair(source: 'I, me', target: '저'),
        MatchPair(source: 'name', target: '이름'),
        MatchPair(source: 'nice to meet you', target: '반갑습니다'),
        MatchPair(source: 'hello', target: '안녕하세요'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l2e2',
      prompt: 'What does this mean?',
      question: '이름',
      note: 'ireum',
      vocabIds: ['v_name'],
      options: ['Name', 'Age', 'Country', 'Friend'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l2e3',
      prompt: 'Build the sentence',
      source: 'I am Minsu.',
      vocabIds: ['v_i'],
      bank: ['저는', '민수예요', '이름은', '반갑습니다'],
      solution: ['저는', '민수예요'],
    ),
    ListeningExercise(
      id: 'l2e4',
      prompt: 'What did you hear?',
      spoken: '반갑습니다',
      gloss: 'nice to meet you',
      vocabIds: ['v_nicetomeet'],
      options: ['반갑습니다', '감사합니다', '안녕하세요', '아니요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l2e5',
      prompt: 'Fill in the blank',
      before: '',
      after: '이 뭐예요?',
      translation: 'What is your name?',
      vocabIds: ['v_name'],
      options: ['이름', '저', '네', '반갑습니다'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l2e6',
      prompt: 'Build the sentence',
      source: 'Hello, nice to meet you.',
      vocabIds: ['v_hello', 'v_nicetomeet'],
      bank: ['안녕하세요', '반갑습니다', '감사합니다', '저는'],
      solution: ['안녕하세요', '반갑습니다'],
    ),
  ],
);

const Lesson _l3 = Lesson(
  id: 'l3',
  title: 'Saying goodbye',
  subtitle: 'Close a conversation without freezing up',
  newWordIds: ['v_goodbye'],
  exercises: [
    MultipleChoiceExercise(
      id: 'l3e1',
      prompt: 'What does this mean?',
      question: '안녕히 가세요',
      note: 'annyeonghi gaseyo',
      vocabIds: ['v_goodbye'],
      options: [
        'Goodbye (to someone leaving)',
        'Hello',
        'See you tomorrow',
        'Welcome',
      ],
      correctIndex: 0,
    ),
    MatchPairsExercise(
      id: 'l3e2',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_goodbye', 'v_hello', 'v_thanks', 'v_nicetomeet'],
      pairs: [
        MatchPair(source: 'goodbye', target: '안녕히 가세요'),
        MatchPair(source: 'hello', target: '안녕하세요'),
        MatchPair(source: 'thank you', target: '감사합니다'),
        MatchPair(source: 'nice to meet you', target: '반갑습니다'),
      ],
    ),
    WordBankExercise(
      id: 'l3e3',
      prompt: 'Build the sentence',
      source: 'Thank you, goodbye.',
      vocabIds: ['v_thanks', 'v_goodbye'],
      bank: ['감사합니다', '안녕히 가세요', '안녕하세요', '네'],
      solution: ['감사합니다', '안녕히 가세요'],
    ),
    ListeningExercise(
      id: 'l3e4',
      prompt: 'What did you hear?',
      spoken: '안녕히 가세요',
      gloss: 'goodbye',
      vocabIds: ['v_goodbye'],
      options: ['안녕히 가세요', '안녕하세요', '반갑습니다', '감사합니다'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l3e5',
      prompt: 'Fill in the blank',
      before: '감사합니다. ',
      after: '.',
      translation: 'Thank you. Goodbye.',
      vocabIds: ['v_goodbye'],
      options: ['안녕히 가세요', '안녕하세요', '반갑습니다', '네'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l3e6',
      prompt: 'Build the sentence',
      source: 'Yes, nice to meet you.',
      vocabIds: ['v_yes', 'v_nicetomeet'],
      bank: ['네', '반갑습니다', '아니요', '감사합니다'],
      solution: ['네', '반갑습니다'],
    ),
  ],
);

// ── Unit 2 ────────────────────────────────────────────────────────────────

const Unit _unit2 = Unit(
  id: 'u2',
  title: 'At the café',
  subtitle: 'Order something and understand the answer',
  lessons: [_l4, _l5, _l6],
);

const Lesson _l4 = Lesson(
  id: 'l4',
  title: 'Ordering',
  subtitle: 'Ask for what you want, politely',
  newWordIds: ['v_coffee', 'v_water', 'v_please'],
  exercises: [
    MatchPairsExercise(
      id: 'l4e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_coffee', 'v_water', 'v_please', 'v_hello'],
      pairs: [
        MatchPair(source: 'coffee', target: '커피'),
        MatchPair(source: 'water', target: '물'),
        MatchPair(source: 'please give me', target: '주세요'),
        MatchPair(source: 'hello', target: '안녕하세요'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l4e2',
      prompt: 'What does this mean?',
      question: '물',
      note: 'mul',
      vocabIds: ['v_water'],
      options: ['Water', 'Milk', 'Coffee', 'Juice'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l4e3',
      prompt: 'Build the sentence',
      source: 'Coffee, please.',
      vocabIds: ['v_coffee', 'v_please'],
      bank: ['커피', '주세요', '물', '감사합니다'],
      solution: ['커피', '주세요'],
    ),
    ListeningExercise(
      id: 'l4e4',
      prompt: 'What did you hear?',
      spoken: '물 주세요',
      gloss: 'water, please',
      vocabIds: ['v_water', 'v_please'],
      options: ['물 주세요', '커피 주세요', '감사합니다', '안녕하세요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l4e5',
      prompt: 'Fill in the blank',
      before: '물 ',
      after: '.',
      translation: 'Water, please.',
      vocabIds: ['v_please'],
      options: ['주세요', '커피', '네', '이름'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l4e6',
      prompt: 'Build the sentence',
      source: 'Water, please. Thank you.',
      vocabIds: ['v_water', 'v_please', 'v_thanks'],
      bank: ['물', '주세요', '감사합니다', '커피'],
      solution: ['물', '주세요', '감사합니다'],
    ),
  ],
);

const Lesson _l5 = Lesson(
  id: 'l5',
  title: 'How much?',
  subtitle: 'Get a price without pointing and hoping',
  newWordIds: ['v_howmuch', 'v_one', 'v_excuseme'],
  exercises: [
    MultipleChoiceExercise(
      id: 'l5e1',
      prompt: 'What does this mean?',
      question: '얼마예요',
      note: 'eolmayeyo',
      vocabIds: ['v_howmuch'],
      options: [
        'How much is it?',
        'Where is it?',
        'What is it?',
        'Is it good?',
      ],
      correctIndex: 0,
    ),
    MatchPairsExercise(
      id: 'l5e2',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_howmuch', 'v_one', 'v_excuseme', 'v_please'],
      pairs: [
        MatchPair(source: 'how much is it', target: '얼마예요'),
        MatchPair(source: 'one', target: '하나'),
        MatchPair(source: 'excuse me', target: '여기요'),
        MatchPair(source: 'please give me', target: '주세요'),
      ],
    ),
    WordBankExercise(
      id: 'l5e3',
      prompt: 'Build the sentence',
      source: 'One coffee, please.',
      vocabIds: ['v_coffee', 'v_one', 'v_please'],
      bank: ['커피', '하나', '주세요', '물'],
      solution: ['커피', '하나', '주세요'],
    ),
    ListeningExercise(
      id: 'l5e4',
      prompt: 'What did you hear?',
      spoken: '얼마예요',
      gloss: 'how much is it',
      vocabIds: ['v_howmuch'],
      options: ['얼마예요', '어디예요', '맛있어요', '주세요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l5e5',
      prompt: 'Fill in the blank',
      before: '여기요, 커피 ',
      after: ' 주세요.',
      translation: 'Excuse me, one coffee please.',
      vocabIds: ['v_one'],
      options: ['하나', '물', '네', '얼마예요'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l5e6',
      prompt: 'Build the sentence',
      source: 'Excuse me, how much is it?',
      vocabIds: ['v_excuseme', 'v_howmuch'],
      bank: ['여기요', '얼마예요', '주세요', '하나'],
      solution: ['여기요', '얼마예요'],
    ),
  ],
);

const Lesson _l6 = Lesson(
  id: 'l6',
  title: "It's delicious",
  subtitle: 'React to what you just ordered',
  newWordIds: ['v_delicious', 'v_tea'],
  exercises: [
    MatchPairsExercise(
      id: 'l6e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_delicious', 'v_tea', 'v_coffee', 'v_water'],
      pairs: [
        MatchPair(source: "it's delicious", target: '맛있어요'),
        MatchPair(source: 'tea', target: '차'),
        MatchPair(source: 'coffee', target: '커피'),
        MatchPair(source: 'water', target: '물'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l6e2',
      prompt: 'What does this mean?',
      question: '맛있어요',
      note: 'masisseoyo',
      vocabIds: ['v_delicious'],
      options: ["It's delicious", "It's expensive", "It's hot", "It's enough"],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l6e3',
      prompt: 'Build the sentence',
      source: 'The coffee is delicious.',
      vocabIds: ['v_coffee', 'v_delicious'],
      bank: ['커피', '맛있어요', '차', '주세요'],
      solution: ['커피', '맛있어요'],
    ),
    ListeningExercise(
      id: 'l6e4',
      prompt: 'What did you hear?',
      spoken: '차 맛있어요',
      gloss: 'the tea is delicious',
      vocabIds: ['v_tea', 'v_delicious'],
      options: ['차 맛있어요', '커피 맛있어요', '물 주세요', '얼마예요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l6e5',
      prompt: 'Fill in the blank',
      before: '',
      after: ' 주세요.',
      translation: 'Tea, please.',
      vocabIds: ['v_tea'],
      options: ['차', '맛있어요', '하나', '여기요'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l6e6',
      prompt: 'Build the sentence',
      source: "Tea, please. It's delicious.",
      vocabIds: ['v_tea', 'v_please', 'v_delicious'],
      bank: ['차', '주세요', '맛있어요', '커피'],
      solution: ['차', '주세요', '맛있어요'],
    ),
  ],
);

// ── Unit 3 ────────────────────────────────────────────────────────────────

const Unit _unit3 = Unit(
  id: 'u3',
  title: 'Finding your way',
  subtitle: 'Ask where something is and follow the answer',
  lessons: [_l7, _l8],
);

const Lesson _l7 = Lesson(
  id: 'l7',
  title: 'Where is it?',
  subtitle: 'Here, there, and how to ask',
  newWordIds: ['v_where', 'v_here', 'v_there'],
  exercises: [
    MatchPairsExercise(
      id: 'l7e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_where', 'v_here', 'v_there', 'v_howmuch'],
      pairs: [
        MatchPair(source: 'where', target: '어디'),
        MatchPair(source: 'here', target: '여기'),
        MatchPair(source: 'over there', target: '저기'),
        MatchPair(source: 'how much is it', target: '얼마예요'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l7e2',
      prompt: 'What does this mean?',
      question: '어디',
      note: 'eodi',
      vocabIds: ['v_where'],
      options: ['Where', 'When', 'Who', 'Why'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l7e3',
      prompt: 'Build the sentence',
      source: 'Where is the coffee?',
      vocabIds: ['v_coffee', 'v_where'],
      bank: ['커피', '어디예요', '여기', '주세요'],
      solution: ['커피', '어디예요'],
    ),
    ListeningExercise(
      id: 'l7e4',
      prompt: 'What did you hear?',
      spoken: '여기예요',
      gloss: "it's here",
      vocabIds: ['v_here'],
      options: ['여기예요', '저기예요', '어디예요', '맛있어요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l7e5',
      prompt: 'Fill in the blank',
      before: '물이 ',
      after: '?',
      translation: 'Where is the water?',
      vocabIds: ['v_where'],
      options: ['어디예요', '여기', '저기', '하나'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l7e6',
      prompt: 'Build the sentence',
      source: "It's here. Thank you.",
      vocabIds: ['v_here', 'v_thanks'],
      bank: ['여기예요', '감사합니다', '저기예요', '어디예요'],
      solution: ['여기예요', '감사합니다'],
    ),
  ],
);

const Lesson _l8 = Lesson(
  id: 'l8',
  title: 'Left and right',
  subtitle: 'Follow directions once you have asked for them',
  newWordIds: ['v_left', 'v_right', 'v_go'],
  exercises: [
    MatchPairsExercise(
      id: 'l8e1',
      prompt: 'Tap the matching pairs',
      vocabIds: ['v_left', 'v_right', 'v_go', 'v_where'],
      pairs: [
        MatchPair(source: 'left', target: '왼쪽'),
        MatchPair(source: 'right', target: '오른쪽'),
        MatchPair(source: 'go', target: '가요'),
        MatchPair(source: 'where', target: '어디'),
      ],
    ),
    MultipleChoiceExercise(
      id: 'l8e2',
      prompt: 'What does this mean?',
      question: '오른쪽',
      note: 'oreunjjok',
      vocabIds: ['v_right'],
      options: ['Right', 'Left', 'Straight', 'Back'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l8e3',
      prompt: 'Build the sentence',
      source: 'Go to the left.',
      vocabIds: ['v_left', 'v_go'],
      bank: ['왼쪽으로', '가요', '오른쪽으로', '어디로'],
      solution: ['왼쪽으로', '가요'],
    ),
    ListeningExercise(
      id: 'l8e4',
      prompt: 'What did you hear?',
      spoken: '오른쪽으로 가요',
      gloss: 'go to the right',
      vocabIds: ['v_right', 'v_go'],
      options: ['오른쪽으로 가요', '왼쪽으로 가요', '여기예요', '어디예요'],
      correctIndex: 0,
    ),
    FillBlankExercise(
      id: 'l8e5',
      prompt: 'Fill in the blank',
      before: '',
      after: '으로 가요.',
      translation: 'Go to the right.',
      vocabIds: ['v_right'],
      options: ['오른쪽', '왼쪽', '여기', '차'],
      correctIndex: 0,
    ),
    WordBankExercise(
      id: 'l8e6',
      prompt: 'Build the sentence',
      source: 'Where do I go?',
      vocabIds: ['v_where', 'v_go'],
      bank: ['어디로', '가요', '여기로', '오른쪽으로'],
      solution: ['어디로', '가요'],
    ),
  ],
);
