create or replace force view mup_ui_message_vw
as
select
    com_api_label_pkg.get_label_text('MUP_CLEARING_MESSAGE',  l.lang) as name
  , a.mti || '/' || a.de024 as tech_msg_type
  , a.id as oper_id
  , '' as tech_id
  , '' as time_mark
  , 'mup_ui_fin_msg_vw' as view_name
  , l.lang
  , a.de012 as oper_date
from
    mup_fin a
  , com_language_vw l                
order by
    time_mark
  , oper_date     
/
