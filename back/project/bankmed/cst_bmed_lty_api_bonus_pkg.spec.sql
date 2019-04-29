create or replace package cst_bmed_lty_api_bonus_pkg as

function check_customer_has_lty_card(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_service_id         in     com_api_type_pkg.t_short_id   default null
  , i_card_id            in     com_api_type_pkg.t_long_id    default null
  , i_eff_date           in     date
) return com_api_type_pkg.t_boolean;

end;
/
