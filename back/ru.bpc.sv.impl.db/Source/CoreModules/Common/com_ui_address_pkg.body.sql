create or replace package body com_ui_address_pkg as
/********************************************************* 
 *  UI for Address <br /> 
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 14.10.2009 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: acom_ui_address_pkg  <br /> 
 *  @headcom 
 **********************************************************/ 
procedure add_address (
    o_address_id       out com_api_type_pkg.t_medium_id
  , o_seqnum           out com_api_type_pkg.t_seqnum
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_country       in     com_api_type_pkg.t_country_code
  , i_region        in     com_api_type_pkg.t_double_name
  , i_city          in     com_api_type_pkg.t_double_name
  , i_street        in     com_api_type_pkg.t_double_name
  , i_house         in     com_api_type_pkg.t_double_name
  , i_apartment     in     com_api_type_pkg.t_double_name
  , i_postal_code   in     varchar2
  , i_region_code   in     com_api_type_pkg.t_dict_value
  , i_latitude      in     com_api_type_pkg.t_geo_coord
  , i_longitude     in     com_api_type_pkg.t_geo_coord
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_place_code    in     com_api_type_pkg.t_name
) is
begin
    o_address_id := com_address_seq.nextval;
    o_seqnum     := 1;

    trc_log_pkg.debug('add_address: l_lang='||i_lang||', i_latitude='||i_latitude||',i_longitude='||i_longitude );

    insert into com_address_vw(
        id
      , seqnum
      , lang
      , country
      , region
      , city
      , street
      , house
      , apartment
      , postal_code
      , region_code
      , latitude
      , longitude
      , inst_id
      , place_code
    ) values (
        o_address_id
      , o_seqnum
      , nvl(i_lang, com_ui_user_env_pkg.get_user_lang)
      , i_country
      , i_region
      , i_city
      , i_street
      , i_house
      , i_apartment
      , i_postal_code
      , i_region_code
      , i_latitude
      , i_longitude
      , ost_api_institution_pkg.get_sandbox(i_inst_id)
      , i_place_code
    );

    com_api_address_pkg.register_event(i_address_id  => o_address_id );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error         =>  'DUPLICATE_ADDRESS'
          , i_env_param1    =>  o_address_id
          , i_env_param2    =>  i_lang
        );
end;

procedure modify_address (
    i_address_id    in     com_api_type_pkg.t_medium_id
  , io_seqnum       in out com_api_type_pkg.t_seqnum
  , i_lang          in     com_api_type_pkg.t_dict_value
  , i_country       in     com_api_type_pkg.t_country_code
  , i_region        in     com_api_type_pkg.t_double_name
  , i_city          in     com_api_type_pkg.t_double_name
  , i_street        in     com_api_type_pkg.t_double_name
  , i_house         in     com_api_type_pkg.t_double_name
  , i_apartment     in     com_api_type_pkg.t_double_name
  , i_postal_code   in     varchar2
  , i_region_code   in     com_api_type_pkg.t_dict_value
  , i_latitude      in     com_api_type_pkg.t_geo_coord
  , i_longitude     in     com_api_type_pkg.t_geo_coord
  , i_inst_id       in     com_api_type_pkg.t_inst_id
  , i_place_code    in     com_api_type_pkg.t_name
) is
    l_lang              com_api_type_pkg.t_dict_value;
    l_count             com_api_type_pkg.t_count := 0;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    trc_log_pkg.debug('modify_address: l_lang='||l_lang||', i_address_id='||i_address_id);

    update com_address_vw
       set country     = i_country
         , region      = decode(lang, l_lang, i_region, region)
         , city        = decode(lang, l_lang, i_city,   city)
         , street      = decode(lang, l_lang, i_street, street)
         , house       = i_house
         , apartment   = i_apartment
         , postal_code = i_postal_code
         , region_code = i_region_code
         , latitude    = i_latitude
         , longitude   = i_longitude
         , seqnum      = io_seqnum
         , lang        = l_lang
         , place_code  = i_place_code
     where id          = i_address_id;

    io_seqnum := io_seqnum + 1;

    select count(1)
      into l_count
      from com_address_vw
     where id   = i_address_id
       and lang = l_lang;

    if l_count = 0 then
        insert into com_address_vw(
            id
          , lang
          , country
          , region
          , city
          , street
          , house
          , apartment
          , postal_code
          , region_code
          , seqnum
          , latitude
          , longitude
          , inst_id
          , place_code
        ) values (
            i_address_id
          , l_lang
          , i_country
          , i_region
          , i_city
          , i_street
          , i_house
          , i_apartment
          , i_postal_code
          , i_region_code
          , io_seqnum
          , i_latitude
          , i_longitude
          , ost_api_institution_pkg.get_sandbox(i_inst_id)
          , i_place_code
    );
    end if;

    com_api_address_pkg.register_event( i_address_id => i_address_id);
end;

procedure remove_address (
    i_address_id           in com_api_type_pkg.t_medium_id
    , i_seqnum             in com_api_type_pkg.t_seqnum
) is
begin
    com_api_address_pkg. remove_address(
        i_address_id  => i_address_id
      , i_seqnum      => i_seqnum
    );
end;

procedure add_address_object (
    i_address_id           in     com_api_type_pkg.t_medium_id
    , i_address_type       in     com_api_type_pkg.t_dict_value
    , i_entity_type        in     com_api_type_pkg.t_dict_value
    , i_object_id          in     com_api_type_pkg.t_long_id
    , o_address_object_id     out com_api_type_pkg.t_long_id
) is
begin
    com_api_address_pkg.add_address_object (
        i_address_id           => i_address_id
        , i_address_type       => i_address_type
        , i_entity_type        => i_entity_type
        , i_object_id          => i_object_id
        , o_address_object_id  => o_address_object_id
    );
end;

procedure remove_address_object (
    i_address_object_id    in      com_api_type_pkg.t_long_id
) is
begin
    com_api_address_pkg.remove_address_object (
        i_address_object_id  => i_address_object_id
    );
end;

procedure check_address_object(
    i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
)
is
begin
    com_api_address_pkg.check_address_object(
        i_address_type => i_address_type
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
    );
end;

procedure add_address_relation(
    o_address_id              out com_api_type_pkg.t_medium_id
  , o_seqnum                  out com_api_type_pkg.t_seqnum
  , o_address_object_id       out com_api_type_pkg.t_long_id
  , i_lang                 in     com_api_type_pkg.t_dict_value
  , i_country              in     com_api_type_pkg.t_country_code
  , i_region               in     com_api_type_pkg.t_double_name
  , i_city                 in     com_api_type_pkg.t_double_name
  , i_street               in     com_api_type_pkg.t_double_name
  , i_house                in     com_api_type_pkg.t_double_name
  , i_apartment            in     com_api_type_pkg.t_double_name
  , i_postal_code          in     varchar2
  , i_region_code          in     com_api_type_pkg.t_dict_value
  , i_latitude             in     com_api_type_pkg.t_geo_coord
  , i_longitude            in     com_api_type_pkg.t_geo_coord
  , i_inst_id              in     com_api_type_pkg.t_inst_id := null
  , i_place_code           in     com_api_type_pkg.t_name
  , i_address_type         in     com_api_type_pkg.t_dict_value
  , i_entity_type          in     com_api_type_pkg.t_dict_value
  , i_object_id            in     com_api_type_pkg.t_long_id
)
is
begin
    com_api_address_pkg.check_address_object(
        i_address_type => i_address_type
      , i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
    );

    add_address(
        o_address_id  => o_address_id
      , o_seqnum      => o_seqnum
      , i_lang        => i_lang
      , i_country     => i_country
      , i_region      => i_region
      , i_city        => i_city
      , i_street      => i_street
      , i_house       => i_house
      , i_apartment   => i_apartment
      , i_postal_code => i_postal_code
      , i_region_code => i_region_code
      , i_latitude    => i_latitude
      , i_longitude   => i_longitude
      , i_inst_id     => i_inst_id
      , i_place_code  => i_place_code);

    add_address_object(
        i_address_id        => o_address_id
      , i_address_type      => i_address_type
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , o_address_object_id => o_address_object_id
    );
end;

end com_ui_address_pkg;
/
