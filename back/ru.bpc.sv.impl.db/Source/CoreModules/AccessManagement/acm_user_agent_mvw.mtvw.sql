create materialized view acm_user_agent_mvw
cache
logging
build immediate
refresh complete on demand as
select x.agent_id
     , x.user_id
     , nvl (y.is_default, get_false) is_default
     , x.grant_type
from
    (select agent_id
          , user_id
          , decode (min (lvl)
                  , 0,   'ROOT'
                  , 1,   'DIRECT'
                     ,   'PARENT') as grant_type
     from(
        -- all agents for root
         select f.id as agent_id
              , e.user_id
              , 0 as lvl
         from ost_agent f
          , ( select b.user_id
              from acm_user_role b
                 , acm_role c
              where b.role_id = c.id
              and c.name = 'ROOT'
            ) e
        union all
        -- direct agents
        select a.agent_id
             , a.user_id
             , 1 as lvl 
        from acm_user_agent a
        union all
        -- all child agents for  'entirely' institution
        select d.id as agent_id
             , c.user_id
             , 2 as lvl
        from
            (select inst_id
                  , user_id
             from( 
                 select a.id inst_id
                      , b.id as user_id
                      , parent_id 
                 from ost_institution a
                    , acm_user b
                 )
             connect by prior inst_id = parent_id
             and prior user_id        = user_id
             start with(inst_id, user_id) in 
                 ( select inst_id
                        , user_id
                   from acm_user_inst
                   where is_entirely = get_true
                 )
            ) c
          , ost_agent d
        where c.inst_id = d.inst_id
        )
   group by agent_id, user_id
    ) x
  , acm_user_agent y
where x.user_id  = y.user_id(+)
  and x.agent_id = y.agent_id(+)
union all
        -- default agent
select get_def_agent as agent_id
      ,o.id as user_id
      ,decode(nvl(r.is_default
                , get_false)
             ,get_true
             ,get_false
             ,get_false
             ,get_true) is_default
      ,'DEFAULT' as grant_type
from   acm_user o
      ,(select sum(p.is_default) is_default
             , p.user_id
        from   acm_user_agent p
        group  by p.user_id) r
where  o.id = r.user_id(+)
/

create index acm_user_agent_mvw_ndx on acm_user_agent_mvw (user_id, agent_id)
/
