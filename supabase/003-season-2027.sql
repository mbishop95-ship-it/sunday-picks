-- Sunday Picks 2027, isolated from 2026. Run once in Supabase SQL Editor.
begin;
create table if not exists public.sp27_league (id text primary key, phase text not null check(phase in ('regular','chase')), base jsonb not null, revision bigint not null default 0);
create table if not exists public.sp27_races (id text primary key, official_race_id text unique, phase text not null check(phase in ('regular','chase')), metadata jsonb not null);
create table if not exists public.sp27_picks (race_id text references public.sp27_races(id) on delete cascade, player text check(player in ('Matthew','Tanner','Tom','Debora')), driver text not null, primary key(race_id,player));
create table if not exists public.sp27_schedule (id text primary key, info jsonb not null);
insert into public.sp27_league values ('family-2027','regular','{"Matthew":0,"Tanner":0,"Tom":0,"Debora":0}'::jsonb,0) on conflict(id) do nothing;
insert into public.sp27_schedule(id,info)
select x->>'race_id',x from jsonb_array_elements('[{"race_id":"2027-01","date":"2027-02-21","name":"Daytona 500","track":"Daytona International Speedway","phase":"regular","starts_at":null},{"race_id":"2027-02","date":"2027-02-28","name":"Autotrader 400","track":"EchoPark Speedway","phase":"regular","starts_at":null},{"race_id":"2027-03","date":"2027-03-07","name":"DuraMAX Texas Grand Prix","track":"Circuit of The Americas","phase":"regular","starts_at":null},{"race_id":"2027-04","date":"2027-03-14","name":"Phoenix Raceway","track":"Phoenix Raceway","phase":"regular","starts_at":null},{"race_id":"2027-05","date":"2027-03-21","name":"Las Vegas Motor Speedway","track":"Las Vegas Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-06","date":"2027-04-04","name":"Darlington Raceway","track":"Darlington Raceway","phase":"regular","starts_at":null},{"race_id":"2027-07","date":"2027-04-11","name":"Bristol Motor Speedway","track":"Bristol Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-08","date":"2027-04-18","name":"Cook Out 400","track":"Martinsville Speedway","phase":"regular","starts_at":null},{"race_id":"2027-09","date":"2027-04-25","name":"Jack Link''s 500","track":"Talladega Superspeedway","phase":"regular","starts_at":null},{"race_id":"2027-10","date":"2027-05-02","name":"Würth 400 presented by Liqui Moly","track":"Texas Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-11","date":"2027-05-09","name":"Kansas Speedway","track":"Kansas Speedway","phase":"regular","starts_at":null},{"race_id":"2027-12","date":"2027-05-16","name":"Dover Motor Speedway","track":"Dover Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-13","date":"2027-05-30","name":"Coca-Cola 600","track":"Charlotte Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-14","date":"2027-06-06","name":"Nashville Superspeedway","track":"Nashville Superspeedway","phase":"regular","starts_at":null},{"race_id":"2027-15","date":"2027-06-13","name":"Great American Getaway 400","track":"Pocono Raceway","phase":"regular","starts_at":null},{"race_id":"2027-16","date":"2027-06-20","name":"Michigan International Speedway","track":"Michigan International Speedway","phase":"regular","starts_at":null},{"race_id":"2027-17","date":"2027-06-27","name":"Chicagoland Speedway","track":"Chicagoland Speedway","phase":"regular","starts_at":null},{"race_id":"2027-18","date":"2027-07-04","name":"Iowa Speedway","track":"Iowa Speedway","phase":"regular","starts_at":null},{"race_id":"2027-19","date":"2027-07-11","name":"Toyota/Save Mart 350","track":"Sonoma Raceway","phase":"regular","starts_at":null},{"race_id":"2027-20","date":"2027-07-18","name":"Dollar Tree 400","track":"EchoPark Speedway","phase":"regular","starts_at":null},{"race_id":"2027-21","date":"2027-07-25","name":"Brickyard 400","track":"Indianapolis Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-22","date":"2027-08-01","name":"Naval Base Coronado","track":"Naval Base Coronado","phase":"regular","starts_at":null},{"race_id":"2027-23","date":"2027-08-14","name":"Bass Pro Shops Night Race","track":"Bristol Motor Speedway","phase":"regular","starts_at":null},{"race_id":"2027-24","date":"2027-08-22","name":"Enjoy Illinois 300","track":"World Wide Technology Raceway","phase":"regular","starts_at":null},{"race_id":"2027-25","date":"2027-08-28","name":"Coke Zero Sugar 400","track":"Daytona International Speedway","phase":"regular","starts_at":null},{"race_id":"2027-26","date":"2027-09-05","name":"Southern 500","track":"Darlington Raceway","phase":"regular","starts_at":null},{"race_id":"2027-27","date":"2027-09-11","name":"Richmond Raceway","track":"Richmond Raceway","phase":"chase","starts_at":null},{"race_id":"2027-28","date":"2027-09-19","name":"Watkins Glen International","track":"Watkins Glen International","phase":"chase","starts_at":null},{"race_id":"2027-29","date":"2027-09-26","name":"New Hampshire Motor Speedway","track":"New Hampshire Motor Speedway","phase":"chase","starts_at":null},{"race_id":"2027-30","date":"2027-10-03","name":"Kansas Speedway","track":"Kansas Speedway","phase":"chase","starts_at":null},{"race_id":"2027-31","date":"2027-10-10","name":"Las Vegas Motor Speedway","track":"Las Vegas Motor Speedway","phase":"chase","starts_at":null},{"race_id":"2027-32","date":"2027-10-17","name":"Charlotte Motor Speedway","track":"Charlotte Motor Speedway","phase":"chase","starts_at":null},{"race_id":"2027-33","date":"2027-10-24","name":"Freeway Insurance 500","track":"Phoenix Raceway","phase":"chase","starts_at":null},{"race_id":"2027-34","date":"2027-10-31","name":"YellaWood 500","track":"Talladega Superspeedway","phase":"chase","starts_at":null},{"race_id":"2027-35","date":"2027-11-07","name":"Xfinity 500","track":"Martinsville Speedway","phase":"chase","starts_at":null},{"race_id":"2027-36","date":"2027-11-14","name":"Homestead-Miami Speedway","track":"Homestead-Miami Speedway","phase":"chase","starts_at":null}]'::jsonb) x
on conflict(id) do nothing;
create or replace function public.sp27_snapshot() returns jsonb language sql stable security definer set search_path='' as $$
 select jsonb_build_object('phase',l.phase,'base',l.base,'revision',l.revision,'races',coalesce((select jsonb_agg(r.metadata || jsonb_build_object('id',r.id,'phase',r.phase,'officialRaceId',r.official_race_id,'picks',coalesce((select jsonb_object_agg(p.player,p.driver) from public.sp27_picks p where p.race_id=r.id),'{}'::jsonb)) order by r.metadata->>'date',r.id) from public.sp27_races r),'[]'::jsonb))
 from public.sp27_league l where id='family-2027';
$$;
create or replace function public.sp27_save_pick(race text,chosen_driver text) returns void language plpgsql security definer set search_path='' as $$
declare who text; ph text; info jsonb; rid text; other_phase text; expected_phase text;
begin
 who=public.sp_player(); if who is null then raise exception 'Use your registered player email'; end if;
 select phase into ph from public.sp27_league where id='family-2027' for update;
 select s.info into info from public.sp27_schedule s where s.id=race;
 if info is null then raise exception 'Unknown 2027 race'; end if;
 expected_phase=coalesce(info->>'phase',case when (right(race,2))::int<=26 then 'regular' else 'chase' end);
 if ph<>expected_phase then raise exception 'This race belongs to the other season phase'; end if;
 if not exists(select 1 from public.sp_drivers where name=chosen_driver) then raise exception 'Unknown driver'; end if;
 if info->>'starts_at' is null then raise exception 'Race start time is not available yet'; end if;
 if clock_timestamp()>=(info->>'starts_at')::timestamptz then raise exception 'Picks are locked for this race'; end if;
 select id,phase into rid,other_phase from public.sp27_races where official_race_id=race;
 if rid is not null and other_phase<>ph then raise exception 'Race belongs to another phase'; end if;
 if exists(select 1 from public.sp27_races where id=rid and coalesce((metadata->>'scored')::boolean,false)) then raise exception 'Race already scored'; end if;
 if exists(select 1 from public.sp27_picks p join public.sp27_races r on r.id=p.race_id where p.player=who and p.driver=chosen_driver and r.phase=ph and r.id is distinct from rid) then raise exception 'Driver already used this phase'; end if;
 if rid is null then
  rid=race;
  insert into public.sp27_races values(rid,race,ph,jsonb_build_object('name',info->>'name','date',info->>'date','scored',false,'results','{}'::jsonb));
 end if;
 insert into public.sp27_picks values(rid,who,chosen_driver) on conflict(race_id,player) do update set driver=excluded.driver;
 update public.sp27_league set revision=revision+1 where id='family-2027';
end; $$;
create or replace function public.sp27_replace(payload jsonb,expected_revision bigint) returns void language plpgsql security definer set search_path='' as $$
declare r jsonb; p text; rev bigint;
begin
 if public.sp_player() is distinct from 'Matthew' then raise exception 'Commissioner only'; end if;
 select revision into rev from public.sp27_league where id='family-2027' for update;
 if expected_revision is distinct from rev then raise exception 'League changed. Reload before saving'; end if;
 if payload->>'phase' not in ('regular','chase') or jsonb_typeof(payload->'races') <> 'array' then raise exception 'Invalid league data'; end if;
 delete from public.sp27_races where id is not null;
 for r in select value from jsonb_array_elements(payload->'races') loop
  if r->>'officialRaceId' not like '2027-%' then raise exception 'Invalid 2027 race'; end if;
  insert into public.sp27_races values(r->>'id',r->>'officialRaceId',r->>'phase',r-'picks'-'id'-'phase'-'officialRaceId');
  foreach p in array array['Matthew','Tanner','Tom','Debora'] loop
   if coalesce(r->'picks'->>p,'')<>'' then insert into public.sp27_picks values(r->>'id',p,r->'picks'->>p); end if;
  end loop;
 end loop;
 update public.sp27_league set phase=payload->>'phase',base=payload->'base',revision=revision+1 where id='family-2027';
end; $$;
create or replace function public.sp27_sync_start_times(entries jsonb) returns void language plpgsql security definer set search_path='' as $$
declare x jsonb; old_start timestamptz; new_start timestamptz;
begin
 if public.sp_player() is distinct from 'Matthew' then raise exception 'Commissioner only'; end if;
 for x in select value from jsonb_array_elements(entries) loop
  if x->>'starts_at' is null then continue; end if;
  new_start=(x->>'starts_at')::timestamptz;
  select (info->>'starts_at')::timestamptz into old_start from public.sp27_schedule where id=x->>'race_id' for update;
  if old_start is null or clock_timestamp()<old_start then
   update public.sp27_schedule set info=info || jsonb_build_object('starts_at',new_start,'nascar_race_id',x->>'nascar_race_id') where id=x->>'race_id';
  end if;
 end loop;
end; $$;
alter table public.sp27_league enable row level security;
alter table public.sp27_races enable row level security;
alter table public.sp27_picks enable row level security;
alter table public.sp27_schedule enable row level security;
create policy sp27_read on public.sp27_league for select to anon,authenticated using(true);
create policy sp27_read on public.sp27_races for select to anon,authenticated using(true);
create policy sp27_read on public.sp27_picks for select to anon,authenticated using(true);
create policy sp27_read on public.sp27_schedule for select to anon,authenticated using(true);
revoke all on public.sp27_league,public.sp27_races,public.sp27_picks,public.sp27_schedule from anon,authenticated;
grant select on public.sp27_league,public.sp27_races,public.sp27_picks,public.sp27_schedule to anon,authenticated;
revoke all on function public.sp27_snapshot(),public.sp27_save_pick(text,text),public.sp27_replace(jsonb,bigint),public.sp27_sync_start_times(jsonb) from public,anon,authenticated;
grant execute on function public.sp27_snapshot() to anon,authenticated;
grant execute on function public.sp27_save_pick(text,text),public.sp27_replace(jsonb,bigint),public.sp27_sync_start_times(jsonb) to authenticated;
commit;
