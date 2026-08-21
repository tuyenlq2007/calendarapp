insert into public.calendar_entries (
  id,
  gregorian_date,
  tibetan_date_text,
  title_en,
  title_bo,
  description_en,
  description_bo,
  status,
  published_at
) values
  (
    '11111111-1111-4111-8111-111111111111',
    date '2026-08-21',
    'བོད་ཟླ ༧ ཚེས ༩',
    'Daily Barom Kagyu practice',
    'འབའ་རོམ་བཀའ་བརྒྱུད་ཉིན་རེའི་སྒྲུབ་པ།',
    'Morning refuge, bodhicitta, and lineage supplication practice.',
    'སྐྱབས་འགྲོ། བྱང་ཆུབ་སེམས། བརྒྱུད་འདེབས།',
    'published',
    timestamptz '2026-08-21 00:00:00+00'
  ),
  (
    '22222222-2222-4222-8222-222222222222',
    date '2026-08-22',
    'བོད་ཟླ ༧ ཚེས ༡༠',
    'Guru Rinpoche day',
    'གུ་རུ་རིན་པོ་ཆེའི་དུས་ཆེན།',
    'A day for Guru Rinpoche prayers, tsok, and aspiration practice.',
    'གུ་རུའི་གསོལ་འདེབས། ཚོགས། སྨོན་ལམ།',
    'published',
    timestamptz '2026-08-22 00:00:00+00'
  ),
  (
    '33333333-3333-4333-8333-333333333333',
    date '2026-08-25',
    'བོད་ཟླ ༧ ཚེས ༡༣',
    'Lineage supplication day',
    'བརྒྱུད་པའི་གསོལ་འདེབས་ཉིན།',
    'Community practice focused on the Barom Kagyu lineage prayer.',
    'འབའ་རོམ་བཀའ་བརྒྱུད་གསོལ་འདེབས་སྒྲུབ་པ།',
    'published',
    timestamptz '2026-08-25 00:00:00+00'
  ),
  (
    '44444444-4444-4444-8444-444444444444',
    date '2026-08-29',
    'བོད་ཟླ ༧ ཚེས ༡༧',
    'Meditation and dedication',
    'སྒོམ་སྒྲུབ་དང་བསྔོ་བ།',
    'Meditation session with dedication of merit for all beings.',
    'སེམས་ཅན་ཐམས་ཅད་ཀྱི་དོན་དུ་དགེ་བ་བསྔོ་བ།',
    'published',
    timestamptz '2026-08-29 00:00:00+00'
  ),
  (
    '55555555-5555-4555-8555-555555555555',
    date '2026-08-31',
    'བོད་ཟླ ༧ ཚེས ༡༩',
    'Dharma protector practice',
    'ཆོས་སྐྱོང་སྒྲུབ་པ།',
    'Dharma protector prayers and evening dedication.',
    'ཆོས་སྐྱོང་གསོལ་མཆོད་དང་དགོང་མོའི་བསྔོ་བ།',
    'published',
    timestamptz '2026-08-31 00:00:00+00'
  )
on conflict (id) do update set
  gregorian_date = excluded.gregorian_date,
  tibetan_date_text = excluded.tibetan_date_text,
  title_en = excluded.title_en,
  title_bo = excluded.title_bo,
  description_en = excluded.description_en,
  description_bo = excluded.description_bo,
  status = excluded.status,
  published_at = excluded.published_at;
