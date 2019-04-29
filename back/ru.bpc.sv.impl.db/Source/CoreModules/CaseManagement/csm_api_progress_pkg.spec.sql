create or replace package csm_api_progress_pkg as
/*********************************************************
 *  Case management API  <br />
 *  Created by Nick (shalnov@bpcbt.com)  at 05.04.2019 <br />
 *  Module: csm_api_progress_pkg <br />
 *  @headcom
 **********************************************************/

procedure get_msg_type(
    i_network_id              in     com_api_type_pkg.t_tiny_id
  , i_case_progress           in     com_api_type_pkg.t_dict_value
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_msg_type                   out com_api_type_pkg.t_dict_value
  , o_is_reversal                out com_api_type_pkg.t_boolean
);

procedure get_case_progress(
    i_network_id              in     com_api_type_pkg.t_tiny_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_is_reversal             in     com_api_type_pkg.t_boolean 
  , i_mask_error              in     com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , o_case_progress              out com_api_type_pkg.t_dict_value
);

function get_is_incoming(
    i_flow_id                 in     com_api_type_pkg.t_tiny_id
  , i_msg_type                in     com_api_type_pkg.t_dict_value
  , i_is_reversal             in     com_api_type_pkg.t_boolean
) return com_api_type_pkg.t_boolean result_cache;

end csm_api_progress_pkg;
/
