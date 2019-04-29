create or replace package cst_sat_api_type_pkg is
/*********************************************************
*  SAT custom API type <br />
*  Created by Gogolev I. (i.gogolev@bpcbt.com) at 07.06.2018 <br />
*  Module: CST_SAT_API_TYPE_PKG <br />
*  @headcom
**********************************************************/

type t_list_card_to_reiss_rec is record(
    inst_id             com_api_type_pkg.t_inst_id
  , agent_id            com_api_type_pkg.t_agent_id
  , customer_number     com_api_type_pkg.t_name
  , product_id          com_api_type_pkg.t_short_id
  , card_id             com_api_type_pkg.t_medium_id
  , split_hash          com_api_type_pkg.t_tiny_id
  , card_number         com_api_type_pkg.t_card_number
  , card_type_id        com_api_type_pkg.t_tiny_id
  , expir_date          date
  , pin_request         com_api_type_pkg.t_dict_value
  , embossing_request   com_api_type_pkg.t_dict_value
  , pin_mailer_request  com_api_type_pkg.t_dict_value
  , card_reissue_frozen com_api_type_pkg.t_sign
  , inherit_pin_offset  com_api_type_pkg.t_boolean
);

type t_list_card_to_reiss_tab is table of t_list_card_to_reiss_rec index by binary_integer;

type t_card_reissue_fields_rec is record(
    inst_id             com_api_type_pkg.t_inst_id
  , agent_id            com_api_type_pkg.t_agent_id
  , customer_number     com_api_type_pkg.t_name
  , product_id          com_api_type_pkg.t_short_id
  , card_id             com_api_type_pkg.t_medium_id
  , card_number         com_api_type_pkg.t_card_number
  , card_type_id        com_api_type_pkg.t_tiny_id
  , start_date          date
  , expir_date          date
  , pin_request         com_api_type_pkg.t_dict_value
  , embossing_request   com_api_type_pkg.t_dict_value
  , pin_mailer_request  com_api_type_pkg.t_dict_value
  , card_reissue_frozen com_api_type_pkg.t_sign
  , inherit_pin_offset  com_api_type_pkg.t_boolean
);

end cst_sat_api_type_pkg;
/
