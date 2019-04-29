create or replace package rus_api_order_report_pkg is
/*********************************************************
 *  Acquiring application API  <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 02.02.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: RUS_API_ORDER_REPORT_PKG <br />
 *  @headcom
 **********************************************************/
procedure memorial_order (
    o_xml           out clob
  , i_lang       in     com_api_type_pkg.t_dict_value
  , i_object_id  in     com_api_type_pkg.t_long_id
);

procedure payment_order (
    o_xml           out  clob
  , i_lang       in      com_api_type_pkg.t_dict_value
  , i_object_id  in      com_api_type_pkg.t_long_id
);

function get_account_name(
    i_account_id    in     com_api_type_pkg.t_account_id
  , i_balance_type  in     com_api_type_pkg.t_dict_value
  , i_lang          in     com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_name;

end;
/
