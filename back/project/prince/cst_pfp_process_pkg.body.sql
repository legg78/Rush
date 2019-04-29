create or replace package body cst_pfp_process_pkg as
/************************************************************
 * Custom processes for Prince bank in Cambodia <br />
 * LastChangedDate::  14.01.2019 <br />
 * Module: cst_pfp_process_pkg <br />
 * @headcom
 ************************************************************/

type t_event_id_tab is table of com_api_type_pkg.t_number_tab index by com_api_type_pkg.t_name;
type t_object_rec  is record(
    object_id    com_api_type_pkg.t_number_tab
  , event_id     t_event_id_tab
);

type t_entity_tab  is table of t_object_rec index by com_api_type_pkg.t_dict_value;

procedure add_objects_in_tab(
    i_inst_id              in      com_api_type_pkg.t_inst_id
  , i_entity_type          in      com_api_type_pkg.t_dict_value
  , i_proc_name            in      com_api_type_pkg.t_name
  , i_sysdate              in      date
  , io_event_object_tab    in out  t_entity_tab
  , io_entity_tab          in out  com_api_type_pkg.t_dict_tab
) is
begin
    for rec in (select o.id as event_id
                     , o.entity_type
                     , o.object_id
                  from evt_event_object o
                     , evt_event e
                     , evt_subscriber s
                 where decode(o.status, 'EVST0001', o.procedure_name, null) = i_proc_name
                   and o.eff_date      <= i_sysdate
                   and (o.inst_id       = i_inst_id
                        or i_inst_id    is null
                        or i_inst_id    = ost_api_const_pkg.DEFAULT_INST
                       )
                   and o.entity_type    = i_entity_type
                   and e.id             = o.event_id
                   and e.event_type     = s.event_type
                   and o.procedure_name = s.procedure_name
                 order by
                       o.id
    ) loop
        if io_event_object_tab.count = 0 then
            io_event_object_tab(rec.entity_type).object_id(1) := rec.object_id; 
            io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
            if io_entity_tab.exists(1) then
                io_entity_tab.delete;
            end if;
            io_entity_tab(1) := rec.entity_type;
        else
            if io_event_object_tab.exists(rec.entity_type) then
                if io_event_object_tab(rec.entity_type).event_id.exists(rec.object_id) then
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(io_event_object_tab(rec.entity_type).event_id(rec.object_id).last + 1) := rec.event_id;
                else
                    io_event_object_tab(rec.entity_type).object_id(io_event_object_tab(rec.entity_type).object_id.last + 1) := rec.object_id;
                    io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                end if;
            else
                io_event_object_tab(rec.entity_type).object_id(1)   := rec.object_id;
                io_event_object_tab(rec.entity_type).event_id(rec.object_id)(1) := rec.event_id;
                io_entity_tab(io_entity_tab.last + 1) := rec.entity_type;
            end if;
        end if;
    end loop;
end add_objects_in_tab;

procedure clear_check_data(
    i_entity_type              in     com_api_type_pkg.t_dict_value
  , i_index_element            in     com_api_type_pkg.t_long_id
  , io_event_object_tab        in out t_entity_tab
)
is
begin
    if io_event_object_tab(i_entity_type).event_id.exists(i_index_element) then
        io_event_object_tab(i_entity_type).event_id.delete(i_index_element);
    end if;
end clear_check_data;

procedure add_event_collection(
    i_index                    in     com_api_type_pkg.t_long_id
  , i_entity_tab               in     com_api_type_pkg.t_dict_tab
  , i_oper_id                  in     com_api_type_pkg.t_long_id
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    for i in i_index .. i_entity_tab.last
    loop
        if i_entity_tab(i) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_oper_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_oper_id)(n);
                end if;
            end loop;
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_oper_id
              , io_event_object_tab  => io_event_object_tab
            );
        end if;
    end loop;
end add_event_collection;

procedure add_not_used_event_collection(
    i_entity_tab               in     com_api_type_pkg.t_dict_tab
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    if i_entity_tab.exists(1) then
        for i in i_entity_tab.first .. i_entity_tab.last
        loop
            if io_event_object_tab.exists(i_entity_tab(i)) then
                if io_event_object_tab(i_entity_tab(i)).object_id.exists(1) then
                    for j in io_event_object_tab(i_entity_tab(i)).object_id.first .. io_event_object_tab(i_entity_tab(i)).object_id.last
                    loop
                        if io_event_object_tab(i_entity_tab(i)).event_id.exists(io_event_object_tab(i_entity_tab(i)).object_id(j))
                        then
                            for k in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j)).last
                            loop
                                if io_event_tab.exists(1) then
                                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                else
                                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(io_event_object_tab(i_entity_tab(i)).object_id(j))(k);
                                end if;
                            end loop;
                        end if;
                    end loop;
                end if;
            end if;
        end loop;
    end if;
end add_not_used_event_collection;

function format_amount (
    i_amount                in      com_api_type_pkg.t_money
  , i_curr_code             in      com_api_type_pkg.t_curr_code
  , i_mask_error            in      com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_result                        com_api_type_pkg.t_name;
begin
    if i_amount is not null then
        select to_char(i_amount * power(10, 3 - exponent))
          into l_result
          from com_currency
         where code = i_curr_code;
    end if;
    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return to_char(i_amount);
        else
            com_api_error_pkg.raise_error(
                i_error      => 'CURRENCY_NOT_FOUND'
              , i_env_param1 => i_curr_code
            );
        end if;
end format_amount;

function get_tran_code_gl(
    i_card_id               in      com_api_type_pkg.t_long_id
  , i_account_id            in      com_api_type_pkg.t_long_id
  , i_oper_reason           in      com_api_type_pkg.t_dict_value
  , i_mask_error            in      com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return com_api_type_pkg.t_name
is
    l_result                        com_api_type_pkg.t_name;
    l_contract_type                 com_api_type_pkg.t_dict_value;
begin

    select co.contract_type
      into l_contract_type
      from prd_contract co
         , iss_card ca 
     where co.id = ca.contract_id
       and ca.id = i_card_id;

    case l_contract_type
        when 'CNTPINIC' -- Debit card contract
        then case i_oper_reason 
                 when 'FETP0101' -- Card reissue fee
                 then l_result := 'DRF';
                 when 'FETP0102' -- Card Annual Fee
                 then l_result := 'DMF';
                 when 'FETP0154' -- PIN reissue fee
                 then l_result := 'DPF';
                 else l_result := '';
             end case;
        else l_result := '';
    end case;

    return l_result;
exception
    when no_data_found then
        if i_mask_error = com_api_type_pkg.TRUE then
            return '';
        else
            com_api_error_pkg.raise_error(
                i_error      => 'REQUESTED_DATA_NOT_FOUND'
              , i_env_param1 => 'i_card_id=' || i_card_id || 'i_account_id=' || i_account_id
            );
        end if;
end get_tran_code_gl;

procedure export_gl_data(
    i_inst_id               in     com_api_type_pkg.t_inst_id
  , i_start_date            in     date
  , i_end_date              in     date
  , i_full_export           in     com_api_type_pkg.t_boolean          default com_api_type_pkg.FALSE
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.EXPORT_GL_DATA';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.export_gl_data: ';
    l_param_tab                com_api_type_pkg.t_param_tab;
    l_estimated_count          com_api_type_pkg.t_count := 0;
    l_record_count             com_api_type_pkg.t_count := 0;
    l_seq_num                  com_api_type_pkg.t_count := 0;
    l_thread_number            com_api_type_pkg.t_tiny_id;
    l_record                   com_api_type_pkg.t_raw_tab;
    l_session_file_id          com_api_type_pkg.t_long_id;
    l_inst_id                  com_api_type_pkg.t_inst_id;
    l_from_date                date;
    l_to_date                  date;
    l_sysdate                  date;
    l_incremental_data_exists  com_api_type_pkg.t_boolean;
    l_event_object_tab         t_entity_tab;
    l_event_tab                com_api_type_pkg.t_number_tab;
    l_entity_tab               com_api_type_pkg.t_dict_tab;
    l_event_id                 com_api_type_pkg.t_long_id;
    l_event_type               com_api_type_pkg.t_dict_value;
    l_file_type                com_api_type_pkg.t_dict_value;
    l_file_attr_id             com_api_type_pkg.t_short_id;
    l_file_purpose             com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'process begin'
    );
    prc_api_stat_pkg.log_start;

    l_inst_id   := nvl(i_inst_id, cst_pfp_api_const_pkg.DEFAULT_INST);

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    l_thread_number := get_thread_number;

    if i_full_export = com_api_type_pkg.TRUE then
        l_from_date := trunc(coalesce(i_start_date, l_sysdate), 'DD');
        l_to_date   := nvl(trunc(i_end_date, 'DD'), l_from_date) + 1 - com_api_const_pkg.ONE_SECOND;

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'Date period: sysdate [#1], start_date [#2], end_date [#3]'
          , i_env_param1 => to_char(l_sysdate, 'dd-mon-yyyy hh24:mi:ss')
          , i_env_param2 => to_char(l_from_date, 'dd-mon-yyyy hh24:mi:ss')
          , i_env_param3 => to_char(l_to_date, 'dd-mon-yyyy hh24:mi:ss')
        );
    else
        begin
            select o.event_id
                 , e.event_type
              into l_event_id
                 , l_event_type
              from evt_event_object_vw o
                 , evt_event_vw e
                 , evt_subscriber_vw s
             where o.procedure_name = PROC_NAME
               and o.eff_date <= l_sysdate
               and nvl(o.status, evt_api_const_pkg.EVENT_STATUS_READY) != evt_api_const_pkg.EVENT_STATUS_PROCESSED
               and (o.inst_id = i_inst_id 
                    or i_inst_id is null
                    or i_inst_id = ost_api_const_pkg.DEFAULT_INST
                   )
               and (o.split_hash in (select split_hash from com_split_map where thread_number = l_thread_number)
                    or l_thread_number = -1
                   )
               and e.id = o.event_id
               and e.event_type = s.event_type
               and o.procedure_name = s.procedure_name
               and o.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and rownum = 1;

            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'Sysdate [#1], l_event_id [#2], l_event_type [#3]' 
              , i_env_param1 => to_char(l_sysdate, 'dd-mon-yyyy hh24:mi:ss')
              , i_env_param2 => l_event_id
              , i_env_param3 => l_event_type
            );

            l_incremental_data_exists := com_api_type_pkg.TRUE;

            add_objects_in_tab(
                i_inst_id              => i_inst_id
              , i_entity_type          => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_proc_name            => PROC_NAME
              , i_sysdate              => l_sysdate
              , io_event_object_tab    => l_event_object_tab
              , io_entity_tab          => l_entity_tab
            );

        exception when no_data_found then
            l_incremental_data_exists := com_api_type_pkg.FALSE;
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'There is no data for incremental upload'
            );
        end;
    end if;

    prc_api_file_pkg.open_file(
        o_sess_file_id  => l_session_file_id
      , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
      , io_params       => l_param_tab
    );

    l_file_type :=
        rul_api_param_pkg.get_param_char (
            i_name        => 'FILE_TYPE'
          , io_params     => l_param_tab
          , i_mask_error  => com_api_type_pkg.TRUE
        );

    l_file_purpose :=
        rul_api_param_pkg.get_param_char (
            i_name        => 'FILE_PURPOSE'
          , io_params     => l_param_tab
          , i_mask_error  => com_api_type_pkg.TRUE
        );

    l_file_attr_id :=
        rul_api_param_pkg.get_param_num (
            i_name        => 'FILE_ATTR_ID'
          , io_params     => l_param_tab
          , i_mask_error  => com_api_type_pkg.TRUE
        );

    select count(a.id) + 1
      into l_seq_num
      from prc_session_file a
         , prc_session b
         , prc_file f
     where a.session_id = b.id
       and trunc(a.file_date) = trunc(get_sysdate())
       and (a.file_type = l_file_type or l_file_type is null)
       and b.process_id = f.process_id
       and (b.inst_id in (i_inst_id, prc_api_session_pkg.get_inst_id) or i_inst_id = ost_api_const_pkg.DEFAULT_INST)
       and (f.file_purpose = l_file_purpose or l_file_purpose is null)
       and (a.file_attr_id = l_file_attr_id or l_file_attr_id is null);

    --File header:
    l_record(1) := 'HDR,SV OFFLINE FEE,FCUBS,' || to_char(get_sysdate, 'yyyymmdd');

    prc_api_file_pkg.put_line(
        i_raw_data      => l_record(1)
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record(1)
    );
    l_record.delete;

    select count(1)
      into l_estimated_count
      from (
            -- 1. Participant client_id_type = 'CITPACCT'
            select aa.agent_id
                 , aa.id as account_id
                 , par.customer_id
                 , aa.account_number
                 , ent.amount
                 , ent.currency
                 , ent.balance_impact
                 , opr.id as oper_id
                 , opr.oper_amount
                 , opr.oper_type
                 , opr.oper_reason
                 , opr.oper_date
                 , opr.host_date
                 , opr.network_refnum as ARN
                 , opr.originator_refnum as RRN
                 , opr.is_reversal
                 , bun.posting_date
                 , pc.contract_type
              from opr_operation opr
                 , opr_participant par
                 , acc_macros mac
                 , acc_entry ent
                 , acc_account aa
                 , acc_bunch bun
                 , acc_account aa_cust
                 , prd_contract pc
             where opr.id = par.oper_id
               and opr.id = mac.object_id
               and mac.id = ent.macros_id
               and aa.id  = ent.account_id
               and bun.id = ent.bunch_id
               and par.account_id = aa_cust.id
               and aa_cust.contract_id = pc.id
               and aa.split_hash = ent.split_hash
               and par.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT -- 'CITPACCT'
               and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
               and ent.balance_type in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER -- 'BLTP0001'
                                       , acc_api_const_pkg.BALANCE_TYPE_FEES   -- 'BLTP0003'
                                       , 'BLTP5002' --VAT
                                       , crd_api_const_pkg.BALANCE_TYPE_INTEREST -- 'BLTP1003'
                                       )
               and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
               and ent.status = acc_api_const_pkg.ENTRY_STATUS_POSTED -- 'ENTRPOST'
               and opr.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
               and bun.bunch_type_id between cst_pfp_api_const_pkg.BUNCH_TYPE_ID_FROM
                                         and cst_pfp_api_const_pkg.BUNCH_TYPE_ID_TO
            union all
            -- 2. Participant client_id_type = 'CITPCARD'
            select aa.agent_id 
                 , aa.id as account_id
                 , par.customer_id
                 , aa.account_number
                 , ent.amount
                 , ent.currency
                 , ent.balance_impact
                 , opr.id as oper_id
                 , opr.oper_amount
                 , opr.oper_type
                 , opr.oper_reason
                 , opr.oper_date
                 , opr.host_date
                 , opr.network_refnum as ARN
                 , opr.originator_refnum as RRN 
                 , opr.is_reversal       
                 , bun.posting_date
                 , pc.contract_type
              from opr_operation opr
                 , opr_participant par
                 , acc_macros mac
                 , acc_entry ent
                 , acc_account aa
                 , iss_card ica
                 , prd_contract pc
                 , acc_bunch bun
             where opr.id = par.oper_id
               and opr.id = mac.object_id
               and mac.id = ent.macros_id
               and ica.id = par.card_id
               and ica.contract_id = pc.id
               and aa.id  = ent.account_id
               and bun.id = ent.bunch_id
               and aa.split_hash = ent.split_hash
               and ica.split_hash = par.split_hash
               and par.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD --'CITPCARD'
               and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
               and ent.balance_type in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER -- 'BLTP0001'
                                       , acc_api_const_pkg.BALANCE_TYPE_FEES   -- 'BLTP0003'
                                       , 'BLTP5002' --VAT
                                       , crd_api_const_pkg.BALANCE_TYPE_INTEREST -- 'BLTP1003'
                                       )
               and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
               and ent.status = acc_api_const_pkg.ENTRY_STATUS_POSTED -- 'ENTRPOST'
               and opr.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
               and bun.bunch_type_id between cst_pfp_api_const_pkg.BUNCH_TYPE_ID_FROM
                                         and cst_pfp_api_const_pkg.BUNCH_TYPE_ID_TO
           ) t
         , acc_gl_account_mvw gl
     where t.account_id = gl.id(+)
       and l_inst_id = gl.inst_id(+)
       and ((i_full_export = com_api_type_pkg.TRUE 
             and t.posting_date between l_from_date and l_to_date
            )
            or
            (i_full_export = com_api_type_pkg.FALSE
             and l_incremental_data_exists = com_api_type_pkg.TRUE
             and t.oper_id in (select eo.object_id
                                 from evt_event_object eo
                                    , evt_event e
                                    , evt_subscriber s
                                where decode(eo.status, 'EVST0001', eo.procedure_name, null) = PROC_NAME
                                   and eo.eff_date      <= l_sysdate
                                   and (eo.inst_id = i_inst_id 
                                        or i_inst_id is null
                                        or i_inst_id = ost_api_const_pkg.DEFAULT_INST
                                       )
                                   and eo.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                   and e.id              = eo.event_id
                                   and e.event_type      = s.event_type
                                   and eo.procedure_name = s.procedure_name
                              )
            )
           );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count   => l_estimated_count
    );

    for m in (
        select com_api_currency_pkg.get_currency_name(t.currency) as ccy
             , format_amount(i_amount => t.amount, i_curr_code => t.currency) as amount
             , case t.currency
                    when '116' then ''
                    else format_amount(i_amount => t.amount, i_curr_code => '840') 
               end as lcyamount
             , case t.balance_impact
                    when 1 then 'C'
                    else 'D'
               end as drcr
             , case 
                    when gl.id is null
                    then t.account_number
                    else case 
                         when t.account_number like '116%'
                         then substr(t.account_number, 7)
                         else substr(t.account_number, 4)
                         end
               end as acno 
             , ost_ui_agent_pkg.get_agent_number(t.agent_id) as acbrn
             , cst_pfp_process_pkg.get_tran_code_gl(
                   i_card_id     => t.card_id
                 , i_account_id  => t.account_id
                 , i_oper_reason => t.oper_reason
                ) as txncd
             , to_char(t.posting_date, 'yyyymmdd') as valdt
             , prd_api_customer_pkg.get_customer_number(t.customer_id) as relcust
             , to_char(t.oper_date, 'yyyymmdd') as initdate
             , t.oper_reason || ' - ' || com_api_dictionary_pkg.get_article_text(t.oper_reason) as addltext
             , t.rrn as extrefno
             , to_char(l_seq_num, 'FM0000') as batchno
             , 993 as brn
             , 'SMARTVISTA' as srccd
             , 'U' as upldstat
             , t.oper_id
          from (
                -- 1. Participant client_id_type = 'CITPACCT'
                select aa.agent_id
                     , aa.id as account_id
                     , par.customer_id
                     , aa.account_number
                     , ent.amount
                     , ent.currency
                     , ent.balance_impact
                     , opr.id as oper_id
                     , opr.oper_amount
                     , opr.oper_type
                     , opr.oper_reason
                     , opr.oper_date
                     , opr.host_date
                     , opr.network_refnum as ARN
                     , opr.originator_refnum as RRN
                     , opr.is_reversal
                     , bun.posting_date
                     , pc.contract_type
                     , par.card_id
                  from opr_operation opr
                     , opr_participant par
                     , acc_macros mac
                     , acc_entry ent
                     , acc_account aa
                     , acc_bunch bun
                     , acc_account aa_cust
                     , prd_contract pc
                 where opr.id = par.oper_id
                   and opr.id = mac.object_id
                   and mac.id = ent.macros_id
                   and aa.id  = ent.account_id
                   and bun.id = ent.bunch_id
                   and par.account_id = aa_cust.id
                   and aa_cust.contract_id = pc.id
                   and aa.split_hash = ent.split_hash
                   and par.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_ACCOUNT -- 'CITPACCT'
                   and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                   and ent.balance_type in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER -- 'BLTP0001'
                                           , acc_api_const_pkg.BALANCE_TYPE_FEES   -- 'BLTP0003'
                                           , 'BLTP5002' --VAT
                                           , crd_api_const_pkg.BALANCE_TYPE_INTEREST -- 'BLTP1003'
                                           )
                   and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
                   and ent.status = acc_api_const_pkg.ENTRY_STATUS_POSTED -- 'ENTRPOST'
                   and opr.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
                   and bun.bunch_type_id between cst_pfp_api_const_pkg.BUNCH_TYPE_ID_FROM 
                                             and cst_pfp_api_const_pkg.BUNCH_TYPE_ID_TO
                union all
                -- 2. Participant client_id_type = 'CITPCARD'
                select aa.agent_id 
                     , aa.id as account_id
                     , par.customer_id
                     , aa.account_number
                     , ent.amount
                     , ent.currency
                     , ent.balance_impact
                     , opr.id as oper_id
                     , opr.oper_amount
                     , opr.oper_type
                     , opr.oper_reason
                     , opr.oper_date
                     , opr.host_date
                     , opr.network_refnum as ARN
                     , opr.originator_refnum as RRN
                     , opr.is_reversal
                     , bun.posting_date
                     , pc.contract_type
                     , par.card_id
                  from opr_operation opr
                     , opr_participant par
                     , acc_macros mac
                     , acc_entry ent
                     , acc_account aa
                     , iss_card ica
                     , prd_contract pc
                     , acc_bunch bun
                 where opr.id = par.oper_id
                   and opr.id = mac.object_id
                   and mac.id = ent.macros_id
                   and ica.id = par.card_id
                   and ica.contract_id = pc.id
                   and aa.id  = ent.account_id
                   and bun.id = ent.bunch_id
                   and aa.split_hash = ent.split_hash
                   and ica.split_hash = par.split_hash
                   and par.client_id_type = opr_api_const_pkg.CLIENT_ID_TYPE_CARD --'CITPCARD'
                   and par.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER --'PRTYISS'
                   and ent.balance_type in ( acc_api_const_pkg.BALANCE_TYPE_LEDGER -- 'BLTP0001'
                                           , acc_api_const_pkg.BALANCE_TYPE_FEES   -- 'BLTP0003'
                                           , 'BLTP5002' --VAT
                                           , crd_api_const_pkg.BALANCE_TYPE_INTEREST -- 'BLTP1003'
                                           )
                   and mac.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION -- 'ENTTOPER'
                   and ent.status = acc_api_const_pkg.ENTRY_STATUS_POSTED -- 'ENTRPOST'
                   and opr.status = opr_api_const_pkg.OPERATION_STATUS_PROCESSED -- 'OPST0400'
                   and bun.bunch_type_id between cst_pfp_api_const_pkg.BUNCH_TYPE_ID_FROM
                                             and cst_pfp_api_const_pkg.BUNCH_TYPE_ID_TO
               ) t
             , acc_gl_account_mvw gl
         where t.account_id = gl.id(+)
           and l_inst_id = gl.inst_id(+)
           --and t.posting_date between l_from_date and l_to_date
           and ((i_full_export = com_api_type_pkg.TRUE 
                 and t.posting_date between l_from_date and l_to_date
                )
                or
                (i_full_export = com_api_type_pkg.FALSE
                 and l_incremental_data_exists = com_api_type_pkg.TRUE
                 and t.oper_id in (select eo.object_id
                                     from evt_event_object eo
                                        , evt_event e
                                        , evt_subscriber s
                                    where decode(eo.status, 'EVST0001', eo.procedure_name, null) = PROC_NAME
                                       and eo.eff_date      <= l_sysdate
                                       and (eo.inst_id = i_inst_id 
                                            or i_inst_id is null
                                            or i_inst_id = ost_api_const_pkg.DEFAULT_INST
                                           )
                                       and eo.entity_type    = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                       and e.id              = eo.event_id
                                       and e.event_type      = s.event_type
                                       and eo.procedure_name = s.procedure_name
                                  )
                )
               )
         order by 
               t.posting_date
             , t.oper_id
             , t.amount
             , t.balance_impact desc
    ) loop
        l_record_count := l_record_count + 1;
        l_record(1) :=  'BDY'       -- Indicates Body Element
            || ',' || l_record_count-- Current/Sequence Number
            || ',' || m.ccy         -- Currency code in alphabets
            || ',' || m.amount      -- Amount
            || ',' || m.lcyamount   -- Amount in local currency(USD)
            || ',' || m.drcr        -- Debit Credit indicator
            || ',' || m.acno        -- Account number
            || ',' || m.acbrn       -- Account Branch
            || ',' || m.txncd       -- Transaction Code
            || ',' || m.valdt       -- Value Date
            || ',' || ''            -- FINCYC Financial Cycle
            || ',' || ''            -- INSTNO Instrument Number
            || ',' || ''            -- PRDCODE Period Code
            || ',' || ''            -- Related Customer, was m.relcust
            || ',' || ''            -- MISCODE MIS Code
            || ',' || m.initdate    -- Related Customer
            || ',' || m.addltext    -- Additional Text
            || ',' || m.extrefno    -- External reference Number
            || ',' || m.batchno     -- Batch Number
            || ',' || m.brn         -- Branch code
            || ',' || ''            -- RELACC Related account
            || ',' || ''            -- RELREF Related reference
            || ',' || m.srccd       -- Source code
            || ',' || m.upldstat    -- Upload status
            ;

        prc_api_file_pkg.put_line(
            i_raw_data      => l_record(1)
          , i_sess_file_id  => l_session_file_id
        );

        prc_api_file_pkg.put_file(
            i_sess_file_id   => l_session_file_id
          , i_clob_content   => l_record(1)
          , i_add_to         => com_api_const_pkg.TRUE
        );

        if i_full_export = com_api_type_pkg.FALSE then
            add_event_collection(
                i_index                  => 1 -- we have only one possible entity type
              , i_entity_tab             => l_entity_tab
              , i_oper_id                => m.oper_id
              , io_event_object_tab      => l_event_object_tab
              , io_event_tab             => l_event_tab
            );
        end if;

        l_record.delete;

        if mod(l_record_count, 100) = 0 then
            prc_api_stat_pkg.log_current (
                i_current_count     => l_record_count
              , i_excepted_count    => 0
            );
        end if;

    end loop;

    prc_api_stat_pkg.log_current(
        i_current_count     => l_record_count
      , i_excepted_count    => 0
    );

    --File trailer:
    l_record(1) := 'TLR,' || l_record_count;

    prc_api_file_pkg.put_line(
        i_raw_data      => l_record(1)
      , i_sess_file_id  => l_session_file_id
    );
    prc_api_file_pkg.put_file(
        i_sess_file_id   => l_session_file_id
      , i_clob_content   => l_record(1)
      , i_add_to         => com_api_const_pkg.TRUE
    );
    l_record.delete;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    if i_full_export = com_api_type_pkg.FALSE then
        add_not_used_event_collection(
            i_entity_tab               => l_entity_tab
          , io_event_object_tab        => l_event_object_tab
          , io_event_tab               => l_event_tab
        );
        if l_event_tab.exists(1) then
            evt_api_event_pkg.process_event_object(
                i_event_object_id_tab => l_event_tab
            );
        end if;
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => 0
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.debug (
        i_text        => LOG_PREFIX || 'Process Finished.'
    );

exception
  when others then
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || 'Finished with errors: [#1]'
      , i_env_param1  => sqlcode
    );

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_processed_total   => l_record_count
      , i_excepted_total    => 1
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
    );

    if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
        raise;
    elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'UNHANDLED_EXCEPTION'
          , i_env_param1  => sqlerrm
        );
    end if;
end export_gl_data;

end cst_pfp_process_pkg;
/
