
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}

with data_prep as (
  select 
    case
      when category_score between 0 and 10 then '0 - 10%'
      when category_score between 11 and 20 then '10 - 20%'
      when category_score between 21 and 30 then '20 - 30%'
      when category_score between 31 and 40 then '30 - 40%'
      when category_score between 41 and 50 then '40 - 50%'
      when category_score between 51 and 60 then '50 - 60%'
      when category_score between 61 and 70 then '60 - 70%'
      when category_score between 71 and 80 then '70 - 80%'
      when category_score between 81 and 90 then '80 - 90%'
      when category_score between 91 and 100 then '90 - 100%'
      end as category_scores,
  *
  from TransformedData.Conversation_Rating
  where source = 'AutoQA')

select 
distinct source as Source,
category as Destination,
count(*) as Value
from TransformedData.Conversation_Rating
where source = 'AutoQA'
group by 1,2

union all 

select 
distinct category as Source,
  case
    when category_score between 0 and 10 then '0 - 10%'
    when category_score between 11 and 20 then '10 - 20%'
    when category_score between 21 and 30 then '20 - 30%'
    when category_score between 31 and 40 then '30 - 40%'
    when category_score between 41 and 50 then '40 - 50%'
    when category_score between 51 and 60 then '50 - 60%'
    when category_score between 61 and 70 then '60 - 70%'
    when category_score between 71 and 80 then '70 - 80%'
    when category_score between 81 and 90 then '80 - 90%'
    when category_score between 91 and 100 then '90 - 100%'
    end as Destination,
count(*) as Value
from TransformedData.Conversation_Rating
where source = 'AutoQA'
group by 1,2


union all 

select 
distinct category_scores as Source,
klaus_sentiment as Destination,
count(*) as Value
from data_prep 
group by 1,2


/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null
