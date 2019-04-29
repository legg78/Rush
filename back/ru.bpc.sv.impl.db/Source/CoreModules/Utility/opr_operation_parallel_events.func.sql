create or replace function opr_operation_parallel_events(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab             is table of number(16);
    type t_int_tab             is table of number(4);
    l_oper_id_tab              t_num_tab;
    l_inst_id_tab              t_int_tab;
    l_split_hash_tab           t_int_tab;
    l_session_id               com_api_type_pkg.t_long_id;
    l_cnt                      integer   := 0;
begin
    l_session_id := get_session_id;

    loop
        fetch i_cursor bulk collect into l_oper_id_tab, l_inst_id_tab, l_split_hash_tab limit 1000;
        exit when l_oper_id_tab.count() = 0;
        forall i in l_oper_id_tab.first .. l_oper_id_tab.last
            insert into evt_event_object(
                    id
                  , event_id
                  , procedure_name
                  , entity_type
                  , object_id
                  , eff_date
                  , event_timestamp
                  , inst_id
                  , split_hash
                  , session_id
                  , proc_session_id
                  , status
              )
              values(
                    to_number(to_char(sysdate, 'yymmdd')) * 10000000000 + evt_event_object_seq.nextval
                  , (select e.id from evt_event e where e.event_type = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY and e.inst_id = l_inst_id_tab(i))
                  , 'QPR_PRC_AGGREGATE_PKG.REFRESH_DETAIL'
                  , opr_api_const_pkg.ENTITY_TYPE_OPERATION
                  , l_oper_id_tab(i)
                  , sysdate
                  , systimestamp
                  , l_inst_id_tab(i)
                  , l_split_hash_tab(i)
                  , l_session_id
                  , null
                  , evt_api_const_pkg.EVENT_STATUS_READY
              );
        commit;
        l_cnt := l_cnt + l_oper_id_tab.count;
    end loop;
    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end;
/
