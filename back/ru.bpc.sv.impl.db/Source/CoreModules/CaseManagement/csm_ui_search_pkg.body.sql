create or replace package body csm_ui_search_pkg is

-- Transforming the table with parameters to string clause
function get_sorting_clause(
    i_sorting_tab       in     com_param_map_tpt
) return com_api_type_pkg.t_name
is
    LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_sorting_clause: ';
    l_result            com_api_type_pkg.t_name;
begin
    begin
        select nvl2(list, 'order by '||list, '')
          into l_result
          from (select rtrim(xmlagg(xmlelement(e, name||' '||char_value, ',').extract('//text()')), ',') as list
                  from table(cast(i_sorting_tab as com_param_map_tpt))
               );
    exception
        when no_data_found then
            return null;
    end;

    trc_log_pkg.debug(LOG_PREFIX || ' sort by [' || l_result || ']');

    return l_result;
end;

function get_char_value(
    i_param_tab         in     com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_full_desc
) return com_api_type_pkg.t_full_desc is
    l_result            com_api_type_pkg.t_name;
begin
    select t.char_value
      into l_result
      from table(cast(i_param_tab as com_param_map_tpt)) t
     where t.name = i_param_name;

    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_char_value[' || i_param_name || '] FAILED');
        raise;
end;

function get_date_value(
    i_param_tab         in     com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return date is
    l_result            date;
begin
    select t.date_value
      into l_result
      from table(cast(i_param_tab as com_param_map_tpt)) t
     where t.name = i_param_name;

    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_date_value[' || i_param_name || '] FAILED');
        raise;
end;

function get_number_value(
    i_param_tab         in     com_param_map_tpt
  , i_param_name        in     com_api_type_pkg.t_name
) return number is
    l_result            number;
begin
    select t.number_value
      into l_result
      from table(cast(i_param_tab as com_param_map_tpt)) t
     where t.name = i_param_name;

    return l_result;
exception
    when no_data_found then
        return null;
    when others then
        trc_log_pkg.debug(lower($$PLSQL_UNIT) || '.get_number_value[' || i_param_name || '] FAILED');
        raise;
end;

procedure get_ref_cur_base(
    o_ref_cur              out com_api_type_pkg.t_ref_cur
  , o_row_count            out com_api_type_pkg.t_long_id
  , i_first_row         in     com_api_type_pkg.t_long_id
  , i_last_row          in     com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt
  , i_is_count_only     in     com_api_type_pkg.t_boolean
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name     := lower($$PLSQL_UNIT) || '.get_ref_cur_base ';
    CRLF                       constant com_api_type_pkg.t_name     := chr(13) || chr(10);
    DEFAULT_SORTING_CLAUSE     constant com_api_type_pkg.t_name     := 'order by a.id';
    SORTING_CLAUSE_PLCHLDR     constant com_api_type_pkg.t_name     := '@SORTING_CLAUSE@';
    OPER_FILTER_PLCHLDR        constant com_api_type_pkg.t_name     := '@OPER@';
    APPL_FILTER_PLCHLDR        constant com_api_type_pkg.t_name     := '@APPL@';
    OPER_DATE_LAG              constant com_api_type_pkg.t_count    := 180;

    SELECT_STMT_START          constant com_api_type_pkg.t_sql_statement := '
select v.application_id
     , v.seqnum
     , v.appl_number
     , v.flow_id
     , v.inst_id
     , v.agent_id
     , v.appl_status
     , com_api_dictionary_pkg.get_article_text(v.appl_status) as appl_status_name
     , v.reject_code
     , (select comments
          from (
                    select a.comments
                         , a.appl_id
                         , row_number() over(partition by appl_id order by id desc) as rnk
                      from app_history a
                     where a.reject_code is not null
                ) h
         where h.appl_id = v.application_id
           and h.rnk = 1
       ) as reject_comment
     , com_api_dictionary_pkg.get_article_text(v.reject_code) as reject_code_name
     , v.user_id
     , v.is_visible
     , v.customer_number
     , iss_api_card_pkg.get_card_mask(i_card_number => v.card_number) as card_mask
     , iss_api_token_pkg.decode_card_number(i_card_number => v.card_number) as card_number
     , null as account_number
     , v.dispute_id
     , v.dispute_reason
     , com_api_dictionary_pkg.get_article_text(v.dispute_reason) as dispute_reason_name
     , v.dispute_progress
     , v.case_progress
     , com_api_dictionary_pkg.get_article_text(v.case_progress) as case_progress_name
     , v.due_date
     , v.oper_id
     , v.oper_date
     , v.arn
     , v.auth_code
     , v.merchant_id
     , v.terminal_id
     , v.forw_inst_bin
     , v.merchant_city
     , v.merchant_country
     , v.merchant_postcode
     , v.merchant_region
     , v.merchant_street
     , v.mcc
     , v.fin_mes_arn
     , v.rrn
     , v.created_date as creation_date
     , (select max(comments) keep (dense_rank first order by h.change_date, h.id)
          from app_history h
         where h.appl_id = v.application_id
       ) as comments
     , com_api_i18n_pkg.get_text(''app_flow'', ''label'', v.flow_id, x.p_lang) as flow_name
     , get_text(''ost_institution'', ''name'', v.inst_id, x.p_lang) as inst_name
     , get_text(''ost_agent'', ''name'', v.agent_id, x.p_lang) as agent_name
     , (select m.merchant_number from acq_merchant m where m.id = v.merchant_id) as merchant_number
     , (select t.terminal_number from acq_terminal t where t.id = v.terminal_id) as terminal_number
     , v.case_source
     , com_api_dictionary_pkg.get_article_text(v.case_source) as case_source_name
     , v.user_id as case_owner
     , (select com_ui_person_pkg.get_person_name(u.person_id, x.p_lang) from acm_user u where u.id = v.user_id) as case_owner_name
     , coalesce(v.merchant_name, (select m.merchant_name from acq_merchant m where m.id = v.merchant_id)) as merchant_name
     , v.oper_amount
     , v.oper_currency
     , v.disputed_amount
     , v.disputed_currency
     , coalesce(
            v.reason_code
         , (select max(vf.reason_code) keep (dense_rank first order by vf.id desc)
              from vis_fin_message vf where vf.dispute_id = v.dispute_id
               and (vf.id != v.oper_id
                     or (vf.id = v.oper_id
                            and exists (
                                select 1
                                  from opr_operation o
                                 where o.id = vf.id
                                   and o.msg_type in (''MSGTCHBK'', ''MSGTREPR'', ''MSGTRTRQ'', ''MSGTACBK'')
                               )
                       )
                    )
             group by vf.dispute_id)
         , (select max(mf.de025) keep (dense_rank first order by mf.id desc)
              from mcw_fin mf where mf.dispute_id = v.dispute_id
               and (mf.id != v.oper_id
                     or (mf.id = v.oper_id
                            and exists (
                                select 1
                                  from opr_operation o
                                 where o.id = mf.id
                                   and o.msg_type in (''MSGTCHBK'', ''MSGTREPR'', ''MSGTRTRQ'', ''MSGTACBK'')
                               )
                       )
                    )
             group by mf.dispute_id)
       ) as reason_code
     , coalesce(
           (select mf.de072 from mcw_fin mf where mf.id = v.oper_id)
         , (select vf.member_msg_text from vis_fin_message vf where vf.id = v.oper_id)
       ) as mmt
     , v.write_off_amount
     , v.write_off_currency
     , v.created_by_user_id
     , (select com_ui_person_pkg.get_person_name(u.person_id, x.p_lang) from acm_user u where u.id = v.user_id) as created_by_user_name
     , v.claim_id
     , v.acquirer_inst_bin
     , v.transaction_code
     , v.sttl_amount
     , v.sttl_currency
     , v.base_amount
     , v.base_currency
     , v.hide_date
     , v.unhide_date
     , v.team_id
     , v.ext_claim_id
     , (select get_text (''com_array_element'', ''label'', e.id, x.p_lang) from com_array_element e where e.array_id = 10000077 and e.element_value = to_char(v.team_id, ''FM000000000000000000.0000'')) as team_name
     , x.p_lang as lang
  from ('
    ;
    SELECT_STMT_ROWNUM         constant com_api_type_pkg.t_text := '
     , row_number() over (' || SORTING_CLAUSE_PLCHLDR  || ') as rn';
    SELECT_STMT_END            constant com_api_type_pkg.t_text :=
') v
 cross join (select :p_lang as p_lang from dual) x
 where v.rn between :p_first_row and :p_last_row
order by v.rn'
    ;
    SELECT_LIST                constant com_api_type_pkg.t_text := '
select a.id as application_id
     , a.seqnum
     , a.appl_number
     , a.flow_id
     , a.inst_id
     , a.agent_id
     , a.appl_status
     , a.reject_code
     , a.case_owner as user_id
     , a.is_visible
     , a.created_date
     , a.case_source
     , a.customer_number
     , a.card_number
     , a.dispute_id
     , a.original_id
     , a.dispute_reason
     , a.dispute_progress
     , a.merchant_name
     , a.disputed_amount
     , a.disputed_currency
     , a.oper_date
     , a.oper_amount
     , a.oper_currency
     , a.case_progress
     , a.reason_code
     , a.due_date
     , op.oper_id
     , a.arn
     , a.auth_code
     , a.write_off_amount
     , a.write_off_currency
     , a.created_by_user_id
     , a.claim_id
     , a.acquirer_inst_bin
     , a.transaction_code
     , a.sttl_amount
     , a.sttl_currency
     , a.base_amount
     , a.base_currency
     , a.hide_date
     , a.unhide_date
     , a.team_id
     , a.ext_claim_id
     , op.merchant_id
     , op.terminal_id
     , op.forw_inst_bin
     , op.merchant_city
     , op.merchant_country
     , op.merchant_postcode
     , op.merchant_region
     , op.merchant_street
     , op.mcc
     , op.fin_mes_arn
     , op.rrn'
    ;
    PARAMS_WITH_CLAUSE         constant com_api_type_pkg.t_text := '
with params as (
select :card_number     as card_number
     , :from_oper_id    as from_oper_id
     , :to_oper_id      as to_oper_id
     , :network_refnum  as network_refnum
     , :auth_code       as auth_code
     , :merchant_id     as merchant_id
     , :terminal_id     as terminal_id
     , :from_appl_id    as from_appl_id
     , :to_appl_id      as to_appl_id
     , :appl_status     as appl_status
     , :inst_id         as inst_id
     , :appl_number     as appl_number
     , :appl_id         as appl_id
     , :agent_id        as agent_id
     , :case_owner      as case_owner
     , :is_visible      as is_visible
     , :case_source     as case_source
     , :reject_code     as reject_code
     , :merchant_name   as merchant_name
     , :merchant_number as merchant_number
     , :terminal_number as terminal_number
     , :dispute_id      as dispute_id
     , :claim_id        as claim_id
     , :dispute_reason  as dispute_reason
  from dual
)'
    ;
    l_query                    com_api_type_pkg.t_sql_statement := '
  from (select a.id
             , a.seqnum
             , a.appl_number
             , a.flow_id
             , a.inst_id
             , a.agent_id
             , a.appl_status
             , a.reject_code
             , a.user_id as case_owner
             , nvl(a.is_visible, 1) as is_visible
             , a.appl_type
             , a.session_file_id
             , a.file_rec_num
             , a.resp_session_file_id
             , a.is_template
             , a.product_id
             , a.split_hash
             , c.customer_number
             , card.card_number
             , c.dispute_id
             , c.original_id
             , c.dispute_reason
             , c.dispute_progress
             , c.due_date
             , c.merchant_name
             , c.disputed_amount
             , c.disputed_currency
             , c.oper_date
             , c.oper_amount
             , c.oper_currency
             , c.case_progress
             , c.reason_code
             , c.case_source
             , c.created_date
             , c.arn
             , c.auth_code
             , c.write_off_amount
             , c.write_off_currency
             , c.created_by_user_id
             , c.claim_id
             , c.acquirer_inst_bin
             , c.transaction_code
             , c.sttl_amount
             , c.sttl_currency
             , c.base_amount
             , c.base_currency
             , c.hide_date
             , c.unhide_date
             , c.team_id
             , c.ext_claim_id
          from app_application a
             , csm_case c
             , csm_card card
         where ' || APPL_FILTER_PLCHLDR || '
           and a.id = c.id(+)
           and c.id = card.id(+)
     ) a'
    ;
    OPERATION_CLAUSE           com_api_type_pkg.t_text := '
      select opr.dispute_id
           , opr.id              as oper_id
           , opr.oper_date
           , opr.network_refnum  as arn
           , iss.auth_code
           , iss.customer_id
           , acq.merchant_id
           , acq.terminal_id
           , opr.oper_amount
           , opr.oper_currency
           , opr.forw_inst_bin            as forw_inst_bin
           , opr.merchant_city            as merchant_city
           , opr.merchant_country         as merchant_country
           , opr.merchant_postcode        as merchant_postcode
           , opr.merchant_region          as merchant_region
           , opr.merchant_street          as merchant_street
           , coalesce(mcw.de026, vis.mcc) as mcc
           , coalesce(mcw.de031, vis.arn) as fin_mes_arn
           , coalesce(mcw.de037, vis.rrn) as rrn
        from      opr_operation   opr
        left join opr_card        crd    on crd.oper_id          = opr.id
                                        and crd.participant_type = ''PRTYISS''
        left join opr_participant iss    on iss.oper_id          = opr.id
                                        and iss.participant_type = ''PRTYISS''
        left join opr_participant acq    on acq.oper_id          = opr.id
                                        and acq.participant_type = ''PRTYACQ''
        left join mcw_fin         mcw   on opr.id                = mcw.id
        left join vis_fin_message vis   on opr.id                = vis.id
       where ' || OPER_FILTER_PLCHLDR || '
  ) op
    on op.oper_id = a.original_id'
    ;
    l_param_tab                com_param_map_tpt := i_param_tab;
    l_where_clause             com_api_type_pkg.t_text;
    l_appl_id_clause           com_api_type_pkg.t_text;
    l_full_query               com_api_type_pkg.t_sql_statement;
    l_privil_limitation        com_api_type_pkg.t_full_desc;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_arn                      com_api_type_pkg.t_rrn;
    l_auth_code                com_api_type_pkg.t_auth_code;
    l_card_number              com_api_type_pkg.t_card_number;
    l_merchant_id              com_api_type_pkg.t_short_id;
    l_terminal_id              com_api_type_pkg.t_short_id;
    l_split_hash               com_api_type_pkg.t_tiny_id;
    l_from_date                date;
    l_from_appl_id             com_api_type_pkg.t_long_id;
    l_from_oper_id             com_api_type_pkg.t_long_id;
    l_to_date                  date;
    l_to_appl_id               com_api_type_pkg.t_long_id;
    l_to_oper_id               com_api_type_pkg.t_long_id;
    l_show_hidden_applications com_api_type_pkg.t_boolean;
    l_appl_subtype             com_api_type_pkg.t_dict_value;
    l_flow_id_tab              com_api_type_pkg.t_name_tab;
    l_lov_param_tab            com_param_map_tpt := com_param_map_tpt();
    l_flow_id                  com_api_type_pkg.t_name;
    l_reject_code              com_api_type_pkg.t_dict_value;
    l_merchant_number          com_api_type_pkg.t_merchant_number;
    l_terminal_number          com_api_type_pkg.t_terminal_number;

    -- The function returns string with filtering condition for WHERE clause.
    -- Flag <i_use_reverse> should be used ONLY if there is an index with reverse() function on field <i_field_name>,
    -- and this field doesn't contain multi-byte strings, because reverse() function can be applied to a byte sequence only.
    -- Otherwise, exception ORA-29275 will be raised for multi-byte strings.
    function get_condition(
        i_param_name         in     com_api_type_pkg.t_oracle_name
      , i_field_name         in     com_api_type_pkg.t_oracle_name
      , i_use_reverse        in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
      , i_use_nvl            in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
      , i_checknull          in     com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
    ) return com_api_type_pkg.t_name is
        l_result                    com_api_type_pkg.t_name;
        l_param_name                com_api_type_pkg.t_oracle_name;
    begin
        l_param_name := '(select ' || lower(i_param_name) || ' from params)';

        if i_field_name is null then
            l_result := l_param_name; -- complete filtering condition is not required, only parameter value
        else
            begin
                select case
                       when t.number_value is not null then
                           lower(i_field_name) || nvl(t.condition, ' = ') || l_param_name
                       when t.char_value is not null
                        and i_use_reverse = com_api_const_pkg.TRUE then
                            'reverse(' || lower(i_field_name) ||
                           ') like reverse(replace(' || l_param_name || ', ''*'', ''%''))'
                       when t.char_value is not null then
                           case when t.char_value = '-1' and i_checknull = com_api_const_pkg.TRUE then
                                   lower(i_field_name) || ' is null'
                                else case
                                    when instr(t.char_value, '%') != 0
                                        then 'nvl(' || lower(i_field_name) || ', ''%'')' || nvl(t.condition, ' like ')

                                    else lower(i_field_name)                         || nvl(t.condition, ' = ')
                                end
                                || l_param_name
                           end
                       when t.date_value is not null then
                           lower(i_field_name)
                           || nvl(t.condition, ' = ')
                           || 'to_date(''' || l_param_name
                                           || ''', '''
                                           || com_api_const_pkg.DATE_FORMAT || ''')'
                       end
                  into l_result
                  from table(cast(l_param_tab as com_param_map_tpt)) t
                 where t.name = upper(i_param_name);

                if i_use_nvl = com_api_const_pkg.TRUE then
                    l_result := '(' || lower(i_field_name) || ' is null or ' || l_result || ')';
                end if;

                l_result := case
                                when l_result is not null
                                then '   and ' || l_result || CRLF
                                else null
                            end;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        return l_result;
    exception
        when others then
            trc_log_pkg.debug(
                i_text => 'get_condition() FAILED: i_field_name [' || i_field_name
                       || '], i_param_name [' || i_param_name || ']'
            );
            raise;
    end get_condition;

begin
    trc_log_pkg.debug(LOG_PREFIX || ' Start: i_tab_name [' || i_tab_name
                                 || '], i_is_count_only [' || i_is_count_only || ']');
    -- Logging collections with input parameters for debugging
    utl_data_pkg.print_table(i_param_tab => l_param_tab);

    if i_tab_name != 'DISPUTE' then
        com_api_error_pkg.raise_error(
            i_error      => 'INVALID_TAB_NAME'
          , i_env_param1 => i_tab_name
        );
    end if;

    l_privil_limitation := get_char_value(l_param_tab, 'PRIVIL_LIMITATION');
    l_inst_id           := coalesce(get_number_value(l_param_tab, 'INST_ID'), com_ui_user_env_pkg.get_user_inst);
    l_arn               := get_char_value(l_param_tab, 'NETWORK_REFNUM');
    l_auth_code         := get_char_value(l_param_tab, 'AUTH_CODE');
    l_from_date         := get_date_value(l_param_tab, 'DATE_FROM');
    l_to_date           := get_date_value(l_param_tab, 'DATE_TO');
    l_merchant_number   := get_char_value(l_param_tab, 'MERCHANT_NUMBER');
    l_terminal_number   := get_char_value(l_param_tab, 'TERMINAL_NUMBER');

    l_from_oper_id := com_api_id_pkg.get_from_id(
                          i_date => coalesce(l_from_date, com_api_sttl_day_pkg.get_sysdate()) - OPER_DATE_LAG
                      );
    l_to_oper_id   := com_api_id_pkg.get_till_id(
                          i_date => coalesce(l_to_date, com_api_sttl_day_pkg.get_sysdate())
                      );
    l_from_appl_id := case
                          when l_from_date is not null
                          then com_api_id_pkg.get_from_id(i_date => l_from_date)
                          else null
                      end;
    l_to_appl_id   := case
                          when l_to_date is not null
                          then com_api_id_pkg.get_till_id(i_date => l_to_date)
                          else null
                      end;
    trc_log_pkg.debug(
        i_text => 'l_from_oper_id [' || l_from_oper_id || '], l_from_appl_id [' || l_from_appl_id
                             || '], l_to_oper_id ['|| l_to_oper_id   || '], l_to_appl_id ['   || l_to_appl_id || ']'
    );

    -- Application subtype defines a list of available flows.
    -- So if a flow is not defined explicitly via incoming parameters
    -- then select's filter condition must contain this list
    l_appl_subtype      := get_char_value(l_param_tab, 'APPL_SUBTYPE');
    l_flow_id           := get_number_value(l_param_tab, 'FLOW_ID');
    l_reject_code       := get_char_value(l_param_tab, 'REJECT_CODE');

    trc_log_pkg.debug(
        i_text       => 'l_reject_code [' || l_reject_code || ']'
    );

    trc_log_pkg.debug(
        i_text       => 'l_appl_subtype [#1], l_flow_id [' || l_flow_id || ']'
      , i_env_param1 => l_appl_subtype
    );

    if      l_flow_id      is null
        and l_appl_subtype is not null
    then
        l_lov_param_tab.extend(1);
        l_lov_param_tab(1) := com_param_map_tpr('APPL_SUBTYPE', l_appl_subtype, null, null, null);

        com_ui_lov_pkg.get_lov_codes(
            o_code_tab   => l_flow_id_tab
          , i_lov_id     => app_api_const_pkg.LOV_ID_DISPUTE_FLOWS
          , i_param_map  => l_lov_param_tab
        );

        for i in 1 .. l_flow_id_tab.count() loop
            l_flow_id := l_flow_id || l_flow_id_tab(i) || ', ';
        end loop;

        l_flow_id := substr(l_flow_id, 1, instr(l_flow_id, ', ', -1) - 1);

        trc_log_pkg.debug(
            i_text => 'l_flow_id [' || l_flow_id || ']'
        );
    end if;

    -- Use a token if tokenization is enabled and exact PAN was passed into the procedure (not a mask)
    l_card_number := replace(get_char_value(l_param_tab, 'CARD_NUMBER'), '*', '%');
    if l_card_number is not null and instr(l_card_number, '%') = 0 then
        begin
            l_card_number := iss_api_token_pkg.encode_card_number(i_card_number => l_card_number);
        exception
            when com_api_error_pkg.e_application_error then
                null; -- Use source value on error, don't interrupt the search
        end;
    end if;

    -- Value of <from_appl_id> matches to start of day <l_from_date>,
    -- and <to_appl_id> matches to end of day <l_to_date>.
    -- Therefore, it is possible to use <from_appl_id> and <to_appl_id> not only for
    -- field APP_APPLICATION.id but also for field APP_DATA.id since application and
    -- its data should be processed within one settlement day.
    l_appl_id_clause := case
                            when l_from_date is not null
                            then 'a.id >= ' || get_condition(i_param_name => 'from_appl_id'
                                                           , i_field_name => null)
                        end
                     || case
                            when l_from_date is not null
                             and l_to_date   is not null
                            then ' and '
                        end
                     || case
                            when l_to_date   is not null
                            then 'a.id <= ' || get_condition(i_param_name => 'to_appl_id'
                                                           , i_field_name => null)
                        end;
    trc_log_pkg.debug('l_appl_id_clause [' || l_appl_id_clause || ']');

    -- Check if it is possible to search applications by its element values
    if l_card_number is not null then
        l_where_clause := nvl(l_appl_id_clause, '7 = 7')
                       || CRLF || '      '
                       || get_condition(
                              i_param_name  => 'CARD_NUMBER'
                            , i_field_name  => 'card.card_number'
                          )
                       || case
                              when l_appl_id_clause is not null
                              then '         and ' || l_appl_id_clause
                          end;
        l_query := replace(l_query, APPL_FILTER_PLCHLDR, l_where_clause);
    else
        l_query := replace(l_query, APPL_FILTER_PLCHLDR, nvl(l_appl_id_clause, '7 = 7'));
    end if;

    if l_appl_subtype = app_api_const_pkg.APPL_TYPE_ACQUIRING then
        -- Check if it is possible to search applications by associated dispute operations
        acq_api_merchant_pkg.get_merchant(
            i_inst_id         => l_inst_id
          , i_merchant_number => l_merchant_number
          , o_merchant_id     => l_merchant_id
          , o_split_hash      => l_split_hash
        );
        trc_log_pkg.debug('l_merchant_id [' || l_merchant_id || ']');

        if l_merchant_id is not null then
            l_param_tab.extend(1);
            l_param_tab(l_param_tab.count()) := com_param_map_tpr('MERCHANT_ID', null, l_merchant_id, null, null);
        elsif l_merchant_id is null and l_merchant_number is not null then
            l_param_tab.extend(1);
            l_param_tab(l_param_tab.count()) := com_param_map_tpr('MERCHANT_ID', null, -1, null, null);
            l_merchant_id := -1;
        end if;

        if l_terminal_number is not null then
            if nvl(l_merchant_id, 0) > 0 then
                acq_api_terminal_pkg.get_terminal(
                    i_merchant_id     => l_merchant_id
                  , i_terminal_number => l_terminal_number
                  , o_terminal_id     => l_terminal_id
                );
            else
                acq_api_terminal_pkg.get_terminal(
                    i_inst_id         => l_inst_id
                  , i_merchant_number => l_merchant_number
                  , i_terminal_number => l_terminal_number
                  , o_merchant_id     => l_merchant_id
                  , o_terminal_id     => l_terminal_id
                );
            end if;
        end if;

        trc_log_pkg.debug('l_terminal_id [' || l_terminal_id || ']');

        if l_terminal_id is not null then
            l_param_tab.extend(1);
            l_param_tab(l_param_tab.count()) := com_param_map_tpr('TERMINAL_ID', null, l_terminal_id, null, null);
        elsif l_terminal_id is null and l_terminal_number is not null then
            l_param_tab.extend(1);
            l_param_tab(l_param_tab.count()) := com_param_map_tpr('TERMINAL_ID', null, -1, null, null);
            l_terminal_id := -1;
        end if;

    end if;

    l_where_clause :=      'opr.id >= ' || get_condition(i_param_name => 'from_oper_id'
                                                       , i_field_name => null)
                   || ' and opr.id <= ' || get_condition(i_param_name => 'to_oper_id'
                                                       , i_field_name => null)
    ;
    if      l_merchant_id is null
        and l_terminal_id is null
        and l_merchant_number is null
        and l_terminal_number is null
    then
        l_query := l_query || CRLF || '  left join ('; -- there are no filters by operations
    else
        l_query := l_query || CRLF ||      '  join (';

        if l_appl_subtype = app_api_const_pkg.APPL_TYPE_ACQUIRING then
            l_where_clause := l_where_clause
                           || CRLF
                           || get_condition(
                                  i_param_name  => 'MERCHANT_ID'
                                , i_field_name  => 'acq.merchant_id'
                                , i_use_nvl     => com_api_const_pkg.TRUE
                              )
                           || get_condition(
                                  i_param_name  => 'TERMINAL_ID'
                                , i_field_name  => 'acq.terminal_id'
                                , i_use_nvl     => com_api_const_pkg.TRUE
                              );
        else
            l_where_clause := l_where_clause
                           || CRLF
                           || get_condition(
                                  i_param_name  => 'MERCHANT_NUMBER'
                                , i_field_name  => 'opr.merchant_number'
                              )
                           || get_condition(
                                  i_param_name  => 'TERMINAL_NUMBER'
                                , i_field_name  => 'opr.terminal_number'
                              );
        end if;
    end if;

    l_query := l_query || replace(OPERATION_CLAUSE, OPER_FILTER_PLCHLDR, l_where_clause);

    l_show_hidden_applications := acm_api_privilege_pkg.check_privs_user(
                                      i_user_id => com_ui_user_env_pkg.get_user_id()
                                    , i_priv_id => app_api_const_pkg.PRIV_VIEW_HIDDEN_DSP_APPLCTN
                                  );
    trc_log_pkg.debug('l_show_hidden_applications [' || l_show_hidden_applications || ']');

    l_query := l_query || CRLF
            || ' where a.inst_id in (select ai.inst_id from acm_cu_inst_vw ai)' || CRLF
            || '   and a.appl_type = ''' || app_api_const_pkg.APPL_TYPE_DISPUTE || '''' || CRLF
            || case
                   when l_privil_limitation is not null
                   then '   and ' || l_privil_limitation  || CRLF
               end
            || case
                   when l_show_hidden_applications = com_api_type_pkg.FALSE
                   then '   and nvl(a.is_visible, 1) = 1'  || CRLF
                   else null -- show all dispute applications
               end
            || case
                   when l_appl_id_clause is not null
                   then '   and ' || l_appl_id_clause || CRLF
               end
            || case
                   when l_flow_id is not null
                   then '   and a.flow_id in (' || l_flow_id || ')' || CRLF
               end
            || get_condition(
                   i_param_name  => 'REJECT_CODE'
                 , i_field_name  => 'a.reject_code'
            )
            || get_condition(
                   i_param_name  => 'APPL_STATUS'
                 , i_field_name  => 'a.appl_status'
               )
            || get_condition(
                   i_param_name  => 'INST_ID'
                 , i_field_name  => 'a.inst_id'
               )
            || get_condition(
                   i_param_name  => 'APPL_NUMBER'
                 , i_field_name  => 'a.appl_number'
               )
            || get_condition(
                   i_param_name  => 'APPL_ID'
                 , i_field_name  => 'a.id'
               )
            || get_condition(
                   i_param_name  => 'AGENT_ID'
                 , i_field_name  => 'a.agent_id'
               )
            || get_condition(
                   i_param_name  => 'CASE_OWNER'
                 , i_field_name  => 'a.case_owner'
                 , i_checknull   => com_api_const_pkg.TRUE
               )
            || get_condition(
                   i_param_name  => 'IS_VISIBLE'
                 , i_field_name  => 'a.is_visible'
               )
            || get_condition(
                   i_param_name  => 'CASE_SOURCE'
                 , i_field_name  => 'a.case_source'
               )
            || get_condition(
                   i_param_name  => 'MERCHANT_NAME'
                 , i_field_name  => 'a.merchant_name'
               )
            || get_condition(
                   i_param_name  => 'NETWORK_REFNUM'
                 , i_field_name  => 'a.arn'
            )
            || get_condition(
                   i_param_name  => 'AUTH_CODE'
                 , i_field_name  => 'a.auth_code'
            )
            || get_condition(
                   i_param_name  => 'CARD_NUMBER'
                 , i_field_name  => 'a.card_number'
                 , i_use_reverse => com_api_const_pkg.TRUE
                 , i_use_nvl     => com_api_const_pkg.TRUE
            )
            || get_condition(
                   i_param_name  => 'DISPUTE_ID'
                 , i_field_name  => 'a.dispute_id'
            )
            || get_condition(
                   i_param_name  => 'CLAIM_ID'
                 , i_field_name  => 'a.claim_id'
            )
            || get_condition(
                   i_param_name  => 'DISPUTE_REASON'
                 , i_field_name  => 'a.dispute_reason'
            )
    ;

    if i_is_count_only = com_api_const_pkg.TRUE then
        l_full_query := PARAMS_WITH_CLAUSE || CRLF || 'select count(a.id)'|| l_query;

        trc_log_pkg.debug('l_full_query(1) [' || substr(l_full_query, 1,    3900) || ']');
        trc_log_pkg.debug('l_full_query(2) [' || substr(l_full_query, 3901, 3900) || ']');

        execute immediate l_full_query
        into o_row_count
        using
            l_card_number
          , l_from_oper_id
          , l_to_oper_id
          , l_arn
          , l_auth_code
          , l_merchant_id
          , l_terminal_id
          , l_from_appl_id
          , l_to_appl_id
          , get_char_value  (l_param_tab, 'APPL_STATUS')
          , get_number_value(l_param_tab, 'INST_ID')
          , get_char_value  (l_param_tab, 'APPL_NUMBER')
          , get_number_value(l_param_tab, 'APPL_ID')
          , get_number_value(l_param_tab, 'AGENT_ID')
          , get_char_value  (l_param_tab, 'CASE_OWNER')
          , get_char_value  (l_param_tab, 'IS_VISIBLE')
          , get_char_value  (l_param_tab, 'CASE_SOURCE')
          , l_reject_code
          , get_char_value  (l_param_tab, 'MERCHANT_NAME')
          , get_char_value  (l_param_tab, 'MERCHANT_NUMBER')
          , get_char_value  (l_param_tab, 'TERMINAL_NUMBER')
          , get_number_value(l_param_tab, 'DISPUTE_ID')
          , get_number_value(l_param_tab, 'CLAIM_ID')
          , get_char_value  (l_param_tab, 'DISPUTE_REASON');
    else
        l_full_query := PARAMS_WITH_CLAUSE
                     || SELECT_STMT_START
                     || SELECT_LIST
                     || replace(
                            SELECT_STMT_ROWNUM
                          , SORTING_CLAUSE_PLCHLDR
                          , nvl(get_sorting_clause(i_sorting_tab), DEFAULT_SORTING_CLAUSE)
                        );

        l_full_query := l_full_query
                     || l_query
                     || SELECT_STMT_END;

        trc_log_pkg.debug('l_full_query(1) [' || substr(l_full_query, 1,    3900) || ']');
        trc_log_pkg.debug('l_full_query(2) [' || substr(l_full_query, 3901, 3900) || ']');
        trc_log_pkg.debug('l_full_query(3) [' || substr(l_full_query, 3901 + 3900, 3900) || ']');

        open o_ref_cur for l_full_query
        using
            l_card_number
          , l_from_oper_id
          , l_to_oper_id
          , l_arn
          , l_auth_code
          , l_merchant_id
          , l_terminal_id
          , l_from_appl_id
          , l_to_appl_id
          , get_char_value  (l_param_tab, 'APPL_STATUS')
          , get_number_value(l_param_tab, 'INST_ID')
          , get_char_value  (l_param_tab, 'APPL_NUMBER')
          , get_number_value(l_param_tab, 'APPL_ID')
          , get_number_value(l_param_tab, 'AGENT_ID')
          , get_char_value  (l_param_tab, 'CASE_OWNER')
          , get_char_value  (l_param_tab, 'IS_VISIBLE')
          , get_char_value  (l_param_tab, 'CASE_SOURCE')
          , l_reject_code
          , get_char_value  (l_param_tab, 'MERCHANT_NAME')
          , get_char_value  (l_param_tab, 'MERCHANT_NUMBER')
          , get_char_value  (l_param_tab, 'TERMINAL_NUMBER')
          , get_number_value(l_param_tab, 'DISPUTE_ID')
          , get_number_value(l_param_tab, 'CLAIM_ID')
          , get_char_value  (l_param_tab, 'DISPUTE_REASON')
          , com_ui_user_env_pkg.get_user_lang
          , i_first_row
          , i_last_row;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ' Finish');
exception
    when others then
        trc_log_pkg.debug(LOG_PREFIX || 'FAILED with sqlerrm [' || sqlerrm || ']');
        trc_log_pkg.debug('l_query:' || CRLF || l_query);
        trc_log_pkg.debug('l_full_query(1) [' || substr(l_full_query, 1,    3900) || ']');
        trc_log_pkg.debug('l_full_query(2) [' || substr(l_full_query, 3901, 3900) || ']');
        trc_log_pkg.debug('l_full_query(3) [' || substr(l_full_query, 3901 + 3900, 3900) || ']');
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out com_api_type_pkg.t_ref_cur
  , i_first_row         in     com_api_type_pkg.t_long_id
  , i_last_row          in     com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
  , i_sorting_tab       in     com_param_map_tpt
) is
    l_row_count         com_api_type_pkg.t_long_id;
begin
    get_ref_cur_base(
        o_ref_cur       => o_ref_cur
      , o_row_count     => l_row_count
      , i_first_row     => i_first_row
      , i_last_row      => i_last_row
      , i_tab_name      => i_tab_name
      , i_param_tab     => i_param_tab
      , i_sorting_tab   => i_sorting_tab
      , i_is_count_only => com_api_const_pkg.FALSE
    );
end;

procedure get_row_count(
    o_row_count            out com_api_type_pkg.t_long_id
  , i_tab_name          in     com_api_type_pkg.t_name
  , i_param_tab         in     com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt := com_param_map_tpt();
begin
    get_ref_cur_base(
        o_ref_cur       => l_ref_cur
      , o_row_count     => o_row_count
      , i_first_row     => null
      , i_last_row      => null
      , i_tab_name      => i_tab_name
      , i_param_tab     => i_param_tab
      , i_sorting_tab   => l_sorting_tab
      , i_is_count_only => com_api_const_pkg.TRUE
    );
end;

end;
/
