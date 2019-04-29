create or replace package body iss_api_card_instance_pkg is
/*********************************************************
*  Issuer - Card instance <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 15.04.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: iss_api_card_instance_pkg <br />
*  @headcom
**********************************************************/

BULK_COLLECT                constant pls_integer := 100;

function get_card_instance_id (
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_seq_number            in com_api_type_pkg.t_tiny_id     default null
  , i_expir_date            in date                           default null
) return com_api_type_pkg.t_medium_id is
    l_card_instance_id      com_api_type_pkg.t_medium_id;
begin
    select max(id)
      into l_card_instance_id
      from iss_card_instance_vw
     where card_id = i_card_id
       and (i_seq_number is null or seq_number = i_seq_number)
       and (i_expir_date is null or trunc(expir_date, 'mm') = trunc(i_expir_date, 'mm'));

    if l_card_instance_id is null then
        select max(id)
          into l_card_instance_id
          from iss_card_instance_vw
         where card_id = i_card_id
           and status = iss_api_const_pkg.CARD_STATUS_VALID_CARD;
    end if;

    if l_card_instance_id is null then
        select max(id)
          into l_card_instance_id
          from iss_card_instance_vw
         where card_id = i_card_id;
    end if;

    return l_card_instance_id;
end get_card_instance_id;

/*
 * [2nd] Get card instance identifier by 2 of 4 possible parameters:
 * i_card_id or i_card_number must be present TOGETHER with i_seq_number or i_expir_date
 * @param  i_card_id      - Card identifier
 * @param  i_seq_number   - Card instance sequential number
 * @param  i_expir_date   - Card instance expiration date;
 *                          only year and month specification is required, day is not taken into consideration
 * @param  i_raise_error  - Raise exception CARD_INSTANCE_NOT_FOUND if searching process failed
 */
function get_card_instance_id(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_card_number           in com_api_type_pkg.t_card_number
  , i_seq_number            in com_api_type_pkg.t_tiny_id
  , i_expir_date            in date
  , i_raise_error           in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id
is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_instance_id[2th]: ';
    l_card_instance_id         com_api_type_pkg.t_medium_id;
    l_card_mask                com_api_type_pkg.t_card_number;
begin
    l_card_mask := iss_api_card_pkg.get_card_mask(i_card_number => i_card_number);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_id [#1], l_card_mask [#2], i_seq_number [#3], i_expir_date [#4]'
      , i_env_param1 => i_card_id
      , i_env_param2 => l_card_mask
      , i_env_param3 => i_seq_number
      , i_env_param4 => i_expir_date
    );

    if i_seq_number is null and i_expir_date is null then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'no card instance could be found because i_seq_number and i_expir_date are empty'
        );
    else
        -- Try to search l_card_instance_id by a one(!) of available parameters
        if i_card_id is not null then
            begin
                select max(id)
                  into l_card_instance_id
                  from iss_card_instance
                 where card_id = i_card_id
                   and (i_seq_number is null or seq_number = i_seq_number)
                   and (i_expir_date is null or trunc(expir_date, 'mm') = trunc(i_expir_date, 'mm'));
            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || 'no card instance has been found by i_card_id [#1]'
                      , i_env_param1 => i_card_id
                    );
            end;
        end if;

        if l_card_instance_id is null and i_card_number is not null then
            begin
                select max(ci.id)
                  into l_card_instance_id
                  from iss_card_instance ci
                  join iss_card_number cn    on cn.card_id = ci.card_id
                 where reverse(cn.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_card_number))
                   and (i_seq_number is null or ci.seq_number = i_seq_number)
                   and (i_expir_date is null or trunc(ci.expir_date, 'mm') = trunc(i_expir_date, 'mm'));
            exception
                when no_data_found then
                    trc_log_pkg.debug(
                        i_text       => LOG_PREFIX || 'no card instance has been found by i_card_number; l_card_mask [#1]'
                      , i_env_param1 => l_card_mask
                    );
            end;
        end if;

        if i_raise_error = com_api_const_pkg.TRUE and l_card_instance_id is null then
            com_api_error_pkg.raise_error(
                i_error      => 'CARD_INSTANCE_NOT_FOUND'
              , i_env_param1 => nvl(l_card_mask, i_card_id)
              , i_env_param2 => i_seq_number
            );
        end if;
    end if;

    return l_card_instance_id;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_card_id [#1], l_card_mask [#2], i_seq_number [#3], i_expir_date [#4]'
          , i_env_param1 => i_card_id
          , i_env_param2 => l_card_mask
          , i_env_param3 => i_seq_number
          , i_env_param4 => i_expir_date
        );
        raise;
end get_card_instance_id; -- #2th

/*
 * [3rd] Get card instance identifier by 4 parameters,
 *       (i_seq_number and i_expir_date are interchangeable parameters):
 * @param  i_card_id      - Card identifier
 * @param  i_seq_number   - Card instance sequential number
 * @param  i_expir_date   - Card instance expiration date;
 *                          only year and month specification is required, day is not taken into consideration
 * @param  i_status       - Preferable card instance's status, it is an optional parameter, so that if instance
 *                          with such status doesn't exist then minimal card instance's identifier will be returned
 * @param  i_raise_error  - Raise exception CARD_INSTANCE_NOT_FOUND if searching process failed
 */
function get_card_instance_id(
    i_card_id               in com_api_type_pkg.t_medium_id
  , i_seq_number            in com_api_type_pkg.t_tiny_id
  , i_expir_date            in date
  , i_state                 in com_api_type_pkg.t_dict_value
  , i_raise_error           in com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_medium_id
is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_card_instance_id[3th]: ';
    l_card_instance_id         com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_id [#1], i_seq_number [#2], i_expir_date [#3], i_state [#4]'
      , i_env_param1 => i_card_id
      , i_env_param2 => i_seq_number
      , i_env_param3 => i_expir_date
      , i_env_param4 => i_state
    );

    if i_card_id is null or i_seq_number is null and i_expir_date is null then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'card instance could not be found because of insufficient input data'
        );
    else
        begin
            select distinct
                   first_value(ci.id) over (
                       order by case when ci.state = i_state then 0 else 1 end
                              , ci.id desc
                   )
              into l_card_instance_id
              from iss_card_instance ci
             where ci.card_id = i_card_id
               and (i_seq_number is null or i_seq_number = ci.seq_number)
               and (i_expir_date is null or trunc(i_expir_date, 'mm') = trunc(ci.expir_date, 'mm'));
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text       => LOG_PREFIX || 'no card instance has been found'
                  , i_env_param1 => i_card_id
                );
        end;
    end if;

    if i_raise_error = com_api_const_pkg.TRUE and l_card_instance_id is null then
        com_api_error_pkg.raise_error (
            i_error      => 'CARD_INSTANCE_NOT_FOUND'
        );
    end if;

    return l_card_instance_id;

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED with i_card_id [#1], i_seq_number [#2], i_expir_date [#3], i_state [#4]'
          , i_env_param1 => i_card_id
          , i_env_param2 => i_seq_number
          , i_env_param3 => i_expir_date
          , i_env_param4 => i_state
        );
        raise;
end get_card_instance_id; -- #3th

procedure register_pvv (
    i_card_instance_id      in com_api_type_pkg.t_medium_id
  , i_pvv                   in com_api_type_pkg.t_tiny_id
  , i_pin_block             in com_api_type_pkg.t_pin_block
  , i_change_id             in com_api_type_pkg.t_long_id
  , i_pvk_index             in com_api_type_pkg.t_tiny_id
) is
begin
    update iss_card_instance_data_vw d
       set d.old_pvv       = d.pvv
         , d.pvv           = i_pvv
         , d.kcolb_nip     = i_pin_block
         , d.pvv_change_id = i_change_id
         , d.pvk_index     = nvl(i_pvk_index, d.pvk_index)
     where d.card_instance_id = i_card_instance_id;

    if sql%rowcount = 0 then
        insert into iss_card_instance_data_vw(
            card_instance_id
          , kcolb_nip
          , pin_block_format
          , pvv
          , pvk_index
          , pvv_change_id
        ) values (
            i_card_instance_id
          , i_pin_block
          , prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
          , i_pvv
          , nvl(i_pvk_index, 1)
          , i_change_id
        );
    end if;
end;

procedure update_sensitive_data(
    i_id                    in com_api_type_pkg.t_medium_id
  , i_pvk_index             in com_api_type_pkg.t_tiny_id
  , i_pvv                   in com_api_type_pkg.t_tiny_id
  , i_pin_offset            in com_api_type_pkg.t_cmid
  , i_pin_block             in com_api_type_pkg.t_pin_block
  , i_pin_block_format      in com_api_type_pkg.t_dict_value
) is
begin
    merge into
        iss_card_instance_data dst
    using (
        select
            i_id                  card_instance_id
            , i_pin_block         pin_block
            , i_pin_block_format  pin_block_format
            , i_pvv               pvv
            , i_pin_offset        pin_offset
            , i_pvk_index         pvk_index
        from dual
    ) src
    on (
        src.card_instance_id = dst.card_instance_id
    )
    when matched then
        update
        set
            dst.kcolb_nip          = src.pin_block
            , dst.pin_block_format = src.pin_block_format
            , dst.pvv              = src.pvv
            , dst.pin_offset       = src.pin_offset
            , dst.pvk_index        = src.pvk_index
            , dst.old_pvv          = dst.pvv
            , dst.pvv_change_id    = null
    when not matched then
        insert (
            dst.card_instance_id
            , dst.kcolb_nip
            , dst.pin_block_format
            , dst.pvv
            , dst.pin_offset
            , dst.pvk_index
        ) values (
            src.card_instance_id
            , src.pin_block
            , src.pin_block_format
            , src.pvv
            , src.pin_offset
            , src.pvk_index
        );
end;

procedure update_sensitive_data (
    i_id                    in com_api_type_pkg.t_medium_tab
  , i_pvk_index             in com_api_type_pkg.t_tiny_tab
  , i_pvv                   in com_api_type_pkg.t_tiny_tab
  , i_pin_offset            in com_api_type_pkg.t_cmid_tab
  , i_pin_block             in com_api_type_pkg.t_varchar2_tab
  , i_pin_block_format      in com_api_type_pkg.t_dict_tab
) is
begin
    forall i in 1 .. i_id.count
        merge into
            iss_card_instance_data dst
        using (
            select
                i_id(i)                  card_instance_id
                , i_pin_block(i)         pin_block
                , i_pin_block_format(i)  pin_block_format
                , i_pvv(i)               pvv
                , i_pin_offset(i)        pin_offset
                , i_pvk_index(i)         pvk_index
            from dual
        ) src
        on (
            src.card_instance_id = dst.card_instance_id
        )
        when matched then
            update
            set
                dst.kcolb_nip          = src.pin_block
                , dst.pin_block_format = src.pin_block_format
                , dst.pvv              = src.pvv
                , dst.pin_offset       = src.pin_offset
                , dst.pvk_index        = src.pvk_index
                , dst.old_pvv          = dst.pvv
                , dst.pvv_change_id    = null
        when not matched then
            insert (
                dst.card_instance_id
                , dst.kcolb_nip
                , dst.pin_block_format
                , dst.pvv
                , dst.pin_offset
                , dst.pvk_index
            ) values (
                src.card_instance_id
                , src.pin_block
                , src.pin_block_format
                , src.pvv
                , src.pin_offset
                , src.pvk_index
            );
end;

procedure rollback_pvv (
    i_card_instance_id      in com_api_type_pkg.t_medium_id
  , i_change_id             in com_api_type_pkg.t_long_id
) is
begin
    update iss_card_instance_data_vw d
       set d.pvv           = d.old_pvv
         , d.old_pvv       = null
         , d.kcolb_nip     = null
         , d.pvv_change_id = null
     where d.card_instance_id = i_card_instance_id
       and d.pvv_change_id    = i_change_id;
end;

procedure add_card_instance(
    i_card_number           in     com_api_type_pkg.t_card_number
  , io_card_instance        in out iss_api_type_pkg.t_card_instance
  , i_register_event        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_status_reason         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_command       in     com_api_type_pkg.t_dict_value    default null
) is
    l_postponed_event_tab          evt_api_type_pkg.t_postponed_event_tab;
begin
    add_card_instance(
        i_card_number           => i_card_number
      , io_card_instance        => io_card_instance
      , i_register_event        => i_register_event
      , i_status_reason         => i_status_reason
      , i_reissue_command       => i_reissue_command
      , i_need_postponed_event  => com_api_const_pkg.FALSE
      , io_postponed_event_tab  => l_postponed_event_tab
    );
end add_card_instance;

procedure add_card_instance(
    i_card_number           in     com_api_type_pkg.t_card_number
  , io_card_instance        in out iss_api_type_pkg.t_card_instance
  , i_register_event        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , i_status_reason         in     com_api_type_pkg.t_dict_value    default null
  , i_reissue_command       in     com_api_type_pkg.t_dict_value    default null
  , i_need_postponed_event  in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
  , io_postponed_event_tab  in out nocopy evt_api_type_pkg.t_postponed_event_tab
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add_card_instance: ';
    l_params                    com_api_type_pkg.t_param_tab;
    l_delivery_params           com_api_type_pkg.t_param_tab;
    l_session_id                com_api_type_pkg.t_long_id;
    l_card_type_name            com_api_type_pkg.t_short_desc;
    l_card_type_id              com_api_type_pkg.t_tiny_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'i_card_id [#1], i_card_number [#2]'
      , i_env_param1 => io_card_instance.card_id
      , i_env_param2 => iss_api_card_pkg.get_card_mask(i_card_number => i_card_number)
    );

    if io_card_instance.card_id is null then
        io_card_instance.card_id := iss_api_card_pkg.get_card(
                                            i_card_number => i_card_number
                                          , i_mask_error  => com_api_type_pkg.FALSE
                                        ).id;
    end if;
    
    if io_card_instance.split_hash is null then
        begin
            select split_hash
              into io_card_instance.split_hash
              from iss_card
             where id = io_card_instance.card_id;
        exception
            when no_data_found then
               com_api_error_pkg.raise_error (
                   i_error         => 'CARD_NOT_FOUND'
                 , i_env_param1    => io_card_instance.card_id
                 , i_env_param2    => io_card_instance.inst_id
               );
        end;
    end if;

    if io_card_instance.expir_date < io_card_instance.start_date then
        com_api_error_pkg.raise_error(
            i_error      => 'EXPIRATION_DATE_LT_START_DATE'
          , i_env_param1 => com_api_type_pkg.convert_to_char(io_card_instance.start_date)
          , i_env_param2 => com_api_type_pkg.convert_to_char(io_card_instance.expir_date)
        );
    end if;

    if io_card_instance.id is null then
        io_card_instance.id := iss_card_instance_seq.nextval;
    end if;
        
    io_card_instance.cardholder_name := upper(io_card_instance.cardholder_name);
    l_session_id                     := prc_api_session_pkg.get_session_id;

    if io_card_instance.delivery_ref_number is null then
        -- Generate delivery_ref_number
        begin
            select card_type_id
              into l_card_type_id
              from iss_card
             where id = io_card_instance.card_id;
        exception
            when no_data_found then
               com_api_error_pkg.raise_error (
                   i_error         => 'CARD_NOT_FOUND'
                 , i_env_param1    => io_card_instance.card_id
                 , i_env_param2    => io_card_instance.inst_id
               );
        end;
        
        l_card_type_name := substr(
            com_api_i18n_pkg.get_text(
                i_table_name  => 'NET_CARD_TYPE'
              , i_column_name => 'NAME'   
              , i_object_id   => l_card_type_id
              , i_lang        => com_api_const_pkg.DEFAULT_LANGUAGE) 
          , 1
          , 200);

        rul_api_param_pkg.set_param(
            i_name          => 'INST_ID'
          , i_value         => nvl(io_card_instance.inst_id, ost_api_const_pkg.DEFAULT_INST)
          , io_params       => l_delivery_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'AGENT_NUMBER'
          , i_value         => ost_ui_agent_pkg.get_agent_number(io_card_instance.agent_id)
          , io_params       => l_delivery_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'SYS_DATE'
          , i_value         => get_sysdate
          , io_params       => l_delivery_params
        );

        rul_api_param_pkg.set_param(
            i_name          => 'CARD_TYPE_NAME'
          , i_value         => l_card_type_name
          , io_params       => l_delivery_params
        );

        if rul_api_name_pkg.get_format_id(
               i_inst_id         => io_card_instance.inst_id
             , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD_DELIVERY
             , i_raise_error     => com_api_type_pkg.FALSE
           ) is not null
        then
            io_card_instance.delivery_ref_number := rul_api_name_pkg.get_name(
                                                        i_inst_id             => nvl(io_card_instance.inst_id, ost_api_const_pkg.DEFAULT_INST)
                                                      , i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD_DELIVERY
                                                      , i_param_tab           => l_delivery_params
                                                      , i_double_check_value  => null
                                                    );
        else
            trc_log_pkg.warn(
                i_text        => 'NO_NAME_FORMAT'
              , i_env_param1  => ost_ui_institution_pkg.get_inst_name(io_card_instance.inst_id)
              , i_env_param2  => iss_api_const_pkg.ENTITY_TYPE_CARD_DELIVERY
            );
        end if;
    end if; 

    update iss_card_instance ci
       set ci.is_last_seq_number = com_api_type_pkg.FALSE
     where ci.card_id    = io_card_instance.card_id
       and ci.split_hash = io_card_instance.split_hash
       and ci.seq_number = (select max(s.seq_number) from iss_card_instance s where s.card_id = ci.card_id);

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'adding new card instance with id [#1]'
      , i_env_param1 => io_card_instance.id
    );

    insert into iss_card_instance (
        id
      , split_hash
      , card_id
      , seq_number
      , state
      , reg_date
      , iss_date
      , start_date
      , expir_date
      , cardholder_name
      , company_name
      , pin_request
      , pin_mailer_request
      , embossing_request
      , status
      , perso_priority
      , perso_method_id
      , bin_id
      , inst_id
      , agent_id
      , blank_type_id
      , icc_instance_id
      , delivery_channel
      , preceding_card_instance_id
      , reissue_reason
      , reissue_date
      , session_id
      , card_uid
      , delivery_ref_number
      , delivery_status
      , embossed_surname
      , embossed_first_name
      , embossed_second_name
      , embossed_title
      , embossed_line_additional
      , supplementary_info_1
      , cardholder_photo_file_name
      , cardholder_sign_file_name
      , is_last_seq_number
    ) values (
        io_card_instance.id
      , io_card_instance.split_hash
      , io_card_instance.card_id
      , io_card_instance.seq_number
      , io_card_instance.state
      , io_card_instance.reg_date
      , io_card_instance.iss_date
      , io_card_instance.start_date
      , io_card_instance.expir_date
      , io_card_instance.cardholder_name
      , io_card_instance.company_name
      , io_card_instance.pin_request
      , io_card_instance.pin_mailer_request
      , io_card_instance.embossing_request
      , io_card_instance.status
      , io_card_instance.perso_priority
      , io_card_instance.perso_method_id
      , io_card_instance.bin_id
      , io_card_instance.inst_id
      , io_card_instance.agent_id
      , io_card_instance.blank_type_id
      , io_card_instance.icc_instance_id
      , io_card_instance.delivery_channel
      , io_card_instance.preceding_card_instance_id
      , io_card_instance.reissue_reason
      , io_card_instance.reissue_date
      , l_session_id
      , io_card_instance.card_uid
      , io_card_instance.delivery_ref_number
      , nvl(io_card_instance.delivery_status, iss_api_const_pkg.CARD_DELIVERY_STATUS_PERS)
      , io_card_instance.embossed_surname
      , io_card_instance.embossed_first_name
      , io_card_instance.embossed_second_name
      , io_card_instance.embossed_title
      , io_card_instance.embossed_line_additional
      , io_card_instance.supplementary_info_1
      , io_card_instance.cardholder_photo_file_name
      , io_card_instance.cardholder_sign_file_name
      , com_api_type_pkg.TRUE
    );

    evt_api_status_pkg.add_status_log(
        i_event_type  => iss_api_const_pkg.EVENT_TYPE_INSTANCE_CREATION
      , i_initiator   => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id   => io_card_instance.id
      , i_reason      => i_status_reason
      , i_status      => io_card_instance.state
      , i_eff_date    => io_card_instance.iss_date
    );

    evt_api_status_pkg.add_status_log(
        i_event_type  => iss_api_const_pkg.EVENT_TYPE_INSTANCE_CREATION
      , i_initiator   => evt_api_const_pkg.INITIATOR_SYSTEM
      , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id   => io_card_instance.id
      , i_reason      => i_status_reason
      , i_status      => io_card_instance.status
      , i_eff_date    => io_card_instance.iss_date
    );
       
    if i_register_event = com_api_const_pkg.TRUE then
        rul_api_shared_data_pkg.load_card_params(
            i_card_id           => io_card_instance.card_id
          , i_card_instance_id  => io_card_instance.id
          , io_params           => l_params
        );

        fcl_api_cycle_pkg.add_cycle_counter (
            i_cycle_type     => iss_api_const_pkg.CYCLE_EXPIRATION_DATE
            , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            , i_object_id    => io_card_instance.id
            , i_split_hash   => io_card_instance.split_hash
            , i_next_date    => io_card_instance.expir_date
            , i_inst_id      => io_card_instance.inst_id
        );

        rul_api_param_pkg.set_param(
            i_name    => 'REISS_COMMAND'
          , i_value   => i_reissue_command
          , io_params => l_params
        );

        evt_api_event_pkg.register_event (
            i_event_type            => iss_api_const_pkg.EVENT_TYPE_INSTANCE_CREATION
          , i_eff_date              => com_api_sttl_day_pkg.get_calc_date(i_inst_id => io_card_instance.inst_id)
          , i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id             => io_card_instance.id
          , i_inst_id               => io_card_instance.inst_id
          , i_split_hash            => io_card_instance.split_hash
          , i_param_tab             => l_params
          , i_need_postponed_event  => i_need_postponed_event
          , io_postponed_event_tab  => io_postponed_event_tab
        );
    
    end if;
    
    if io_card_instance.preceding_card_instance_id is not null then
        iss_api_card_token_pkg.relink_token(
            i_card_instance_id  => io_card_instance.id
        );
    end if;
end add_card_instance;

procedure change_agent(
    i_contract_id           in     com_api_type_pkg.t_medium_id
  , i_split_hash            in     com_api_type_pkg.t_tiny_id
  , i_new_agent_id          in     com_api_type_pkg.t_agent_id
) is
    cursor l_cur_iss_card_instance(
        p_contract_id  in com_api_type_pkg.t_medium_id
      , p_split_hash   in com_api_type_pkg.t_tiny_id
    ) is
    select ci.id
      from iss_card c
      join iss_card_instance ci on ci.card_id = c.id
     where c.contract_id  = p_contract_id
       and c.split_hash   = p_split_hash
       and ci.split_hash  = p_split_hash
       and ci.state      != iss_api_const_pkg.CARD_STATE_CLOSED;

    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.change_agent: ';

--    type t_card_instance_id_tab is table of com_api_type_pkg.t_medium_id index by pls_integer;
--    l_card_instance_id_tab         t_card_instance_id_tab;
    l_card_instance_id_tab         com_api_type_pkg.t_medium_tab;
begin
    if i_new_agent_id is not null then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'i_contract_id [#1], i_split_hash [#2], i_new_agent_id [#3]'
          , i_env_param1 => i_contract_id
          , i_env_param2 => i_split_hash
          , i_env_param3 => i_new_agent_id
        );

        open l_cur_iss_card_instance(i_contract_id, i_split_hash);
        loop
            fetch l_cur_iss_card_instance bulk collect into l_card_instance_id_tab limit BULK_COLLECT;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'l_cur_iss_card_instance%rowcount [#1], l_card_instance_id_tab.count [#2] first[#3] last[#4]'
              , i_env_param1 => l_cur_iss_card_instance%rowcount
              , i_env_param2 => l_card_instance_id_tab.count
            );

            forall i in 1..l_card_instance_id_tab.count
                update iss_card_instance
                   set agent_id   = i_new_agent_id
                 where id         = l_card_instance_id_tab(i)
                   and split_hash = i_split_hash;

            exit when l_cur_iss_card_instance%notfound;
        end loop;

        close l_cur_iss_card_instance;
    end if;
exception
    when others then
        if l_cur_iss_card_instance%isopen then
            close l_cur_iss_card_instance;
        end if;
        raise;
end;

/*
 * Change card instance state.
 * @param  i_id              - card instance identifier
 * @param  i_card_state      - new card instance state (CSTE dictionary)
 */
procedure change_card_state(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_card_state            in     com_api_type_pkg.t_dict_value
  , i_raise_error           in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_params                com_api_type_pkg.t_param_tab;
    l_status                com_api_type_pkg.t_dict_value;
begin
    if i_id is not null and i_card_state is not null then
        evt_api_status_pkg.change_status(
            i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id      => i_id
          , i_new_status     => i_card_state
          , i_reason         => null
          , i_params         => l_params
          , i_raise_error    => i_raise_error
          , o_status         => l_status
        );
    end if;
end;

function get_card_uid (
    i_card_instance_id        in com_api_type_pkg.t_medium_id
) return com_api_type_pkg.t_name is
    l_result        com_api_type_pkg.t_name;
begin

    select card_uid 
      into l_result
      from iss_card_instance 
     where id = i_card_instance_id;

    return l_result;
    
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error      => 'CARD_INSTANCE_NOT_FOUND'
          , i_env_param1 => i_card_instance_id
        );
end;

/*
 * Get card instance record.
 * @param  i_id              - card instance identifier
 * @param  i_card_id         - card identifier may be optionally checked during a search
 */
function get_instance(
    i_id                    in     com_api_type_pkg.t_medium_id
  , i_card_id               in     com_api_type_pkg.t_medium_id     default null
  , i_raise_error           in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
) return iss_api_type_pkg.t_card_instance
is
    l_instance_rec                 iss_api_type_pkg.t_card_instance;
begin
    begin
        select id
             , split_hash
             , card_id
             , seq_number
             , state
             , reg_date
             , iss_date
             , start_date
             , expir_date
             , cardholder_name
             , company_name
             , pin_request
             , pin_mailer_request
             , embossing_request
             , status
             , perso_priority
             , perso_method_id
             , bin_id
             , inst_id
             , agent_id
             , blank_type_id
             , reissue_reason
             , reissue_date
             , preceding_card_instance_id
             , delivery_channel
             , icc_instance_id
             , card_uid
             , delivery_ref_number
             , delivery_status
             , embossed_surname
             , embossed_first_name
             , embossed_second_name
             , embossed_title
             , embossed_line_additional
             , supplementary_info_1
             , cardholder_photo_file_name
             , cardholder_sign_file_name
             , is_last_seq_number
          into l_instance_rec
          from iss_card_instance
         where id = i_id
           and (i_card_id is null or card_id = i_card_id);
    exception
        when no_data_found then
            if i_raise_error = com_api_const_pkg.FALSE then
                return null;
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'CARD_INSTANCE_NOT_FOUND'
                  , i_env_param1 => nvl(i_card_id, i_id)
                );
            end if;
    end;

    return l_instance_rec;
end get_instance;

procedure set_preceding_instance_id(
    i_instance_id           in     com_api_type_pkg.t_medium_id
  , i_preceding_instance_id in     com_api_type_pkg.t_medium_id
)
is
begin
    update iss_card_instance i
       set i.preceding_card_instance_id = i_preceding_instance_id
     where i.id = i_instance_id;
end;

procedure register_pin_offset (
    i_card_instance_id      in     com_api_type_pkg.t_medium_id
  , i_pin_offset            in     com_api_type_pkg.t_cmid
  , i_pin_block             in     com_api_type_pkg.t_pin_block
  , i_change_id             in     com_api_type_pkg.t_long_id
  , i_pvk_index             in     com_api_type_pkg.t_tiny_id := null
) is
begin
    update iss_card_instance_data_vw d
       set d.pin_offset    = i_pin_offset
         , d.kcolb_nip     = i_pin_block
         , d.pvv_change_id = i_change_id
         , d.pvk_index     = nvl(i_pvk_index, d.pvk_index)
     where d.card_instance_id = i_card_instance_id;

    if sql%rowcount = 0 then
        insert into iss_card_instance_data_vw(
            card_instance_id
          , kcolb_nip
          , pin_block_format
          , pin_offset
          , pvk_index
          , pvv_change_id
        ) values (
            i_card_instance_id
          , i_pin_block
          , prs_api_const_pkg.PIN_BLOCK_FORMAT_ANSI
          , i_pin_offset
          , nvl(i_pvk_index, 1)
          , i_change_id
        );
    end if;
end register_pin_offset;

end iss_api_card_instance_pkg;
/
