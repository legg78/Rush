create or replace package ecm_api_service_pkg is

    function get_active_service_id (
        i_card_id                 in com_api_type_pkg.t_medium_id
        , i_eff_date              in date
    ) return com_api_type_pkg.t_boolean;

    function get_active_service_id (
        i_card_number             in com_api_type_pkg.t_card_number
        , i_eff_date              in date
    ) return com_api_type_pkg.t_boolean;

end;
/
