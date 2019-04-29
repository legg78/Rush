create or replace package utl_parallel_update_pkg is

function fcl_cycle_upd(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function fcl_cycle_counter_upd(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function card_instance_parallel_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function event_object_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function event_card_number_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function aut_auth_trace_number_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function aup_tag_value_seq_num_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

function attribute_value_update(
    i_cursor in sys_refcursor
) return num_tab_tpt parallel_enable (partition i_cursor by any) pipelined;

end utl_parallel_update_pkg;
/
