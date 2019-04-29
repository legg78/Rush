create or replace package mup_prc_report_pkg is
/********************************************************* 
 *  API for Mir reporting  <br /> 
 *  Created by Nick (shalnovv@bpcbt.com)  at 02.03.2018 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: mup_prc_report_pkg <br /> 
 *  @headcom 
 **********************************************************/ 
 
MCC_ARRAY_NUM constant  com_api_type_pkg.t_long_id := 10000084;

/*
 * Procedure gather MIR card insfrastructure.
 */
procedure report_card_instrastructure(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_long_id
  , i_start_date        in     date
  , i_end_date          in     date
  , i_user_id           in     com_api_type_pkg.t_long_id           default null
  , i_lang              in     com_api_type_pkg.t_dict_value        default null
);

procedure process_form_1_iss_oper(
    i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_start_date   in  date
  , i_end_date     in  date
  , i_lang         in  com_api_type_pkg.t_dict_value
);

procedure process_form_2_2_acq_oper(
    i_inst_id      in  com_api_type_pkg.t_tiny_id
  , i_agent_id     in  com_api_type_pkg.t_short_id  default null
  , i_start_date   in  date
  , i_end_date     in  date
  , i_lang         in  com_api_type_pkg.t_dict_value
);

end mup_prc_report_pkg;
/
