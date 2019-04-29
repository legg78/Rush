create or replace package din_prc_import_pkg as
/*********************************************************
*  Diners Club importing of financial messages (incoming clearing) <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 25.05.2016 <br />
*  Module: DIN_PRC_IMPORT_PKG <br />
*  @headcom
**********************************************************/

procedure process(
    i_network_id               in            com_api_type_pkg.t_network_id    default null
  , i_create_operation         in            com_api_type_pkg.t_boolean
);

end;
/
