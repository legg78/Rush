create or replace package acq_api_type_pkg as
/*********************************************************
*  Acquier application - types <br />
*  Created by Alalykin A.(alalykin@bpc.ru) at 11.12.2017 <br />
*  Module: ACQ_API_TYPE_PKG <br />
*  @headcom
**********************************************************/

type t_merchant is record(
    id                      com_api_type_pkg.t_short_id
  , seqnum                  com_api_type_pkg.t_seqnum
  , merchant_number         com_api_type_pkg.t_merchant_number
  , merchant_name           com_api_type_pkg.t_name
  , merchant_type           com_api_type_pkg.t_dict_value
  , parent_id               com_api_type_pkg.t_short_id
  , mcc                     com_api_type_pkg.t_mcc
  , status                  com_api_type_pkg.t_dict_value
  , contract_id             com_api_type_pkg.t_medium_id
  , product_id              com_api_type_pkg.t_short_id
  , inst_id                 com_api_type_pkg.t_inst_id
  , split_hash              com_api_type_pkg.t_tiny_id
  , partner_id_code         com_api_type_pkg.t_auth_code
  , risk_indicator          com_api_type_pkg.t_dict_value
  , mc_assigned_id          com_api_type_pkg.t_tag
);

type t_merchant_card is record(
    card_id                 com_api_type_pkg.t_medium_id
  , card_product_id         com_api_type_pkg.t_short_id
  , card_type_id            com_api_type_pkg.t_tiny_id
  , card_number             com_api_type_pkg.t_card_number
  , card_contract_type      com_api_type_pkg.t_dict_value
);

type t_merchant_card_tab is table of t_merchant_card index by binary_integer;

type t_terminal is record(
    id                      com_api_type_pkg.t_short_id
  , seqnum                  com_api_type_pkg.t_seqnum
  , is_template             com_api_type_pkg.t_boolean
  , terminal_number         com_api_type_pkg.t_terminal_number
  , terminal_type           com_api_type_pkg.t_dict_value
  , merchant_id             com_api_type_pkg.t_short_id
  , mcc                     com_api_type_pkg.t_mcc
  , plastic_number          com_api_type_pkg.t_card_number
  , card_data_input_cap     com_api_type_pkg.t_dict_value
  , crdh_auth_cap           com_api_type_pkg.t_dict_value
  , card_capture_cap        com_api_type_pkg.t_dict_value
  , term_operating_env      com_api_type_pkg.t_dict_value
  , crdh_data_present       com_api_type_pkg.t_dict_value
  , card_data_present       com_api_type_pkg.t_dict_value
  , card_data_input_mode    com_api_type_pkg.t_dict_value
  , crdh_auth_method        com_api_type_pkg.t_dict_value
  , crdh_auth_entity        com_api_type_pkg.t_dict_value
  , card_data_output_cap    com_api_type_pkg.t_dict_value
  , term_data_output_cap    com_api_type_pkg.t_dict_value
  , pin_capture_cap         com_api_type_pkg.t_dict_value
  , cat_level               com_api_type_pkg.t_dict_value
  , gmt_offset              pls_integer
  , is_mac                  com_api_type_pkg.t_boolean
  , device_id               com_api_type_pkg.t_short_id
  , status                  com_api_type_pkg.t_dict_value
  , contract_id             com_api_type_pkg.t_medium_id
  , inst_id                 com_api_type_pkg.t_inst_id
  , split_hash              com_api_type_pkg.t_tiny_id
  , cash_dispenser_present  com_api_type_pkg.t_boolean
  , payment_possibility     com_api_type_pkg.t_boolean
  , use_card_possibility    com_api_type_pkg.t_boolean
  , cash_in_present         com_api_type_pkg.t_boolean
  , available_network       com_api_type_pkg.t_short_id
  , available_operation     com_api_type_pkg.t_short_id
  , available_currency      com_api_type_pkg.t_short_id
  , mcc_template_id         com_api_type_pkg.t_medium_id
  , terminal_profile        com_api_type_pkg.t_medium_id
  , pin_block_format        com_api_type_pkg.t_dict_value
  , pos_batch_support       com_api_type_pkg.t_dict_value
);

end;
/
