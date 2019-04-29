begin
    delete
      from prc_parameter_value
     where id in(
         select pv.id
           from prc_container c
              , prc_parameter_value pv
              , prc_parameter par 
          where c.process_id = -50000192
            and pv.container_id = c.id
            and par.id = pv.param_id
            and upper(par.param_name) = 'I_STTL_DATE'
                );

    dbms_output.put_line('deleted from prc_parameter_value: ' || sql%rowcount);
end;
