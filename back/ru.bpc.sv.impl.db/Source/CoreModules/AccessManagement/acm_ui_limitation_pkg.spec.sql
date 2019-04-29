create or replace package acm_ui_limitation_pkg as

procedure add_limitation(
    o_limitation_id        out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_priv_id           in      com_api_type_pkg.t_short_id
  , i_condition         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_limitation_type   in      com_api_type_pkg.t_dict_value
);

procedure modify_limitation(
    i_limitation_id     in      com_api_type_pkg.t_short_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_condition         in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_label             in      com_api_type_pkg.t_name
  , i_limitation_type   in      com_api_type_pkg.t_dict_value default null
);

procedure remove_limitation(
    i_limitation_id     in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

procedure add_field(
    o_id             out   com_api_type_pkg.t_short_id
  , i_priv_limit_id   in   com_api_type_pkg.t_short_id
  , i_field           in   com_api_type_pkg.t_name
  , i_condition       in   com_api_type_pkg.t_full_desc
  , i_label_id        in   com_api_type_pkg.t_large_id
);

procedure modify_field(
    i_id              in   com_api_type_pkg.t_short_id
  , i_priv_limit_id   in   com_api_type_pkg.t_short_id
  , i_field           in   com_api_type_pkg.t_name
  , i_condition       in   com_api_type_pkg.t_full_desc
  , i_label_id        in   com_api_type_pkg.t_large_id
);

procedure remove_field(
    i_id  in   com_api_type_pkg.t_short_id 
);

end acm_ui_limitation_pkg;
/
