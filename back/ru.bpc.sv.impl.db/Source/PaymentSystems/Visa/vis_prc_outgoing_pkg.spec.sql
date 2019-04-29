create or replace package vis_prc_outgoing_pkg as
/*********************************************************
 *  Visa outgoing files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.10.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

procedure process(
    i_network_id            in com_api_type_pkg.t_tiny_id       default null
  , i_inst_id               in com_api_type_pkg.t_inst_id       default null
  , i_host_inst_id          in com_api_type_pkg.t_inst_id       default null
  , i_test_option           in varchar2                         default null -- possible value 'TEST' for test processing
  , i_start_date            in date                             default null
  , i_end_date              in date                             default null
  , i_include_affiliate     in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_charset               in com_api_type_pkg.t_oracle_name   default null
  , i_create_disp_case      in com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

procedure process_unload_sms_dispute(
    i_start_date in    date,
    i_end_date   in    date
);

end;
/
