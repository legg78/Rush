create or replace package din_prc_export_pkg as
/*********************************************************
*  API for Diners Club exporting of financial messages (outgoing clearing) <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 02.05.2016 <br />
*  Module: DIN_PRC_EXPORT_PKG <br />
*  @headcom
**********************************************************/

procedure process(
    i_network_id          in     com_api_type_pkg.t_tiny_id    default null
  , i_inst_id             in     com_api_type_pkg.t_inst_id    default null
  , i_start_date          in     date                          default null
  , i_end_date            in     date                          default null
  , i_include_affiliate   in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

end;
/
