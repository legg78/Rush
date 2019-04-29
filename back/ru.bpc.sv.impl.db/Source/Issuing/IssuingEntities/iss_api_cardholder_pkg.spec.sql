create or replace package iss_api_cardholder_pkg is
/*********************************************************
*  Issuer application - API for cardholder <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 26.04.2010 <br />
*  Module: IAP_API_CARDHOLDER_PKG <br />
*  @headcom
**********************************************************/ 

procedure create_cardholder(
    o_id                     out com_api_type_pkg.t_medium_id
  , i_customer_id         in     com_api_type_pkg.t_medium_id
  , i_person_id           in     com_api_type_pkg.t_person_id
  , i_cardholder_name     in     com_api_type_pkg.t_name
  , i_relation            in     com_api_type_pkg.t_dict_value
  , i_resident            in     com_api_type_pkg.t_boolean
  , i_nationality         in     com_api_type_pkg.t_curr_code
  , i_marital_status      in     com_api_type_pkg.t_dict_value
  
  , io_cardholder_number  in out com_api_type_pkg.t_name
  , i_inst_id             in     com_api_type_pkg.t_inst_id
);

/* Procedure changes cardholder name for cardholder and associated card instances,
 * it also generates a new event.
 * i_is_event_forced    — if this flag is set to true then a new event will be generated
                          even when cardholder name isn't changed (or i_cardholder_name is empty)
 */
procedure modify_cardholder(
    i_id                  in     com_api_type_pkg.t_medium_id
  , i_cardholder_name     in     com_api_type_pkg.t_name
  , i_relation            in     com_api_type_pkg.t_dict_value
  , i_resident            in     com_api_type_pkg.t_boolean
  , i_nationality         in     com_api_type_pkg.t_curr_code
  , i_marital_status      in     com_api_type_pkg.t_dict_value
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_is_event_forced     in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
);

function get_cardholder_name(
    i_id                  in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name;

function get_cardholder_by_card(
    i_card_number         in    com_api_type_pkg.t_card_number
  , i_mask_error          in    com_api_type_pkg.t_boolean     default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_medium_id;

function get_cardholder_by_card(
    i_card_id             in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id;

function get_cardholder_by_contract(
    i_contract_id         in    com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_medium_id;

/*
 * Returns record with cardholder data.
 * The following parameters are used for searching in order of priority (until first successful try):
 * 1) i_inst_id + i_cardholder_number;
 * 2) i_inst_id + i_person_id;
 * 3) i_card_id;
 * 4) i_card_number.
 */
function get_cardholder(
    i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_cardholder_number   in     com_api_type_pkg.t_name
  , i_person_id           in     com_api_type_pkg.t_medium_id   default null
  , i_card_id             in     com_api_type_pkg.t_medium_id   default null
  , i_card_number         in     com_api_type_pkg.t_card_number default null
  , i_mask_error          in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_cardholder;

procedure get_cardholder_info_by_card(
    i_card_id             in     com_api_type_pkg.t_medium_id
  , o_address                out com_api_type_pkg.t_double_name
  , o_city                   out com_api_type_pkg.t_double_name
  , o_country                out com_api_type_pkg.t_country_code
  , o_postal_code            out com_api_type_pkg.t_postal_code
  , o_cardholder_name        out com_api_type_pkg.t_name
  , o_birthday               out com_api_type_pkg.t_date_short
);

function get_cardholder(
    i_cardholder_id       in     com_api_type_pkg.t_long_id
  , i_mask_error          in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_cardholder;

end iss_api_cardholder_pkg;
/
