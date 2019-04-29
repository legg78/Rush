create or replace package frp_buffer_pkg as

auth_id                 com_api_type_pkg.t_number_tab;
msg_type                com_api_type_pkg.t_dict_tab;
oper_type               com_api_type_pkg.t_dict_tab;
resp_code               com_api_type_pkg.t_dict_tab;
acq_bin                 com_api_type_pkg.t_name_tab;
merchant_number         com_api_type_pkg.t_merchant_number_tab;
merchant_country        com_api_type_pkg.t_country_code_tab;
merchant_city           com_api_type_pkg.t_name_tab;
merchant_street         com_api_type_pkg.t_name_tab;
merchant_region         com_api_type_pkg.t_name_tab;
mcc                     com_api_type_pkg.t_mcc_tab;
terminal_number         com_api_type_pkg.t_terminal_number_tab;
card_data_input_mode    com_api_type_pkg.t_dict_tab;
card_data_output_cap    com_api_type_pkg.t_dict_tab;
pin_presence            com_api_type_pkg.t_dict_tab;
oper_amount             com_api_type_pkg.t_number_tab;
oper_currency           com_api_type_pkg.t_curr_code_tab;
oper_date               com_api_type_pkg.t_date_tab;
card_number             com_api_type_pkg.t_card_number_tab;

end;
/
