declare
    l_cnt     number;
    l_from_id number;
    l_till_id number;
begin
    null;
    /*
    for i in 0 .. 110 loop
      l_from_id := com_api_id_pkg.get_from_id(get_sysdate - i);
      l_till_id := com_api_id_pkg.get_from_id(get_sysdate - i + 1);
      select sum(column_value)
        into l_cnt
        from table(opr_operation_parallel_events(cursor(
                 select o.id
                      , p.inst_id
                      , p.split_hash
                   from opr_operation o
                      , (select element_value from com_array_element where array_id = 10000014) oper_type
                      , (select element_value from com_array_element where array_id = 10000020) oper_status
                      , (select element_value from com_array_element where array_id = 10000012) iss_sttl
                      , (select element_value from com_array_element where array_id = 10000013) acq_sttl
                      , opr_participant p
                  where o.id >= l_from_id
                    and o.id  < l_till_id
                    and oper_type.element_value   = o.oper_type
                    and oper_status.element_value = o.status
                    and iss_sttl.element_value(+) = o.sttl_type
                    and acq_sttl.element_value(+) = o.sttl_type
                    and p.oper_id                 = o.id
                    and p.participant_type        = 'PRTYISS'
                    and ((iss_sttl.element_value is not null and o.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_PRESENTMENT))
                         or
                         (acq_sttl.element_value is not null and o.msg_type in (opr_api_const_pkg.MESSAGE_TYPE_AUTHORIZATION
                                                                              , opr_api_const_pkg.MESSAGE_TYPE_COMPLETION)))
             )));
    end loop;
    */
end;
