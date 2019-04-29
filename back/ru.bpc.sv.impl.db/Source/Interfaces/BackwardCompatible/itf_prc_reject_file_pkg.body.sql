create or replace package body itf_prc_reject_file_pkg is
/************************************************************
 * API for process reject files <br /> 
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 28.10.2015 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-12-01 16:30:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 61628 $ <br />
 * Module: itf_prc_reject_file_pkg <br />
 * @headcom
 ***********************************************************/

procedure get_rejected_count(
    i_xml_content       in     xmltype
  , io_estimated_count  in out com_api_type_pkg.t_long_id
  , i_file_type         in     com_api_type_pkg.t_dict_value
  , i_is_saver_mode     in     com_api_type_pkg.t_boolean
)
is
    l_estimated_count   com_api_type_pkg.t_long_id := 0;
    l_measure           com_api_type_pkg.t_dict_value;
begin
    if i_file_type    = FILE_TYPE_REJECT_TURNOVER then
        l_measure    := acc_api_const_pkg.ENTITY_TYPE_ACCOUNT;

        select count(1)
          into l_estimated_count
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVXP')
              , '/accounts/account'
                passing i_xml_content
                columns
                    account_number    varchar2(32 char)    path 'account_number'
               ) x
         where x.account_number is not null;

    elsif i_file_type = FILE_TYPE_REJECT_CARDS then
        l_measure    := iss_api_const_pkg.ENTITY_TYPE_CARD;

        select count(1)
          into l_estimated_count
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/sv/SVXP/card_info')
              , '/cards_info/card_info'
                passing i_xml_content
                columns
                    card_number        varchar2(24 char)   path 'card_number'
               ) x
         where x.card_number is not null;

    elsif i_file_type = FILE_TYPE_REJECT_MERCHANTS then
        l_measure    := acq_api_const_pkg.ENTITY_TYPE_MERCHANT;

        select count(1)
          into l_estimated_count
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVAP')
              , '/applications/application/customer/contract/merchant'
                passing i_xml_content
                columns
                    merchant_number    varchar2(15 char)   path 'merchant_number'
               ) x
         where x.merchant_number is not null;

    elsif i_file_type = FILE_TYPE_REJECT_TERMINALS then
        l_measure    := acq_api_const_pkg.ENTITY_TYPE_TERMINAL;

        select count(1)
          into l_estimated_count
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVAP')
              , '/applications/application/customer/contract/merchant/terminal'
                passing i_xml_content
                columns
                    terminal_number    varchar2(16 char)   path 'terminal_number'
               ) x
         where x.terminal_number is not null;

    end if;

    io_estimated_count := io_estimated_count + l_estimated_count;

    if i_is_saver_mode = com_api_type_pkg.TRUE then
        trc_log_pkg.debug (
            i_text            => 'get_rejected_count: rejected_count [#1]'
          , i_env_param1      => io_estimated_count
        );
    else
        prc_api_stat_pkg.log_estimation (
            i_estimated_count => io_estimated_count
          , i_measure         => l_measure
        );

        trc_log_pkg.debug (
            i_text            => 'get_rejected_count: estimated_count [#1]'
          , i_env_param1      => io_estimated_count
        );
    end if;

end get_rejected_count;

procedure rollback_turnover_events(
    i_xml_content       in     xmltype
  , o_changed_count        out com_api_type_pkg.t_long_id
) is
    BULK_LIMIT                 constant simple_integer := 2000;
    l_xml_cur                  sys_refcursor;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_session_id               com_api_type_pkg.t_long_id;
    l_account_event_id         com_api_type_pkg.t_tiny_id;
    l_oper_event_id            com_api_type_pkg.t_tiny_id;
    l_sysdate                  date;
    l_account_id_tab           num_tab_tpt := num_tab_tpt();
    l_split_hash_tab           num_tab_tpt := num_tab_tpt();
    l_event_object_id_tab      num_tab_tpt := num_tab_tpt();
    l_inserted_count           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'rollback_turnover_events start'
    );

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;
    o_changed_count := 0;

    -- Get inst id from XML header
    select x.inst_id
      into l_inst_id
      from xmltable(
            xmlnamespaces(default 'http://sv.bpc.in/SVXP')
          , '/accounts'
            passing i_xml_content
            columns
                inst_id    number(4)    path 'inst_id'
           ) x;

    -- Get default event id for used event types for accounts.
    select max(e.id)
      into l_account_event_id
      from evt_event e
     where e.event_type = acc_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_ACCOUNT
       and e.inst_id   in (l_inst_id, ost_api_const_pkg.DEFAULT_INST);

    -- Get default event id for used event types for operations.
    select max(e.id)
      into l_oper_event_id
      from evt_event e
     where e.event_type = opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
       and e.inst_id   in (l_inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug (
        i_text          => 'l_inst_id [#1], l_oper_event_id [#2]'
      , i_env_param1    => l_inst_id
      , i_env_param2    => l_oper_event_id
    );

    -- Get reject objects from XML
    open l_xml_cur for
        select (select a.id
                  from acc_account a
                 where a.account_number = x.account_number
                   and a.inst_id = l_inst_id
               ) as account_id
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVXP')
              , '/accounts/account'
                passing i_xml_content
                columns
                    account_number    varchar2(32 char)    path 'account_number'
               ) x
         where x.account_number is not null;

    -- Read reject file.
    loop
        fetch l_xml_cur
            bulk collect into l_account_id_tab       
            limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text          => 'l_account_id_tab.count [#1]'
          , i_env_param1    => l_account_id_tab.count
        );

        if l_account_id_tab.count > 0 then

            for i in 1 .. l_account_id_tab.count loop
                l_split_hash_tab.extend;
                l_split_hash_tab(i) := com_api_hash_pkg.get_split_hash(
                                           i_entity_type => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                                         , i_object_id   => l_account_id_tab(i)
                                       );

                l_event_object_id_tab.extend;
                l_event_object_id_tab(i) := com_api_id_pkg.get_id(
                                                i_seq         => evt_event_object_seq.nextval
                                              , i_date        => l_sysdate
                                            );
            end loop;

            -- We create events only for subscriber 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
            -- therefore we cannot use the "register_event" method.
            forall i in 1 .. l_account_id_tab.count
                insert into evt_event_object
                    (id, event_id, procedure_name, entity_type, object_id, eff_date, event_timestamp
                   , inst_id, split_hash, session_id, proc_session_id, status, event_type)
                  select l_event_object_id_tab(i)
                       , case when x.oper_id is not null
                              then l_oper_event_id
                              else l_account_event_id
                         end
                       , 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'
                       , case when x.oper_id is not null
                              then opr_api_const_pkg.ENTITY_TYPE_OPERATION
                              else acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                         end
                       , case when x.oper_id is not null
                              then x.oper_id
                              else x.account_id
                         end
                       , l_sysdate
                       , systimestamp
                       , l_inst_id
                       , l_split_hash_tab(i)
                       , l_session_id
                       , null
                       , evt_api_const_pkg.EVENT_STATUS_READY
                       , case when x.oper_id is not null
                              then opr_api_const_pkg.EVENT_PROCESSED_SUCCESSFULLY
                              else acc_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_ACCOUNT
                         end
                    from (
                          select l_account_id_tab(i) as account_id
                               , (select p.oper_id
                                    from opr_participant p
                                   where p.account_id       = l_account_id_tab(i)
                                     and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
                                     and rownum             = 1
                                 ) as oper_id
                            from dual
                    ) x;

            l_inserted_count := sql%rowcount;

            trc_log_pkg.debug (
                i_text          => 'account events: inserted [#1]'
              , i_env_param1    => l_inserted_count
            );

            if l_inserted_count > 0 then
                o_changed_count := o_changed_count + l_inserted_count;
            end if;

        end if;
                
        exit when l_xml_cur%notfound;
    end loop;

    close l_xml_cur;

    trc_log_pkg.debug (
        i_text          => 'rollback_turnover_events finish'
    );
end rollback_turnover_events;

procedure rollback_card_events(
    i_xml_content       in     xmltype
  , o_changed_count        out com_api_type_pkg.t_long_id
) is
    BULK_LIMIT                 constant simple_integer := 2000; 
    l_xml_cur                  sys_refcursor;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_session_id               com_api_type_pkg.t_long_id;
    l_card_event_id            com_api_type_pkg.t_tiny_id;
    l_sysdate                  date;
    l_card_id_tab              num_tab_tpt := num_tab_tpt();
    l_split_hash_tab           num_tab_tpt := num_tab_tpt();
    l_event_object_id_tab      num_tab_tpt := num_tab_tpt();
    l_inserted_count           com_api_type_pkg.t_long_id;
    l_tokenized_pan            com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug (
        i_text          => 'rollback_card_events start'
    );

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;
    o_changed_count := 0;

    -- Get inst id from XML header
    select x.inst_id
         , x.tokenized_pan
      into l_inst_id
         , l_tokenized_pan
      from xmltable(
            xmlnamespaces(default 'http://bpc.ru/sv/SVXP/card_info')
          , '/cards_info'
            passing i_xml_content
            columns
                inst_id          number(4)    path 'inst_id'
              , tokenized_pan    number(1)    path 'tokenized_pan'
           ) x;

    -- Get default event id for used event types.
    select max(e.id)
      into l_card_event_id
      from evt_event e
     where e.event_type = iss_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_CARD
       and e.inst_id   in (l_inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug (
        i_text          => 'l_inst_id [#1], l_card_event_id [#2], l_tokenized_pan [#3]'
      , i_env_param1    => l_inst_id
      , i_env_param2    => l_card_event_id
      , i_env_param3    => l_tokenized_pan
    );

    -- Get reject objects from XML
    open l_xml_cur for
        select (
                   -- It's unique relation: cn.card_id <--> cn.card_number
                   select cn.card_id
                     from iss_card_number cn
                    where reverse(cn.card_number) = reverse(
                                                        case l_tokenized_pan
                                                            when com_api_const_pkg.FALSE
                                                            then x.card_number
                                                            else iss_api_token_pkg.encode_card_number(i_card_number => x.card_number)
                                                        end
                                                    )
               ) as card_id
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/sv/SVXP/card_info')
              , '/cards_info/card_info'
                passing i_xml_content
                columns
                    card_number        varchar2(24 char)     path 'card_number'
               ) x
         where x.card_number is not null;

    -- Read reject file.
    loop
        fetch l_xml_cur
            bulk collect into l_card_id_tab
                limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text          => 'l_card_id_tab.count [#1]'
          , i_env_param1    => l_card_id_tab.count
        );

        if l_card_id_tab.count > 0 then

            for i in 1 .. l_card_id_tab.count loop
                l_split_hash_tab.extend;
                l_split_hash_tab(i) := com_api_hash_pkg.get_split_hash(
                                           i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                                         , i_object_id   => l_card_id_tab(i)
                                       );

                l_event_object_id_tab.extend;
                l_event_object_id_tab(i) := com_api_id_pkg.get_id(
                                                i_seq         => evt_event_object_seq.nextval
                                              , i_date        => l_sysdate
                                            );
            end loop;

            -- We create events only for subscriber 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
            -- therefore we cannot use the "register_event" method.
            forall i in 1 .. l_card_id_tab.count
                insert into evt_event_object(
                                id
                              , event_id
                              , procedure_name
                              , entity_type
                              , object_id
                              , eff_date
                              , event_timestamp
                              , inst_id
                              , split_hash
                              , session_id
                              , proc_session_id
                              , status
                              , event_type
                            )
                  values    (
                                l_event_object_id_tab(i)
                              , l_card_event_id
                              , 'ISS_PRC_EXPORT_PKG.EXPORT_CARDS_NUMBERS'
                              , iss_api_const_pkg.ENTITY_TYPE_CARD
                              , l_card_id_tab(i)
                              , l_sysdate
                              , systimestamp
                              , l_inst_id
                              , l_split_hash_tab(i)
                              , l_session_id
                              , null
                              , evt_api_const_pkg.EVENT_STATUS_READY
                              , iss_api_const_pkg.EVENT_ATTRIBUTE_CHANGE_CARD
                            );

            l_inserted_count := sql%rowcount;

            trc_log_pkg.debug (
                i_text          => 'card events: inserted [#1]'
              , i_env_param1    => l_inserted_count
            );

            if l_inserted_count > 0 then
                o_changed_count := o_changed_count + l_inserted_count;
            end if;

        end if;

        exit when l_xml_cur%notfound;
    end loop;

    close l_xml_cur;

    trc_log_pkg.debug (
        i_text          => 'rollback_card_events finish'
    );
end rollback_card_events;

procedure rollback_merchant_events(
    i_xml_content       in     xmltype
  , o_changed_count        out com_api_type_pkg.t_long_id
) is
    BULK_LIMIT                 constant simple_integer := 2000; 
    l_xml_cur                  sys_refcursor;
    l_session_id               com_api_type_pkg.t_long_id;
    l_sysdate                  date;
    l_inst_id_tab              num_tab_tpt := num_tab_tpt();
    l_merchant_id_tab          num_tab_tpt := num_tab_tpt();
    l_split_hash_tab           num_tab_tpt := num_tab_tpt();
    l_event_object_id_tab      num_tab_tpt := num_tab_tpt();
    l_inserted_count           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'rollback_merchant_events start'
    );

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;
    o_changed_count := 0;

    -- Get reject objects from XML
    open l_xml_cur for
        select x.inst_id
             , (
                   -- It's unique relation: m.id <--> m.merchant_number, m.inst_id
                   select m.id
                     from acq_merchant m
                    where reverse(m.merchant_number) = reverse(x.merchant_number)
               ) as merchant_id
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVAP')
              , '/applications/application'
                passing i_xml_content
                columns
                    inst_id            number(4)             path 'institution_id'
                  , merchant_number    varchar2(15 char)     path 'customer/contract/merchant/merchant_number'
               ) x
         where x.merchant_number is not null;

    -- Read reject file.
    loop
        fetch l_xml_cur
            bulk collect into l_inst_id_tab, l_merchant_id_tab
            limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text          => 'l_merchant_id_tab.count [#1]'
          , i_env_param1    => l_merchant_id_tab.count
        );

        if l_merchant_id_tab.count > 0 then

            for i in 1 .. l_merchant_id_tab.count loop
                l_split_hash_tab.extend;
                l_split_hash_tab(i)      := com_api_hash_pkg.get_split_hash(
                                                i_entity_type => acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                              , i_object_id   => l_merchant_id_tab(i)
                                            );

                l_event_object_id_tab.extend;
                l_event_object_id_tab(i) := com_api_id_pkg.get_id(
                                                i_seq         => evt_event_object_seq.nextval
                                              , i_date        => l_sysdate
                                            );
            end loop;

            -- We create events only for subscriber 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
            -- therefore we cannot use the "register_event" method.
            forall i in 1 .. l_merchant_id_tab.count
                insert into evt_event_object(
                                id
                              , event_id
                              , procedure_name
                              , entity_type
                              , object_id
                              , eff_date
                              , event_timestamp
                              , inst_id
                              , split_hash
                              , session_id
                              , proc_session_id
                              , status
                              , event_type
                            )
                  values    (
                                l_event_object_id_tab(i)
                              , (
                                    select max(e.id)
                                      from evt_event e
                                     where e.event_type = acq_api_const_pkg.EVENT_MERCHANT_ATTR_CHANGE
                                       and e.inst_id   in (l_inst_id_tab(i), ost_api_const_pkg.DEFAULT_INST)
                                )
                              , 'ITF_PRC_ACQUIRING_PKG.PROCESS_MERCHANT'
                              , acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                              , l_merchant_id_tab(i)
                              , l_sysdate
                              , systimestamp
                              , l_inst_id_tab(i)
                              , l_split_hash_tab(i)
                              , l_session_id
                              , null
                              , evt_api_const_pkg.EVENT_STATUS_READY
                              , acq_api_const_pkg.EVENT_MERCHANT_ATTR_CHANGE
                            );

            l_inserted_count := sql%rowcount;

            trc_log_pkg.debug (
                i_text          => 'merchant events: inserted [#1]'
              , i_env_param1    => l_inserted_count
            );

            if l_inserted_count > 0 then
                o_changed_count := o_changed_count + l_inserted_count;
            end if;

        end if;

        exit when l_xml_cur%notfound;
    end loop;

    close l_xml_cur;

    trc_log_pkg.debug (
        i_text          => 'rollback_merchant_events finish'
    );
end rollback_merchant_events;

procedure rollback_terminal_events(
    i_xml_content       in     xmltype
  , o_changed_count        out com_api_type_pkg.t_long_id
) is
    BULK_LIMIT                 constant simple_integer := 2000; 
    l_xml_cur                  sys_refcursor;
    l_session_id               com_api_type_pkg.t_long_id;
    l_sysdate                  date;
    l_inst_id_tab              num_tab_tpt := num_tab_tpt();
    l_terminal_id_tab          num_tab_tpt := num_tab_tpt();
    l_split_hash_tab           num_tab_tpt := num_tab_tpt();
    l_event_object_id_tab      num_tab_tpt := num_tab_tpt();
    l_inserted_count           com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'rollback_terminal_events start'
    );

    l_sysdate       := com_api_sttl_day_pkg.get_sysdate;
    l_session_id    := prc_api_session_pkg.get_session_id;
    o_changed_count := 0;

    -- Get reject objects from XML
    open l_xml_cur for
        select x.inst_id
             , (
                   -- It's unique relation: m.id <--> m.terminal_number, m.inst_id
                   select t.id
                     from acq_terminal t
                    where reverse(t.terminal_number) = reverse(x.terminal_number)
               ) as terminal_id
          from xmltable(
                xmlnamespaces(default 'http://sv.bpc.in/SVAP')
              , '/applications/application'
                passing i_xml_content
                columns
                    inst_id            number(4)             path 'institution_id'
                  , terminal_number    varchar2(16 char)     path 'customer/contract/merchant/terminal/terminal_number'
               ) x
         where x.terminal_number is not null;

    -- Read reject file.
    loop
        fetch l_xml_cur
            bulk collect into l_inst_id_tab, l_terminal_id_tab
            limit BULK_LIMIT;

        trc_log_pkg.debug (
            i_text          => 'l_terminal_id_tab.count [#1]'
          , i_env_param1    => l_terminal_id_tab.count
        );

        if l_terminal_id_tab.count > 0 then

            for i in 1 .. l_terminal_id_tab.count loop
                l_split_hash_tab.extend;
                l_split_hash_tab(i)      := com_api_hash_pkg.get_split_hash(
                                                i_entity_type => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                                              , i_object_id   => l_terminal_id_tab(i)
                                            );

                l_event_object_id_tab.extend;
                l_event_object_id_tab(i) := com_api_id_pkg.get_id(
                                                i_seq         => evt_event_object_seq.nextval
                                              , i_date        => l_sysdate
                                            );
            end loop;

            -- We create events only for subscriber 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
            -- therefore we cannot use the "register_event" method.
            forall i in 1 .. l_terminal_id_tab.count
                insert into evt_event_object(
                                id
                              , event_id
                              , procedure_name
                              , entity_type
                              , object_id
                              , eff_date
                              , event_timestamp
                              , inst_id
                              , split_hash
                              , session_id
                              , proc_session_id
                              , status
                              , event_type
                            )
                  values    (
                                l_event_object_id_tab(i)
                              , (
                                    select max(e.id)
                                      from evt_event e
                                     where e.event_type = acq_api_const_pkg.EVENT_TERMINAL_ATTR_CHANGE
                                       and e.inst_id   in (l_inst_id_tab(i), ost_api_const_pkg.DEFAULT_INST)
                                )
                              , 'ITF_PRC_ACQUIRING_PKG.PROCESS_TERMINAL'
                              , acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                              , l_terminal_id_tab(i)
                              , l_sysdate
                              , systimestamp
                              , l_inst_id_tab(i)
                              , l_split_hash_tab(i)
                              , l_session_id
                              , null
                              , evt_api_const_pkg.EVENT_STATUS_READY
                              , acq_api_const_pkg.EVENT_TERMINAL_ATTR_CHANGE
                            );

            l_inserted_count := sql%rowcount;

            trc_log_pkg.debug (
                i_text          => 'terminal events: inserted [#1]'
              , i_env_param1    => l_inserted_count
            );

            if l_inserted_count > 0 then
                o_changed_count := o_changed_count + l_inserted_count;
            end if;

        end if;

        exit when l_xml_cur%notfound;
    end loop;

    close l_xml_cur;

    trc_log_pkg.debug (
        i_text          => 'rollback_terminal_events finish'
    );
end rollback_terminal_events;

procedure process_rejected_file(
    i_file_type          in     com_api_type_pkg.t_dict_value
  , i_search_days        in     com_api_type_pkg.t_tiny_id     default null
) is
    l_estimated_count           com_api_type_pkg.t_long_id     := 0;
    l_excepted_count            com_api_type_pkg.t_long_id     := 0;
    l_processed_count           com_api_type_pkg.t_long_id     := 0;
    l_changed_count             com_api_type_pkg.t_long_id     := 0;
    l_from_session_id           com_api_type_pkg.t_long_id;
    l_search_days               com_api_type_pkg.t_tiny_id     := nvl(i_search_days, 3);
    l_xml_content               xmltype;
begin
    savepoint sp_process_rejected_file;

    trc_log_pkg.debug (
        i_text          => 'process_rejected_file start'
    );

    prc_api_stat_pkg.log_start;

    l_from_session_id  := com_api_id_pkg.get_from_id(get_sysdate - l_search_days);

    -- get files
    for r in (
        select s.file_name
             , s.session_id
             , s.id             as session_file_id
             , s.file_contents
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id  >= l_from_session_id
           and s.file_type    = i_file_type
           and s.status       = prc_api_const_pkg.FILE_STATUS_POSTPONED
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
           --and f.file_nature  = prc_api_const_pkg.FILE_NATURE_XML
         order by s.id
    ) loop
        trc_log_pkg.debug (
            i_text              => 'Process file [#1]'
          , i_env_param1        => r.file_name
        );

        if r.file_contents is null then
            com_api_error_pkg.raise_error(
                i_error         => 'PRC_IMPORT_FAILED'
              , i_env_param1    => r.session_id
            );
        end if;

        l_xml_content := xmltype(r.file_contents);

        -- Get estimated count
        get_rejected_count(
            i_xml_content      => l_xml_content
          , io_estimated_count => l_estimated_count
          , i_file_type        => i_file_type
          , i_is_saver_mode    => com_api_type_pkg.FALSE
        );

        if i_file_type    = FILE_TYPE_REJECT_TURNOVER then
            rollback_turnover_events(
                i_xml_content      => l_xml_content
              , o_changed_count    => l_changed_count
            );

        elsif i_file_type = FILE_TYPE_REJECT_CARDS then
            rollback_card_events(
                i_xml_content      => l_xml_content
              , o_changed_count    => l_changed_count
            );

        elsif i_file_type = FILE_TYPE_REJECT_MERCHANTS then
            rollback_merchant_events(
                i_xml_content      => l_xml_content
              , o_changed_count    => l_changed_count
            );

        elsif i_file_type = FILE_TYPE_REJECT_TERMINALS then
            rollback_terminal_events(
                i_xml_content      => l_xml_content
              , o_changed_count    => l_changed_count
            );

        end if;

        l_processed_count := l_processed_count + l_changed_count;

        trc_log_pkg.debug (
            i_text              => 'Reject file [#1] changed [#2]'
          , i_env_param1        => r.file_name
          , i_env_param2        => l_changed_count
        );

        prc_api_file_pkg.change_file_status(
            i_sess_file_id      => r.session_file_id
          , i_status            => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );

        prc_api_stat_pkg.log_current (
            i_current_count     => l_processed_count
          , i_excepted_count    => l_excepted_count
        );

    end loop;

    prc_api_stat_pkg.log_end (
        i_processed_total       => l_processed_count
      , i_excepted_total        => l_excepted_count
      , i_result_code           => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text                  => 'process_rejected_file finish'
    );

exception
    when others then
        rollback to savepoint sp_process_rejected_file;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error (
                i_error         => 'UNHANDLED_EXCEPTION'
                , i_env_param1  => sqlerrm
            );
        end if;

        raise;

end process_rejected_file;

procedure process_rejected_turnover
is
begin
    process_rejected_file(
        i_file_type => FILE_TYPE_REJECT_TURNOVER
    );
end process_rejected_turnover;

procedure process_rejected_cards
is
begin
    process_rejected_file(
        i_file_type => FILE_TYPE_REJECT_CARDS
    );
end process_rejected_cards;

procedure process_rejected_merchants
is
begin
    process_rejected_file(
        i_file_type => FILE_TYPE_REJECT_MERCHANTS
    );
end process_rejected_merchants;

procedure process_rejected_terminals
is
begin
    process_rejected_file(
        i_file_type => FILE_TYPE_REJECT_TERMINALS
    );
end process_rejected_terminals;

procedure save_rejected_count(
    i_file_type         com_api_type_pkg.t_dict_value
) is
    l_session_id        com_api_type_pkg.t_long_id;
    l_thread_number     com_api_type_pkg.t_tiny_id;
    l_rejected_count    com_api_type_pkg.t_long_id     := 0;
begin
    l_session_id    := prc_api_session_pkg.get_session_id;
    l_thread_number := prc_api_session_pkg.get_thread_number;

    trc_log_pkg.debug (
        i_text              => 'save_rejected_count START: i_file_type [#1], l_session_id [#2], l_thread_number [#3]'
      , i_env_param1        => i_file_type
      , i_env_param2        => l_session_id
      , i_env_param3        => l_thread_number
    );

    -- get files
    for r in (
        select s.file_name
             , s.session_id
             , s.file_contents
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id     = l_session_id
           and s.thread_number  = l_thread_number
           and s.file_type      = i_file_type
           and s.status         = prc_api_const_pkg.FILE_STATUS_POSTPONED
           and s.file_attr_id   = a.id
           and f.id             = a.file_id
           and f.file_purpose   = prc_api_const_pkg.FILE_PURPOSE_IN
           --and f.file_nature    = prc_api_const_pkg.FILE_NATURE_XML
         order by s.id
    ) loop
        trc_log_pkg.debug (
            i_text              => 'Process file [#1]'
          , i_env_param1        => r.file_name
        );

        if r.file_contents is null then
            com_api_error_pkg.raise_error(
                i_error         => 'PRC_IMPORT_FAILED'
              , i_env_param1    => r.session_id
            );
        end if;

        -- Get estimated count
        get_rejected_count(
            i_xml_content       => xmltype(r.file_contents)
          , io_estimated_count  => l_rejected_count
          , i_file_type         => i_file_type
          , i_is_saver_mode     => com_api_type_pkg.TRUE
        );
    end loop;

    prc_api_stat_pkg.increase_rejected_total(
        i_session_id            => l_session_id
      , i_thread_number         => l_thread_number
      , i_rejected_total        => l_rejected_count
    );

    trc_log_pkg.debug (
        i_text              => 'save_rejected_count FINISH: l_rejected_count [#1]'
      , i_env_param1        => l_rejected_count
    );

end save_rejected_count;

procedure process_rejected_persons
is
begin
    process_rejected_file(
      i_file_type => FILE_TYPE_REJECT_PERSONS
    );
end process_rejected_persons;

end itf_prc_reject_file_pkg;
/
