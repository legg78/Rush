create or replace package emv_ui_script_pkg is
/************************************************************
 * User interface for EMV script<br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.12.2012 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: emv_ui_script_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add script
 * @param  o_id                  - Script identifier
 * @param  i_object_id           - Object identifier using script
 * @param  i_entity_type         - Entity type using script
 * @param  i_type                - EMV type script (SRTP key)
 * @param  i_status              - EMV script status (SRST key)
 * @param  i_param_tab           - Params
 */
    procedure add_script (
        o_id                    out com_api_type_pkg.t_long_id
        , i_object_id           in com_api_type_pkg.t_long_id
        , i_entity_type         in com_api_type_pkg.t_dict_value
        , i_type                in com_api_type_pkg.t_dict_value
        , i_status              in com_api_type_pkg.t_dict_value
        , i_param_tab           in com_param_map_tpt
   );

/*
 * Remove script
 * @param  o_id                  - Script identifier
 */
    procedure remove_script (
        i_id                    in com_api_type_pkg.t_long_id
    );

end;
/
