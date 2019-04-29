create or replace function opr_operation_parallel_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab             is table of number(16);
    type t_session_file_id_tab is table of varchar2(30);
    l_oper_id_tab              t_num_tab;
    l_session_file_id_tab      t_session_file_id_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_oper_id_tab, l_session_file_id_tab limit 1000;
        exit when l_oper_id_tab.count() = 0;
        forall i in l_oper_id_tab.first .. l_oper_id_tab.last
          update opr_operation set incom_sess_file_id = l_session_file_id_tab(i) where id = l_oper_id_tab(i);  
        commit;
        l_cnt := l_cnt + l_oper_id_tab.count;
    end loop;
    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end;
/
