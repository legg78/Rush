create or replace package body utl_parallel_update_pkg is

function fcl_cycle_upd(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;

    type t_num_tab             is table of com_api_type_pkg.t_long_id;
    type t_dict_value_tab      is table of com_api_type_pkg.t_dict_value;
    
    l_id_tab                   t_num_tab;
    l_cycle_type_tab           t_dict_value_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_id_tab, l_cycle_type_tab limit 10000;
        exit when l_id_tab.count() = 0;
        forall i in l_id_tab.first .. l_id_tab.last
            update fcl_cycle set cycle_type = l_cycle_type_tab(i) where id = l_id_tab(i);  
        commit;
        l_cnt := l_cnt + l_id_tab.count;
    end loop;
    
    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end fcl_cycle_upd;

function fcl_cycle_counter_upd(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;

    type t_num_tab             is table of com_api_type_pkg.t_long_id;
    type t_dict_value_tab      is table of com_api_type_pkg.t_dict_value;
    
    l_id_tab                   t_num_tab;
    l_cycle_type_tab           t_dict_value_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_id_tab, l_cycle_type_tab limit 10000;
        exit when l_id_tab.count() = 0;
        forall i in l_id_tab.first .. l_id_tab.last
            update fcl_cycle_counter set cycle_type = l_cycle_type_tab(i) where id = l_id_tab(i);
        commit;
        l_cnt := l_cnt + l_id_tab.count;
    end loop;
    
    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end fcl_cycle_counter_upd;

function card_instance_parallel_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab             is table of number(16);
    l_id_tab                   t_num_tab;
    l_is_last_seq_number       t_num_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_id_tab, l_is_last_seq_number limit 1000;
        exit when l_id_tab.count() = 0;

        forall i in l_id_tab.first .. l_id_tab.last
          update iss_card_instance set is_last_seq_number = l_is_last_seq_number(i) where id = l_id_tab(i);  

        commit;
        l_cnt := l_cnt + l_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end card_instance_parallel_update;

function event_object_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab             is table of number(16);
    type t_dict_value_tab      is table of varchar2(8);

    l_id_tab                   t_num_tab;
    l_event_type_tab           t_dict_value_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_id_tab, l_event_type_tab limit 1000;
        exit when l_id_tab.count() = 0;

        forall i in l_id_tab.first .. l_id_tab.last
          update evt_event_object set event_type = l_event_type_tab(i) where id = l_id_tab(i);  

        commit;
        l_cnt := l_cnt + l_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end event_object_update;

function event_card_number_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab             is table of com_api_type_pkg.t_long_id;
    type t_proc_name_tab       is table of com_api_type_pkg.t_name;

    l_id_tab                   t_num_tab;
    l_proc_name_tab           t_proc_name_tab;
    l_cnt                      integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_id_tab, l_proc_name_tab limit 1000;
        exit when l_id_tab.count() = 0;

        forall i in l_id_tab.first .. l_id_tab.last
          update evt_event_object set procedure_name = l_proc_name_tab(i) where id = l_id_tab(i);  

        commit;
        l_cnt := l_cnt + l_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end event_card_number_update;

function aut_auth_trace_number_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab          is table of number(16);
    type t_trace_number_tab is table of varchar2(30);

    l_auth_id_tab           t_num_tab;
    l_trace_number_tab      t_trace_number_tab;
    l_cnt                   integer   := 0;
begin
    loop
        fetch i_cursor bulk collect into l_auth_id_tab, l_trace_number_tab limit 1000;
        exit when l_auth_id_tab.count() = 0;

        forall i in l_auth_id_tab.first .. l_auth_id_tab.last
          update aut_auth set trace_number = l_trace_number_tab(i) where id = l_auth_id_tab(i);  

        commit;
        l_cnt := l_cnt + l_auth_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end aut_auth_trace_number_update;

function aup_tag_value_seq_num_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;
    type t_num_tab          is table of number(16);

    l_auth_id_tab           t_num_tab;
    l_tag_id_tab            t_num_tab;
    l_cnt                   integer     := 0;
begin
    loop
        fetch i_cursor bulk collect into l_auth_id_tab, l_tag_id_tab limit 1000;
        exit when l_auth_id_tab.count() = 0;

        forall i in l_auth_id_tab.first .. l_auth_id_tab.last
          update aup_tag_value tv set seq_number = 1 where tv.auth_id = l_auth_id_tab(i) and tv.tag_id = l_tag_id_tab(i) and tv.seq_number is null;

        commit;
        l_cnt := l_cnt + l_auth_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end aup_tag_value_seq_num_update;

function attribute_value_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined
is
    pragma autonomous_transaction;

    type t_num_tab             is table of com_api_type_pkg.t_long_id;
    type t_dict_value_tab      is table of com_api_type_pkg.t_dict_value;

    l_entity_type_tab          t_dict_value_tab;
    l_object_id_tab            t_num_tab;
    l_cnt                      integer     := 0;
begin
    loop
        fetch i_cursor bulk collect into l_entity_type_tab, l_object_id_tab limit 1000;
        exit when l_object_id_tab.count() = 0;

        forall i in l_object_id_tab.first .. l_object_id_tab.last
          update prd_attribute_value v
             set v.split_hash   = com_api_hash_pkg.get_split_hash(
                                      i_entity_type => l_entity_type_tab(i)
                                    , i_object_id   => l_object_id_tab(i)
                                    , i_mask_error  => com_api_const_pkg.TRUE
                                  )
           where v.entity_type  = l_entity_type_tab(i)
             and v.object_id    = l_object_id_tab(i)
             and v.entity_type in (prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                 , prd_api_const_pkg.ENTITY_TYPE_SERVICE);

        commit;
        l_cnt := l_cnt + l_object_id_tab.count;
    end loop;

    close i_cursor;
    commit;
    pipe row(l_cnt);
    return;
end attribute_value_update;

end utl_parallel_update_pkg;
/
