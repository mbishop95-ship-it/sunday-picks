import json, urllib.request, pathlib, datetime

BASE="https://feed.nascar.com/api"
YEAR=datetime.datetime.now().year
def get(url):
    req=urllib.request.Request(url,headers={"User-Agent":"Sunday-Picks/1.0","Accept":"application/json"})
    with urllib.request.urlopen(req,timeout=30) as r:
        return json.load(r)

races=get(f"{BASE}/racelist?startseason={YEAR}&endseason={YEAR}&series_id=1&v=4")
if isinstance(races,dict):
    for key in ("races","race_list","RaceInfo"):
        if key in races:
            races=races[key]; break
eligible=[r for r in races if int(r.get("series_id",1))==1 and int(r.get("race_type_id",1))==1 and int(r.get("actual_laps") or 0)>0]
eligible.sort(key=lambda r:r.get("race_date") or "")
out={"season":YEAR,"series_id":1,"updated_at":datetime.datetime.now(datetime.timezone.utc).isoformat(),"races":[]}
for info in eligible:
    rid=info["race_id"]
    try:
        race=get(f"{BASE}/races/{rid}?v=4")
    except Exception as e:
        print("skip",rid,e); continue
    if isinstance(race,list): race=race[0] if race else {}
    results=race.get("results") or race.get("race_results") or []
    # Only publish final post-inspection data.
    if not race.get("inspection_complete",False):
        continue
    normalized=[]
    for x in results:
        name=x.get("driver_fullname") or x.get("driver_name")
        pts=x.get("points_earned")
        if name and pts is not None:
            normalized.append({"driver":name,"points":int(pts),"finish":int(x.get("finishing_position") or 0),"disqualified":bool(x.get("disqualified",False))})
    if normalized:
        out["races"].append({"race_id":rid,"name":race.get("race_name") or info.get("race_name"),"track":race.get("track_name") or info.get("track_name"),"date":(race.get("race_date") or info.get("race_date") or "")[:10],"inspection_complete":True,"results":normalized})
path=pathlib.Path("data/results.json"); path.parent.mkdir(parents=True,exist_ok=True)
path.write_text(json.dumps(out,indent=2),encoding="utf-8")
print("published",len(out["races"]),"final races")
