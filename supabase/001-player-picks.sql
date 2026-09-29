-- TEMPLATE ONLY: replace all four EMAIL placeholders. Use the private setup SQL supplied with the pull request.
-- Run once in the Sunday Picks Supabase SQL Editor. Transactional; legacy data retained.
begin;
create table public.sp_league (id text primary key, phase text not null check(phase in ('regular','chase')), base jsonb not null, revision bigint not null default 0);
create table public.sp_races (id text primary key, official_race_id text unique, phase text not null check(phase in ('regular','chase')), metadata jsonb not null);
create table public.sp_picks (race_id text references public.sp_races(id) on delete cascade, player text check(player in ('Matthew','Tanner','Tom','Debora')), driver text not null, primary key(race_id,player));
create table public.sp_schedule (id text primary key, info jsonb not null);
create table public.sp_drivers (name text primary key);
insert into public.sp_schedule select x->>'race_id',x from jsonb_array_elements('[{"race_id": "2026-01", "date": "2026-02-15", "name": "Daytona 500", "track": "Daytona International Speedway"}, {"race_id": "2026-02", "date": "2026-02-22", "name": "EchoPark Speedway (Atlanta)", "track": "EchoPark Speedway"}, {"race_id": "2026-03", "date": "2026-03-01", "name": "Circuit of The Americas (Austin)", "track": "Circuit of The Americas"}, {"race_id": "2026-04", "date": "2026-03-08", "name": "Phoenix Raceway", "track": "Phoenix Raceway"}, {"race_id": "2026-05", "date": "2026-03-15", "name": "Las Vegas Motor Speedway", "track": "Las Vegas Motor Speedway"}, {"race_id": "2026-06", "date": "2026-03-22", "name": "Darlington Raceway", "track": "Darlington Raceway"}, {"race_id": "2026-07", "date": "2026-03-29", "name": "Martinsville Speedway", "track": "Martinsville Speedway"}, {"race_id": "2026-08", "date": "2026-04-12", "name": "Bristol Motor Speedway", "track": "Bristol Motor Speedway"}, {"race_id": "2026-09", "date": "2026-04-19", "name": "Kansas Speedway", "track": "Kansas Speedway"}, {"race_id": "2026-10", "date": "2026-04-26", "name": "Talladega Superspeedway", "track": "Talladega Superspeedway"}, {"race_id": "2026-11", "date": "2026-05-03", "name": "Texas Motor Speedway", "track": "Texas Motor Speedway"}, {"race_id": "2026-12", "date": "2026-05-10", "name": "Watkins Glen International", "track": "Watkins Glen International"}, {"race_id": "2026-13", "date": "2026-05-24", "name": "Charlotte Motor Speedway", "track": "Charlotte Motor Speedway"}, {"race_id": "2026-14", "date": "2026-05-31", "name": "Nashville Superspeedway", "track": "Nashville Superspeedway"}, {"race_id": "2026-15", "date": "2026-06-07", "name": "Michigan International Speedway", "track": "Michigan International Speedway"}, {"race_id": "2026-16", "date": "2026-06-14", "name": "Pocono Raceway", "track": "Pocono Raceway"}, {"race_id": "2026-17", "date": "2026-06-21", "name": "San Diego (Naval Base Coronado)", "track": "Naval Base Coronado"}, {"race_id": "2026-18", "date": "2026-06-28", "name": "Sonoma Raceway", "track": "Sonoma Raceway"}, {"race_id": "2026-19", "date": "2026-07-05", "name": "Chicagoland Speedway", "track": "Chicagoland Speedway"}, {"race_id": "2026-20", "date": "2026-07-12", "name": "EchoPark Speedway (Atlanta)", "track": "EchoPark Speedway"}, {"race_id": "2026-21", "date": "2026-07-19", "name": "North Wilkesboro Speedway", "track": "North Wilkesboro Speedway"}, {"race_id": "2026-22", "date": "2026-07-26", "name": "Indianapolis Motor Speedway", "track": "Indianapolis Motor Speedway"}, {"race_id": "2026-23", "date": "2026-08-09", "name": "Iowa Speedway", "track": "Iowa Speedway"}, {"race_id": "2026-24", "date": "2026-08-15", "name": "Richmond Raceway", "track": "Richmond Raceway"}, {"race_id": "2026-25", "date": "2026-08-23", "name": "New Hampshire Motor Speedway", "track": "New Hampshire Motor Speedway"}, {"race_id": "2026-26", "date": "2026-08-29", "name": "Daytona International Speedway", "track": "Daytona International Speedway"}, {"race_id": "2026-27", "date": "2026-09-06", "name": "Cook Out Southern 500", "track": "Darlington Raceway"}, {"race_id": "2026-28", "date": "2026-09-13", "name": "Enjoy Illinois 300", "track": "World Wide Technology Raceway"}, {"race_id": "2026-29", "date": "2026-09-19", "name": "Bass Pro Shops Night Race", "track": "Bristol Motor Speedway"}, {"race_id": "2026-30", "date": "2026-09-27", "name": "Hollywood Casino 400", "track": "Kansas Speedway"}, {"race_id": "2026-31", "date": "2026-10-04", "name": "Las Vegas Motor Speedway", "track": "Las Vegas Motor Speedway"}, {"race_id": "2026-32", "date": "2026-10-11", "name": "Bank of America 400", "track": "Charlotte Motor Speedway"}, {"race_id": "2026-33", "date": "2026-10-18", "name": "Phoenix Raceway", "track": "Phoenix Raceway"}, {"race_id": "2026-34", "date": "2026-10-25", "name": "Talladega Superspeedway", "track": "Talladega Superspeedway"}, {"race_id": "2026-35", "date": "2026-11-01", "name": "Martinsville Speedway", "track": "Martinsville Speedway"}, {"race_id": "2026-36", "date": "2026-11-08", "name": "NASCAR Championship", "track": "Homestead-Miami Speedway"}]'::jsonb) x;
insert into public.sp_drivers select jsonb_array_elements_text('["Ross Chastain", "Austin Cindric", "Austin Dillon", "Noah Gragson", "Kyle Larson", "Brad Keselowski", "Daniel Su\u00e1rez", "Chase Elliott", "Ty Dillon", "Denny Hamlin", "Ryan Blaney", "AJ Allmendinger", "Chris Buescher", "Chase Briscoe", "Christopher Bell", "Josh Berry", "Joey Logano", "Bubba Wallace", "William Byron", "Todd Gilliland", "Riley Herbst", "Zane Smith", "Cole Custer", "John Hunter Nemechek", "Erik Jones", "Tyler Reddick", "Ricky Stenhouse Jr.", "Alex Bowman", "Cody Ware", "Ty Gibbs", "Ryan Preece", "Michael McDowell", "Carson Hocevar", "Connor Zilisch", "Shane van Gisbergen"]'::jsonb);
create function public.sp_player() returns text language sql stable security definer set search_path='' as $$
 select case lower(email) when 'MATTHEW_EMAIL' then 'Matthew' when 'TANNER_EMAIL' then 'Tanner' when 'DEBORA_EMAIL' then 'Debora' when 'TOM_EMAIL' then 'Tom' end from auth.users where id=auth.uid() and email_confirmed_at is not null;
$$;
create function public.sp_snapshot() returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('phase',l.phase,'base',l.base,'revision',l.revision,'races',coalesce((select jsonb_agg(r.metadata || jsonb_build_object('id',r.id,'phase',r.phase,'officialRaceId',r.official_race_id,'picks',coalesce((select jsonb_object_agg(p.player,p.driver) from public.sp_picks p where p.race_id=r.id),'{}'::jsonb)) order by r.metadata->>'date',r.id) from public.sp_races r),'[]'::jsonb)) from public.sp_league l where id='family-2026';
$$;
-- Used by migration and authenticated commissioner only. Revision prevents stale whole-league edits.
create function public.sp_replace(payload jsonb, expected_revision bigint) returns void language plpgsql security definer set search_path='' as $$
declare r jsonb; p text; rev bigint;
begin
 if public.sp_player() is distinct from 'Matthew' then raise exception 'Commissioner only'; end if;
 select revision into rev from public.sp_league where id='family-2026' for update;
 if expected_revision is distinct from rev then raise exception 'League changed. Reload before trying again.'; end if;
 if payload->>'phase' not in ('regular','chase') or jsonb_typeof(payload->'races') <> 'array' then raise exception 'Invalid backup'; end if;
 delete from public.sp_races;
 for r in select value from jsonb_array_elements(payload->'races') loop
  insert into public.sp_races values(r->>'id',coalesce((select id from public.sp_schedule where info->>'date'=r->>'date'),r->>'officialRaceId'),r->>'phase',r-'picks'-'id'-'phase'-'officialRaceId');
  foreach p in array array['Matthew','Tanner','Tom','Debora'] loop
   if coalesce(r->'picks'->>p,'') <> '' then insert into public.sp_picks values(r->>'id',p,r->'picks'->>p); end if;
  end loop;
 end loop;
 update public.sp_league set phase=payload->>'phase',base=payload->'base',revision=revision+1 where id='family-2026';
end; $$;
-- Import the authoritative shared JSON; no browser-local state is uploaded automatically.
insert into public.sp_league values('family-2026','regular','{"Matthew":0,"Tanner":0,"Tom":0,"Debora":0}',0);
do $$ declare s jsonb; r jsonb; p text; begin
 select data into s from public.sunday_picks_league where id='family-2026';
 if s is null then raise exception 'Existing shared league missing; migration aborted'; end if;
 s=replace(s::text,'"Debra"','"Debora"')::jsonb;
 for r in select value from jsonb_array_elements(s->'races') loop
 insert into public.sp_races values(r->>'id',coalesce((select id from public.sp_schedule where info->>'date'=r->>'date'),r->>'officialRaceId'),r->>'phase',r-'picks'-'id'-'phase'-'officialRaceId');
 foreach p in array array['Matthew','Tanner','Tom','Debora'] loop
  if coalesce(r->'picks'->>p,'') <> '' then insert into public.sp_picks values(r->>'id',p,r->'picks'->>p); end if;
 end loop;
end loop;
update public.sp_league set phase=s->>'phase',base=s->'base',revision=1 where id='family-2026';
end $$;
-- Permanently retire anonymous whole-state writes, including old installed app versions.
alter table public.sunday_picks_league enable row level security;
revoke all on public.sunday_picks_league from anon, authenticated;
do $$ declare p record; begin for p in select policyname from pg_policies where schemaname='public' and tablename='sunday_picks_league' loop execute format('drop policy %I on public.sunday_picks_league',p.policyname); end loop; end $$;
create function public.sp_save_pick(race text, chosen_driver text) returns void language plpgsql security definer set search_path='' as $$
declare who text; ph text; info jsonb; rid text; other_phase text;
begin
 who=public.sp_player(); if who is null then raise exception 'Use your registered player email'; end if;
 select phase into ph from public.sp_league where id='family-2026' for update;
 select s.info into info from public.sp_schedule s where s.id=race;
 if info is null then raise exception 'Unknown race'; end if;
 if not exists(select 1 from public.sp_drivers where name=chosen_driver) then raise exception 'Unknown driver'; end if;
 -- Feed has dates only: lock at the start of race day in Eastern time.
 if now() >= ((info->>'date')::date::timestamp at time zone 'America/New_York') then raise exception 'Picks are locked for this race. Ask Matthew for a correction.'; end if;
 select id,phase into rid,other_phase from public.sp_races where official_race_id=race;
 if rid is not null and other_phase<>ph then raise exception 'Race belongs to another phase'; end if;
 if exists(select 1 from public.sp_races where id=rid and (metadata->>'scored')::boolean) then raise exception 'Race already scored'; end if;
 if exists(select 1 from public.sp_picks p join public.sp_races r on r.id=p.race_id where p.player=who and p.driver=chosen_driver and r.phase=ph and r.id is distinct from rid) then raise exception 'Driver already used this phase'; end if;
 if rid is null then
  rid=race;
  insert into public.sp_races values(rid,race,ph,jsonb_build_object('name',info->>'name','date',info->>'date','scored',false,'results','{}'::jsonb));
 end if;
 insert into public.sp_picks values(rid,who,chosen_driver) on conflict(race_id,player) do update set driver=excluded.driver;
 update public.sp_league set revision=revision+1 where id='family-2026';
end; $$;
alter table public.sp_league enable row level security;
alter table public.sp_races enable row level security;
alter table public.sp_picks enable row level security;
alter table public.sp_schedule enable row level security;
alter table public.sp_drivers enable row level security;
create policy shared_read on public.sp_league for select to anon,authenticated using(true);
create policy shared_read on public.sp_races for select to anon,authenticated using(true);
create policy shared_read on public.sp_picks for select to anon,authenticated using(true);
create policy shared_read on public.sp_schedule for select to anon,authenticated using(true);
create policy shared_read on public.sp_drivers for select to anon,authenticated using(true);
revoke all on public.sp_league,public.sp_races,public.sp_picks,public.sp_schedule,public.sp_drivers from anon,authenticated;
grant select on public.sp_league,public.sp_races,public.sp_picks,public.sp_schedule,public.sp_drivers to anon,authenticated;
revoke all on function public.sp_player(),public.sp_snapshot(),public.sp_replace(jsonb,bigint),public.sp_save_pick(text,text) from public,anon,authenticated;
grant execute on function public.sp_snapshot() to anon,authenticated;
grant execute on function public.sp_player(),public.sp_replace(jsonb,bigint),public.sp_save_pick(text,text) to authenticated;
commit;
