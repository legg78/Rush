declare
    l_cnt                                           com_api_type_pkg.t_long_id    := 0;
    l_from_id                                       com_api_type_pkg.t_long_id;
    l_till_id                                       com_api_type_pkg.t_long_id;
begin
    for i in 0 .. 40 loop
        l_from_id := com_api_id_pkg.get_from_id(get_sysdate - i);
        l_till_id := com_api_id_pkg.get_from_id(get_sysdate - i + 1);

        select sum(column_value)
          into l_cnt
          from table(
            utl_parallel_update_pkg.aup_tag_value_seq_num_update(
                cursor(
                    select tv.auth_id
                         , tv.tag_id
                      from opr_operation o
                         , aup_tag_value tv
                     where o.id         = tv.auth_id
                       and o.id        >= l_from_id
                       and o.id        <  l_till_id
                       and tv.seq_number is null
                )
            )
        );
    end loop;
end;
