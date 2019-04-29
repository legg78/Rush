create or replace package rus_api_report_pkg is
/********************************************************* 
 *  Api for some reports  <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.02.2012 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: rus_api_report_pkg <br /> 
 *  @headcom 
 **********************************************************/ 

procedure run_report_acc (
    o_xml                  out clob
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_mode              in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_agent_id          in     com_api_type_pkg.t_agent_id       default null
  , i_currency          in     com_api_type_pkg.t_curr_code
  , i_balance_number    in     com_api_type_pkg.t_name           default null
);

end;
/
