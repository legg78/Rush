create or replace force view prc_ui_user_session_vw as
select
    s.id
  , u.user_name
  , s.start_time
  , s.end_time last_used
  , u.first_name
  , u.second_name
  , u.surname
  , u.lang
  , s.ip_address
  , (select min(a.status) from adt_trail a where a.session_id = s.id and a.priv_id = 10000037) login_status 
from
    prc_session s
  , acm_ui_user_vw u
where
    s.user_id = u.user_id(+)
    and s.process_id is null
/
