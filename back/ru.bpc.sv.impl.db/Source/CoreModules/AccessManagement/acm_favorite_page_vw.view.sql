create or replace force view acm_favorite_page_vw as
select user_id
     , section_id
from acm_favorite_page
/