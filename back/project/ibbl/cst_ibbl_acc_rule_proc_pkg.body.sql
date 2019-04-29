create or replace package body cst_ibbl_acc_rule_proc_pkg as

LEAFLET     constant com_api_type_pkg.t_name := 'LEAFLET';

procedure register_checkbook is

    l_agent_number    com_api_type_pkg.t_name;
    l_leaflet_count     com_api_type_pkg.t_medium_id;
    l_iss_participant   opr_api_type_pkg.t_oper_part_rec;
    l_operation         opr_api_type_pkg.t_oper_rec;

    l_checkbook_id    com_api_type_pkg.t_long_id;
    l_leaflet_id      com_api_type_pkg.t_long_id;
    l_sysdate         date := com_api_sttl_day_pkg.get_sysdate();
    l_params          com_api_type_pkg.t_param_tab;
    l_account_link_id com_api_type_pkg.t_medium_id;
    l_account         acc_api_type_pkg.t_account_rec;
begin

    l_iss_participant := opr_api_shared_data_pkg.get_participant(i_participant_type => COM_API_CONST_PKG.PARTICIPANT_ISSUER);
    l_operation       := opr_api_shared_data_pkg.get_operation;

    l_agent_number := aup_api_tag_pkg.get_tag_value(
        i_auth_id => l_operation.id
      , i_tag_id  => cst_ibbl_api_const_pkg.TAG_AGENT_NUMBER
    );

    l_leaflet_count := nvl(aup_api_tag_pkg.get_tag_value(
        i_auth_id => l_operation.id
      , i_tag_id  => cst_ibbl_api_const_pkg.TAG_LEAFLET_COUNT
    ), 10);

    trc_log_pkg.debug(
        i_text => 'cst_ibbl_acc_rule_proc_pkg.register_checkbook l_iss_participant.account_number=' || l_iss_participant.account_number 
         || ' l_iss_inst_id='  || l_iss_participant.inst_id
         || ' l_agent_number=' || l_agent_number
         || ' l_leaflet_count='|| l_leaflet_count
    );

    l_account := acc_api_account_pkg.get_account(
        i_account_id     => null
      , i_account_number => l_iss_participant.account_number
      , i_inst_id        => l_iss_participant.inst_id
      , i_mask_error     => com_api_type_pkg.FALSE
    );
    
    if l_agent_number is null then

        l_agent_number := ost_ui_agent_pkg.get_agent_number(
            i_agent_id =>  l_account.agent_id
        );

        if l_agent_number is null then
            com_api_error_pkg.raise_error( --Agent [#1] not found for institute [#2].
                i_error      => 'AGENT_NOT_FOUND'
              , i_env_param1 => l_account.agent_id
              , i_env_param2 => l_iss_participant.inst_id
            );
        end if;
    else
        l_account.agent_id := ost_api_agent_pkg.get_agent_id(
            i_agent_id     => null
          , i_agent_number => l_agent_number
          , i_inst_id      => l_iss_participant.inst_id
          , i_mask_error   => com_api_const_pkg.FALSE
        );
    end if;

    l_checkbook_id := com_api_id_pkg.get_id(cst_ibbl_acc_checkbook_seq.nextval, l_sysdate);

    insert into cst_ibbl_acc_checkbook(
        id
      , checkbook_number
      , checkbook_status
      , delivery_branch_number
      , leaflet_count
      , reg_date
      , spent_date
    ) values (
        l_checkbook_id
      , l_checkbook_id
      , cst_ibbl_api_const_pkg.CHECKBOOK_STATUS_ORDERED --  'CHBS0010' -- ordered
      , l_agent_number
      , l_leaflet_count
      , l_sysdate
      , null
    );
    
    begin
        for i in 1..l_leaflet_count loop
          
            l_leaflet_id := com_api_id_pkg.get_id(cst_ibbl_acc_cb_leaflet_seq.nextval, l_sysdate);
            
            insert into cst_ibbl_acc_checkbook_leaflet(
                id
              , checkbook_id
              , leaflet_number
              , leaflet_status
              , reg_date
              , used_date
            ) values(
                l_leaflet_id
              , l_checkbook_id
              , l_leaflet_id
              , cst_ibbl_api_const_pkg.LEAFLET_STATUS_ACTIVE --- 'CBLS0000'
              , l_sysdate
              , null
            );
            
        end loop;
        
    exception
        when others then
            com_api_error_pkg.raise_error(
                i_error      => 'LEAFLET_REG_ERROR'
              , i_env_param1 => l_iss_participant.account_number
              , i_env_param2 => l_leaflet_id
              , i_env_param3 => sqlerrm
            );
    end;

    acc_api_account_pkg.add_account_link(
        i_account_id      => l_account.account_id
      , i_object_id       => l_checkbook_id
      , i_entity_type     => cst_ibbl_api_const_pkg.ENTITY_TYPE_CHECKBOOK
      , i_description     => null
      , i_is_active       => com_api_const_pkg.TRUE
      , o_account_link_id => l_account_link_id
    );   
    
    evt_api_event_pkg.register_event(
        i_event_type  => cst_ibbl_api_const_pkg.EVENT_TYPE_CHECKBOOK_REG -- 'EVNT5100'
      , i_eff_date    => l_sysdate
      , i_entity_type => cst_ibbl_api_const_pkg.ENTITY_TYPE_CHECKBOOK
      , i_object_id   => l_checkbook_id
      , i_inst_id     => l_iss_participant.inst_id
      , i_split_hash  => l_account.split_hash
      , i_param_tab   => l_params
      , i_status      => evt_api_const_pkg.EVENT_STATUS_READY
    );

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'CHECKBOOK_REG_ERROR'
          , i_env_param1 => l_iss_participant.account_number
          , i_env_param2 => sqlerrm
        );

end register_checkbook;

procedure checkbook_leaflet_redemption is
    l_leaflet_number    com_api_type_pkg.t_account_number;
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
    l_account           acc_api_type_pkg.t_account_rec;
    l_lang              com_api_type_pkg.t_dict_value;
    l_checkbook_status  com_api_type_pkg.t_dict_value;
    l_leaflet_status    com_api_type_pkg.t_dict_value;
    l_leaflet_id        com_api_type_pkg.t_long_id;
    l_checkbook_id      com_api_type_pkg.t_long_id;
    l_checkbook_number  com_api_type_pkg.t_account_number;
    l_leaflet_count     com_api_type_pkg.t_count := 0;
    l_account_link_id   com_api_type_pkg.t_medium_id;
    l_sysdate           date     := com_api_sttl_day_pkg.get_sysdate;
    l_count             com_api_type_pkg.t_count := 0;
    l_iss_participant   opr_api_type_pkg.t_oper_part_rec;
begin
    trc_log_pkg.debug(i_text => 'checkbook_leaflet_redemption started' );

    l_iss_participant := opr_api_shared_data_pkg.get_participant(i_participant_type => COM_API_CONST_PKG.PARTICIPANT_ISSUER);
   
    l_iss_inst_id     := opr_api_shared_data_pkg.get_param_num('ISS_INST_ID');
    l_lang            := nvl(opr_api_shared_data_pkg.get_param_char(
                                 i_name       => 'LANGUAGE'
                               , i_mask_error => com_api_const_pkg.TRUE )
                           , com_api_const_pkg.LANGUAGE_ENGLISH
                         );
    
    l_account := acc_api_account_pkg.get_account(
                     i_account_id     => null
                   , i_account_number => l_iss_participant.account_number -- l_account_number
                   , i_inst_id        => l_iss_inst_id
                   , i_mask_error     => com_api_type_pkg.FALSE
                 );

    select min(n.text)
         , count(1)
      into l_leaflet_number
         , l_leaflet_count
      from ntb_ui_note_vw n
     where n.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- ENTTOPER
       and n.object_id   = l_iss_participant.oper_id
       and n.note_type   = cst_ibbl_api_const_pkg.NOTE_TYPE_CB_LEAFLET -- NTTPCHBL – Checkbook leaflet. 
       and n.header      = LEAFLET
       and n.lang        = l_lang;
       
    trc_log_pkg.debug(i_text => 'oper_id=' || l_iss_participant.oper_id
                || ', acc_num=' || l_iss_participant.account_number || ', leaflet_num=' || l_leaflet_number );

    if l_leaflet_count > 1 then
        com_api_error_pkg.raise_error(
            i_error      => 'LEAFLET_WRONG_COUNT'
          , i_env_param1 => l_iss_participant.oper_id
          , i_env_param2 => l_leaflet_count
        ); 
    elsif l_leaflet_count = 0 then
        -- If an operation doesn’t have a leaflet note (ntb_note, see above) do nothing.
        trc_log_pkg.debug(i_text => 'ntb_note not found - exiting' );   

        return;
    end if;

    begin
        select l.id
             , l.checkbook_id
          into l_leaflet_id
             , l_checkbook_id
          from cst_ibbl_acc_checkbook_leaflet l
         where l.leaflet_number = l_leaflet_number;
    exception
        when no_data_found then
           com_api_error_pkg.raise_error(
               i_error      => 'LEAFLET_NOT_FOUND'
             , i_env_param1 => l_leaflet_number
           );
    end;           

    begin
        select c.checkbook_status
             , cl.leaflet_status
             , cl.id
             , c.checkbook_number
          into l_checkbook_status
             , l_leaflet_status
             , l_leaflet_id
             , l_checkbook_number
          from cst_ibbl_acc_checkbook c
             , cst_ibbl_acc_checkbook_leaflet cl
         where c.id              = cl.checkbook_id
           and cl.leaflet_number = l_leaflet_number;

        if l_checkbook_status != cst_ibbl_api_const_pkg.CHECKBOOK_STATUS_ACTIVE then
            com_api_error_pkg.raise_error(
                i_error      => 'CHECKBOOK_BAD_STATE'
              , i_env_param1 => l_checkbook_number
              , i_env_param2 => l_checkbook_status
            );
        end if;

        if l_leaflet_status != cst_ibbl_api_const_pkg.LEAFLET_STATUS_ACTIVE then
            com_api_error_pkg.raise_error(
                i_error      => 'LEAFLET_BAD_STATE'
              , i_env_param1 => l_leaflet_number
              , i_env_param2 => l_leaflet_status
            );

        end if;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      =>  'CHECKBOOK_NOT_FOUND'
              , i_env_param1 => l_checkbook_id
            );
    end;

    begin
        select l.id
          into l_account_link_id
          from acc_account_link l
             , acc_account a
             , cst_ibbl_acc_checkbook c
         where l.entity_type      = cst_ibbl_api_const_pkg.ENTITY_TYPE_CHECKBOOK
           and l.object_id        = c.id
           and c.checkbook_number = l_checkbook_number
           and a.id               = l.account_id
           and a.account_number   = l_iss_participant.account_number
           and a.inst_id          = l_account.inst_id
           and l.is_active        = com_api_const_pkg.TRUE;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'ACCOUNT_LINK_ERR'
              , i_env_param1 => l_iss_participant.account_number
              , i_env_param3 => l_checkbook_number
            );
    end;

    update cst_ibbl_acc_checkbook_leaflet l
       set l.leaflet_status = cst_ibbl_api_const_pkg.LEAFLET_STATUS_USED
         , l.used_date      = l_sysdate
     where l.id             = l_leaflet_id;

     trc_log_pkg.debug(i_text  => 'updated ' || sql%rowcount || ' leaflet (id=' || l_leaflet_id || ')' );

    select count(1)
      into l_count
      from cst_ibbl_acc_checkbook cb
         , cst_ibbl_acc_checkbook_leaflet l
     where l.checkbook_id      = cb.id
       and cb.checkbook_number = l_checkbook_number
       and l.leaflet_status    = cst_ibbl_api_const_pkg.LEAFLET_STATUS_ACTIVE;
       
    if l_count = 0 then
        update cst_ibbl_acc_checkbook
           set checkbook_status = cst_ibbl_api_const_pkg.CHECKBOOK_STATUS_SPENT
             , spent_date       = l_sysdate
         where checkbook_number = l_checkbook_number;
         trc_log_pkg.debug(i_text  => 'Status of checkbook ' || l_checkbook_number || ' set to SPENT' );
    end if;
    
    trc_log_pkg.debug(i_text => 'checkbook_leaflet_redemption finished' );
    
exception
    when com_api_error_pkg.e_application_error
      or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end;

end cst_ibbl_acc_rule_proc_pkg;
/
