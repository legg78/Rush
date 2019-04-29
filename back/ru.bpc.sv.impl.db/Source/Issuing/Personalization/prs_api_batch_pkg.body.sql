CREATE OR REPLACE package body prs_api_batch_pkg is
/************************************************************
 * API for batch batch <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_batch_pkg <br />
 * @headcom
 ************************************************************/

    function get_batch (
        i_id                    in com_api_type_pkg.t_short_id
    ) return prs_api_type_pkg.t_batch_rec is
        l_result                    prs_api_type_pkg.t_batch_rec;
    begin
        select
            id
            , seqnum
            , inst_id
            , agent_id
            , product_id
            , card_type_id
            , blank_type_id
            , card_count
            , hsm_device_id
            , status
            , status_date
            , sort_id
        into
            l_result
        from
            prs_batch_vw
        where
            id = i_id;

        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'ILLEGAL_PERSO_BATCH'
                , i_env_param1  => i_id
            );
    end;

    procedure mark_ok_batch (
        i_id                    in com_api_type_pkg.t_short_id
        , i_status              in com_api_type_pkg.t_dict_value
    ) is
    begin
        update
            prs_batch_vw
        set
            status = i_status
            , status_date = systimestamp
        where
            id = i_id;
    end;

    procedure mark_ok_batch_card (
        i_id                    in com_api_type_pkg.t_number_tab
        , i_pin_generated       in com_api_type_pkg.t_number_tab
        , i_pin_mailer_printed  in com_api_type_pkg.t_number_tab
        , i_embossing_done      in com_api_type_pkg.t_number_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text         => 'Mark batch card...'
        );

        forall i in 1 .. i_id.count
            update
                prs_batch_card_vw
            set
                pin_generated = i_pin_generated(i)
                , pin_mailer_printed = i_pin_mailer_printed(i)
                , embossing_done = i_embossing_done(i)
            where
                id = i_id(i);

        trc_log_pkg.debug (
            i_text         => 'Mark batch card - ok'
        );
    end;

    procedure mark_error_batch_card (
        i_id                    in com_api_type_pkg.t_number_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text         => 'Mark batch...'
        );

        forall i in 1 .. i_id.count
            update
                prs_batch_card_vw
            set
                pin_generated = com_api_type_pkg.FALSE
                , pin_mailer_printed = com_api_type_pkg.FALSE
                , embossing_done = com_api_type_pkg.FALSE
            where
                id = i_id(i);

        trc_log_pkg.debug (
            i_text         => 'Mark batch - ok'
        );
    end;

    procedure set_batch_status_delivered (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
    ) is
    begin
        set_batch_instance_state(
            i_batch_id  => i_batch_id
          , i_agent_id  => i_agent_id
          , i_state     => iss_api_const_pkg.CARD_STATE_DELIVERED
        );
        
    end;
    
    procedure set_batch_instance_state (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
        , i_state               in com_api_type_pkg.t_dict_value    default null
        , i_event_type          in com_api_type_pkg.t_dict_value    default null    
    ) is
        l_params com_api_type_pkg.t_param_tab;
        l_status com_api_type_pkg.t_dict_value;
        l_count  pls_integer := 0;   
        
    begin
        trc_log_pkg.debug (
            i_text         => 'set_batch_status started. i_batch_id = ' || i_batch_id
        );

        select count(1)
          into l_count 
          from prs_batch
         where id = i_batch_id;
          
        if l_count = 0 then
            com_api_error_pkg.raise_error (
                i_error         => 'PRS_BATCH_NOT_FOUND'
                , i_env_param1  => i_batch_id
            );
        end if;
        
        for i in (
            select p.card_instance_id
              from prs_batch_card p
              join iss_card_instance ci on (p.card_instance_id = ci.id)
             where p.batch_id = i_batch_id
               and ci.agent_id = nvl(i_agent_id, ci.agent_id))
        loop
            if i_state is not null then
            
                evt_api_status_pkg.change_status(
                    i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                  , i_object_id      => i.card_instance_id
                  , i_new_status     => i_state
                  , i_reason         => case when i_state = iss_api_const_pkg.CARD_STATE_DELIVERED then iss_api_const_pkg.CARD_STATUS_REASON_DELIVERED else null end
                  , o_status         => l_status
                  , i_raise_error    => com_api_const_pkg.TRUE
                  , i_register_event => com_api_const_pkg.TRUE
                  , i_params         => l_params
                );
            
                trc_log_pkg.debug (
                    i_text         => 'Changed card instance[#1] state to [#2]'
                    , i_env_param1 => i.card_instance_id
                    , i_env_param2 => i_state
                );
            
            elsif i_event_type is not null then
            
                evt_api_status_pkg.change_status(
                    i_event_type     => i_event_type
                  , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                  , i_object_id      => i.card_instance_id
                  , i_reason         => case when i_state = iss_api_const_pkg.CARD_STATE_DELIVERED then iss_api_const_pkg.CARD_STATUS_REASON_DELIVERED else null end
                  , i_params         => l_params
                  , i_register_event => com_api_const_pkg.TRUE
                );
                
                trc_log_pkg.debug (
                    i_text         => 'Changed card instance[#1] state by event [#2]'
                    , i_env_param1 => i.card_instance_id
                    , i_env_param2 => i_event_type
                );
            else
                trc_log_pkg.error (
                    i_text         => 'i_state and i_event_type are empty.'
                );
            end if;    
            
        end loop;

        trc_log_pkg.debug (
            i_text         => 'set_batch_status finished'
        );
    end;
    
    procedure change_card_instances_status (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_agent_id            in com_api_type_pkg.t_agent_id      default null
        , i_event_type          in com_api_type_pkg.t_dict_value    default null
    ) is
        l_batch_status      com_api_type_pkg.t_dict_value;
        l_params            com_api_type_pkg.t_param_tab;
    begin
        trc_log_pkg.debug (
            i_text         => 'change_card_instances_status started.'
        );

        select status
          into l_batch_status 
          from prs_batch_vw
         where id = i_batch_id;
            
        if nvl(l_batch_status, '~') != prs_api_const_pkg.BATCH_STATUS_PROCESSED then
            com_api_error_pkg.raise_error (
                i_error         => 'ILLEGAL_BATCH_STATUS'
                , i_env_param1  => i_batch_id
                , i_env_param2  => l_batch_status
            );
        end if;

        for i in (
            select p.card_instance_id
              from prs_batch_card p
              join iss_card_instance ci on (p.card_instance_id = ci.id)
             where p.batch_id = i_batch_id
               and ci.agent_id = nvl(i_agent_id, ci.agent_id))
        loop
            evt_api_status_pkg.change_status(
                i_event_type     => i_event_type
              , i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => i.card_instance_id
              , i_reason         => null
              , i_eff_date       => null
              , i_params         => l_params
              , i_register_event => com_api_const_pkg.TRUE
            );

            trc_log_pkg.debug (
                i_text         => 'Changed card instance[#1] satus by event [#2]'
                , i_env_param1 => i.card_instance_id
                , i_env_param2 => i_event_type
            );
        end loop;

        trc_log_pkg.debug (
            i_text         => 'change_card_instances_status ended.'
        );

    end;

end;
/
