create or replace package iss_api_product_pkg is

    function get_product_card_type (
        i_contract_id               in com_api_type_pkg.t_medium_id  default null
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_seq_number              in com_api_type_pkg.t_tiny_id    default null
        , i_service_id              in com_api_type_pkg.t_short_id   default null
        , i_product_id              in com_api_type_pkg.t_short_id   default null
        , i_bin_id                  in com_api_type_pkg.t_short_id   default null
    ) return iss_api_type_pkg.t_product_card_type_rec;
end;
/