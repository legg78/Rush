create or replace package prd_prc_customer_export_pkg is
/*********************************************************
 *  process for customers export to XML file <br />
 *  Created by Fomichev A.(fomichev@bpcbt.com)  at 29.05.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_prc_customer_export_pkg <br />
 *  @headcom
 **********************************************************/

procedure process(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_full_export   in  com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
  , i_lang          in  com_api_type_pkg.t_dict_value   default com_api_const_pkg.DEFAULT_LANGUAGE
);

end;
/
