create or replace package prd_ui_contract_type_pkg as
/*********************************************************
*  UI for contract types <br />
*  Created by Kryukov E.(krukov@bpcsv.com)  at 25.05.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: PRD_UI_CONTRACT_TYPE_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_contract_type         in      com_api_type_pkg.t_dict_value
  , i_customer_entity_type  in      com_api_type_pkg.t_dict_value
  , i_product_type          in      com_api_type_pkg.t_dict_value
);

procedure remove(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_seqnum                in      com_api_type_pkg.t_seqnum
);

function get_product_type (
    i_contract_type                in com_api_type_pkg.t_dict_value
    , i_customer_entity_type       in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_dict_value;

end prd_ui_contract_type_pkg;
/
