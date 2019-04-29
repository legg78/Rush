create or replace package opr_ui_message_pkg is

    procedure get_ref_cur (
        o_ref_cur                 out com_api_type_pkg.t_ref_cur
        , i_first_row             in com_api_type_pkg.t_tiny_id
        , i_last_row              in com_api_type_pkg.t_tiny_id
        , i_param_tab             in com_param_map_tpt
    );

    procedure get_row_count (
        o_row_count               out com_api_type_pkg.t_tiny_id
        , i_param_tab             in com_param_map_tpt
    );
    
end;
/
