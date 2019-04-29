declare
    l_merged    number;
    l_reversal  number;
begin
    for cur in (select id
                  from prc_container
                 where process_id = 10000047)
    loop
        select nvl(max(param_value), com_api_const_pkg.TRUE)
          into l_reversal
          from prc_parameter_value
         where container_id = cur.id
           and param_id = 10002391;

        select nvl(max(param_value), com_api_const_pkg.TRUE)
          into l_merged
          from prc_parameter_value
         where container_id = cur.id
           and param_id = 10002989;

        merge into prc_parameter_value dst
        using (
            select null                id
                 , cur.id              container_id 
                 , 10003047            param_id
                 , case
                       when l_reversal = com_api_const_pkg.TRUE
                        and l_merged   = com_api_const_pkg.TRUE
                       then
                           opr_api_const_pkg.REVERSAL_UPLOAD_ALL
                       when l_reversal = com_api_const_pkg.FALSE
                        and l_merged   = com_api_const_pkg.TRUE
                       then
                           opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                       when l_reversal = com_api_const_pkg.TRUE
                        and l_merged   = com_api_const_pkg.FALSE
                       then
                           opr_api_const_pkg.REVERSAL_UPLOAD_WITHOUT_MERGED
                       when l_reversal = com_api_const_pkg.FALSE
                        and l_merged   = com_api_const_pkg.FALSE
                       then
                           opr_api_const_pkg.REVERSAL_UPLOAD_ORIGINAL
                   end                 param_value
              from dual
        ) src
        on (
            src.container_id = dst.container_id
        and src.param_id     = dst.param_id
        )
        when not matched then
            insert (
                dst.id
              , dst.container_id
              , dst.param_id
              , dst.param_value
            )
            values (
                prc_parameter_value_seq.nextval
              , src.container_id
              , src.param_id
              , src.param_value
            );
    end loop;

    delete from prc_parameter_value
     where container_id in (select id
                              from prc_container
                             where process_id = 10000047)
       and param_id in (10002391, 10002989);
end;
