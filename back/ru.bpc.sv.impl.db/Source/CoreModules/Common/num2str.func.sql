create or replace function num2str(
    i_source                    in com_api_type_pkg.t_money
  , i_lang                      in com_api_type_pkg.t_dict_value
  , i_currency                  in com_api_type_pkg.t_curr_code
) return com_api_type_pkg.t_name as
begin
    return com_api_type_pkg.num2str(
        i_source   => i_source
      , i_lang     => i_lang
      , i_currency => i_currency
    );
end num2str;
/
