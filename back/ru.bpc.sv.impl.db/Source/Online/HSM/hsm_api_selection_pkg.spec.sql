create or replace package hsm_api_selection_pkg is
/************************************************************
 * API for HSM selection <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_selection_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Select first HSM
 * @param  i_inst_id   - Owner institution identifier
 * @param  i_action    - Action with HSM
 * @param  i_params    - Parameter tab
 */
    function select_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_params                  in com_api_type_pkg.t_param_tab
    ) return com_api_type_pkg.t_tiny_id;
    
/*
 * Select HSM identifier
 * @param  i_inst_id   - Owner institution identifier
 * @param  i_agent_id  - Owner agent identifier
 * @param  i_hsm_id    - HSM identifier
 * @param  i_action    - Action with HSM
 */
    function select_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_hsm_id                  in com_api_type_pkg.t_tiny_id := null
        , i_action                  in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_tiny_id;

/*
 * Select all HSM
 * @param  i_inst_id   - Owner institution identifier
 * @param  i_action    - Action with HSM
 * @param  i_params    - Parameter tab
 */
    function select_all_hsm (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_action                  in com_api_type_pkg.t_dict_value
        , i_params                  in com_api_type_pkg.t_param_tab
    ) return com_api_type_pkg.t_number_tab;

end; 
/
