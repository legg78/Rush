create or replace package body rul_ui_rule_pkg is
/*********************************************************
*  UI for Rules <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 21.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_RULE_PKG <br />
*  @headcom
**********************************************************/
procedure add (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_rule_set_id         in com_api_type_pkg.t_tiny_id
    , i_proc_id             in com_api_type_pkg.t_tiny_id
    , i_exec_order          in com_api_type_pkg.t_tiny_id
) is
begin
    o_id := rul_rule_seq.nextval;
    o_seqnum := 1;
            
    insert into rul_rule_vw (
        id
        , seqnum
        , rule_set_id
        , proc_id
        , exec_order
    ) values (
        o_id
        , o_seqnum
        , i_rule_set_id
        , i_proc_id
        , i_exec_order
    );
end;

procedure modify (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_rule_set_id         in com_api_type_pkg.t_tiny_id
    , i_proc_id             in com_api_type_pkg.t_tiny_id
    , i_exec_order          in com_api_type_pkg.t_tiny_id
) is
begin
    update
        rul_rule_vw
    set
        seqnum = io_seqnum
        , rule_set_id = i_rule_set_id
        , proc_id = i_proc_id
        , exec_order = i_exec_order
    where
        id = i_id;
            
    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
) is
begin
    -- delete rule param value
    delete from 
        rul_rule_param_value_vw
    where
        rule_id = i_id;
                
    -- delete rule
    update
        rul_rule_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        rul_rule_vw
    where
        id = i_id;
end;

end;
/
