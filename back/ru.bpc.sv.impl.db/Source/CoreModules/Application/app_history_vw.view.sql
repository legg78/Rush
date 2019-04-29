create or replace force view app_history_vw as
select
    a.id
    , a.seqnum
    , a.appl_id
    , a.change_date
    , a.change_user
    , a.change_action
    , a.appl_status
    , a.comments
    , a.reject_code
from
    app_history a
/
