create or replace package frp_static_pkg as

function auth_id(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_long_id;
PRAGMA RESTRICT_REFERENCES(auth_id, TRUST);

function msg_type(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(msg_type, TRUST);

function oper_type(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(oper_type, TRUST);

function resp_code(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(resp_code, TRUST);

function acq_bin(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(acq_bin, TRUST);

function merchant_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_merchant_number;
PRAGMA RESTRICT_REFERENCES(merchant_number, TRUST);

function merchant_country(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(merchant_country, TRUST);

function merchant_city(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(merchant_city, TRUST);

function merchant_street(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(merchant_street, TRUST);

function merchant_region(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(merchant_region, TRUST);

function mcc(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_mcc;
PRAGMA RESTRICT_REFERENCES(mcc, TRUST);

function terminal_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_name;
PRAGMA RESTRICT_REFERENCES(terminal_number, TRUST);

function card_data_input_mode(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(card_data_input_mode, TRUST);

function card_data_output_cap(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(card_data_output_cap, TRUST);

function pin_presence(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_dict_value;
PRAGMA RESTRICT_REFERENCES(pin_presence, TRUST);

function oper_amount(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_money;
PRAGMA RESTRICT_REFERENCES(oper_amount, TRUST);

function oper_currency(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_curr_code;
PRAGMA RESTRICT_REFERENCES(oper_currency, TRUST);

function oper_date(i_rec_num in com_api_type_pkg.t_count) return date;
PRAGMA RESTRICT_REFERENCES(oper_date, TRUST);

function card_number(i_rec_num in com_api_type_pkg.t_count) return com_api_type_pkg.t_card_number;
PRAGMA RESTRICT_REFERENCES(card_number, TRUST);

function execute_check (
    i_check_id          in      com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id;

end;
/