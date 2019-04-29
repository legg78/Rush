create or replace force view acm_ui_user_ass_agent_vw as
select 
      id
    , name
    , parent_Id
    , is_default
    , inst_id
    , user_id
    , is_default_for_user
    , is_default_for_inst
    , agent_type
    , decode(user_id, null,0,1) is_assigned
    , grant_type
    , level agent_level
    , connect_by_isleaf as is_leaf
from (
    select distinct 
              ii.id
            , ii.parent_id
            , nvl(ui.is_default, 0) is_default
            , ui.user_id
            , ui.agent_type
            , nvl(ui.is_default, 0) is_default_for_user
            , nvl(ii.is_default, 0) is_default_for_inst
            , ii.name
            , ii.inst_id
            , ui.grant_type
    from (
        select distinct id
                      , seqnum
                      , inst_id
                      , parent_id
                      , agent_type
                      , is_default
                      , name
                      , description
                      , lang
                      , agent_number 
                   from ost_ui_agent_vw
        start with id in (
            select distinct agent_id
            from acm_ui_user_agent_vw
        ) 
        and lang = com_ui_user_env_pkg.get_user_lang()
        connect by prior parent_id = id and prior lang = lang
    ) ii, acm_ui_user_agent_vw ui
    where ii.id = ui.agent_id(+) and ii.lang = ui.lang(+)
) i 
start with i.parent_id is null
connect by prior i.id = i.parent_id
/
