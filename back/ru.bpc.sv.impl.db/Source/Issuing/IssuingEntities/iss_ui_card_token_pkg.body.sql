create or replace package body iss_ui_card_token_pkg is

function get_token_value(
    i_card_id               in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_card_number
is
    l_card_token               iss_api_type_pkg.t_card_token_rec;
begin
    l_card_token := iss_api_card_token_pkg.get_token(
                        i_card_id    => i_card_id
                      , i_mask_error => com_api_const_pkg.TRUE
                    );
    return l_card_token.token;
end get_token_value;

end iss_ui_card_token_pkg;
/
