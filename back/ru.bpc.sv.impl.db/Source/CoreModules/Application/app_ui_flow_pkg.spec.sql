create or replace package app_ui_flow_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                   out  com_api_type_pkg.t_tiny_id
  , o_seqnum               out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id  in      com_api_type_pkg.t_long_id
  , i_is_customer_exist in      com_api_type_pkg.t_boolean
  , i_is_contract_exist in      com_api_type_pkg.t_boolean
  , i_customer_type     in      com_api_type_pkg.t_dict_value
  , i_contract_type     in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_xslt_source       in      clob
  , i_xsd_source        in      clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc   default null
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);

procedure modify(
    i_id                in      com_api_type_pkg.t_tiny_id
  , io_seqnum           in out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_tiny_id
  , i_template_appl_id  in      com_api_type_pkg.t_long_id
  , i_is_customer_exist in      com_api_type_pkg.t_boolean
  , i_is_contract_exist in      com_api_type_pkg.t_boolean
  , i_customer_type     in      com_api_type_pkg.t_dict_value
  , i_contract_type     in      com_api_type_pkg.t_dict_value
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_xslt_source       in      clob
  , i_xsd_source        in      clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc   default null
  , i_lang              in      com_api_type_pkg.t_dict_value  default null
);

procedure remove( 
    i_id                in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_tiny_id
);

procedure get_flow_source(
    i_flow_id           in      com_api_type_pkg.t_tiny_id
  , o_xslt_source          out  clob
  , o_xsd_source           out  clob
);

end app_ui_flow_pkg;
/
