create or replace package body iss_cst_card_pkg as

function get_expir_date(
    i_contract_id           in com_api_type_pkg.t_medium_id
  , i_card_id               in com_api_type_pkg.t_medium_id
  , i_start_date            in date
  , i_service_id            in com_api_type_pkg.t_short_id
  , i_params                in com_api_type_pkg.t_param_tab
) return date is
begin
    return null;
end get_expir_date;

procedure get_product_card_type(
    io_card_type        in out nocopy   iss_api_type_pkg.t_product_card_type_rec
  , io_card             in out nocopy   iss_api_type_pkg.t_card_rec
) is
begin
    trc_log_pkg.debug(
        i_text          => 'iss_cst_card_pkg.get_product_card_type'
    );
end;

end;
/
