create or replace package app_prc_response_pkg as
/*********************************************************
*  API for application process  responce<br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 08.11.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::  $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_prc_response_pkg <br />
*  @headcom
**********************************************************/

/*
 * Process for unloading application responses for those applications that were uploaded earlier
 * (created via GUI applications aren't processed by this process).
 * @param i_export_clear_pan  – if it is FALSE then process unloads undecoded
 *     PANs (tokens) for case when Message Bus is capable to handle them.
 */
procedure event_upload_app_response(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_count               in     com_api_type_pkg.t_medium_id  default null
);

end;
/
