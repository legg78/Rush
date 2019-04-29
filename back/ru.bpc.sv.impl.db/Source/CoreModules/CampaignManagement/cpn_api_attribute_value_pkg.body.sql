create or replace package body cpn_api_attribute_value_pkg is

function get_attribute_value_id(
    i_campaign_id          in     com_api_type_pkg.t_short_id
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id       default null
) return com_api_type_pkg.t_medium_tab
is
    l_id_tab                      com_api_type_pkg.t_medium_tab;
    l_split_hash                  com_api_type_pkg.t_tiny_id;
begin
    l_split_hash :=
        coalesce(
            i_split_hash
          , com_api_hash_pkg.get_split_hash(
                i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_mask_error   => com_api_const_pkg.FALSE
            )
        );

    select attr_val.id
      bulk collect
      into l_id_tab
      from prd_attribute_value  attr_val
      join cpn_attribute_value  cpn_attr_val    on cpn_attr_val.attribute_value_id = attr_val.id
                                               and cpn_attr_val.campaign_id        = i_campaign_id
     where attr_val.entity_type = i_entity_type
       and attr_val.object_id   = i_object_id
       and attr_val.split_hash  = l_split_hash
    ;
    return l_id_tab;
end;

procedure add_attribute_value(
    i_campaign             in     cpn_api_type_pkg.t_campaign_rec
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
  , i_split_hash           in     com_api_type_pkg.t_tiny_id       default null
  , i_start_date           in     date
) is
    l_split_hash                  com_api_type_pkg.t_tiny_id;
    l_end_date                    date;
begin
    l_split_hash :=
        coalesce(
            i_split_hash
          , com_api_hash_pkg.get_split_hash(
                i_entity_type  => i_entity_type
              , i_object_id    => i_object_id
              , i_mask_error   => com_api_const_pkg.FALSE
            )
        );

    -- End date is calculated for every entity <i_object_id> separately using the campaign cycle
    fcl_api_cycle_pkg.calc_next_date(
        i_cycle_id    => i_campaign.cycle_id
      , i_start_date  => i_start_date
      , i_forward     => com_api_const_pkg.TRUE
      , o_next_date   => l_end_date
    );

    -- Copy all attributes values from the campaign to the entity object with new start/end dates
    insert into prd_attribute_value(
        id
      , service_id
      , object_id
      , entity_type
      , attr_id
      , mod_id
      , start_date
      , end_date
      , register_timestamp
      , attr_value
      , split_hash
    )
    select prd_attribute_value_seq.nextval
         , attr_val.service_id
         , i_object_id
         , i_entity_type
         , attr_val.attr_id
         , attr_val.mod_id
         , i_start_date
         , l_end_date
         , systimestamp
         , attr_val.attr_value
         , l_split_hash
      from prd_attribute_value  attr_val
     where attr_val.entity_type = cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
       and attr_val.object_id   = i_campaign.id
    ;
end add_attribute_value;

procedure update_attribute_value(
    i_id_tab               in     com_api_type_pkg.t_medium_tab
  , i_end_date             in     date
) is
begin
    forall i in  i_id_tab.first() .. i_id_tab.last()
        update prd_attribute_value
           set end_date = i_end_date
          where id      = i_id_tab(i);
end;

end;
/
