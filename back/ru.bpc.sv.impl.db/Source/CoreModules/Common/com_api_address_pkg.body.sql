create or replace package body com_api_address_pkg as
/************************************************************
*  API for adresses <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 19.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_API_ADDRESS_PKG <br />
*  @headcom
*************************************************************/

procedure register_event(
    i_address_id  in  com_api_type_pkg.t_long_id
) is
    l_param_tab       com_api_type_pkg.t_param_tab;
    l_event_type      com_api_type_pkg.t_dict_value;
    l_entity_type     com_api_type_pkg.t_dict_value;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
             , o.entity_type
             , c.id as customer_id
             , p.id as product_id
             , p.product_type
          from com_address_object o
             , prd_customer c
             , prd_contract n
             , prd_product p
         where o.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and o.address_id  = i_address_id
           and c.id          = o.object_id
           and n.id          = c.contract_id
           and p.id          = n.product_id
         union all
        select c.id
             , c.inst_id
             , c.split_hash
             , o.entity_type
             , c.id as customer_id
             , p.id as product_id
             , p.product_type
          from com_address_object o
             , iss_cardholder h
             , prd_customer c
             , prd_contract n
             , prd_product p
         where o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
           and o.object_id   = h.id
           and h.person_id   = c.id
           and c.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
           and o.address_id  = i_address_id
           and n.id          = c.contract_id
           and p.id          = n.product_id
         union all
        select m.id
             , m.inst_id
             , m.split_hash
             , o.entity_type
             , n.customer_id
             , p.id as product_id
             , p.product_type
          from com_address_object o
             , acq_merchant m
             , prd_contract n
             , prd_product p
         where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.address_id  = i_address_id
           and m.id          = o.object_id
           and n.id          = m.contract_id
           and p.id          = n.product_id
         union all
        select t.id
             , t.inst_id
             , t.split_hash
             , o.entity_type
             , n.customer_id
             , p.id as product_id
             , p.product_type
          from com_address_object o
             , acq_terminal t
             , prd_contract n
             , prd_product p
         where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL
           and o.address_id  = i_address_id
           and t.id          = o.object_id
           and t.is_template = com_api_type_pkg.FALSE      
           and n.id          = t.contract_id
           and  p.id         = n.product_id
    ) loop
        if rec.entity_type in (prd_api_const_pkg.ENTITY_TYPE_CUSTOMER, iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER) then
            l_event_type      := prd_api_const_pkg.EVENT_CUSTOMER_MODIFY;
            l_entity_type     := prd_api_const_pkg.ENTITY_TYPE_CUSTOMER;

        elsif rec.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            l_event_type      := acq_api_const_pkg.EVENT_MERCHANT_ATTR_CHANGE;
            l_entity_type     := acq_api_const_pkg.ENTITY_TYPE_MERCHANT;

        elsif rec.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            l_event_type      := acq_api_const_pkg.EVENT_TERMINAL_ATTR_CHANGE;
            l_entity_type     := acq_api_const_pkg.ENTITY_TYPE_TERMINAL;

        end if;

        evt_api_event_pkg.register_event(
            i_event_type      => l_event_type
          , i_eff_date        => get_sysdate
          , i_entity_type     => l_entity_type
          , i_object_id       => rec.id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PRODUCT_ID'
          , i_value   => rec.product_id
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'PRODUCT_TYPE'
          , i_value   => rec.product_type
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'SRC_ENTITY_TYPE'
          , i_value   => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , io_params => l_param_tab
        );
        rul_api_param_pkg.set_param(
            i_name    => 'SRC_OBJECT_ID'
          , i_value   => rec.customer_id
          , io_params => l_param_tab
        );
        evt_api_event_pkg.register_event(
            i_event_type      => com_api_const_pkg.EVENT_TYPE_ADDRESS_CHANGED
          , i_eff_date        => get_sysdate
          , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_ADDRESS
          , i_object_id       => i_address_id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );
        rul_api_param_pkg.clear_params(
            io_params => l_param_tab
        );
        
    end loop;
end;

procedure add_address(
    io_address_id       in out  com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_country           in      com_api_type_pkg.t_country_code
  , i_region            in      com_api_type_pkg.t_double_name
  , i_city              in      com_api_type_pkg.t_double_name
  , i_street            in      com_api_type_pkg.t_double_name
  , i_house             in      com_api_type_pkg.t_double_name
  , i_apartment         in      com_api_type_pkg.t_double_name
  , i_postal_code       in      varchar2
  , i_region_code       in      com_api_type_pkg.t_dict_value
  , i_latitude          in      com_api_type_pkg.t_geo_coord
  , i_longitude         in      com_api_type_pkg.t_geo_coord
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_place_code        in      com_api_type_pkg.t_name
  , i_comments          in      com_api_type_pkg.t_name             default null
) is
begin
    io_address_id := coalesce(io_address_id, com_address_seq.nextval);

    trc_log_pkg.debug (
        i_text          => 'add_address: [#1] [#2] [#3] [#4]'
        , i_env_param1  => i_lang
        , i_env_param2  => io_address_id
        , i_env_param3  => i_latitude
        , i_env_param4  => i_longitude
    );

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
      , comments
    ) values (
        io_address_id
      , 1
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
      , i_comments
    );

    register_event(i_address_id  => io_address_id);
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error         => 'DUPLICATE_ADDRESS'
          , i_env_param1    => io_address_id
          , i_env_param2    => i_lang
        );
end;

procedure modify_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_region            in      com_api_type_pkg.t_double_name
  , i_city              in      com_api_type_pkg.t_double_name
  , i_street            in      com_api_type_pkg.t_double_name
  , i_house             in      com_api_type_pkg.t_double_name
  , i_apartment         in      com_api_type_pkg.t_double_name
  , i_postal_code       in      varchar2
  , i_region_code       in      com_api_type_pkg.t_dict_value
  , i_latitude          in      com_api_type_pkg.t_geo_coord
  , i_longitude         in      com_api_type_pkg.t_geo_coord
  , i_lang              in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_place_code        in      com_api_type_pkg.t_name
  , i_comments          in      com_api_type_pkg.t_name             default null
) is
    l_lang              com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

    trc_log_pkg.debug (
        i_text          => 'modify_address: [#1] [#2]'
        , i_env_param1  => l_lang
        , i_env_param2  => i_address_id
    );

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
         , place_code  = i_place_code
         , comments    = i_comments
     where id          = i_address_id
       and lang        = l_lang;

    if sql%rowcount = 0 then
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
          , comments
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
          , 1
          , i_latitude
          , i_longitude
          , ost_api_institution_pkg.get_sandbox(i_inst_id)
          , i_place_code
          , i_comments
        );
    end if;

    register_event(i_address_id => i_address_id);
end;

procedure remove_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
    l_count             pls_integer;
begin
    select count(1)
      into l_count
      from com_address_object
     where address_id = i_address_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error(
            i_error         => 'ADDRESS_HAS_ATTACHED_OBJECTS'
        );
    end if;

    update com_address_vw
       set seqnum      = i_seqnum
     where id          = i_address_id;

    register_event(i_address_id => i_address_id);
end;

procedure remove_address(
    i_address_id        in      com_api_type_pkg.t_medium_id
) is
begin
    trc_log_pkg.debug(
        i_text          => 'remove_address [#1] '
        , i_env_param1  => i_address_id
    );

    delete com_address_vw
     where id          = i_address_id;
end;

procedure add_address_object(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
  , o_address_object_id    out  com_api_type_pkg.t_long_id
) is
begin
    select com_address_object_seq.nextval into o_address_object_id from dual;

    insert into com_address_object_vw(
        id
      , object_id
      , entity_type
      , address_id
      , address_type
    ) values (
        o_address_object_id
      , i_object_id
      , i_entity_type
      , i_address_id
      , i_address_type
    );

    register_event(i_address_id => i_address_id);
exception
    when dup_val_on_index then
        trc_log_pkg.debug('add_address_object is FAILED');
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_ADDRESS_TYPE'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_address_type
        );
end;

procedure modify_address_object(
    i_address_object_id in      com_api_type_pkg.t_long_id
  , i_address_id        in      com_api_type_pkg.t_medium_id
  , i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
) is
begin
    update com_address_object_vw
       set object_id    = i_object_id
         , entity_type  = i_entity_type
         , address_id   = i_address_id
         , address_type = i_address_type
     where id           = i_address_object_id;

    register_event(i_address_id => i_address_id);
exception
    when dup_val_on_index then
        trc_log_pkg.debug(
            i_text => 'modify_address_object with i_address_object_id [' || i_address_object_id
                   || '], i_address_id [' || i_address_id || '] is FAILED'
        );
        com_api_error_pkg.raise_error(
            i_error       => 'DUPLICATE_ADDRESS_TYPE'
          , i_env_param1  => i_entity_type
          , i_env_param2  => i_object_id
          , i_env_param3  => i_address_type
        );
end;

procedure remove_address_object(
    i_address_object_id in      com_api_type_pkg.t_long_id
) is
    l_address_id        com_api_type_pkg.t_long_id;
begin
    for rec in (
        select count(1) as cnt
             , b.entity_type
             , b.object_id
          from com_address_object_vw b
         where (b.object_id, b.entity_type) in (
                   select a.object_id
                        , a.entity_type
                     from com_address_object_vw a
                    where a.id = i_address_object_id
               )
      group by b.entity_type
             , b.object_id
    ) loop
        if rec.cnt > 1 then
            delete com_address_object_vw
             where id = i_address_object_id
         returning address_id
              into l_address_id;

            register_event(i_address_id => l_address_id);

        else
            com_api_error_pkg.raise_error(
                i_error      => 'OBJECT_LAST_ADDRESS'
              , i_env_param1 => rec.entity_type
              , i_env_param2 => rec.object_id
            );
        end if;
    end loop;
end remove_address_object;

function get_address_string(
    i_address_id        in      com_api_type_pkg.t_medium_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id          default null
  , i_enable_empty      in      com_api_type_pkg.t_boolean          default com_api_const_pkg.FALSE  
) return varchar2 is
    l_lang              com_api_type_pkg.t_dict_value;
    l_result            com_api_type_pkg.t_full_desc;
    l_inst_id           com_api_type_pkg.t_inst_id;    
    l_format_id         com_api_type_pkg.t_inst_id;
    l_params            com_api_type_pkg.t_param_tab;
    l_str               com_api_type_pkg.t_name;    
    l_entity_type       com_api_type_pkg.t_dict_value;
    l_object_id         com_api_type_pkg.t_long_id;
begin
    l_lang    := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);
    l_inst_id := i_inst_id;
    
    if l_inst_id is null then
        begin
            select entity_type
                 , object_id
              into l_entity_type
                 , l_object_id
              from com_address_object o
             where o.address_id = i_address_id
               and rownum = 1; 
                   
            l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                i_entity_type  => l_entity_type
              , i_object_id    => l_object_id
              , i_mask_errors  => com_api_const_pkg.FALSE
            ); 
        exception
            when no_data_found then
                trc_log_pkg.error('ADDRESS_NOT_FOUND. address_id = ' || i_address_id);
                return null;
                    
            when others then
                trc_log_pkg.error(sqlerrm);
                return null;
        end;
    end if;

    l_format_id := rul_api_name_pkg.get_format_id (
                       i_inst_id     => l_inst_id
                     , i_entity_type => com_api_const_pkg.ENTITY_TYPE_ADDRESS
                   );

    for r in (
        select a.postal_code
             , a.country
             , a.city
             , a.street
             , a.house
             , a.apartment
             , a.region
             , a.region_code
             , com_api_i18n_pkg.get_text('com_country', 'name', b.id, a.lang) country_name
             , a.comments
          from com_address_vw a
             , com_country_vw b
         where a.id         = i_address_id
           and a.country    = b.code(+)
         order by decode(a.lang, l_lang, 1, 'LANGENG', 2, 3)
    ) loop
        --get address string
        rul_api_param_pkg.set_param (
            i_name       => 'COUNTRY'
            , i_value    => r.country_name
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'POSTAL_CODE'
            , i_value    => r.postal_code
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'REGION_CODE'
            , i_value    => r.region_code
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'REGION'
            , i_value    => r.region
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'CITY'
            , i_value    => r.city
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'STREET'
            , i_value    => r.street
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name     => 'HOUSE'
          , i_value    => r.house
          , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name     => 'APARTMENT'
          , i_value    => r.apartment
          , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name     => 'COMMENT'
          , i_value    => r.comments
          , io_params  => l_params
        );

        com_cst_address_pkg.collect_address_params (
            i_address_id  => i_address_id
          , i_lang        => l_lang
          , i_inst_id     => l_inst_id
          , ia_params_tab => l_params
        );

        l_result := rul_api_name_pkg.get_name(
            i_format_id    => l_format_id
          , i_param_tab    => l_params
          , i_enable_empty => i_enable_empty
        );

        exit;
    end loop;

    l_str := substr(l_result, length(l_result)-1, 2);
    if l_str = ',' or l_str = ', ' then
        l_result := substr(l_result, 1, length(l_result)-2);        
    end if;

    return l_result;    
end get_address_string;

function get_address_string(
    i_country           in      com_api_type_pkg.t_country_code default null
  , i_region            in      com_api_type_pkg.t_double_name  default null
  , i_city              in      com_api_type_pkg.t_double_name  default null
  , i_street            in      com_api_type_pkg.t_double_name  default null
  , i_house             in      com_api_type_pkg.t_double_name  default null
  , i_apartment         in      com_api_type_pkg.t_double_name  default null
  , i_postal_code       in      varchar2                        default null
  , i_region_code       in      com_api_type_pkg.t_dict_value   default null
  , i_comments          in      com_api_type_pkg.t_name         default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_enable_empty      in      com_api_type_pkg.t_boolean      default com_api_const_pkg.FALSE
) return varchar2
is
    l_str               com_api_type_pkg.t_name;
    l_result            com_api_type_pkg.t_full_desc;
    l_format_id         com_api_type_pkg.t_inst_id;
    l_params            com_api_type_pkg.t_param_tab;
begin
    begin
        select id 
          into l_format_id  
          from rul_name_format 
         where inst_id = i_inst_id 
           and entity_type = com_api_const_pkg.ENTITY_TYPE_ADDRESS;    
 
    exception
        when no_data_found then
            select id 
              into l_format_id  
              from rul_name_format 
             where inst_id = ost_api_const_pkg.DEFAULT_INST 
               and entity_type = com_api_const_pkg.ENTITY_TYPE_ADDRESS;    
        when others then
            trc_log_pkg.error(sqlerrm);
            return null;
    end;

    rul_api_param_pkg.set_param (
        i_name       => 'COUNTRY'
        , i_value    => i_country
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'POSTAL_CODE'
        , i_value    => i_postal_code
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'REGION_CODE'
        , i_value    => i_region_code
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'REGION'
        , i_value    => i_region
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'CITY'
        , i_value    => i_city
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param (
        i_name       => 'STREET'
        , i_value    => i_street
        , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'HOUSE'
      , i_value    => i_house
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'APARTMENT'
      , i_value    => i_apartment
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'COMMENT'
      , i_value    => i_comments
      , io_params  => l_params
    );

    l_result := rul_api_name_pkg.get_name (
        i_format_id      => l_format_id
        , i_param_tab    => l_params
        , i_enable_empty => i_enable_empty
    );

    if not (l_result is null and i_enable_empty = com_api_type_pkg.TRUE) then
        l_str := substr(l_result, length(l_result)-1, 2);
        if l_str = ',' or l_str = ', ' then
            l_result := substr(l_result, 1, length(l_result)-2);
        end if;
    end if;

    return l_result;
end get_address_string;

function get_address(
    i_object_id    in     com_api_type_pkg.t_long_id
  , i_entity_type  in     com_api_type_pkg.t_dict_value
  , i_address_type in     com_api_type_pkg.t_dict_value
  , i_lang         in     com_api_type_pkg.t_dict_value := get_user_lang
  , i_mask_error   in     com_api_type_pkg.t_boolean    := com_api_const_pkg.TRUE
) return com_api_type_pkg.t_address_rec is 
    l_address_rec         com_api_type_pkg.t_address_rec;
    l_lang                com_api_type_pkg.t_dict_value;
begin
    l_lang := nvl(i_lang, get_user_lang);
    
    select a.id
         , a.seqnum
         , a.lang
         , a.country
         , a.region
         , a.city
         , a.street
         , a.house
         , a.apartment
         , a.postal_code
         , a.region_code
         , a.latitude
         , a.longitude
         , a.inst_id
         , a.place_code
         , o.address_type
      into l_address_rec.id
         , l_address_rec.seqnum
         , l_address_rec.lang
         , l_address_rec.country
         , l_address_rec.region
         , l_address_rec.city
         , l_address_rec.street
         , l_address_rec.house
         , l_address_rec.apartment
         , l_address_rec.postal_code
         , l_address_rec.region_code
         , l_address_rec.latitude
         , l_address_rec.longitude
         , l_address_rec.inst_id
         , l_address_rec.place_code
         , l_address_rec.address_type
      from com_address_object o
         , com_address a
     where a.id           = o.address_id
       and o.address_type = nvl(i_address_type, o.address_type)
       and a.lang         = l_lang
       and (o.object_id, o.entity_type) in ((i_object_id, i_entity_type))
       and rownum         = 1;

    return l_address_rec;
exception
    when no_data_found
      or com_api_error_pkg.e_application_error
    then
        if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.TRUE then
            return l_address_rec;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ADDRESS_NOT_FOUND'
              , i_env_param1 => i_entity_type || ' ' || i_object_id || ' ' || i_address_type
            );
        end if;
    when com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
       
end;

procedure check_address_object(
    i_address_type      in      com_api_type_pkg.t_dict_value
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_long_id
)
is 
    l_address_count             com_api_type_pkg.t_long_id;
begin
    select count(ao.id)
      into l_address_count
      from com_address_object_vw ao
     where ao.entity_type  = i_entity_type
       and ao.object_id    = i_object_id
       and ao.address_type = i_address_type;

    if l_address_count > 0 then
        trc_log_pkg.debug('com_address_object is already exists - entity_type [' || i_entity_type || '] object [' || i_object_id || '] address_type[' || i_address_type || ']');
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_ADDRESS_TYPE'
          , i_env_param1 => i_entity_type
          , i_env_param2 => i_object_id
          , i_env_param3 => i_address_type
        );
    end if;
end;

end com_api_address_pkg;
/
