import json, urllib.request, pathlib, datetime

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
