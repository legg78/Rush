create or replace package body cst_bmed_account_export_pkg is
/************************************************************
 * API for process files <br />
 * Created by Kondratyev A.(kondratyev@bpcbt.com)  at 09.08.2016 <br />
 * Last changed by $Author: kondratyev $ <br />
 * $LastChangedDate:: 2016-08-09 16:00:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 60179 $ <br />
 * Module: cst_bmed_account_export_pkg <br />
 * @headcom
 ***********************************************************/

CRLF           constant  com_api_type_pkg.t_name := chr(13)||chr(10);

procedure process(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_lang                  in     com_api_type_pkg.t_dict_value     default null
) is
    
    type t_list_cards_rec is record(
        linked_cards    num_tab_tpt
      , closed_cards    num_tab_tpt
      , unlinked_cards  num_tab_tpt
    );
    
    type t_list_cards_tab is table of t_list_cards_rec index by com_api_type_pkg.t_name;
    
    type t_account_data_rec is record(
        account_id      com_api_type_pkg.t_name
      , account_number  com_api_type_pkg.t_account_number
      , account_type    com_api_type_pkg.t_dict_value
    );
    
    type t_account_data_tab is table of t_account_data_rec index by binary_integer;
    
    l_list_cards           t_list_cards_tab;
    l_estimate_count       simple_integer := 0;
    l_expected_count       simple_integer := 0;
    l_check_cards          integer ;
    l_file_type            com_api_type_pkg.t_dict_value;
    l_record               com_api_type_pkg.t_text;
    l_container_id         com_api_type_pkg.t_long_id    :=  prc_api_session_pkg.get_container_id;
    l_params               com_api_type_pkg.t_param_tab;

    l_event_tab            com_api_type_pkg.t_number_tab;
    l_event_type_tab       com_api_type_pkg.t_dict_tab;
    l_entity_type_tab      com_api_type_pkg.t_dict_tab;
    l_account_id_tab       num_tab_tpt                   := num_tab_tpt();
    l_account_data_tab     t_account_data_tab;
    l_card_id_tab          num_tab_tpt                   := num_tab_tpt();
    l_card_status_tab      com_api_type_pkg.t_dict_tab;
    l_account_number_tab   com_api_type_pkg.t_account_number_tab;
    l_accout_num_tab_indx  binary_integer;
    l_account_type_tab     com_api_type_pkg.t_dict_tab;
    l_eff_date             date;
    l_total_count          com_api_type_pkg.t_medium_id;
    l_lang                 com_api_type_pkg.t_dict_value;
    l_session_file_id      com_api_type_pkg.t_long_id;

    cursor evt_object_cur is
        select oe.id
             , oe.event_type
             , oe.entity_type
             , a.id as account_id
             , oe.object_id as card_id
             , (select status 
                  from iss_card_instance 
                 where id = iss_api_card_instance_pkg.get_card_instance_id(i_card_id => oe.object_id)
               ) as card_status
             , a.account_number
             , t.account_type
          from (select o.id
                     , e.event_type
                     , o.entity_type
                     , o.object_id
                     , o.split_hash
                     , o.inst_id
                     , row_number() over(partition by e.event_type, o.object_id, o.entity_type order by o.id desc) as rn
                  from evt_event_object o
                     , evt_event e
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_ACCOUNT_EXPORT_PKG.PROCESS'
                   and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and o.eff_date      <= l_eff_date
                   and o.inst_id        = i_inst_id
                   and o.split_hash    in (select split_hash from com_api_split_map_vw)
                   and e.id             = o.event_id
                   and e.event_type    in (iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD
                                         , iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
                                         , iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT)
               ) oe
             , acc_account_object ao
             , (select ul.account_id
                     , ul.object_id
                     , ul.entity_type
                     , row_number() over(partition by ul.entity_type, ul.object_id order by id desc) rn
                  from acc_unlink_account ul
               ) an
             , (select l.account_id
                     , l.object_id
                     , l.entity_type
                     , row_number() over(partition by l.entity_type, l.object_id order by id desc) rn
                  from acc_account_link l
               ) al
             , acc_account a
             , acc_account_type t
         where ao.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT, oe.object_id, null)
           and ao.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT, oe.entity_type, null)
           and al.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.object_id, null)
           and al.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.entity_type, null)
           and al.rn(+)            = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.rn, null)
           and an.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.object_id, null)
           and an.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.entity_type, null)
           and an.rn(+)            = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.rn, null)
           and a.id             = case oe.event_type
                                      when iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD
                                          then al.account_id
                                      when iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT
                                          then ao.account_id
                                      when iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
                                          then an.account_id
                                      else null
                                  end
           and a.inst_id        = oe.inst_id
           and a.split_hash     = oe.split_hash
           and t.account_type   = a.account_type
           and t.inst_id        = a.inst_id
           and t.product_type   = prd_api_const_pkg.PRODUCT_TYPE_ISS
           and t.account_type  in (acc_api_const_pkg.ACCOUNT_TYPE_SAVINGS_ACCOUNT
                                 , acc_api_const_pkg.ACCOUNT_TYPE_CHECKING_ACCOUNT);

begin
    select min(file_type)
      into l_file_type
      from prc_file_attribute a
         , prc_file f
     where a.container_id = l_container_id
       and a.file_id      = f.id
       and file_purpose   = prc_api_const_pkg.FILE_PURPOSE_OUT;

    l_eff_date      := com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id);
    l_lang          := nvl(i_lang, com_ui_user_env_pkg.get_user_lang());

    trc_log_pkg.debug(
        i_text => 'cst_bmed_account_export_pkg.process, file_type=#1, l_container_id=#2, l_eff_date=#3, l_lang=#4'
      , i_env_param1 => l_file_type
      , i_env_param2 => l_container_id
      , i_env_param3 => l_eff_date
      , i_env_param4 => l_lang
    );
    
    prc_api_stat_pkg.log_start;
    l_total_count := 0;

    select count(distinct account_id) as cnt
      into l_estimate_count
      from (
          select a.id as account_id
            from (select o.id
                       , e.event_type
                       , o.entity_type
                       , o.object_id
                       , o.split_hash
                       , o.inst_id
                       , row_number() over(partition by e.event_type, o.object_id, o.entity_type order by o.id desc) as rn
                    from evt_event_object o
                       , evt_event e
                   where decode(o.status, 'EVST0001', o.procedure_name, null) = 'CST_BMED_ACCOUNT_EXPORT_PKG.PROCESS'
                     and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
                     and o.eff_date      <= l_eff_date
                     and o.inst_id        = i_inst_id
                     and o.split_hash    in (select split_hash from com_api_split_map_vw)
                     and e.id             = o.event_id
                     and e.event_type    in (iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD
                                           , iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
                                           , iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT)
                 ) oe
               , acc_account_object ao
               , (select ul.account_id
                       , ul.object_id
                       , ul.entity_type
                       , row_number() over(partition by ul.entity_type, ul.object_id order by id desc) rn
                    from acc_unlink_account ul
                 ) an
               , (select l.account_id
                       , l.object_id
                       , l.entity_type
                       , row_number() over(partition by l.entity_type, l.object_id order by id desc) rn
                    from acc_account_link l
                 ) al
               , acc_account a
               , acc_account_type t
           where ao.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT, oe.object_id, null)
             and ao.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT, oe.entity_type, null)
             and al.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.object_id, null)
             and al.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.entity_type, null)
             and al.rn(+)            = decode(oe.event_type, iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD, oe.rn, null)
             and an.object_id(+)     = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.object_id, null)
             and an.entity_type(+)   = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.entity_type, null)
             and an.rn(+)            = decode(oe.event_type, iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD, oe.rn, null)
             and a.id             = case oe.event_type
                                        when iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD
                                            then al.account_id
                                        when iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT
                                            then ao.account_id
                                        when iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD
                                            then an.account_id
                                        else null
                                    end
             and a.inst_id        = oe.inst_id
             and a.split_hash     = oe.split_hash
             and t.account_type   = a.account_type
             and t.inst_id        = a.inst_id
             and t.product_type   = prd_api_const_pkg.PRODUCT_TYPE_ISS
             and t.account_type  in (
                     acc_api_const_pkg.ACCOUNT_TYPE_SAVINGS_ACCOUNT
                   , acc_api_const_pkg.ACCOUNT_TYPE_CHECKING_ACCOUNT
                 )
      );

    trc_log_pkg.debug('Estimate count = [' || l_estimate_count || ']');

    prc_api_stat_pkg.log_estimation(
        i_estimated_count => l_estimate_count
    );

    if l_estimate_count > 0 then

        l_params.delete;
        rul_api_param_pkg.set_param (
              i_name     => 'INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );

        open evt_object_cur;
        fetch evt_object_cur bulk collect into
              l_event_tab
            , l_event_type_tab
            , l_entity_type_tab
            , l_account_id_tab
            , l_card_id_tab
            , l_card_status_tab
            , l_account_number_tab
            , l_account_type_tab;
            
        for i in 1 .. l_account_id_tab.count loop
            if l_list_cards.exists(to_char(l_account_id_tab(i))) then
                if l_event_type_tab(i) = iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD then
                    if l_card_status_tab(i) in (
                           iss_api_const_pkg.CARD_STATUS_VALID_CARD
                         , iss_api_const_pkg.CARD_STATUS_HONOR_WITH_ID
                         , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                         , iss_api_const_pkg.CARD_STATUS_PIN_ATTEMPTS_EXCD
                         , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                         , iss_api_const_pkg.CARD_STATUS_VRT_CARD_PERS_WAIT
                         , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                         , iss_api_const_pkg.CARD_STATUS_PERSONIF_WAITING
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLIENT
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ
                       )
                    then
                        l_list_cards(to_char(l_account_id_tab(i))).linked_cards.extend;
                        l_list_cards(to_char(l_account_id_tab(i))).linked_cards(
                            l_list_cards(to_char(l_account_id_tab(i))).linked_cards.last
                        ) := l_card_id_tab(i);
                    end if;
                elsif l_event_type_tab(i) = iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT then
                    l_list_cards(to_char(l_account_id_tab(i))).closed_cards.extend;
                    l_list_cards(to_char(l_account_id_tab(i))).closed_cards(
                        l_list_cards(to_char(l_account_id_tab(i))).closed_cards.last
                    ) := l_card_id_tab(i);
                elsif l_event_type_tab(i) = iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD then
                    l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards.extend;
                    l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards(
                        l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards.last
                    ) := l_card_id_tab(i);
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'EVENT_TYPE_NOT_SUPPORT_IN_PROC'
                      , i_env_param1 => l_event_type_tab(i)
                      , i_env_param2 => l_entity_type_tab(i)
                      , i_env_param3 => 'CST_BMED_ACCOUNT_EXPORT_PKG.PROCESS'
                    );
                end if;
            else
                l_list_cards(to_char(l_account_id_tab(i))).linked_cards := num_tab_tpt();
                l_list_cards(to_char(l_account_id_tab(i))).closed_cards := num_tab_tpt();
                l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards := num_tab_tpt();
                if l_event_type_tab(i) = iss_api_const_pkg.EVENT_LINK_ACCOUNT_TO_CARD then
                    if l_card_status_tab(i) in (
                           iss_api_const_pkg.CARD_STATUS_VALID_CARD
                         , iss_api_const_pkg.CARD_STATUS_HONOR_WITH_ID
                         , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                         , iss_api_const_pkg.CARD_STATUS_PIN_ATTEMPTS_EXCD
                         , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                         , iss_api_const_pkg.CARD_STATUS_VRT_CARD_PERS_WAIT
                         , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                         , iss_api_const_pkg.CARD_STATUS_PERSONIF_WAITING
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLIENT
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
                         , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ
                       )
                    then
                        l_list_cards(to_char(l_account_id_tab(i))).linked_cards.extend;
                        l_list_cards(to_char(l_account_id_tab(i))).linked_cards(
                            l_list_cards(to_char(l_account_id_tab(i))).linked_cards.last
                        ) := l_card_id_tab(i);
                    end if;
                elsif l_event_type_tab(i) = iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT then
                    l_list_cards(to_char(l_account_id_tab(i))).closed_cards.extend;
                    l_list_cards(to_char(l_account_id_tab(i))).closed_cards(
                        l_list_cards(to_char(l_account_id_tab(i))).closed_cards.last
                    ) := l_card_id_tab(i);
                elsif l_event_type_tab(i) = iss_api_const_pkg.EVENT_UNLINK_ACCOUNT_FROM_CARD then
                    l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards.extend;
                    l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards(
                        l_list_cards(to_char(l_account_id_tab(i))).unlinked_cards.last
                    ) := l_card_id_tab(i);
                else
                    com_api_error_pkg.raise_error(
                        i_error      => 'EVENT_TYPE_NOT_SUPPORT_IN_PROC'
                      , i_env_param1 => l_event_type_tab(i)
                      , i_env_param2 => l_entity_type_tab(i)
                      , i_env_param3 => 'CST_BMED_ACCOUNT_EXPORT_PKG.PROCESS'
                    );
                end if;
                l_accout_num_tab_indx := nvl(l_account_data_tab.last, 0) + 1;
                l_account_data_tab(l_accout_num_tab_indx).account_id := to_char(l_account_id_tab(i));
                l_account_data_tab(l_accout_num_tab_indx).account_number := l_account_number_tab(i);
                l_account_data_tab(l_accout_num_tab_indx).account_type := l_account_type_tab(i);
            end if;
        end loop;

        for i in 1 .. l_account_data_tab.count loop
            if (l_list_cards(l_account_data_tab(i).account_id).linked_cards.exists(1)
                or l_list_cards(l_account_data_tab(i).account_id).closed_cards.exists(1)
                or l_list_cards(l_account_data_tab(i).account_id).unlinked_cards.exists(1)
               ) and
               not (l_list_cards(l_account_data_tab(i).account_id).linked_cards.exists(1)
                    and l_list_cards(l_account_data_tab(i).account_id).unlinked_cards.exists(1)
               ) and
               not (l_list_cards(l_account_data_tab(i).account_id).linked_cards.exists(1)
                    and l_list_cards(l_account_data_tab(i).account_id).closed_cards.exists(1)
               )
            then
                if l_list_cards(l_account_data_tab(i).account_id).linked_cards.exists(1) then
                    select count(*)
                      into l_check_cards
                      from acc_account_object ao
                         , iss_card_instance i
                     where ao.account_id  = l_account_data_tab(i).account_id
                       and i.card_id      = ao.object_id
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and i.status      in (
                               iss_api_const_pkg.CARD_STATUS_VALID_CARD
                             , iss_api_const_pkg.CARD_STATUS_HONOR_WITH_ID
                             , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                             , iss_api_const_pkg.CARD_STATUS_PIN_ATTEMPTS_EXCD
                             , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                             , iss_api_const_pkg.CARD_STATUS_VRT_CARD_PERS_WAIT
                             , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                             , iss_api_const_pkg.CARD_STATUS_PERSONIF_WAITING
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLIENT
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ
                           )
                       and i.card_id not in (select column_value from table(l_list_cards(l_account_data_tab(i).account_id).linked_cards))
                       and rownum < 2;
                elsif l_list_cards(l_account_data_tab(i).account_id).closed_cards.exists(1) then
                    select count(*)
                      into l_check_cards
                      from acc_account_object ao
                         , iss_card_instance i
                     where ao.account_id  = l_account_data_tab(i).account_id
                       and i.card_id      = ao.object_id
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and i.status      in (
                               iss_api_const_pkg.CARD_STATUS_VALID_CARD
                             , iss_api_const_pkg.CARD_STATUS_HONOR_WITH_ID
                             , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                             , iss_api_const_pkg.CARD_STATUS_PIN_ATTEMPTS_EXCD
                             , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                             , iss_api_const_pkg.CARD_STATUS_VRT_CARD_PERS_WAIT
                             , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                             , iss_api_const_pkg.CARD_STATUS_PERSONIF_WAITING
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLIENT
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ
                           )
                       and i.card_id not in (select column_value from table(l_list_cards(l_account_data_tab(i).account_id).closed_cards))
                       and rownum < 2;
                elsif l_list_cards(l_account_data_tab(i).account_id).unlinked_cards.exists(1) then
                    select count(*)
                      into l_check_cards
                      from acc_account_object ao
                         , iss_card_instance i
                     where ao.account_id  = l_account_data_tab(i).account_id
                       and i.card_id      = ao.object_id
                       and ao.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                       and i.status      in (
                               iss_api_const_pkg.CARD_STATUS_VALID_CARD
                             , iss_api_const_pkg.CARD_STATUS_HONOR_WITH_ID
                             , iss_api_const_pkg.CARD_STATUS_NOT_ACTIVATED
                             , iss_api_const_pkg.CARD_STATUS_PIN_ATTEMPTS_EXCD
                             , iss_api_const_pkg.CARD_STATUS_FORCED_PIN_CHANGE
                             , iss_api_const_pkg.CARD_STATUS_VRT_CARD_PERS_WAIT
                             , iss_api_const_pkg.CARD_STATUS_PIN_ACTIVATION
                             , iss_api_const_pkg.CARD_STATUS_PERSONIF_WAITING
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLIENT
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
                             , iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_CLREQ
                           )
                       and i.card_id not in (select column_value from table(l_list_cards(l_account_data_tab(i).account_id).unlinked_cards))
                       and rownum < 2;
                end if;

                l_record := case 
                                when l_list_cards(l_account_data_tab(i).account_id).linked_cards.exists(1)
                                     and l_check_cards = 0
                                    then 'I'
                                when l_list_cards(l_account_data_tab(i).account_id).closed_cards.exists(1)
                                     and l_check_cards = 0
                                    then 'D'
                                when l_list_cards(l_account_data_tab(i).account_id).unlinked_cards.exists(1)
                                     and l_check_cards = 0
                                    then 'D'
                                else
                                    null
                            end;
                if l_record in ('I', 'D') then
                    l_record := l_record || l_account_data_tab(i).account_number;
                    l_record := l_record || 
                                case l_account_data_tab(i).account_type
                                    when acc_api_const_pkg.ACCOUNT_TYPE_SAVINGS_ACCOUNT
                                    then '10'
                                    when acc_api_const_pkg.ACCOUNT_TYPE_CHECKING_ACCOUNT
                                    then '20'
                                end;
                    l_record := l_record ||'433825422';
                    
                    if l_session_file_id is null then
                        prc_api_file_pkg.open_file (
                              o_sess_file_id  => l_session_file_id
                            , i_file_type     => l_file_type
                            , io_params       => l_params
                        );
                    end if;
                    
                    prc_api_file_pkg.put_line(
                        i_raw_data      => l_record
                      , i_sess_file_id  => l_session_file_id
                    );
                    prc_api_file_pkg.put_file(
                        i_sess_file_id   => l_session_file_id
                      , i_clob_content   => l_record || CRLF
                      , i_add_to         => com_api_const_pkg.TRUE
                    );
                end if;
                l_total_count := l_total_count + 1;
            else
                l_expected_count := l_expected_count + 1;
            end if;
        end loop;

        trc_log_pkg.debug('events were processed, cnt = ' || l_event_tab.count);

        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_event_tab
        );

        close evt_object_cur;

    end if;  -- l_estimate_count > 0

    prc_api_stat_pkg.log_end(
        i_processed_total  => l_total_count
      , i_excepted_total   => l_expected_count
      , i_rejected_total   => 0
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug('cst_bmed_account_export_pkg.process END');

exception
    when others then
        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;

        raise;
end process;

end;
/
