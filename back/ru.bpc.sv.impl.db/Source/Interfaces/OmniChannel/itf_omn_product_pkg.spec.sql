create or replace package itf_omn_product_pkg is
/*********************************************************
 *  Product export process <br />
 *  Created by Fomichev Andrey (fomichev@bpcbt.com) at 03.08.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-08-03 13:34:00 +0400#$ <br />
 *  Module: itf_omn_product_pkg <br />
 *  @headcom
 **********************************************************/
function generate_service_block(
    i_product_service_id  in     com_api_type_pkg.t_short_id
  , i_lang                in     com_api_type_pkg.t_dict_value
) return xmltype;

function generate_service_block(
    i_product_service_id  in     com_api_type_pkg.t_short_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_omni_iss_version    in     com_api_type_pkg.t_name
) return xmltype;

function generate_cycle_block(
    i_cycle_id       in  com_api_type_pkg.t_short_id
) return xmltype;

function generate_limit_block(
    i_limit_id       in  com_api_type_pkg.t_long_id
) return xmltype;

function generate_attribute_block (
      i_product_id          in     com_api_type_pkg.t_short_id
    , i_product_service_id  in     com_api_type_pkg.t_short_id
) return xmltype;

function execute_product_query(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_omni_iss_version  in     com_api_type_pkg.t_name
  , o_xml                  out clob
  , i_session_file_id   in     com_api_type_pkg.t_long_id default null
) return number;

end itf_omn_product_pkg;
/
