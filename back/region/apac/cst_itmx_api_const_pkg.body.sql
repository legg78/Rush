create or replace package body cst_itmx_api_const_pkg is

    function init_default_charset return com_api_type_pkg.t_oracle_name is

        l_result        com_api_type_pkg.t_oracle_name;
        PARAMETER_NAME  com_api_type_pkg.t_oracle_name := 'NLS_CHARACTERSET';

    begin
        select value
          into l_result
          from v$nls_parameters
         where parameter = PARAMETER_NAME;

        return l_result;

    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error         => 'ERROR_READING_NLS_CHARACTERSET'
              , i_env_param1    => PARAMETER_NAME
              , i_env_param2    => sqlerrm
            );
    end; 

begin
    g_default_charset := init_default_charset;
end;
/
