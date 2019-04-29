create or replace package aci_api_util_pkg is
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
    ) return com_api_type_pkg.t_raw_data;
    
    function get_field_number (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
    ) return number;
    
    function get_field_date (
        i_raw_data              in varchar2
        , i_start_pos           in pls_integer
        , i_length              in pls_integer
        , i_fmt                 in varchar2
    ) return date;

    function dec2bin (
        i_value                 in number
    ) return com_api_type_pkg.t_name;

    procedure get_oper_type (
        io_oper_type            in out com_api_type_pkg.t_dict_value
        , i_mcc                 in com_api_type_pkg.t_mcc
        , i_mask_error          in com_api_type_pkg.t_boolean default com_api_const_pkg.FALSE
    );

end;
/
