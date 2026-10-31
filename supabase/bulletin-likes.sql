-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run.
-- (If your editor drops lines when pasting, run it in three pieces.)

create table if not exists public.bulletin_likes (
  bulletin_id text primary key check (char_length(bulletin_id) <= 120),
  likes integer not null default 0 check (likes >= 0)
);

alter table public.bulletin_likes enable row level security;

drop policy if exists "Anyone can read likes" on public.bulletin_likes;
create policy "Anyone can read likes"
  on public.bulletin_likes
  for select
  to anon, authenticated
  using (true);

grant select on public.bulletin_likes to anon, authenticated;

create or replace function public.change_like(bid text, delta integer)
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  new_count integer;
begin
  if bid is null or char_length(bid) = 0 or char_length(bid) > 120 then
    raise exception 'invalid bulletin id';
  end if;
  if delta not in (1, -1) then
    raise exception 'delta must be 1 or -1';
  end if;

  insert into public.bulletin_likes (bulletin_id, likes)
  values (bid, greatest(delta, 0))
  on conflict (bulletin_id)
  do update set likes = greatest(public.bulletin_likes.likes + delta, 0)
  returning likes into new_count;

  return new_count;
end;
$$;

revoke all on function public.change_like(text, integer) from public;
grant execute on function public.change_like(text, integer) to anon, authenticated;
