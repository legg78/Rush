declare
    l_cnt     number;
    l_from_id number;
    l_till_id number;
begin
    for i in 0 .. 40 loop
        l_from_id := com_api_id_pkg.get_from_id(get_sysdate - i);
        l_till_id := com_api_id_pkg.get_from_id(get_sysdate - i + 1);

        select sum(column_value)
          into l_cnt
          from table(utl_parallel_update_pkg.aut_auth_trace_number_update(cursor(
                   select id
                        , trim(leading '0' from trace_number)
                     from aut_auth
                    where id >= l_from_id
                      and id < l_till_id
                      and substr(trace_number, 1, 1) = '0'
               )));
    end loop;
end;
