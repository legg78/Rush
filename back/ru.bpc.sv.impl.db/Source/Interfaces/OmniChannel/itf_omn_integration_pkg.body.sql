create or replace package body itf_omn_integration_pkg  is
/*********************************************************
 *  Product export process <br />
 *  Created by Fomichev Andrey (fomichev@bpcbt.com) at 03.08.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-08-03 13:34:00 +0400#$ <br />
 *  Module: itf_omn_integration_pkg  <br />
 *  @headcom
 **********************************************************/
 
procedure get_products(
    i_inst_id          in     com_api_type_pkg.t_inst_id    default null
  , i_lang             in     com_api_type_pkg.t_dict_value default null
  , i_omni_iss_version in     com_api_type_pkg.t_name
  , o_xml                 out clob
) is
    l_count               com_api_type_pkg.t_long_id;
begin
    l_count := itf_omn_product_pkg.execute_product_query(
        i_inst_id       => i_inst_id
      , i_lang          => i_lang
      , i_omni_iss_version  => i_omni_iss_version
      , o_xml           => o_xml
    );

end;

end itf_omn_integration_pkg ;
/
