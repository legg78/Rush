create or replace package net_ui_member_interchange_pkg is
/************************************************************
 * User interface for NET member interchange <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.03.2013 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: net_ui_member_interchange_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_member_interchange (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_value                   in com_api_type_pkg.t_byte_char
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    );

    procedure modify_member_interchange (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_mod_id                  in com_api_type_pkg.t_tiny_id
        , i_value                   in com_api_type_pkg.t_byte_char
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_name                    in com_api_type_pkg.t_name
    );

    procedure remove_member_interchange (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
