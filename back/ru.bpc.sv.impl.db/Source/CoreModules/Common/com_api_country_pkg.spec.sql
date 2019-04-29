create or replace package com_api_country_pkg is

procedure apply_country_update(
    i_code_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_curr_code_tab     in      com_api_type_pkg.t_curr_code_tab
  , i_region_tab        in      com_api_type_pkg.t_dict_tab
  , i_euro_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_desc_tab          in      com_api_type_pkg.t_name_tab
);

procedure apply_country_update(
    i_code_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_name_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_curr_code_tab     in      com_api_type_pkg.t_curr_code_tab
  , i_region_tab        in      com_api_type_pkg.t_dict_tab
  , i_euro_tab          in      com_api_type_pkg.t_curr_code_tab
  , i_desc_tab          in      com_api_type_pkg.t_name_tab
  , i_sepa_tab          in      com_api_type_pkg.t_byte_char_tab
);

function get_country_name(
    i_code              in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code;

function get_country_code(
    i_visa_country_code in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code;
    
function get_visa_code(
    i_country_code      in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return varchar2 result_cache;

function get_country_code_by_name(
    i_name              in      com_api_type_pkg.t_name
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code;

function get_visa_region(
    i_country_code      in      com_api_type_pkg.t_country_code
    , i_raise_error     in      com_api_type_pkg.t_boolean := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_dict_value result_cache;

function get_country_full_name(
    i_code              in      com_api_type_pkg.t_country_code
  , i_lang              in      com_api_type_pkg.t_dict_value     default null
  , i_raise_error       in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_name;

function get_country_code(
    i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value     default null
  , i_address_type      in      com_api_type_pkg.t_dict_value     default null
  , i_mask_errors       in      com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_country_code;

function get_external_country_code(
    i_internal_country_code  in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_country_code;

function get_internal_country_code(
    i_external_country_code  in com_api_type_pkg.t_country_code
) return com_api_type_pkg.t_country_code;

end com_api_country_pkg;
/
