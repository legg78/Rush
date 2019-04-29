declare
    l_count number := 0;
begin
    execute immediate 'create table zsave_opr_match_level as select * from opr_match_level order by id';

    for r_level in (
        select level_id
             , priority
             , max(condition) condition
          from (
              select t.rn
                   , t.level_id
                   , t.priority
                   , replace(sys_connect_by_path('(' || t.condition || ')', '__and_'), '__and_', ' and ') as condition
                from (
                    select row_number() over (partition by level_id order by priority) rn
                         , level_id
                         , condition
                         , priority
                      from (
                          select l.id as level_id
                               , c.condition
                               , l.priority
                            from opr_match_level l
                               , opr_match_level_condition lc
                               , opr_match_condition c
                           where lc.level_id = l.id
                             and c.id = lc.condition_id
                      )
                ) t
                start with t.rn = 1
                connect by prior t.level_id = t.level_id
                       and prior t.rn + 1   = t.rn
          )
          group by priority
                 , level_id
          order by priority
                 , level_id
    ) loop

        l_count := l_count + 10;

        update opr_match_level set priority = l_count where id = r_level.level_id;
        
    end loop;
end;
