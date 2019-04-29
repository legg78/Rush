create or replace package cst_api_terminal_pkg is

    function get_technical_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value := null
    ) return com_api_type_pkg.t_text;


    function get_financial_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value := null
    ) return com_api_type_pkg.t_text;


    function get_expendable_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value := null
    ) return com_api_type_pkg.t_text;

end;
/
