create or replace package body prs_api_const_pkg is

    procedure init_printer_encoding is
    begin
        g_printer_encoding := nvl( set_ui_value_pkg.get_system_param_v( i_param_name => 'PRINTER_ENCODING_CHARSET' ), '');
    end;
    
    function init_default_charset return com_api_type_pkg.t_oracle_name is

        result          com_api_type_pkg.t_oracle_name;
        PARAMETER_NAME  com_api_type_pkg.t_oracle_name := 'NLS_CHARACTERSET';

    begin
        select
            value
        into
            result
        from
            v$nls_parameters
        where
            parameter = PARAMETER_NAME;

        return result;

    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'ERROR_READING_NLS_CHARACTERSET'
              , i_env_param1    => PARAMETER_NAME
              , i_env_param2    => sqlerrm
            );
    end;

begin
    init_printer_encoding;
    g_default_charset := init_default_charset;
end;
/
