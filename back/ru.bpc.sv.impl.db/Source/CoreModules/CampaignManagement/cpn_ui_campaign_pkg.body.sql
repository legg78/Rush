create or replace package body cpn_ui_campaign_pkg is

procedure check_campaign_editability(
    i_campaign_id            in     com_api_type_pkg.t_short_id
) is
    l_current_date   date := com_api_sttl_day_pkg.get_sysdate;
begin
    for rec in (
        select start_date
             , end_date
          from cpn_campaign_vw
         where id  = i_campaign_id
           and l_current_date between start_date and end_date
    ) loop
        com_api_error_pkg.raise_error(
            i_error       => 'CPN_UNABLE_TO_CNANGE_CAMPAIGN'
          , i_env_param1  => i_campaign_id
          , i_env_param2  => rec.start_date
          , i_env_param3  => rec.end_date
          , i_entity_type => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id   => i_campaign_id
        );
    end loop;
end;

procedure check_dates(
    i_start_date             in     date
  , i_end_date               in     date
) is
begin
    if i_start_date is null then
        com_api_error_pkg.raise_error(
            i_error       => 'START_DATE_IS_EMPTY'
          , i_env_param1  => to_char(i_start_date, 'dd.mm.yyyy')
        );
    end if;

    if i_end_date is null then
        com_api_error_pkg.raise_error(
            i_error       => 'END_DATE_IS_EMPTY'
          , i_env_param1  => to_char(i_end_date,   'dd.mm.yyyy')
        );
    end if;

    if i_start_date > i_end_date then
        com_api_error_pkg.raise_error(
            i_error        => 'END_DATE_LESS_THAN_START_DATE'
          , i_env_param1   => to_char(i_end_date,   'dd.mm.yyyy')
          , i_env_param2   => to_char(i_start_date, 'dd.mm.yyyy')
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id    => null
          );
     end if;
end;

procedure perform_checks(
    i_campaign_type          in     com_api_type_pkg.t_dict_value
  , i_cycle_id               in     com_api_type_pkg.t_short_id
) is
begin
    com_api_dictionary_pkg.check_article(
        i_dict  => cpn_api_const_pkg.CAMPAIGN_TYPE_DICTIONARY
      , i_code  => i_campaign_type
    );

    if i_cycle_id is null and i_campaign_type = cpn_api_const_pkg.CAMPAIGN_TYPE_PROMO_CAMPAIGN then
         com_api_error_pkg.raise_error(
            i_error       => 'CPN_CYCLE_IS_REQUIRED_FOR_CAMPAIGN'
          , i_env_param1  => i_campaign_type
        );
    elsif i_cycle_id is not null and i_campaign_type = cpn_api_const_pkg.CAMPAIGN_TYPE_PRODUCT_CAMPAIGN then
         com_api_error_pkg.raise_error(
            i_error       => 'CPN_CYCLE_CANNOT_BE_USED_WITH_CAMPAIGN'
          , i_env_param1  => i_campaign_type
        );
    end if;
end perform_checks;

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
) is
    l_campaign_number        com_api_type_pkg.t_name;
    l_param_tab              com_api_type_pkg.t_param_tab;
    l_sysdate                date := com_api_sttl_day_pkg.get_sysdate;
begin
    check_dates(
        i_start_date => i_start_date
      , i_end_date   => i_end_date
    );

    -- and cannot be "in past" at the moment of campaign creation
    if i_start_date < l_sysdate then
        com_api_error_pkg.raise_error(
            i_error        => 'START_DATE_PASSED'
          , i_env_param1   => to_char(i_start_date, 'dd.mm.yyyy')
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
        );
    end if;

    perform_checks(
        i_campaign_type  => i_campaign_type
      , i_cycle_id       => i_cycle_id
    );

    l_campaign_number := i_campaign_number;
    o_id              := cpn_campaign_seq.nextval;

    if l_campaign_number is null then
        -- Generate campaign_number via naming rule or use i_campaign_number as it is specified.
        -- Pass campaign_id as-in l_param_tab
        rul_api_param_pkg.set_param(
            io_params => l_param_tab
          , i_name    => cpn_api_const_pkg.PARAM_NAME_CAMPAIGN_ID
          , i_value   => to_char(o_id, com_api_const_pkg.XML_NUMBER_FORMAT)
        );
        rul_api_param_pkg.set_param(
            io_params => l_param_tab
          , i_name    => cpn_api_const_pkg.PARAM_NAME_INST_ID
          , i_value   => to_char(i_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
        );
        rul_api_param_pkg.set_param(
            io_params => l_param_tab
          , i_name    => cpn_api_const_pkg.PARAM_NAME_CAMPAIGN_TYPE
          , i_value   => i_campaign_type
        );

        l_campaign_number :=
            rul_api_name_pkg.get_name(
                i_inst_id     => i_inst_id
              , i_entity_type => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
              , i_param_tab   => l_param_tab
            );
    end if;

    o_seqnum := 1;

    insert into cpn_campaign_vw(
        id
      , inst_id
      , seqnum
      , start_date
      , end_date
      , campaign_number
      , campaign_type
      , cycle_id
    ) values (
        o_id
      , i_inst_id
      , o_seqnum
      , i_start_date
      , i_end_date
      , l_campaign_number
      , i_campaign_type
      , i_cycle_id
    );

   com_api_i18n_pkg.add_text(
        i_table_name    => 'cpn_campaign'
      , i_column_name   => 'label'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_label
      , i_check_unique  => com_api_const_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'cpn_campaign'
      , i_column_name   => 'description'
      , i_object_id     => o_id
      , i_lang          => i_lang
      , i_text          => i_description
      , i_check_unique  => com_api_const_pkg.TRUE
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'CAMPAIGN_NUMBER_IS_NOT_UNIQUE'
          , i_env_param1 => l_campaign_number
          , i_env_param2 => i_inst_id
        );
end add_campaign;

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
) is
    l_campaign               cpn_api_type_pkg.t_campaign_rec;
    l_current_date           date   := com_api_sttl_day_pkg.get_sysdate;
begin
    perform_checks(
        i_campaign_type  => i_campaign_type
      , i_cycle_id       => i_cycle_id
    );

    -- Check dates. Start_date can't be greater then end date.
    check_dates(
        i_start_date  => i_start_date
      , i_end_date    => i_end_date
    );

    l_campaign := cpn_api_campaign_pkg.get_campaign(i_campaign_id => i_id);

    if  l_current_date between l_campaign.start_date and nvl(l_campaign.end_date, l_current_date + 1)
        and l_campaign.cycle_id != i_cycle_id
    then
        com_api_error_pkg.raise_error(
            i_error       => 'CPN_UNABLE_TO_CNANGE_CAMPAIGN'
          , i_env_param1  => i_id
          , i_env_param2  => l_campaign.start_date
          , i_env_param3  => l_campaign.end_date
          , i_entity_type => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
          , i_object_id   => i_id
        );
    end if;

    -- New start_date and end_date cannot be "in past" (or should be specified equal to current campaign dates)
    if  trunc(l_campaign.start_date) != trunc(i_start_date)
        and i_start_date < l_current_date
    then
        com_api_error_pkg.raise_error(
            i_error        => 'START_DATE_PASSED'
          , i_env_param1   => to_char(i_start_date, 'dd.mm.yyyy')
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
        );
    end if;

    if  trunc(l_campaign.end_date) != trunc(i_end_date)
        and i_end_date < l_current_date
    then
        com_api_error_pkg.raise_error(
            i_error        => 'END_DATE_PASSED'
          , i_env_param1   => to_char(i_end_date, 'dd.mm.yyyy')
          , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
        );
    end if;

    -- Check current (old) campaign dates
    if l_campaign.start_date > l_current_date then
        -- if campaign is not started yet update both campaign dates to new values
        io_seqnum := io_seqnum + 1;

        update cpn_campaign_vw
           set start_date = i_start_date
             , end_date   = i_end_date
             , cycle_id   = i_cycle_id
             , seqnum     = io_seqnum
         where id = i_id;

        -- update linked product attribute dates to new values
        update prd_attribute_value_vw v
           set start_date = i_start_date
             , end_date   = i_end_date
          where v.id in (select av.attribute_value_id
                           from cpn_attribute_value av
                          where av.campaign_id = i_id
                        );
    end if;

    if l_campaign.start_date <= l_current_date and l_campaign.end_date > l_current_date then
        -- If campaign is started
        io_seqnum := io_seqnum + 1;

        -- Start_date and cycle_id cannot be updated
        update cpn_campaign_vw
           set end_date   = i_end_date
             , seqnum     = io_seqnum
         where id = i_id;

        -- Update end_date of linked product attribute dates with new value
        update prd_attribute_value_vw v
           set end_date   = i_end_date
         where v.id in (select av.attribute_value_id
                           from cpn_attribute_value av
                          where av.campaign_id = i_id
                        );
    end if;

    if l_campaign.start_date <= l_current_date and l_campaign.end_date <= l_current_date then
        -- If campaign is finished, both dates cannot be updated.
        -- If any of dates are modified - find all attribute values of campaign
        -- and renew attribute dates from campaign values
        update prd_attribute_value_vw v
           set start_date = l_campaign.start_date
             , end_date   = l_campaign.end_date
         where v.id in (select av.attribute_value_id
                          from cpn_attribute_value av
                         where av.campaign_id = i_id
                        )
           and (start_date != l_campaign.start_date
             or end_date   != l_campaign.end_date
               )
        ;
    end if;

    io_seqnum := io_seqnum + 1;

    update cpn_campaign_vw c
       set seqnum          = io_seqnum
         , campaign_number = i_campaign_number
         , campaign_type   = i_campaign_type
     where id              = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name    => 'cpn_campaign'
      , i_column_name   => 'label'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_label
      , i_check_unique  => com_api_const_pkg.TRUE
    );

    com_api_i18n_pkg.add_text(
        i_table_name    => 'cpn_campaign'
      , i_column_name   => 'description'
      , i_object_id     => i_id
      , i_lang          => i_lang
      , i_text          => i_description
      , i_check_unique  => com_api_const_pkg.TRUE
    );

exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'CAMPAIGN_NUMBER_IS_NOT_UNIQUE'
          , i_env_param1 => i_campaign_number
          , i_env_param2 => l_campaign.inst_id
        );
end modify_campaign;

procedure remove_campaign(
    i_id           in      com_api_type_pkg.t_short_id
  , i_seqnum       in      com_api_type_pkg.t_seqnum
) is
begin
    -- Check current campaign dates - if it is started, removing is forbidden
    check_campaign_editability(i_campaign_id => i_id);
    -- Remove campaign and all linked objects from cpn* tables.
    delete cpn_campaign_product_vw p
     where p.campaign_id = i_id;

    -- Update linked product attribute dates to new values
    update prd_attribute_value_vw v
       set end_date = start_date
      where v.id in (select av.attribute_value_id
                       from cpn_attribute_value av
                      where av.campaign_id = i_id
                    );

    delete cpn_campaign_attribute_vw a
      where a.campaign_id = i_id;

    delete cpn_attribute_value_vw v
     where v.campaign_id = i_id;

    delete cpn_campaign_service_vw s
      where s.campaign_id = i_id;

    update cpn_campaign_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from cpn_campaign_vw
     where id = i_id;
end;

procedure add_campaign_product(
    o_id              out com_api_type_pkg.t_short_id
  , i_campaign_id  in     com_api_type_pkg.t_short_id
  , i_product_id   in     com_api_type_pkg.t_short_id
) is
begin
    -- Check current campaign dates - if it is started - raise error
    check_campaign_editability(i_campaign_id => i_campaign_id);

    o_id := cpn_campaign_product_seq.nextval;
    begin
        insert into cpn_campaign_product_vw(
            id
          , campaign_id
          , product_id
        ) values (
            o_id
          , i_campaign_id
          , i_product_id
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error        => 'DUPLICATE_DESCRIPTION'
              , i_env_param1   => 'Product'
              , i_env_param2   => 'ID'
              , i_env_param3   => i_product_id
              , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
              , i_object_id    => i_campaign_id
            );
    end;
end;

procedure remove_campaign_product(
    i_id           in     com_api_type_pkg.t_short_id
) is
    l_campaign_id         com_api_type_pkg.t_short_id;
begin
    -- Check current campaign dates - if it is started - removement is forbidden
    select campaign_id
      into l_campaign_id
      from cpn_campaign_product_vw p
     where p.id = i_id;

    check_campaign_editability(i_campaign_id => l_campaign_id);

    -- remove from cpn_campaign_product via cpn_campaign_product.id
    delete cpn_campaign_product_vw p
     where p.id = i_id;
end;

procedure add_campaign_service(
    o_id              out com_api_type_pkg.t_short_id
  , i_campaign_id  in     com_api_type_pkg.t_short_id
  , i_product_id   in     com_api_type_pkg.t_short_id
  , i_service_id   in     com_api_type_pkg.t_short_id
) is
begin
    o_id := cpn_campaign_service_seq.nextval;

    begin
        insert into cpn_campaign_service_vw(
            id
          , campaign_id
          , product_id
          , service_id
        ) values (
            o_id
          , i_campaign_id
          , i_product_id
          , i_service_id
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error        => 'DUPLICATE_DESCRIPTION'
              , i_env_param1   => 'Service'
              , i_env_param2   => 'ID'
              , i_env_param3   => i_service_id
              , i_entity_type  => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
              , i_object_id    => i_campaign_id
            );
    end;
end;

procedure remove_campaign_service(
    i_id           in     com_api_type_pkg.t_short_id
)is
    l_campaign_id         com_api_type_pkg.t_short_id;
begin
    select campaign_id
      into l_campaign_id
      from cpn_campaign_service_vw c
     where id = i_id;
    -- Check current campaign dates - if it is started - removement is forbidden
    check_campaign_editability(i_campaign_id => l_campaign_id);

    -- remove from cpn_campaign_service via cpn_campaign_service.id
    delete from cpn_campaign_service_vw
     where id = i_id;
end;

procedure add_campaign_attribute(
    o_id              out com_api_type_pkg.t_short_id
  , i_campaign_id  in     com_api_type_pkg.t_short_id
  , i_product_id   in     com_api_type_pkg.t_short_id
  , i_service_id   in     com_api_type_pkg.t_short_id
  , i_attribute_id in     com_api_type_pkg.t_short_id
) is
begin
    -- Check current campaign dates - if it is started - raise error
    check_campaign_editability(i_campaign_id => i_campaign_id);

    o_id := cpn_campaign_attribute_seq.nextval;
    -- add into cpn_campaign_attribute
    begin
        insert into cpn_campaign_attribute_vw(
            id
          , campaign_id
          , product_id
          , service_id
          , attribute_id
        ) values (
            o_id
          , i_campaign_id
          , i_product_id
          , i_service_id
          , i_attribute_id
        );
    exception
        when dup_val_on_index then
            com_api_error_pkg.raise_error(
                i_error       => 'DUPLICATE_DESCRIPTION'
              , i_env_param1  => 'Attribute'
              , i_env_param2  => 'ID'
              , i_env_param3  => i_attribute_id
              , i_entity_type => cpn_api_const_pkg.ENTITY_TYPE_CAMPAIGN
              , i_object_id   => i_campaign_id
            );
    end;
end;

procedure remove_campaign_attribute(
    i_id   in     com_api_type_pkg.t_short_id
) is
    l_campaign_id com_api_type_pkg.t_short_id;
begin
    -- Check current campaign dates - if it is started - removement is forbidden
    check_campaign_editability(i_campaign_id => l_campaign_id);

    -- remove from cpn_campaign_attribute via cpn_campaign_attribute.id
    delete from cpn_campaign_attribute_vw a
     where a.id = i_id;
end;

end cpn_ui_campaign_pkg;
/
