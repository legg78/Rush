create or replace package body prs_ui_batch_card_pkg is
/************************************************************
 * User interface for batch for personalisation <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-09-08 17:41:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_ui_batch_card_pkg <br />
 * @headcom
 ************************************************************/

    procedure check_card_count (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_card_count              in com_api_type_pkg.t_short_id
        , o_warning_msg             out com_api_type_pkg.t_text
    ) is
        l_card_count                number;
    begin
        select
            count(*)
        into
            l_card_count
        from
            prs_batch_card_vw
        where
            batch_id = i_batch_id;
        
        if l_card_count+1 > nvl(i_card_count, l_card_count+1) then
            trc_log_pkg.error (
                i_text    => 'SELECTED_CARD_GREATER_BATCH_CARD_COUNT'
                , o_text  => o_warning_msg
            );
        end if;
        
    end;
    
    procedure add_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_card_instance_id        in com_api_type_pkg.t_medium_id
        , o_warning_msg             out com_api_type_pkg.t_text
    ) is
    begin
        for rec in (
            select
                id
                , card_count
            from
                prs_batch_vw
            where
                id = i_batch_id
        ) loop
            delete from prs_batch_card_vw
            where
                batch_id = i_batch_id
                and card_instance_id = i_card_instance_id;

            check_card_count (
                i_batch_id       => i_batch_id
                , i_card_count   => rec.card_count
                , o_warning_msg  => o_warning_msg
            );
            
            if o_warning_msg is null then
                insert into prs_batch_card_vw (
                    id
                    , batch_id
                    , process_order
                    , card_instance_id
                    , pin_request
                    , pin_generated
                    , pin_mailer_request
                    , pin_mailer_printed
                    , embossing_request
                    , embossing_done
                )select
                    prs_batch_card_seq.nextval
                    , i_batch_id
                    , null
                    , ci.id
                    , ci.pin_request
                    , com_api_type_pkg.FALSE
                    , ci.pin_mailer_request
                    , com_api_type_pkg.FALSE
                    , ci.embossing_request
                    , com_api_type_pkg.FALSE
                from
                    iss_card_instance ci
                where
                    ci.id = i_card_instance_id;
            end if;

            return;
        end loop;

        com_api_error_pkg.raise_error (
            i_error        => 'PRS_BATCH_NOT_FOUND'
            , i_env_param1 => i_batch_id
        );
    end;

    procedure remove_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_card_instance_id        in com_api_type_pkg.t_medium_id
    ) is
    begin
        delete from
            prs_batch_card_vw
        where
            batch_id = i_batch_id
            and card_instance_id = i_card_instance_id;
    end;
    
    procedure mark_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
        , i_agent_id                in com_api_type_pkg.t_agent_id
        , i_product_id              in com_api_type_pkg.t_short_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , i_blank_type_id           in com_api_type_pkg.t_tiny_id
        , i_perso_priority          in com_api_type_pkg.t_dict_value
        , i_pin_request             in com_api_type_pkg.t_dict_value
        , i_embossing_request       in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request      in com_api_type_pkg.t_dict_value
        , o_warning_msg             out com_api_type_pkg.t_text
        , i_lang                    in com_api_type_pkg.t_dict_value  default null
        , i_card_count              in com_api_type_pkg.t_tiny_id     default null
        , i_session_id              in com_api_type_pkg.t_long_id     default null
        , i_start_date              in date                           default null
        , i_end_date                in date                           default null
        , i_flow_id                 in com_api_type_pkg.t_tiny_id     default null
    ) is
        l_lang                      com_api_type_pkg.t_dict_value;
        l_card_count                com_api_type_pkg.t_long_id     := 0;
        l_card_limit                com_api_type_pkg.t_long_id;
        l_need_delete_row           com_api_type_pkg.t_boolean     := com_api_type_pkg.FALSE;
        l_event_object_id_tab       com_api_type_pkg.t_number_tab;
        l_sql_statement             com_api_type_pkg.t_sql_statement;
        l_sort_condition            com_api_type_pkg.t_full_desc;
        l_card_number_cond          com_api_type_pkg.t_full_desc;
        l_surname_cond              com_api_type_pkg.t_full_desc;
        l_first_name_cond           com_api_type_pkg.t_full_desc;
        l_product_id_cond           com_api_type_pkg.t_full_desc;
        l_card_type_id_cond         com_api_type_pkg.t_full_desc;
        l_order_statement           com_api_type_pkg.t_full_desc;
        l_event_id_list             com_api_type_pkg.t_full_desc;
        l_product_id_filter         com_api_type_pkg.t_full_desc;
        l_card_type_id_filter       com_api_type_pkg.t_full_desc;
        l_included_filter           com_api_type_pkg.t_full_desc;

        function get_condition(
            i_field_name         in com_api_type_pkg.t_name
          , i_parameter_value    in com_api_type_pkg.t_name
          , i_delim_char         in com_api_type_pkg.t_name := null
        ) return com_api_type_pkg.t_name
        is
            l_result  com_api_type_pkg.t_name;
        begin
            if i_parameter_value is not null then
                l_result := '
                            and ' || i_field_name || ' = ' || i_delim_char || i_parameter_value || i_delim_char;
            end if;
            return l_result;
        end get_condition;
    begin
        trc_log_pkg.debug (
            i_text          => 'i_batch_id[#1] i_card_type_id[#2] i_blank_type_id[#3] i_pin_request[#4] i_embossing_request[#5] i_pin_mailer_request[#6]'
            , i_env_param1  => i_batch_id
            , i_env_param2  => i_card_type_id
            , i_env_param3  => i_blank_type_id
            , i_env_param4  => i_pin_request
            , i_env_param5  => i_embossing_request
            , i_env_param6  => i_pin_mailer_request
        );

        l_lang := nvl(i_lang, com_ui_user_env_pkg.get_user_lang);

        trc_log_pkg.debug (
            i_text          => 'l_lang [#1], i_card_count [#2]'
            , i_env_param1  => l_lang
            , i_env_param2  => i_card_count
        );
            
        for rec in (
            select
                id batch_id
                , inst_id
                , agent_id
                , product_id
                , card_type_id
                , blank_type_id
                , card_count
                , sort_id
                , perso_priority
                , reissue_reason
            from
                prs_batch_vw
            where
                id = i_batch_id
        ) loop
            -- Remove card from batch
            delete from prs_batch_card_vw
              where batch_id = i_batch_id;

            -- Get event_id
            begin
                select stragg(id)
                  into l_event_id_list
                  from evt_event
                 where event_type = iss_api_const_pkg.EVENT_TYPE_PIN_REISSUE
                   and inst_id   in (rec.inst_id, ost_api_const_pkg.DEFAULT_INST);

                l_included_filter := 
                    '
                    and (
                          case 
                              (select nvl(max(1), 0)
                                 from evt_event_object eo
                                where eo.object_id      = ci.id
                                  and eo.entity_type    = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE || '''
                                  and eo.split_hash     = ci.split_hash
                                  and eo.status         = ''' || evt_api_const_pkg.EVENT_STATUS_READY || '''
                                  and eo.procedure_name = ''ITF_PRC_CARDGEN_PKG.GENERATE_WITHOUT_BATCH''
                                  and eo.event_id      in (' || l_event_id_list || ')
                              )
                          when
                              1
                          then
                              0
                          else
                              (select nvl(max(1), 0)
                                 from prs_batch_card t
                                    , prs_batch b
                                where t.card_instance_id = ci.id
                                  and b.id               = t.batch_id
                                  and b.status           = ''' || prs_api_const_pkg.BATCH_STATUS_PROCESSED || '''
                              )
                          end
                        ) = 0';

            exception when others then

                l_included_filter :=
                    '
                    and (
                            select nvl(max(1), 0)
                               from prs_batch_card t
                                  , prs_batch b
                              where t.card_instance_id = ci.id
                                and b.id               = t.batch_id
                                and b.status           = ''' || prs_api_const_pkg.BATCH_STATUS_PROCESSED || '''
                        ) = 0';

            end;

            -- Set card_limit
            if nvl(rec.card_count, 0) > 0 or nvl(i_card_count, 0) > 0 then
                l_card_limit := nvl(rec.card_count, i_card_count);

                if nvl(rec.card_count, 0) > 0 then
                    l_card_limit      := l_card_limit + 1;
                    l_need_delete_row := com_api_type_pkg.TRUE;
                end if;
            end if;

            -- Get sort condition
            l_sort_condition := prs_api_card_pkg.enum_sort_condition(rec.sort_id);

            -- Get product_id condition
            if l_sort_condition like '%PRODUCT_ID%' then
                l_product_id_cond   := '
                                        (
                                            select ct.product_id
                                              from iss_card oc
                                                 , prd_contract ct
                                             where oc.id         = ci.card_id
                                               and oc.split_hash = ci.split_hash
                                               and ct.id         = oc.contract_id
                                               and ct.split_hash = oc.split_hash
                                        )  as product_id';
            else
                l_product_id_cond   := 'null as product_id';
            end if;

            -- Get card_type_id condition
            if l_sort_condition like '%CARD_TYPE_ID%' then
                l_card_type_id_cond := '
                                        (
                                            select oc.card_type_id
                                              from iss_card oc
                                             where oc.id         = ci.card_id
                                               and oc.split_hash = ci.split_hash
                                        )  as card_type_id';
            else
                l_card_type_id_cond := 'null as card_type_id';
            end if;

            -- Get card_number condition
            if l_sort_condition like '%CARD_NUMBER%' then
                l_card_number_cond := '
                                       (
                                           select iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number)
                                             from iss_card_number cn
                                            where cn.card_id = ci.card_id
                                       ) as card_number';
            else
                l_card_number_cond := 'null as card_number';
            end if;

            -- Get surname condition
            if l_sort_condition like '%SURNAME%' then
                l_surname_cond     :=  '
                    coalesce(
                        (
                            select com_ui_person_pkg.get_surname(
                                       i_person_id  => p.id
                                     , i_lang       => p.lang
                                   )
                              from iss_card oc
                                 , iss_cardholder ch
                                 , com_person p
                             where oc.id         = ci.card_id
                               and oc.split_hash = ci.split_hash
                               and ch.id         = oc.cardholder_id
                               and p.id          = ch.person_id
                        )
                      , (
                            select com_ui_person_pkg.get_surname(
                                       i_person_id  => pcm.id
                                     , i_lang       => pcm.lang
                                   )
                              from iss_card oc
                                 , prd_contract ct
                                 , prd_customer cm
                                 , com_person pcm
                             where oc.id          = ci.card_id
                               and oc.split_hash  = ci.split_hash
                               and ct.id          = oc.contract_id
                               and ct.split_hash  = oc.split_hash
                               and cm.id          = ct.customer_id
                               and cm.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_PERSON || '''
                               and pcm.id         = cm.object_id
                        )
                    ) as surname';
            else
                l_surname_cond     :=  'null as surname';
            end if;

            -- Get first_name condition
            if l_sort_condition like '%FIRST_NAME%' then
                l_first_name_cond     :=  '
                    coalesce(
                        (
                            select com_ui_person_pkg.get_first_name(
                                       i_person_id  => p.id
                                     , i_lang       => p.lang
                                   )
                              from iss_card oc
                                 , iss_cardholder ch
                                 , com_person p
                             where oc.id         = ci.card_id
                               and oc.split_hash = ci.split_hash
                               and ch.id         = oc.cardholder_id
                               and p.id          = ch.person_id
                        )
                      , (
                            select com_ui_person_pkg.get_first_name(
                                       i_person_id  => pcm.id
                                     , i_lang       => pcm.lang
                                   )
                              from iss_card oc
                                 , prd_contract ct
                                 , prd_customer cm
                                 , com_person pcm
                             where oc.id          = ci.card_id
                               and oc.split_hash  = ci.split_hash
                               and ct.id          = oc.contract_id
                               and ct.split_hash  = oc.split_hash
                               and cm.id          = ct.customer_id
                               and cm.entity_type = ''' || com_api_const_pkg.ENTITY_TYPE_PERSON || '''
                               and pcm.id         = cm.object_id
                        )
                    ) as first_name';
            else
                l_first_name_cond     :=  'null as first_name';
            end if;

            -- Get order statement
            if l_sort_condition is not null then
                l_order_statement := 'order by ' || l_sort_condition;
            else
                l_order_statement := 'order by ci.card_instance_id';
            end if;

            if rec.product_id is not null or i_product_id is not null then
                l_product_id_filter := '
                            and exists (select 1
                                          from iss_card oc
                                             , prd_contract ct
                                         where oc.id          = ci.card_id
                                           and oc.split_hash  = ci.split_hash
                                           and ct.id          = oc.contract_id
                                           and ct.split_hash  = oc.split_hash
                                           and ct.product_id in (' || nvl(to_char(rec.product_id), 'null') || ', ' || nvl(to_char(i_product_id), 'null') || ')
                                )';
            end if;

            if rec.card_type_id is not null or i_card_type_id is not null then
                l_card_type_id_filter := '
                            and exists (select 1
                                          from iss_card oc
                                         where oc.id          = ci.card_id
                                           and oc.split_hash  = ci.split_hash
                                           and oc.card_type_id in (' || nvl(to_char(rec.card_type_id), 'null') || ', ' || nvl(to_char(i_card_type_id), 'null') || ')
                                )';
            end if;


            l_sql_statement := '
insert into prs_batch_card_vw (
    id
  , batch_id
  , process_order
  , card_instance_id
  , pin_request
  , pin_generated
  , pin_mailer_request
  , pin_mailer_printed
  , embossing_request
  , embossing_done
)
select prs_batch_card_seq.nextval
     , ' || rec.batch_id || '
     , null
     , m.card_instance_id
     , m.pin_request
     , 0
     , m.pin_mailer_request
     , 0
     , m.embossing_request
     , 0
  from (
      select ci.id card_instance_id
           , ci.seq_number
           , ci.cardholder_name
           , ci.inst_id
           , ci.agent_id
           , ci.blank_type_id
           , ci.perso_priority
           , ci.pin_request
           , ci.embossing_request
           , ci.pin_mailer_request
           , ci.reissue_reason
           , ' || l_product_id_cond || '
           , ' || l_card_type_id_cond || '
           , ' || l_card_number_cond || '
           , ' || l_surname_cond || '
           , ' || l_first_name_cond || '
        from iss_card_instance ci
       where decode(ci.state, ''CSTE0100'', ''CSTE0100'') = ''CSTE0100''
         and ci.icc_instance_id    is null
         and ci.inst_id             = ' || rec.inst_id || '
         and ci.inst_id            in (select inst_id from acm_cu_inst_vw)'
         || l_included_filter
         || get_condition('ci.agent_id',           rec.agent_id)
         || get_condition('ci.agent_id',           i_agent_id)
         || get_condition('ci.perso_priority',     rec.perso_priority,   '''')
         || get_condition('ci.perso_priority',     i_perso_priority,     '''')
         || get_condition('ci.blank_type_id',      rec.blank_type_id)
         || get_condition('ci.blank_type_id',      i_blank_type_id)
         || get_condition('ci.reissue_reason',     rec.reissue_reason,   '''')
         || get_condition('ci.pin_request',        i_pin_request,        '''')
         || get_condition('ci.embossing_request',  i_embossing_request,  '''')
         || get_condition('ci.pin_mailer_request', i_pin_mailer_request, '''')
         || l_product_id_filter
         || l_card_type_id_filter
         || case
                 when l_card_limit is not null
                 then '
                       and rownum     <= ' || l_card_limit
                 else null
             end
         || case
                when i_session_id is not null 
                     or i_flow_id is not null
                then '
         and exists (select 1
                       from app_object ao
                          , app_application aa
                      where ao.appl_id = aa.id
                        and ao.entity_type = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || '''
                        and ao.object_id = ci.card_id'
                      || get_condition('aa.flow_id', i_flow_id)
                      || case
                             when i_session_id is not null
                             then '
                         and aa.session_file_id
                                 in (select sf.id from prc_session_file sf
                                      where sf.session_id in (select id
                                                                from prc_session ps
                                                             connect by parent_id = prior id
                                                               start with id = ' || i_session_id || '))'
                             else null
                          end
                      || ')'
                else null
             end
         || case
                when i_start_date is not null
                 and i_end_date is not null
                then '
         and ci.reg_date between com_api_type_pkg.convert_to_date(' || com_api_type_pkg.convert_to_char(i_start_date) || ')
                             and com_api_type_pkg.convert_to_date(' || com_api_type_pkg.convert_to_char(i_end_date) || ')'
                when i_start_date is not null
                then '
         and ci.reg_date >= com_api_type_pkg.convert_to_date(' || com_api_type_pkg.convert_to_char(i_start_date) || ')'
                when i_end_date is not null
                then '
         and ci.reg_date <= com_api_type_pkg.convert_to_date(' || com_api_type_pkg.convert_to_char(i_end_date) || ')'
                else null
             end
         || '
      '  || l_order_statement
         || '
  ) m';

            trc_log_pkg.debug('l_sql_statement(1): [' || substr(l_sql_statement, 1,    3900) || ']');
            trc_log_pkg.debug('l_sql_statement(2): [' || substr(l_sql_statement, 3901, 3900) || ']');

            execute immediate l_sql_statement;

            -- check card count
            l_card_count := sql%rowcount;
            if l_need_delete_row = com_api_type_pkg.TRUE
               and l_card_count > nvl(rec.card_count, l_card_count)
            then
                trc_log_pkg.error (
                    i_text    => 'SELECTED_CARD_GREATER_BATCH_CARD_COUNT'
                    , o_text  => o_warning_msg
                );

                -- remove last card from batch
                delete from prs_batch_card_vw
                    where batch_id = i_batch_id
                      and id       = (select max(id) from prs_batch_card_vw where batch_id = i_batch_id);

                l_card_count := l_card_count - 1;
            end if;

            trc_log_pkg.debug (
                 i_text => 'inserted rows ' || l_card_count
            );
    
            select e.id
              bulk collect into l_event_object_id_tab
              from prs_batch_card_vw b
                 , evt_event_object_vw e
             where b.batch_id       = rec.batch_id
               and e.status         = evt_api_const_pkg.EVENT_STATUS_READY
               and e.procedure_name = 'ITF_PRC_CARDGEN_PKG.GENERATE_WITHOUT_BATCH'
               and e.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
               and e.object_id      = b.card_instance_id;

            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_object_id_tab
            );            

            return;
        end loop;
        
        com_api_error_pkg.raise_error (
            i_error        => 'PRS_BATCH_NOT_FOUND'
            , i_env_param1 => i_batch_id
        );
    end;
    
    procedure unmark_batch_card (
        i_batch_id                  in com_api_type_pkg.t_short_id
    ) is
    begin
        for rec in (
            select
                id
            from
                prs_batch_vw
            where
                id = i_batch_id
        ) loop
            delete from
                prs_batch_card_vw
            where
                batch_id = i_batch_id;
            
            return;
        end loop;
        
        com_api_error_pkg.raise_error (
            i_error        => 'PRS_BATCH_NOT_FOUND'
            , i_env_param1 => i_batch_id
        );
    end;


    procedure get_batch_cards (
        o_ref_cursor           out sys_refcursor
        , i_batch_id           in com_api_type_pkg.t_short_id
    ) is
    l_cursor_sql            com_api_type_pkg.t_text;
    l_sort_condition        com_api_type_pkg.t_name;
    l_sort_id               com_api_type_pkg.t_short_id;
        
    begin
        begin
            select sort_id
              into l_sort_id  
              from prs_sort s
                 , prs_batch b
             where b.sort_id = s.id
               and b.id = i_batch_id;
        
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error        => 'PRS_BATCH_NOT_FOUND'
                    , i_env_param1 => i_batch_id
                );                                 
        end;
        
        l_sort_condition := nvl(prs_api_card_pkg.enum_sort_condition(l_sort_id), 'card_number');

        l_cursor_sql := 
            'select * '                             ||
                'from ('                            ||
                'select bc.batch_id'                ||
                     ', bc.card_instance_id'        ||
                     ', c.card_mask'                ||    
                     ', i.card_id'                  ||
                     ', (select case when count(id) > 1 then 1 else 0 end from iss_card_instance where card_id = c.id) is_renewal' ||
                     ', n.card_number'              ||
                     ', i.cardholder_name'          ||
                     ', b.agent_id'                 ||
                     ', b.product_id'               ||    
                     ', b.card_type_id'             ||
                     ', b.blank_type_id'            ||    
                     ', b.perso_priority '          ||
                  'from prs_batch_card bc'          ||
                     ', prs_batch b'                ||
                     ', iss_card_instance i'        ||
                     ', iss_card c'                 ||
                     ', iss_card_number_vw n'          ||
                     ', (select :p_batch_id p_batch_id from dual) ' ||
                 'where bc.batch_id = p_batch_id '  ||
                   'and b.id = bc.batch_id '        ||
                   'and i.id = bc.card_instance_id '||
                   'and c.id = i.card_id '          ||
                   'and n.card_id = c.id ) x '      || 
                   'order by ' || l_sort_condition
               ;
        
        open o_ref_cursor for l_cursor_sql using i_batch_id;
    
    exception when others then
        trc_log_pkg.error(sqlerrm);  
        raise;    
    end;

end;
/

