create or replace package acm_ui_action_group_pkg is
/************************************************************
 * User interface for Grouping context actions <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 14.12.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: acm_ui_action_group_pkg <br />
 * @headcom
 ************************************************************/

    procedure add_acm_action_group (
        o_id                        out com_api_type_pkg.t_tiny_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_entity_type             in com_api_type_pkg.t_dict_value
        , i_parent_id               in com_api_type_pkg.t_tiny_id
        , i_inst_id                 in com_api_type_pkg.t_inst_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_label                   in com_api_type_pkg.t_name
    );

    procedure modify_acm_action_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_parent_id               in com_api_type_pkg.t_tiny_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , i_label                   in com_api_type_pkg.t_name
    );

    procedure remove_acm_action_group (
        i_id                        in com_api_type_pkg.t_tiny_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );
    
end;
/
