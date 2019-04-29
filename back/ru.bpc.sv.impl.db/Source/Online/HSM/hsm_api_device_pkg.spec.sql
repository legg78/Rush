create or replace package hsm_api_device_pkg is
/************************************************************
 * API for HSM device <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: hsm_api_device_pkg <br />
 * @headcom
 ************************************************************/

    g_use_hsm                      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE;

    function get_hsm_device (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
        , i_hsm_action              in     com_api_type_pkg.t_dict_value default null
        , i_lmk_id                  in     com_api_type_pkg.t_tiny_id    default null
    ) return hsm_api_type_pkg.t_hsm_device_rec;

    procedure init_hsm_devices (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
        , o_connect_status             out com_api_type_pkg.t_name
    );

    procedure deinit_hsm_devices (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
    );

    function get_hsm_standard (
        i_hsm_device_id             in     com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_tiny_id;

    /*
     * Procedure executes some additional actions with HSM device and
     * raises an error if passed result code is not RESULT_CODE_OK.
     */
    procedure process_error(
        i_hsm_devices_id            in     com_api_type_pkg.t_tiny_id
      , i_result_code               in     com_api_type_pkg.t_tiny_id
      , i_error                     in     com_api_type_pkg.t_name
      , i_env_param1                in     com_api_type_pkg.t_full_desc default null
      , i_env_param2                in     com_api_type_pkg.t_name      default null
      , i_env_param3                in     com_api_type_pkg.t_name      default null
      , i_env_param4                in     com_api_type_pkg.t_name      default null
      , i_env_param5                in     com_api_type_pkg.t_name      default null
      , i_env_param6                in     com_api_type_pkg.t_name      default null
    );

    procedure reload_settings;

end;
/
