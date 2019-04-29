create or replace package aup_api_mastercard_pkg is

    function get_mastercard (
        i_auth_id                in com_api_type_pkg.t_long_id
    ) return aup_api_type_pkg.t_aup_mastercard_rec;
    
    function get_acquirer_bin (
        i_auth_id               in com_api_type_pkg.t_long_id
    ) return com_api_type_pkg.t_rrn;

end;
/
