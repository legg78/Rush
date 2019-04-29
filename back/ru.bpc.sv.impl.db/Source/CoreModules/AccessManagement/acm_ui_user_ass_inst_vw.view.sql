create or replace force view acm_ui_user_ass_inst_vw as
select distinct * from(
    select 
        inst_id id
        , parent_id
        , user_id
        , is_default
        , is_entirely
        , name 
        , lang
        , description
        , decode(user_id, null,0,1) is_assigned
        , grant_type
        , level inst_level
        , connect_by_isleaf as is_leaf
    from (
       select distinct 
           ii.id inst_id
           , ii.parent_id
           , ui.user_id
           , nvl(ui.is_default, 0) is_default
           , nvl(ui.is_entirely, 0) is_entirely
           , ii.short_desc as name
           , ii.lang
           , ii.full_desc as description
           , ui.grant_type
       from (
           select distinct * from ost_ui_institution_all_vw 
           start with id in (
               select distinct inst_id
               from acm_ui_user_inst_vw
           ) 
           and lang = com_ui_user_env_pkg.get_user_lang()
           connect by prior parent_id = id and prior lang = lang
       ) ii, acm_ui_user_inst_vw ui
    where ii.id = ui.inst_id(+) 
      and ii.lang = ui.lang(+)
    ) i 
    start with i.parent_id is null
    connect by prior i.inst_id = i.parent_id
)
/
