import pathlib,datetime,unittest
from zoneinfo import ZoneInfo
source=(pathlib.Path(__file__).parents[1]/'scripts/update_results.py').read_text()
code=source[source.index('for entry in schedule:'):source.index('out={"season":')]
class StartTimes(unittest.TestCase):
 def convert(self,info):
  schedule=[{'race_id':'curated-1','name':'Keep My Name','date':info['race_date'][:10]}]
  exec(code,{'schedule':schedule,'cup':[info],'datetime':datetime,'ZoneInfo':ZoneInfo})
  self.assertEqual(schedule[0]['race_id'],'curated-1');self.assertEqual(schedule[0]['name'],'Keep My Name')
  return schedule[0]
 def test_race_event_over_practice(self):
  s=self.convert({'race_id':1,'race_date':'2026-10-04T17:30:00','schedule':[{'run_type':1,'start_time_utc':'2026-10-03T15:00:00'},{'run_type':3,'start_time_utc':'2026-10-04T21:30:00'}]})
  self.assertEqual(s['starts_at'],'2026-10-04T21:30:00+00:00')
 def test_fallback_dst(self):
  for date,expected in [('2026-10-04T15:00:00','2026-10-04T19:00:00+00:00'),('2026-11-08T15:00:00','2026-11-08T20:00:00+00:00')]:
   self.assertEqual(self.convert({'race_id':1,'race_date':date})['starts_at'],expected)
 def test_missing_match_keeps_known_time(self):
  schedule=[{'race_id':'x','date':'2026-10-04','starts_at':'2026-10-04T21:30:00+00:00'}];exec(code,{'schedule':schedule,'cup':[],'datetime':datetime,'ZoneInfo':ZoneInfo});self.assertEqual(schedule[0]['starts_at'],'2026-10-04T21:30:00+00:00')
unittest.main()
