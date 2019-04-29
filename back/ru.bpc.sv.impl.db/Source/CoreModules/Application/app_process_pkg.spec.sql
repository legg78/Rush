create or replace package app_process_pkg as
/********************************************************* 
 *  Application processing API  <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 01.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: app_process_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure prepare(
    i_appl_id           in      com_api_type_pkg.t_long_id
);

procedure finalize(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_is_used_savepoint in      com_api_type_pkg.t_boolean     default com_api_type_pkg.FALSE
  , i_reject_code       in      com_api_type_pkg.t_dict_value  default null
  , o_appl_status          out  com_api_type_pkg.t_dict_value
);

procedure processing(
    i_appl_id           in      com_api_type_pkg.t_long_id
  , i_forced_processing in      com_api_type_pkg.t_boolean     default null
  , o_appl_status          out  com_api_type_pkg.t_dict_value
  , i_run_mode          in      com_api_type_pkg.t_tiny_id     default null
);

end app_process_pkg;
/
