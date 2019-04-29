create materialized view acm_user_inst_mvw 
cache 
build immediate
refresh on demand complete 
with primary key 
as
select x.inst_id
     , x.user_id
     , nvl(y.is_default, get_false) is_default
     , nvl(y.is_entirely, get_false) is_entirely
     , grant_type
  from ( 
        select inst_id
             , user_id
             , decode(min(lvl)
             , 0,  'ROOT'
             , -1, 'DEFAULT'
             , 1,  'DIRECT'
             ,     'PARENT' ) as grant_type
          from (
                -- get all institutions for user with ROOT role
                select f.id as inst_id
                     , e.user_id
                     , 0 as lvl
                  from ost_institution f
                     , (
                        select b.user_id
                          from acm_user_role b
                             , acm_role c
                         where b.role_id = c.id
                           and c.name = 'ROOT'
                       ) e
                union all
                -- get granted institutions including subordinate institutions
                (select inst_id, user_id, min(lvl) as lvl
                  from (
                    select inst_id, user_id, level as lvl 
                      from (
                            select a.id inst_id
                                 , b.id user_id
                                 , parent_id 
                              from ost_institution a
                                 , acm_user b   
                           ) 
                    connect by prior inst_id = parent_id
                           and prior user_id = user_id
                      start with (inst_id, user_id) in (select inst_id, user_id from acm_user_inst)
                       )
                       group by inst_id, user_id )
                union all
                -- get default institution 9999
                select get_def_inst
                     , o.id as user_id
                     , -1 as lvl
                  from acm_user o
               )
        group  by user_id, inst_id
       ) x
     , acm_user_inst y
 where x.user_id = y.user_id(+)
   and x.inst_id = y.inst_id(+)
/

create index acm_user_inst_mvw_ndx on acm_user_inst_mvw (user_id, inst_id)
/
