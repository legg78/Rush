create or replace package lty_prc_promo_pkg is

procedure check_promotion_level(
    i_inst_id                    in     com_api_type_pkg.t_inst_id
  , i_lang                       in     com_api_type_pkg.t_dict_value default null
);

end;
/
