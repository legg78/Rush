create or replace package pmo_prc_import_pkg as
/********************************************************* 
 *  Process for payment orders export to XML file <br /> 
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 02.04.2018 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: pmo_prc_import_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 

procedure import_pmo_response(
    i_inst_id           in      com_api_type_pkg.t_inst_id 
  , i_create_operation  in      com_api_type_pkg.t_boolean  default null
);

procedure import_orders(
    i_inst_id           in      com_api_type_pkg.t_inst_id 
);

procedure create_order_operation(
    i_order_id              in com_api_type_pkg.t_long_id
);

end pmo_prc_import_pkg;
/
