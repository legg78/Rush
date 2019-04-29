create or replace package itf_omn_prc_cust_export_pkg is
/*********************************************************
 *  Export customers into Omni channel processes <br />
 *  Created by Andrey Fomichev (fomichev@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-04-25 11:28:00 +0400#$ <br />
 *  Module: itf_omn_prc_cust_export_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure process_customer(
    i_omni_version in    com_api_type_pkg.t_name
  , i_inst_id      in    com_api_type_pkg.t_inst_id
  , i_full_export  in    com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
  , i_lang         in    com_api_type_pkg.t_dict_value
);

end itf_omn_prc_cust_export_pkg;
/
