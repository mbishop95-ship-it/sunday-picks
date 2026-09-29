-- Run once after 001-player-picks.sql. Does not change picks, results or standings.
begin;
update public.sp_schedule s set info=s.info || (x-'race_id') from jsonb_array_elements('[{"race_id": "2026-01", "starts_at": "2026-02-15T18:30:00+00:00", "nascar_race_id": "5596"}, {"race_id": "2026-02", "starts_at": "2026-02-22T20:00:00+00:00", "nascar_race_id": "5597"}, {"race_id": "2026-03", "starts_at": "2026-03-01T20:30:00+00:00", "nascar_race_id": "5598"}, {"race_id": "2026-04", "starts_at": "2026-03-08T19:30:00+00:00", "nascar_race_id": "5599"}, {"race_id": "2026-05", "starts_at": "2026-03-15T20:00:00+00:00", "nascar_race_id": "5600"}, {"race_id": "2026-06", "starts_at": "2026-03-22T19:00:00+00:00", "nascar_race_id": "5603"}, {"race_id": "2026-07", "starts_at": "2026-03-29T19:30:00+00:00", "nascar_race_id": "5602"}, {"race_id": "2026-08", "starts_at": "2026-04-12T19:00:00+00:00", "nascar_race_id": "5604"}, {"race_id": "2026-09", "starts_at": "2026-04-19T18:00:00+00:00", "nascar_race_id": "5607"}, {"race_id": "2026-10", "starts_at": "2026-04-26T19:00:00+00:00", "nascar_race_id": "5605"}, {"race_id": "2026-11", "starts_at": "2026-05-03T19:30:00+00:00", "nascar_race_id": "5606"}, {"race_id": "2026-12", "starts_at": "2026-05-10T19:00:00+00:00", "nascar_race_id": "5621"}, {"race_id": "2026-13", "starts_at": "2026-05-24T22:00:00+00:00", "nascar_race_id": "5610"}, {"race_id": "2026-14", "starts_at": "2026-05-31T23:00:00+00:00", "nascar_race_id": "5611"}, {"race_id": "2026-15", "starts_at": "2026-06-07T19:00:00+00:00", "nascar_race_id": "5612"}, {"race_id": "2026-16", "starts_at": "2026-06-14T17:00:00+00:00", "nascar_race_id": "5614"}, {"race_id": "2026-17", "starts_at": "2026-06-21T20:00:00+00:00", "nascar_race_id": "5613"}, {"race_id": "2026-18", "starts_at": "2026-06-28T19:30:00+00:00", "nascar_race_id": "5617"}, {"race_id": "2026-19", "starts_at": "2026-07-05T22:00:00+00:00", "nascar_race_id": "5616"}, {"race_id": "2026-20", "starts_at": "2026-07-12T23:00:00+00:00", "nascar_race_id": "5615"}, {"race_id": "2026-21", "starts_at": "2026-07-19T23:00:00+00:00", "nascar_race_id": "5618"}, {"race_id": "2026-22", "starts_at": "2026-07-26T18:00:00+00:00", "nascar_race_id": "5619"}, {"race_id": "2026-23", "starts_at": "2026-08-09T19:30:00+00:00", "nascar_race_id": "5620"}, {"race_id": "2026-24", "starts_at": "2026-08-15T23:00:00+00:00", "nascar_race_id": "5622"}, {"race_id": "2026-25", "starts_at": "2026-08-23T18:00:00+00:00", "nascar_race_id": "5627"}, {"race_id": "2026-26", "starts_at": "2026-08-29T23:30:00+00:00", "nascar_race_id": "5623"}, {"race_id": "2026-27", "starts_at": "2026-09-06T21:00:00+00:00", "nascar_race_id": "5624"}, {"race_id": "2026-28", "starts_at": "2026-09-13T19:00:00+00:00", "nascar_race_id": "5625"}, {"race_id": "2026-29", "starts_at": "2026-09-19T23:30:00+00:00", "nascar_race_id": "5626"}, {"race_id": "2026-30", "starts_at": "2026-09-27T19:00:00+00:00", "nascar_race_id": "5628"}, {"race_id": "2026-31", "starts_at": "2026-10-04T21:30:00+00:00", "nascar_race_id": "5630"}, {"race_id": "2026-32", "starts_at": "2026-10-11T19:00:00+00:00", "nascar_race_id": "5629"}, {"race_id": "2026-33", "starts_at": "2026-10-18T19:00:00+00:00", "nascar_race_id": "5633"}, {"race_id": "2026-34", "starts_at": "2026-10-25T18:00:00+00:00", "nascar_race_id": "5631"}, {"race_id": "2026-35", "starts_at": "2026-11-01T19:00:00+00:00", "nascar_race_id": "5632"}, {"race_id": "2026-36", "starts_at": "2026-11-08T20:00:00+00:00", "nascar_race_id": "5601"}]'::jsonb) x where s.id=x->>'race_id';
create or replace function public.sp_save_pick(race text, chosen_driver text) returns void language plpgsql security definer set search_path='' as $$
declare who text; ph text; info jsonb; rid text; other_phase text;
begin
 who=public.sp_player(); if who is null then raise exception 'Use your registered player email'; end if;
 select phase into ph from public.sp_league where id='family-2026' for update;
 select s.info into info from public.sp_schedule s where s.id=race;
 if info is null then raise exception 'Unknown race'; end if;
 if not exists(select 1 from public.sp_drivers where name=chosen_driver) then raise exception 'Unknown driver'; end if;
 -- Enforce the scheduled race start using the database clock.
 if info->>'starts_at' is null then raise exception 'Race start time is not available. Ask Matthew to update the schedule.'; end if;
 if clock_timestamp() >= (info->>'starts_at')::timestamptz then raise exception 'Picks are locked for this race. Ask Matthew for a correction.'; end if;
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

-- Matthew can synchronize deadline updates from the official feed; other accounts cannot.
create or replace function public.sp_sync_start_times(entries jsonb) returns void language plpgsql security definer set search_path='' as $$
declare x jsonb; old_start timestamptz; new_start timestamptz;
begin
 if public.sp_player() is distinct from 'Matthew' then raise exception 'Commissioner only'; end if;
 for x in select value from jsonb_array_elements(entries) loop
  new_start=(x->>'starts_at')::timestamptz;
  if new_start is null then continue; end if;
  select (info->>'starts_at')::timestamptz into old_start from public.sp_schedule where id=x->>'race_id' for update;
  -- Never reopen a race after its stored deadline has passed.
  if old_start is null or clock_timestamp()<old_start then
   update public.sp_schedule set info=info || jsonb_build_object('starts_at',new_start,'nascar_race_id',x->>'nascar_race_id') where id=x->>'race_id';
  end if;
 end loop;
end; $$;
revoke all on function public.sp_sync_start_times(jsonb) from public,anon,authenticated;
grant execute on function public.sp_sync_start_times(jsonb) to authenticated;
commit;
