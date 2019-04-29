create or replace package body prd_ui_attribute_value_pkg is
/*********************************************************
*  User interface for attribute values <br />
*  Created by Kopachev D. (kopachev@bpcbt.com)  at 15.11.2010 <br />
*  Last changed by $Author: fomichev $ <br />
*  $LastChangedDate:: 2011-07-15 18:24:54 +0400#$ <br />
*  Revision: $LastChangedRevision: 10765 $ <br />
*  Module: prd_ui_attribute_value_pkg <br />
*  @headcom
**********************************************************/

procedure set_attr_value_num (
    io_id               in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date     default null
  , i_end_date          in      date
  , i_value             in      number
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_num (
        io_id               => io_id
      , i_service_id        => i_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_value             => i_value
      , i_check_start_date  => i_check_start_date
      , i_campaign_id       => i_campaign_id
    );
end;

procedure set_attr_value_date (
    io_id               in out com_api_type_pkg.t_medium_id
  , i_service_id        in     com_api_type_pkg.t_short_id
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_attr_name         in     com_api_type_pkg.t_name
  , i_mod_id            in     com_api_type_pkg.t_tiny_id
  , i_start_date        in     date     default null
  , i_end_date          in     date
  , i_value             in     date
  , i_check_start_date  in     com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_campaign_id       in     com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_date (
        io_id                 => io_id
      , i_service_id          => i_service_id
      , i_entity_type         => i_entity_type
      , i_object_id           => i_object_id
      , i_attr_name           => i_attr_name
      , i_mod_id              => i_mod_id
      , i_start_date          => i_start_date
      , i_end_date            => i_end_date
      , i_value               => i_value
      , i_check_start_date    => i_check_start_date
      , i_campaign_id         => i_campaign_id
    );
end;

procedure set_attr_value_char (
    io_id               in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date     default null
  , i_end_date          in      date
  , i_value             in      com_api_type_pkg.t_text
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_char (
        io_id               => io_id
      , i_service_id        => i_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_value             => i_value
      , i_check_start_date  => i_check_start_date
      , i_campaign_id       => i_campaign_id
    );
end;

procedure set_attr_value_fee (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_fee_id            in      com_api_type_pkg.t_short_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_fee (
        io_attr_value_id    => io_attr_value_id
      , i_service_id        => i_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_fee_id            => i_fee_id
      , i_check_start_date  => i_check_start_date
      , i_campaign_id       => i_campaign_id
    );
end;

procedure set_attr_value_cycle (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_cycle_id          in      com_api_type_pkg.t_short_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_cycle (
        io_attr_value_id    => io_attr_value_id
      , i_service_id        => i_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_cycle_id          => i_cycle_id
      , i_check_start_date  => i_check_start_date
      , i_campaign_id       => i_campaign_id
    );
end;

procedure set_attr_value_limit (
    io_attr_value_id    in out  com_api_type_pkg.t_medium_id
  , i_service_id        in      com_api_type_pkg.t_short_id
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_attr_name         in      com_api_type_pkg.t_name
  , i_mod_id            in      com_api_type_pkg.t_tiny_id
  , i_start_date        in      date      default null
  , i_end_date          in      date
  , i_limit_id          in      com_api_type_pkg.t_long_id
  , i_check_start_date  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.TRUE
  , i_is_cyclic         in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , i_campaign_id       in      com_api_type_pkg.t_short_id   default null
) is
begin
    prd_api_attribute_value_pkg.set_attr_value_limit (
        io_attr_value_id    => io_attr_value_id
      , i_service_id        => i_service_id
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_attr_name         => i_attr_name
      , i_mod_id            => i_mod_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_limit_id          => i_limit_id
      , i_check_start_date  => i_check_start_date
      , i_is_cyclic         => i_is_cyclic
      , i_campaign_id       => i_campaign_id
    );
end;

end;
/
