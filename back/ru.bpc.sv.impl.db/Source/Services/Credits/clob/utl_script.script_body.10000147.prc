declare
    l_cnt     number;
begin
    update evt_event set event_type = 'CYTP1010' where event_type = 'CYTP0407';
    update evt_event set event_type = 'CYTP1011' where event_type = 'CYTP0408';
    update evt_event set event_type = 'CYTP1012' where event_type = 'CYTP0406';

    update evt_subscriber set event_type = 'CYTP1010' where event_type = 'CYTP0407';
    update evt_subscriber set event_type = 'CYTP1011' where event_type = 'CYTP0408';
    update evt_subscriber set event_type = 'CYTP1012' where event_type = 'CYTP0406';

    update rul_rule_param_value set param_value = 'CYTP1010' where param_value = 'CYTP0407';
    update rul_rule_param_value set param_value = 'CYTP1011' where param_value = 'CYTP0408';
    update rul_rule_param_value set param_value = 'CYTP1012' where param_value = 'CYTP0406';

    update prc_parameter_value set param_value = 'CYTP1010' where param_value = 'CYTP0407';
    update prc_parameter_value set param_value = 'CYTP1011' where param_value = 'CYTP0408';
    update prc_parameter_value set param_value = 'CYTP1012' where param_value = 'CYTP0406';

    select sum(column_value)
      into l_cnt
      from table(utl_parallel_update_pkg.fcl_cycle_upd(
          cursor(
              select id
                   , decode(cycle_type
                          , 'CYTP0407', 'CYTP1010'
                          , 'CYTP0408', 'CYTP1011'
                          , 'CYTP0406', 'CYTP1012'
                     ) as cycle_type
                from fcl_cycle c
               where cycle_type in ('CYTP0406', 'CYTP0407', 'CYTP0408')
          )
    ));

    for r in (select split_hash from com_api_split_map_vw)
    loop
        select sum(column_value)
          into l_cnt
          from table(utl_parallel_update_pkg.fcl_cycle_counter_upd(
              cursor(
                  select id
                       , decode(cycle_type
                              , 'CYTP0407', 'CYTP1010'
                              , 'CYTP0408', 'CYTP1011'
                              , 'CYTP0406', 'CYTP1012'
                         ) as cycle_type
                    from fcl_cycle_counter
                   where cycle_type in ('CYTP0406', 'CYTP0407', 'CYTP0408')
                     and split_hash = r.split_hash
              )
        ));
    end loop;
end;
