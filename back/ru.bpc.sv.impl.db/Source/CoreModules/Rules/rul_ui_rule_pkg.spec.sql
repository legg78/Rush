create or replace package rul_ui_rule_pkg is

procedure add (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_rule_set_id         in com_api_type_pkg.t_tiny_id
    , i_proc_id             in com_api_type_pkg.t_tiny_id
    , i_exec_order          in com_api_type_pkg.t_tiny_id
);
    
procedure modify (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_rule_set_id         in com_api_type_pkg.t_tiny_id
    , i_proc_id             in com_api_type_pkg.t_tiny_id
    , i_exec_order          in com_api_type_pkg.t_tiny_id
);
    
procedure remove (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
);

end;
/
