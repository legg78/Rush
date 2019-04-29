create or replace package cpn_ui_campaign_pkg is

procedure add_campaign(
    o_id                 out com_api_type_pkg.t_short_id
  , o_seqnum             out com_api_type_pkg.t_seqnum
  , i_inst_id         in     com_api_type_pkg.t_inst_id
  , i_campaign_number in     com_api_type_pkg.t_name
  , i_campaign_type   in     com_api_type_pkg.t_dict_value
  , i_start_date      in     date
  , i_end_date        in     date
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_cycle_id        in     com_api_type_pkg.t_short_id       default null
);

procedure modify_campaign(
    i_id              in     com_api_type_pkg.t_short_id
  , io_seqnum         in out com_api_type_pkg.t_seqnum
  , i_campaign_number in     com_api_type_pkg.t_name
  , i_campaign_type   in     com_api_type_pkg.t_dict_value
  , i_start_date      in     date
  , i_end_date        in     date
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_label           in     com_api_type_pkg.t_name
  , i_description     in     com_api_type_pkg.t_full_desc
  , i_cycle_id        in     com_api_type_pkg.t_short_id       default null
);

procedure remove_campaign(
    i_id              in      com_api_type_pkg.t_short_id
  , i_seqnum          in      com_api_type_pkg.t_seqnum
) ;

procedure add_campaign_product(
    o_id                 out com_api_type_pkg.t_short_id
  , i_campaign_id     in     com_api_type_pkg.t_short_id
  , i_product_id      in     com_api_type_pkg.t_short_id
);

procedure remove_campaign_product(
    i_id              in     com_api_type_pkg.t_short_id
);

procedure add_campaign_service(
    o_id                 out com_api_type_pkg.t_short_id
  , i_campaign_id     in     com_api_type_pkg.t_short_id
  , i_product_id      in     com_api_type_pkg.t_short_id
  , i_service_id      in     com_api_type_pkg.t_short_id
);

procedure remove_campaign_service(
    i_id              in     com_api_type_pkg.t_short_id
);

procedure add_campaign_attribute(
    o_id                 out com_api_type_pkg.t_short_id
  , i_campaign_id     in     com_api_type_pkg.t_short_id
  , i_product_id      in     com_api_type_pkg.t_short_id
  , i_service_id      in     com_api_type_pkg.t_short_id
  , i_attribute_id    in     com_api_type_pkg.t_short_id
);

procedure remove_campaign_attribute(
    i_id              in     com_api_type_pkg.t_short_id
);

end cpn_ui_campaign_pkg;
/
