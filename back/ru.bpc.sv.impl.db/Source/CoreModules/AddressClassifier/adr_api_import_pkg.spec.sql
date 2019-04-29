create or replace package adr_api_import_pkg as

-- Processing of Incoming DANE files
procedure process_dane(
    i_department_code_tab     in com_api_type_pkg.t_curr_code_tab
  , i_department_name_tab     in com_api_type_pkg.t_name_tab
  , i_municipality_code_tab   in com_api_type_pkg.t_curr_code_tab
  , i_municipality_name_tab   in com_api_type_pkg.t_name_tab
  , i_dane_code_tab           in com_api_type_pkg.t_dict_tab
  , i_country_code            in com_api_type_pkg.t_country_code
  , i_lang                    in com_api_type_pkg.t_dict_value
);

end;
/
