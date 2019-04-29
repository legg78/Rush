create or replace package body com_api_id_object_pkg as
/************************************************************
 * Provides an interface for managing documents. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.03.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_API_ID_OBJECT_PKG <br />
 * @headcom
 *************************************************************/
procedure register_event(
    i_id        in      com_api_type_pkg.t_long_id
) is
    l_param_tab         com_api_type_pkg.t_param_tab;
    l_count             com_api_type_pkg.t_sign       := 0;
begin
    for rec in (
        select c.id
             , c.inst_id
             , c.split_hash
          from com_id_object i
             , prd_customer  c
         where i.id          = i_id
           and c.entity_type = i.entity_type
           and c.object_id   = i.object_id
    ) loop
        if l_count = 0 then
            l_count := 1;
        end if;

        evt_api_event_pkg.register_event(
            i_event_type      => prd_api_const_pkg.EVENT_CUSTOMER_MODIFY
          , i_eff_date        => get_sysdate
          , i_entity_type     => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id       => rec.id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );

        evt_api_event_pkg.register_event(
            i_event_type      => com_api_const_pkg.EVENT_TYPE_IDENT_DATA_CHANGED
          , i_eff_date        => get_sysdate
          , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT
          , i_object_id       => i_id
          , i_inst_id         => rec.inst_id
          , i_split_hash      => rec.split_hash
          , i_param_tab       => l_param_tab
        );

    end loop;

    if l_count = 0 then
        for rec in (
            select h.id
                 , h.inst_id
              from com_id_object  i
                 , iss_cardholder h
             where i.id          = i_id
               and i.entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
               and h.id          = i.object_id
        ) loop
            evt_api_event_pkg.register_event(
                i_event_type      => iss_api_const_pkg.EVENT_TYPE_CARDHOLDER_MODIFY
              , i_eff_date        => get_sysdate
              , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
              , i_object_id       => rec.id
              , i_inst_id         => rec.inst_id
              , i_split_hash      => null
              , i_param_tab       => l_param_tab
            );

            evt_api_event_pkg.register_event(
                i_event_type      => com_api_const_pkg.EVENT_TYPE_IDENT_DATA_CHANGED
              , i_eff_date        => get_sysdate
              , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_IDENTIFY_OBJECT
              , i_object_id       => i_id
              , i_inst_id         => rec.inst_id
              , i_split_hash      => null
              , i_param_tab       => l_param_tab
            );

        end loop;
    end if;

end register_event;

procedure add_id_object(
    o_id                 out  com_api_type_pkg.t_medium_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_entity_type     in      com_api_type_pkg.t_dict_value
  , i_object_id       in      com_api_type_pkg.t_long_id
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_full_desc
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_inst_id         in      com_api_type_pkg.t_inst_id
  , i_country         in      com_api_type_pkg.t_country_code       default null
) is
begin
    if length(trim(nvl(i_id_type,''))) = 0 then
        com_api_error_pkg.raise_error(
            i_error => 'ID_CARD_TYPE_EMPTY'
        );
    end if;

    o_id     := com_id_object_seq.nextval;
    o_seqnum := 1;

    insert into com_id_object_vw(
        id
      , seqnum
      , entity_type
      , object_id
      , id_type
      , id_series
      , id_number
      , id_issuer
      , id_issue_date
      , id_expire_date
      , inst_id
      , country
    ) values (
        o_id
      , o_seqnum
      , i_entity_type
      , i_object_id
      , i_id_type
      , trim(i_id_series)
      , trim(i_id_number)
      , trim(i_id_issuer)
      , trim(i_id_issue_date)
      , trim(i_id_expire_date)
      , get_sandbox(i_inst_id)
      , i_country
    );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'COM_ID_OBJECT'
      , i_column_name => 'DESCRIPTION'
      , i_object_id   => o_id
      , i_text        => i_id_desc
      , i_lang        => i_lang
    );
    register_event(i_id => o_id);
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error => 'ID_CARD_ALREADY_EXISTS'
          , i_env_param1 => i_id_type 
          , i_env_param2 => i_id_series 
          , i_env_param3 => i_id_number 
        );

end add_id_object;

procedure modify_id_object(
    i_id              in      com_api_type_pkg.t_medium_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_full_desc
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_country         in      com_api_type_pkg.t_country_code       default null
) is
    l_count                   com_api_type_pkg.t_medium_id;
    l_id_series               com_api_type_pkg.t_name       := trim(i_id_series);
    l_id_number               com_api_type_pkg.t_name       := trim(i_id_number);
    l_id_issuer               com_api_type_pkg.t_full_desc  := trim(i_id_issuer);
    l_is_changed              com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE;
    l_old_text                com_api_type_pkg.t_text;
    l_new_text                com_api_type_pkg.t_text;
begin
    if length(trim(nvl(i_id_type,''))) = 0 then
        com_api_error_pkg.raise_error(
            i_error => 'ID_CARD_TYPE_EMPTY'
        );
    end if;

    update com_id_object_vw
       set id_type        = i_id_type
         , id_series      = l_id_series
         , id_number      = l_id_number
         , id_issuer      = l_id_issuer
         , id_issue_date  = i_id_issue_date
         , id_expire_date = i_id_expire_date
         , seqnum         = io_seqnum
         , country        = i_country
     where id             = i_id
       and not (  -- update row only when some field is changed
               id_type             = i_id_type
               and (id_series      = l_id_series      or (id_series      is null and l_id_series      is null))
               and id_number       = l_id_number
               and (id_issuer      = l_id_issuer      or (id_issuer      is null and l_id_issuer      is null))
               and (id_issue_date  = i_id_issue_date  or (id_issue_date  is null and i_id_issue_date  is null))
               and (id_expire_date = i_id_expire_date or (id_expire_date is null and i_id_expire_date is null))
               and (country         = i_country       or (country        is null and i_country        is null))
           );

    if sql%rowcount > 0 then
        io_seqnum    := io_seqnum + 1;
        l_is_changed := com_api_type_pkg.TRUE;
    end if;

    select count(id)
      into l_count
      from com_id_object_vw
     where id_type    = i_id_type
       and (id_series = l_id_series or (id_series is null and l_id_series is null))
       and id_number  = l_id_number;

    if l_count > 1 then
        com_api_error_pkg.raise_error(
            i_error      => 'ID_CARD_ALREADY_EXISTS'
          , i_env_param1 => i_id_type
          , i_env_param2 => l_id_series
          , i_env_param3 => l_id_number
        );
    end if;

    l_old_text := com_api_i18n_pkg.get_text(
                      i_table_name   => 'COM_ID_OBJECT'
                    , i_column_name  => 'DESCRIPTION'
                    , i_object_id    => i_id
                    , i_lang         => i_lang
                  );

    com_api_i18n_pkg.add_text(
        i_table_name  => 'COM_ID_OBJECT'
      , i_column_name => 'DESCRIPTION'
      , i_object_id   => i_id
      , i_text        => i_id_desc
      , i_lang        => i_lang
    );

    l_new_text := com_api_i18n_pkg.get_text(
                      i_table_name   => 'COM_ID_OBJECT'
                    , i_column_name  => 'DESCRIPTION'
                    , i_object_id    => i_id
                    , i_lang         => i_lang
                  );

    if not (l_new_text = l_old_text or l_old_text is null) then
        l_is_changed := com_api_type_pkg.TRUE;
    end if;

    if l_is_changed = com_api_type_pkg.TRUE then
        register_event(i_id => i_id);
    end if;
end modify_id_object;

procedure remove_id_object(
    i_id                in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    for rec in (select id from com_id_object_vw where id = i_id) loop
        update com_id_object_vw
           set seqnum = i_seqnum
         where id = rec.id;

        delete from com_id_object_vw
         where id = rec.id;

        com_api_i18n_pkg.remove_text(
            i_table_name  => 'COM_ID_OBJECT'
          , i_object_id   => i_id
        );
    end loop;
end remove_id_object;

end com_api_id_object_pkg;
/
