create or replace package cst_woo_api_svgate_pkg as

-- Input status:
C_STATUS_TEMP_BLOCK             constant com_api_type_pkg.t_dict_value := '01';
C_STATUS_UNBLOCK                constant com_api_type_pkg.t_dict_value := '02';
C_STATUS_PERM_BLOCK             constant com_api_type_pkg.t_dict_value := '03';

-- Response codes:
C_RES_CODE_OK                   constant com_api_type_pkg.t_dict_value := '00';
C_RES_CODE_ERROR                constant com_api_type_pkg.t_dict_value := '05';

procedure block_customer_cards (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_cus_number        in      com_api_type_pkg.t_name
  , i_status            in      com_api_type_pkg.t_dict_value
  , o_res_code          out     com_api_type_pkg.t_dict_value
  , o_res_mess          out     com_api_type_pkg.t_text
  , o_int_mess          out     com_api_type_pkg.t_text
);

procedure block_card(
    i_card_number       in      com_api_type_pkg.t_card_number
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_res_code          out     com_api_type_pkg.t_dict_value
  , o_res_mess          out     com_api_type_pkg.t_text
  , o_int_mess          out     com_api_type_pkg.t_text
);

end;
/
