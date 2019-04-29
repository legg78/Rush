create or replace package rcn_prc_export_pkg as
/********************************************************* 
 *  Process for export reconciliation message to XML file <br /> 
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 03.05.2018 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rcn_prc_export_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure process_srvp(
    i_inst_id                 in     com_api_type_pkg.t_inst_id
  , i_service_provider_id     in     com_api_type_pkg.t_short_id
  , i_purpose_id              in     com_api_type_pkg.t_short_id   default null
  , i_count                   in     com_api_type_pkg.t_short_id   default null
);

procedure process_host(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_count                 in     com_api_type_pkg.t_short_id   default null
);

end;
/
