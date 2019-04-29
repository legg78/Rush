create or replace package body iss_ui_card_instance_pkg is
/************************************************************
 * User interface for card instance <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.12.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: iss_ui_card_instance_pkg <br />
 * @headcom
 ************************************************************/

    -- single update
    procedure modify_requesting_action (
        i_card_instance_id      in com_api_type_pkg.t_medium_id
        , i_pin_request         in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_perso_priority      in com_api_type_pkg.t_dict_value
        , i_request_type        in com_api_type_pkg.t_dict_value
        , o_message             out com_api_type_pkg.t_text
    ) is
        i_id_tab                num_tab_tpt := num_tab_tpt();
        l_card_in_batch         com_api_type_pkg.t_tiny_id := 0;
        l_can_update            com_api_type_pkg.t_tiny_id := 0;
        l_message               com_api_type_pkg.t_text;
        l_card_mask             com_api_type_pkg.t_text;
    begin
        --
        select
            (case
                when exists (
                    select 1 from prs_batch_card p
                    where p.card_instance_id = i_card_instance_id)
                then 1
                else 0
           end)
        into l_card_in_batch
        from dual;
        --
        case i_request_type 
            when 'RQTP0001'-- Raise warning if card in batch and not change, else update flags 
                then
                    if l_card_in_batch = 1 then
                        --com_api_error_pkg.raise_error (
                        --    i_error         => 'CARD_ALREADY_IN_BATCH'
                        --    , i_env_param1  => i_card_instance_id
                        --);
                        select
                            com_api_i18n_pkg.get_text(
                                i_table_name        => 'com_label'
                              , i_column_name       => 'name'
                              , i_object_id         => (select id from com_label where name = 'CARD_ALREADY_IN_BATCH')
                              , i_lang              => com_ui_user_env_pkg.get_user_lang
                            )
                        into l_message
                        from dual;
                        --
                        select i.card_mask
                          into l_card_mask
                          from iss_card i,
                               iss_card_instance ic
                         where i.id = ic.card_id
                           and ic.id = i_card_instance_id;
                        --
                        o_message := replace(l_message, '#1', l_card_mask);
                    else
                        l_can_update := 1;
                    end if;
            when 'RQTP0002'-- Remove card from all batches and save flags
                then
                    if l_card_in_batch = 1 then
                        delete
                            from prs_batch_card_vw
                         where
                            card_instance_id = i_card_instance_id;
                    end if;
                    --
                    l_can_update := 1;
            when 'RQTP0003'-- Leave in batch and save flags
                then
                    l_can_update := 1;
            else
                null;
        end case;
        --
        if l_can_update = 1 then
            i_id_tab.extend(1);
            i_id_tab(i_id_tab.count) := i_card_instance_id;
            --
            modify_requesting_action (
                i_card_instance_id_tab  => i_id_tab
                , i_pin_request         => i_pin_request
                , i_pin_mailer_request  => i_pin_mailer_request
                , i_embossing_request   => i_embossing_request
                , i_perso_priority      => i_perso_priority
            );
        end if;
    end modify_requesting_action;

    -- group update with common settings
    procedure modify_requesting_action (
        i_card_instance_id_tab  in num_tab_tpt
        , i_pin_request         in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_perso_priority      in com_api_type_pkg.t_dict_value
    ) is
    begin
        forall i in indices of i_card_instance_id_tab
            update
                iss_card_instance_vw
            set
                pin_request = i_pin_request
                , pin_mailer_request = i_pin_mailer_request
                , embossing_request = i_embossing_request
                , state = case when i_embossing_request != iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS 
                                 or i_pin_mailer_request != iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                               then iss_api_const_pkg.CARD_STATE_PERSONALIZATION
                          else
                              state
                          end
                , perso_priority = nvl(i_perso_priority, perso_priority)
            where
                id = i_card_instance_id_tab(i);
    end modify_requesting_action;

    -- group update with individual settings
    procedure modify_requesting_action (
        i_card_instance_id_tab  in num_tab_tpt
        , i_pin_request         in raw_data_tpt
        , i_pin_mailer_request  in raw_data_tpt
        , i_embossing_request   in raw_data_tpt
        , i_perso_priority      in raw_data_tpt
    ) is
    begin
        forall i in indices of i_card_instance_id_tab
            update
                iss_card_instance_vw
            set
                pin_request = i_pin_request(i).raw_data
                , pin_mailer_request = i_pin_mailer_request(i).raw_data
                , embossing_request = i_embossing_request(i).raw_data
                , state = case when i_embossing_request(i).raw_data != iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS 
                                    or i_pin_mailer_request(i).raw_data != iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                              then iss_api_const_pkg.CARD_STATE_PERSONALIZATION
                          else
                              state
                          end
                , perso_priority = nvl(i_perso_priority(i).raw_data, perso_priority)
            where
                id = i_card_instance_id_tab(i);
    end modify_requesting_action;

    procedure change_card_security_data (
         i_card_id                in com_api_type_pkg.t_medium_id
       , i_card_number            in com_api_type_pkg.t_card_number
       , i_expiration_date        in date
       , i_card_sequental_number  in com_api_type_pkg.t_tiny_id
       , i_card_instance_id       in com_api_type_pkg.t_medium_id
       , i_state                  in com_api_type_pkg.t_dict_value
       , i_pvv                    in com_api_type_pkg.t_tiny_id
       , i_pin_offset             in com_api_type_pkg.t_cmid
       , i_pin_block              in com_api_type_pkg.t_pin_block
       , i_key_index              in com_api_type_pkg.t_tiny_id
       , i_pin_block_format       in com_api_type_pkg.t_dict_value
       , i_issue_date             in date                              default null
    )
    is
        l_card_instance_id           com_api_type_pkg.t_medium_id;
        l_params                     com_api_type_pkg.t_param_tab;
        l_inst_id                    com_api_type_pkg.t_inst_id;
        l_split_hash                 com_api_type_pkg.t_tiny_id;
        l_card_state                 com_api_type_pkg.t_dict_value;
    begin
        trc_log_pkg.debug(
            i_text => 'procedure change_card_security_data, i_card_id [#1], i_card_number [#2], i_expiration_date [#3], i_card_sequental_number [#4], i_card_instance_id [#5], i_state [#6]'
          , i_env_param1 => i_card_id
          , i_env_param2 => iss_api_card_pkg.get_card_mask(i_card_number)
          , i_env_param3 => i_expiration_date
          , i_env_param4 => i_card_sequental_number
          , i_env_param5 => i_card_instance_id
          , i_env_param6 => i_state
        );
        
        if i_card_instance_id is not null then
            l_card_instance_id := i_card_instance_id;
        else
            l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id (
                              i_card_id      => i_card_id
                            , i_card_number  => i_card_number
                            , i_seq_number   => i_card_sequental_number
                            , i_expir_date   => i_expiration_date
                            , i_raise_error  => com_api_const_pkg.TRUE
                        );
        end if;
        begin
            select inst_id
                 , split_hash
                 , state
              into l_inst_id
                 , l_split_hash
                 , l_card_state 
              from iss_card_instance ci
             where ci.id = l_card_instance_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(i_error => 'CARD_INSTANCE_NOT_FOUND');
        end;

        if i_issue_date is not null then
            trc_log_pkg.debug(
                i_text => 'update issue date to [#1] for card instance [#2]'
              , i_env_param1 => i_issue_date
              , i_env_param2 => l_card_instance_id
            );

            update iss_card_instance ci 
               set ci.iss_date = i_issue_date 
             where ci.id = l_card_instance_id;
        end if;

        iss_api_card_instance_pkg.change_card_state(
            i_id          => l_card_instance_id
          , i_card_state  => nvl(i_state, l_card_state)
          , i_raise_error => com_api_type_pkg.TRUE
        );

        iss_api_card_instance_pkg.update_sensitive_data (
            i_id                  => l_card_instance_id
            , i_pvk_index         => i_key_index
            , i_pvv               => i_pvv
            , i_pin_offset        => i_pin_offset
            , i_pin_block         => i_pin_block
            , i_pin_block_format  => i_pin_block_format
        );

        evt_api_event_pkg.register_event(
            i_event_type    => iss_api_const_pkg.EVENT_TYPE_UPD_SENSITIVE_DATA
          , i_eff_date      => com_api_sttl_day_pkg.get_sysdate
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id     => l_card_instance_id
          , i_inst_id       => l_inst_id
          , i_split_hash    => l_split_hash
          , i_param_tab     => l_params
        );
    end;

    procedure update_delivery_ref_number(
        i_inst_id               in com_api_type_pkg.t_inst_id
      , i_agent_id              in com_api_type_pkg.t_agent_id
      , i_card_type_id          in com_api_type_pkg.t_tiny_id
      , i_card_instance_id_tab  in num_tab_tpt
      , i_delivery_ref_number   in com_api_type_pkg.t_name 
      , i_lang                  in com_api_type_pkg.t_dict_value    default com_api_const_pkg.DEFAULT_LANGUAGE
      , i_max_name_size         in com_api_type_pkg.t_tiny_id       default 200
    ) is
        l_params                com_api_type_pkg.t_param_tab;
        l_delivery_ref_number   com_api_type_pkg.t_name;
        l_card_type_name        com_api_type_pkg.t_short_desc := null;

        LOG_PREFIX     constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.update_delivery_ref_number: ';
    begin
        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'START i_card_type_id=[' || i_card_type_id || ']'
        );

        if i_delivery_ref_number is null then
            l_card_type_name := substr(
                com_api_i18n_pkg.get_text(
                    i_table_name  => 'NET_CARD_TYPE'
                  , i_column_name => 'NAME'   
                  , i_object_id   => i_card_type_id
                  , i_lang        => i_lang) 
              , 1
              , least(i_max_name_size, 200));

            rul_api_param_pkg.set_param(
                i_name          => 'INST_ID'
              , i_value         => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
              , io_params       => l_params
            );

            rul_api_param_pkg.set_param(
                i_name          => 'AGENT_NUMBER'
              , i_value         => ost_ui_agent_pkg.get_agent_number(i_agent_id)
              , io_params       => l_params
            );

            rul_api_param_pkg.set_param(
                i_name          => 'SYS_DATE'
              , i_value         => get_sysdate
              , io_params       => l_params
            );

            rul_api_param_pkg.set_param(
                i_name          => 'CARD_TYPE_NAME'
              , i_value         => l_card_type_name
              , io_params       => l_params
            );

            l_delivery_ref_number := rul_api_name_pkg.get_name(
                                         i_inst_id             => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
                                       , i_entity_type         => iss_api_const_pkg.ENTITY_TYPE_CARD_DELIVERY
                                       , i_param_tab           => l_params
                                       , i_double_check_value  => null
                                     );
        end if; 

        forall i in indices of i_card_instance_id_tab
            update iss_card_instance_vw
               set delivery_ref_number = nvl(i_delivery_ref_number, l_delivery_ref_number)
             where id = i_card_instance_id_tab(i);

        trc_log_pkg.debug(
            i_text => LOG_PREFIX || 'END, updated ' || sql%rowcount
        );   
    end;

    procedure modify_delivery_status(
        i_card_instance_id_tab  in num_tab_tpt
      , i_delivery_status       in com_api_type_pkg.t_dict_value
      , i_event_date            in date
    ) is
        l_card_instance_id_tab      com_api_type_pkg.t_number_tab;
        l_event_type_tab            com_api_type_pkg.t_dict_tab;
        l_initiator_tab             com_api_type_pkg.t_dict_tab;
        l_entity_type_tab           com_api_type_pkg.t_dict_tab;
        l_reason_tab                com_api_type_pkg.t_dict_tab;
        l_status_tab                com_api_type_pkg.t_dict_tab;
        l_eff_date_tab              com_api_type_pkg.t_date_tab;
        l_sysdate                   date;
        l_event_date_tab            com_api_type_pkg.t_date_tab;
    begin
        l_sysdate := get_sysdate;

        forall i in indices of i_card_instance_id_tab
            update iss_card_instance_vw
               set delivery_status = i_delivery_status
             where id = i_card_instance_id_tab(i);

        select column_value
             , iss_api_const_pkg.EVENT_DELIVERY_STATUS_CHANGE
             , evt_api_const_pkg.INITIATOR_OPERATOR
             , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
             , iss_api_const_pkg.EVENT_DELIVERY_STATUS_CHANGE
             , i_delivery_status
             , l_sysdate
             , i_event_date
          bulk collect 
          into l_card_instance_id_tab
             , l_event_type_tab
             , l_initiator_tab
             , l_entity_type_tab
             , l_reason_tab
             , l_status_tab
             , l_eff_date_tab
             , l_event_date_tab
          from table(cast(i_card_instance_id_tab as num_tab_tpt));

        evt_api_status_pkg.add_status_log(
            i_event_type        => l_event_type_tab
          , i_initiator         => l_initiator_tab
          , i_entity_type       => l_entity_type_tab
          , i_object_id         => l_card_instance_id_tab
          , i_reason            => l_reason_tab
          , i_status            => l_status_tab
          , i_eff_date          => l_eff_date_tab
          , i_event_date        => l_event_date_tab
        );
    end;

    procedure modify_delivery_status(
        i_delivery_ref_number   in com_api_type_pkg.t_name
      , i_delivery_status       in com_api_type_pkg.t_dict_value
      , i_event_date            in date
    ) is
        l_card_instance_id_tab      num_tab_tpt;
    begin
        select id
          bulk collect
          into l_card_instance_id_tab
          from iss_card_instance_vw
         where delivery_ref_number = i_delivery_ref_number;

        modify_delivery_status(
            i_card_instance_id_tab  => l_card_instance_id_tab
          , i_delivery_status       => i_delivery_status
          , i_event_date            => i_event_date
        );
    end;

begin
    null;
end iss_ui_card_instance_pkg;
/
