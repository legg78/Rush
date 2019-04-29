create or replace package pmo_prc_export_pkg as
/********************************************************* 
 *  Process for payment orders export to XML file <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 31.10.2011 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: pmo_prc_export_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure process(
    i_inst_id                 in     com_api_type_pkg.t_inst_id    default null
  , i_purpose_id              in     com_api_type_pkg.t_short_id   default null
  , i_host_id                 in     com_api_type_pkg.t_tiny_id    default null
  , i_unload_file             in     com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_create_operation        in     com_api_type_pkg.t_boolean    default null
  , i_pmo_status_change_mode  in     com_api_type_pkg.t_dict_value default null
  , i_service_provider_id     in     com_api_type_pkg.t_short_id   default null
);

end pmo_prc_export_pkg;
/
