create or replace package itf_omn_prc_product_export_pkg is
/*********************************************************
 *  Product export process <br />
 *  Created by Fomichev Andrey (fomichev@bpcbt.com) at 03.08.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-08-03 13:34:00 +0400#$ <br />
 *  Module: itf_omn_prc_product_export_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure process(
    i_lang             in     com_api_type_pkg.t_dict_value default null
  , i_omni_iss_version in     com_api_type_pkg.t_name
  , i_inst_id          in     com_api_type_pkg.t_inst_id    default null
);

end itf_omn_prc_product_export_pkg;
/
