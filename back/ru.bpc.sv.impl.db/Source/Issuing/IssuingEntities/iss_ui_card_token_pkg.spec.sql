create or replace package iss_ui_card_token_pkg is

function get_token_value(
    i_card_id               in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_card_number;

end iss_ui_card_token_pkg;
/
