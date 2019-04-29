create or replace package ecm_api_mpi_pkg as

procedure get_merchant_mpi_data(
    i_merchant_id               in      com_api_type_pkg.t_short_id
  , i_host_id                   in      com_api_type_pkg.t_tiny_id
  , o_acquirer_pw               out  com_api_type_pkg.t_name
  , o_acquirer_bin              out  com_api_type_pkg.t_name
  , o_directory_url             out  com_api_type_pkg.t_name
  , o_merchant_country          out  com_api_type_pkg.t_country_code
  , o_merchant_number           out  com_api_type_pkg.t_merchant_number
  , o_merchant_name             out  com_api_type_pkg.t_name
  , o_merchant_url              out  com_api_type_pkg.t_name
  , o_directory_secondary_url   out  com_api_type_pkg.t_name
);

procedure validate_card_number(
    i_card_number       in      com_api_type_pkg.t_card_number
  , o_card_network_id      out  com_api_type_pkg.t_tiny_id
  , o_is_valid             out  com_api_type_pkg.t_boolean
);

procedure get_root_certificate (
      i_host_id         in      com_api_type_pkg.t_tiny_id
    , o_public_key          out com_api_type_pkg.t_key
);

end;
/
