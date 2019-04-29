create or replace package vis_prc_incoming_pkg as
/*********************************************************
 *  Visa incoming files API  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 18.03.2010 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_api_incoming_pkg <br />
 *  @headcom
 **********************************************************/

-- Processing of VISA Incoming Clearing Files
procedure process(
    i_network_id                in com_api_type_pkg.t_tiny_id
    , i_test_option             in varchar2 default null -- possible value 'TEST' for test processing
    , i_dst_inst_id             in com_api_type_pkg.t_inst_id default null
    , i_create_operation        in com_api_type_pkg.t_boolean default null
    , i_host_inst_id            in com_api_type_pkg.t_inst_id default null
    , i_validate_records        in com_api_type_pkg.t_boolean default com_api_const_pkg.false
    , i_charset                 in com_api_type_pkg.t_oracle_name := null
    , i_create_disp_case        in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    , i_register_loading_event  in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
);

-- Processing of VISA Rejected Item Files
procedure process_rejected_item_file(
    i_network_id            in com_api_type_pkg.t_tiny_id
    , i_host_inst_id        in com_api_type_pkg.t_inst_id default null
    , i_validate_records    in com_api_type_pkg.t_boolean default com_api_const_pkg.false
);

-- Processing of VISA interchange fee report
procedure vss_report_uploading(
    i_network_id      in       com_api_type_pkg.t_tiny_id
  , i_inst_id         in       com_api_type_pkg.t_inst_id
  , i_register_event  in       com_api_type_pkg.t_boolean
);

end;
/
