create or replace package body aci_api_util_pkg is
/************************************************************
 * API for utils <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.01.2014 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: aci_api_util_pkg <br />
 * @headcom
 ************************************************************/
 
    function get_field_char (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
    ) return com_api_type_pkg.t_raw_data is
    begin
        return rtrim(substr(i_raw_data, i_start_pos, i_length));
    end;
    
    function get_field_number (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
    ) return number is
        l_raw_data              com_api_type_pkg.t_raw_data;
    begin
        l_raw_data := trim(substr(i_raw_data, i_start_pos, i_length));
        begin
            return to_number(l_raw_data);
        exception
            when com_api_error_pkg.e_invalid_number then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACI_ERROR_WRONG_VALUE'
                    , i_env_param1  => i_start_pos
                    , i_env_param2  => i_length
                    , i_env_param3  => l_raw_data
                );
        end;
    end;
    
    function get_field_date (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
        , i_fmt                 in varchar2
    ) return date is
        l_raw_data              com_api_type_pkg.t_raw_data;
    begin
        l_raw_data := trim(substr(i_raw_data, i_start_pos, i_length));
        begin
            return to_date(l_raw_data, i_fmt);
        exception
            when others then
                com_api_error_pkg.raise_error (
                    i_error         => 'ACI_ERROR_WRONG_VALUE'
                    , i_env_param1  => i_start_pos
                    , i_env_param2  => i_length
                    , i_env_param3  => l_raw_data
                );
        end;
    end;
    
    function dec2bin (
        i_value                 in number
    ) return com_api_type_pkg.t_name is
        l_result                com_api_type_pkg.t_name;
        l_value                 number := i_value;
    begin
        while ( l_value > 0 ) loop
            l_result := mod(l_value, 2) || l_result;
            l_value := trunc(l_value / 2);
        end loop;
        return l_result;
    end;

    procedure get_oper_type (
        io_oper_type            in out com_api_type_pkg.t_dict_value
        , i_mcc                 in com_api_type_pkg.t_mcc
        , i_mask_error          in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    ) is
        l_cab_type              com_api_type_pkg.t_mcc;
    begin
        select
            mastercard_cab_type
        into
            l_cab_type
        from
            com_mcc
        where
            mcc = i_mcc;
            
        if io_oper_type in (
            opr_api_const_pkg.OPERATION_TYPE_PURCHASE
        ) then
            case l_cab_type
                when mcw_api_const_pkg.CAB_TYPE_UNIQUE then
                    io_oper_type := opr_api_const_pkg.OPERATION_TYPE_UNIQUE;
                else
                    null;
            end case;
        end if;
    exception
        when no_data_found then
            if i_mask_error = com_api_type_pkg.TRUE then
                trc_log_pkg.warn (
                    i_text          => 'MCW_UNDEFINED_MCC'
                    , i_env_param1  => i_mcc 
                );
            else
                com_api_error_pkg.raise_error (
                    i_error         => 'MCW_UNDEFINED_MCC'
                    , i_env_param1  => i_mcc 
                );
            end if;
    end;

end;
/
