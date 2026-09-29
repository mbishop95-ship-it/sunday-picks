import json, urllib.request, pathlib, datetime
from zoneinfo import ZoneInfo

YEAR=datetime.datetime.now().year
SERIES=1
CACHE="https://cf.nascar.com/cacher"

def get(url):
    req=urllib.request.Request(url,headers={"User-Agent":"Mozilla/5.0 Sunday-Picks/1.0","Accept":"application/json"})
    with urllib.request.urlopen(req,timeout=30) as r:
        return json.load(r)

def first_list(obj):
    if isinstance(obj,list): return obj
    if isinstance(obj,dict):
        for k in ("races","race_list","RaceInfo","data"):
            if isinstance(obj.get(k),list): return obj[k]
    return []

# NASCAR's CDN cache is the source used by its public race-data surfaces.
race_blob=get(f"{CACHE}/{YEAR}/{SERIES}/race_list_basic.json")
races=first_list(race_blob)
cup=[]
for r in races:
    try:
        if int(r.get("series_id",SERIES))!=SERIES: continue
        if int(r.get("race_type_id",1))!=1: continue
    except Exception:
        continue
    cup.append(r)
cup.sort(key=lambda r:r.get("race_date") or "")

# Preserve the app's curated 36-race schedule. This job's purpose is final points.
path=pathlib.Path("data/results.json")
existing=json.loads(path.read_text(encoding="utf-8")) if path.exists() else {}
schedule=existing.get("schedule",[])
# Keep curated race IDs/names/dates; enrich each with NASCAR's scheduled start.
for entry in schedule:
    info=next((r for r in cup if str(r.get("race_id"))==str(entry.get("nascar_race_id"))),None)
    if info is None:
        candidates=[r for r in cup if (r.get("date_scheduled") or r.get("race_date", ""))[:10]==entry["date"] or r.get("race_date", "")[:10]==entry["date"]]
        info=candidates[0] if len(candidates)==1 else None
    if info is None: continue
    events=[e for e in info.get("schedule",[]) if e.get("run_type")==3 and e.get("start_time_utc")]
    try:
        if events:
            start=datetime.datetime.fromisoformat(events[-1]["start_time_utc"])
            if start.tzinfo is None: start=start.replace(tzinfo=datetime.timezone.utc)
        else:
            start=datetime.datetime.fromisoformat(info["race_date"])
            if start.tzinfo is None: start=start.replace(tzinfo=ZoneInfo("America/New_York"))
        entry["starts_at"]=start.astimezone(datetime.timezone.utc).isoformat()
        entry["nascar_race_id"]=str(info["race_id"])
    except (ValueError,KeyError):
        continue # Preserve the last known deadline if NASCAR omits a time.
out={"season":YEAR,"series_id":SERIES,"updated_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),"schedule":schedule,"races":[]}

for info in cup:
    rid=info.get("race_id")
    if not rid: continue
    # Ignore races that have not started/completed.
    try:
        if int(info.get("actual_laps") or 0)<=0: continue
    except Exception:
        continue
    try:
        blob=get(f"{CACHE}/{YEAR}/{SERIES}/{rid}/raceResults.json")
    except Exception as e:
        print("skip",rid,e)
        continue
    results=first_list(blob)
    normalized=[]
    for x in results:
        name=x.get("driver_fullname") or x.get("driver_name") or x.get("driverFullName")
        pts=x.get("points_earned")
        if pts is None: pts=x.get("points")
        if name and pts is not None:
            try: pts=int(float(pts))
            except Exception: continue
            normalized.append({"driver":name,"points":pts})
    if normalized:
        out["races"].append({
            "race_id":rid,
            "name":info.get("race_name") or "",
            "track":info.get("track_name") or "",
            "date":(info.get("race_date") or "")[:10],
            "official":True,
            "results":normalized
        })
        print("loaded",rid,(info.get("race_date") or "")[:10],len(normalized),"drivers")

path.write_text(json.dumps(out,indent=2),encoding="utf-8")
print("published",len(out["races"]),"completed points races")
