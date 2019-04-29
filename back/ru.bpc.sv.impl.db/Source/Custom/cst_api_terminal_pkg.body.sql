create or replace package body cst_api_terminal_pkg is

    function get_technical_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_text is
        l_result                com_api_type_pkg.t_text;
    begin
        return null;
    end;

    function get_financial_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_text is
        l_result                com_api_type_pkg.t_text;
    begin
        return null;
    end;

    function get_expendable_status (
        i_terminal_id           in com_api_type_pkg.t_short_id
        , i_lang                in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_text is
        l_result                com_api_type_pkg.t_text;
    begin
        return null;
    end;
end;
/
