create or replace package body com_api_checksum_pkg as
/***********************************************************
*  Checksum alghoritms <br />
*  Created by Filimonov A.(filimonov@bpc.ru)  at 21.09.2009 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_CHECKSUM_PKG <br />
*  @headcom
*************************************************************/

    CONTROL_POS          constant  number := 9;

function get_luhn_checksum(
    i_number             in      com_api_type_pkg.t_name
) return varchar2 is
    l_checksum           number := 0;
    l_char               number := 0;
    l_number             varchar2(200) := i_number || '0';
begin
    for i in 1..length(l_number) loop
        l_char := to_number(substr(l_number, -i, 1)) * (mod(i + 1, 2) + 1);
        l_checksum := l_checksum + mod(l_char, 10) + trunc(l_char / 10, 0);
    end loop;

    l_checksum := mod(10 - mod(l_checksum, 10), 10);

    return to_char(l_checksum);

exception
    when others then
        return null;
end;

function get_mod11_checksum(
    i_number             in      com_api_type_pkg.t_name
) return varchar2 is
    l_checksum           number := 0;
begin

    for i in 1..least(10, length(i_number)) loop
        l_checksum := l_checksum + to_number(substr(i_number, -i, 1)) * i;
    end loop;

    l_checksum := mod(l_checksum, 11);
    l_checksum := mod(l_checksum, 10);
    
    return to_char(l_checksum);
exception
    when others then
        return null;
end;

function get_cbrf_checksum(
    i_bik                in      com_api_type_pkg.t_name
  , i_number             in      com_api_type_pkg.t_name
) return varchar2 is
    MULTI_COEFFICIENT    constant  number := 3;
    l_line               com_api_type_pkg.t_name := substr(i_bik, -3) || 
                                                    substr(i_number, 1, CONTROL_POS - 1) ||
                                                    '0' || substr(i_number, CONTROL_POS + 1) ;
    type t_num_arr       is table of simple_integer;
    l_weight_tab         t_num_arr := t_num_arr(7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1,3,7,1);
    l_control_sum        number := 0;
begin
    if length(i_number) <> 20 then
        com_api_error_pkg.raise_error(
            i_error      => 'ACC_NUMBER_LENGTH_ERROR'
          , i_env_param1 => i_number
        );
    end if;

    for i in 1..length(l_line)
    loop
        l_control_sum := l_control_sum + substr( substr(l_line, i, 1) * l_weight_tab(i), -1);
    end loop;
    
    return substr( substr(l_control_sum, -1) * MULTI_COEFFICIENT, -1);
exception
    when VALUE_ERROR then
        com_api_error_pkg.raise_error(
            i_error      => 'CHECKSUM_VALUE_ERROR'
          , i_env_param1 => i_number
          , i_env_param2 => i_bik
        );
end;

procedure check_cbrf_checksum(
    i_bik                in      com_api_type_pkg.t_name
  , i_number             in      com_api_type_pkg.t_name
) is
begin
    if substr(i_number, CONTROL_POS, 1) <> get_cbrf_checksum(i_bik, i_number) then
        com_api_error_pkg.raise_error(
            i_error      => 'CONTOL_SUM_NOT_EQUAL'
          , i_env_param1 => i_number
        );
    end if;
end;


end;
/
