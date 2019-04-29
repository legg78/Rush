create or replace package sec_api_pinblock_pkg as

procedure get_pinblock (
    i_key                   in      com_api_type_pkg.t_key
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_pin                   in      com_api_type_pkg.t_pin_block
  , i_pinblock_format       in      com_api_type_pkg.t_dict_value
  , o_pin_length               out  com_api_type_pkg.t_tiny_id
  , o_pin_padded               out  com_api_type_pkg.t_pin_block
  , o_pinblock                 out  com_api_type_pkg.t_pin_block
  , o_pinblock_clear           out  com_api_type_pkg.t_pin_block
);

procedure get_pin (
    i_key                   in      com_api_type_pkg.t_key
  , i_card_number           in      com_api_type_pkg.t_card_number
  , i_pinblock_encrypted    in      com_api_type_pkg.t_pin_block
  , i_pinblock_format       in      com_api_type_pkg.t_dict_value
  , o_pin                      out  com_api_type_pkg.t_pin_block
  , o_pin_length               out  com_api_type_pkg.t_tiny_id
  , o_pin_padded               out  com_api_type_pkg.t_pin_block
  , o_pinblock_clear           out  com_api_type_pkg.t_pin_block
);

end;
/