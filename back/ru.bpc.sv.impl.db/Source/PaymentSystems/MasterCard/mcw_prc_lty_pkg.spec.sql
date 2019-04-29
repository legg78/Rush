create or replace package mcw_prc_lty_pkg is
/*********************************************************
*  API for MasterCard World Reward Program <br />
*  Created by Gerbeev I.(gerbeev@bpc.ru) at 31.10.2018 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate:: $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: MCW_PRC_LTY_PKG <br />
*  @headcom
**********************************************************/

procedure export(
    i_inst_id           in com_api_type_pkg.t_inst_id
  , i_lang              in com_api_type_pkg.t_dict_value    default null
);

end mcw_prc_lty_pkg;
/
