create or replace function aut_auth_parallel_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab is table of number(16);
    type t_ext_auth_id_tab is table of varchar2(30);
    l_auth_id_tab      t_num_tab;
    l_ext_auth_id_tab  t_ext_auth_id_tab;
    l_ext_orig_id_tab  t_ext_auth_id_tab;
    l_cnt              integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_auth_id_tab, l_ext_auth_id_tab, l_ext_orig_id_tab limit 1000;
        exit when l_auth_id_tab.count() = 0;
        forall i in l_auth_id_tab.first .. l_auth_id_tab.last
          update aut_auth set external_auth_id = l_ext_auth_id_tab(i), external_orig_id = l_ext_orig_id_tab(i) where id = l_auth_id_tab(i);  
        commit;
        l_cnt := l_cnt + l_auth_id_tab.count;
    end loop;
    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end;
/

