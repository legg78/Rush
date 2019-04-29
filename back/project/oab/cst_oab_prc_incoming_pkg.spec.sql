create or replace package cst_oab_prc_incoming_pkg as
/*********************************************************
*  OAB custom incoming proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 04.09.2018 <br />
*  Module: CST_OAB_PRC_INCOMING_PKG <br />
*  @headcom
**********************************************************/
procedure process_load_operations(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_network_id        in  com_api_type_pkg.t_network_id
  , i_separate_char     in  com_api_type_pkg.t_byte_char
);

end;
/
