create or replace package itf_omn_prc_card_export_pkg is
/*********************************************************
 *  Card export process <br />
 *  Created by Nick (shalnov@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author: Nick $ <br />
 *  $LastChangedDate:: 2018-04-25 11:28:00 +0400#$ <br />
 *  Module: itf_omn_prc_card_export_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure export_cards(
    i_omni_version      in    com_api_type_pkg.t_attr_name
  , i_inst_id           in    com_api_type_pkg.t_inst_id
  , i_array_service_id  in    com_api_type_pkg.t_tiny_id
  , i_export_clear_pan  in    com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_full_export       in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
  , i_lang              in    com_api_type_pkg.t_dict_value default com_api_const_pkg.DEFAULT_LANGUAGE
);

end itf_omn_prc_card_export_pkg;
/
