create or replace package cst_sat_prc_outgoing_pkg is
/*********************************************************
*  SAT custom outgoing proceses <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 07.06.2018 <br />
*  Module: CST_SAT_PRC_OUTGOING_PKG <br />
*  @headcom
**********************************************************/

procedure get_list_cards_to_reissue(
    i_inst_id                       in  com_api_type_pkg.t_inst_id    default ost_api_const_pkg.DEFAULT_INST
  , i_product_id                    in  com_api_type_pkg.t_short_id   default null
  , i_expir_month                   in  date
  , i_array_card_status_excluded    in  com_api_type_pkg.t_medium_id  default cst_sat_api_const_pkg.ARRAY_ID_CSTS_REISSUE_EXCLUDE
  , i_separate_char                 in  com_api_type_pkg.t_byte_char
  , i_inherit_pin_offset            in  com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
);

end cst_sat_prc_outgoing_pkg;
/
