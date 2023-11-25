
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}

with clean_manual_ratings as (
  select 
    review_id,
    case 
      when rating < 1 then rating + 1
      when rating > rating_max then ((rating*rating_max)/100)
      else rating
      end as rating,
    case 
      when rating < 1 then rating_max + 1 
      else rating_max
      end as rating_max,
    weight,
    case 
      when critical = false then 0
      else 1
      end as critical,
    case
      when category_name like '%Product%' then 'Product knowledge'
      when category_name like '%GDPR%' then 'GDPR'
      when category_name like '%Knowledge%' then 'Knowledge base'
      when category_name like '%Tone%' then 'Tone'
      when category_name like '%Solution%' then 'Solution'
      when category_name like '%Grammar%' then 'Grammar'
      when category_name like '%Weather%' then 'Weather'
      when category_name like '%Closing%' then 'Closing'
      when category_name like '%Empathy%' then 'Empathy'
      when category_name like '%AIpie%' then 'AIpie'
      when category_name like '%Greeting%' then 'Greeting'
      when category_name like '%Readability%' then 'Readability'
      else 'Undefined'
    end as category
  from `RawData.Manual_Ratings`
  where category_name not in (
    'test cat',
    'Autoqa test',
    'Test',
    'Dog gifs',
    'Cat gifs',
    'Cat memes',
    'Purr for'
      )
  and rating is not null
),
ManualScore as (
  select 
    review_id,
    (rating / rating_max) * (weight+critical) * 100 as category_score,
    category
  from clean_manual_ratings
),
ManualCombined as (
  select 
    mr.review_id,
    mr.created as review_created,
    mr.conversation_created_at,
    mr.conversation_external_id,
    mr.created,
    mr.score,
    -- assignment_review, -- all data are false
    mr.seen,
    mr.disputed,
    -- review_time_seconds, -- empty column
    -- assignment_name
    ms.category_score,
    ms.category
  from ManualScore as ms
  left join `RawData.Manual_Reviews` as mr
  on ms.review_id = mr.review_id
),
AutoQACombined as (
    select 
  datetime(format_timestamp('%Y-%m-%d %H:%M:%S', re.created_at)) AS review_created,
  re.conversation_created_at,
  ra.external_ticket_id as conversation_external_id,
  cast(avg(ra.score) as int) as category_score,
  case
    when ra.rating_category_name like '%Product%' then 'Product knowledge'
    when ra.rating_category_name like '%GDPR%' then 'GDPR'
    when ra.rating_category_name like '%Knowledge%' then 'Knowledge base'
    when ra.rating_category_name like '%Tone%' then 'Tone'
    when ra.rating_category_name like '%Solution%' then 'Solution'
    when ra.rating_category_name like '%Grammar%' then 'Grammar'
    when ra.rating_category_name like '%Weather%' then 'Weather'
    when ra.rating_category_name like '%Closing%' then 'Closing'
    when ra.rating_category_name like '%Empathy%' then 'Empathy'
    when ra.rating_category_name like '%AIpie%' then 'AIpie'
    when ra.rating_category_name like '%Greeting%' then 'Greeting'
    when ra.rating_category_name like '%Readability%' then 'Readability'
    else 'Undefined'
  end as category
  from RawData.Autoqa_Ratings ra
  left join RawData.Autoqa_Reviews re
  on ( ra.payment_token_id = re.payment_token_id and ra.team_id =re.team_id and ra.external_ticket_id = re.external_ticket_id)
  where score is not null
  group by 1,2,3,5
)
select 
c.external_ticket_id,
c.conversation_created_at,
c.closed_at,
c.channel,
c.message_count,
c.language,
c.unique_public_agent_count,
c.public_mean_character_count,
c.public_mean_word_count,
c.private_message_count,
c.public_message_count,
c.klaus_sentiment,
c.is_closed,
m.review_created,
m.category_score,
m.category,
'Reviewer' as source,
from ManualCombined as m
left join RawData.Conversations as c
on c.external_ticket_id = m.conversation_external_id

union all

select 
c.external_ticket_id,
c.conversation_created_at,
c.closed_at,
c.channel,
c.message_count,
c.language,
c.unique_public_agent_count,
c.public_mean_character_count,
c.public_mean_word_count,
c.private_message_count,
c.public_message_count,
c.klaus_sentiment,
c.is_closed,
a.review_created,
a.category_score,
a.category, 
'AI' as source,
from AutoQACombined as a
left join RawData.Conversations as c
on c.external_ticket_id = a.conversation_external_id
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17


/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
