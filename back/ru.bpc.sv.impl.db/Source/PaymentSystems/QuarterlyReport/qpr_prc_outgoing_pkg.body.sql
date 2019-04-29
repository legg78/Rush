create or replace package body qpr_prc_outgoing_pkg as

BULK_LIMIT      constant integer := 500;

procedure aggregate_mc_iss (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
begin
    delete from qpr_mc_iss_aggr where oper_date between i_start_date and i_end_date and inst_id = i_inst_id;
        
    insert into qpr_mc_iss_aggr (
        id
        , oper_date
        , card_type_id
        , group_name
        , param_name
    ) 
    select /*+ parallel(auto)*/
           id
         , oper_date
         , card_type_id
         , group_name
         , param_name
      from qpr_mc_iss_vw
     where oper_date between i_start_date and i_end_date
       and inst_id = i_inst_id;
end;

procedure aggregate_mc_acq (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
begin
    delete from qpr_mc_acq_aggr where oper_date between i_start_date and i_end_date and inst_id = i_inst_id;
        
    insert into qpr_mc_acq_aggr (
        id
        , oper_date
        , group_name
        , param_name
    ) 
    select /*+ parallel(auto)*/
           id
         , oper_date
         , group_name
         , param_name
      from qpr_mc_acq_vw
     where oper_date between i_start_date and i_end_date
       and inst_id = i_inst_id;
end;

procedure aggregate_visa_iss (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
begin
    delete from qpr_visa_iss_aggr where oper_date between i_start_date and i_end_date and inst_id = i_inst_id;
        
    insert into qpr_visa_iss_aggr (
        id
        , oper_date
        , card_type_id
        , param_name
        , group_name
    ) 
    select /*+ parallel(auto)*/
           id
         , oper_date
         , card_type_id
         , param_name
         , group_name
      from qpr_visa_iss_vw
     where oper_date between i_start_date and i_end_date
       and inst_id = i_inst_id;
end;

procedure aggregate_visa_acq (
    i_start_date               in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
begin
    delete from qpr_visa_acq_aggr where oper_date between i_start_date and i_end_date and inst_id = i_inst_id;
        
    insert into qpr_visa_acq_aggr (
        id
        , oper_date
        , param_name
        , subparam_name
        , group_name
    ) 
    select /*+ parallel(auto)*/
           id
         , oper_date
         , param_name
         , subparam_name
         , group_name
      from qpr_visa_acq_vw
     where oper_date between i_start_date and i_end_date
       and inst_id = i_inst_id;
end;

procedure process_mc_iss (
    i_param_group_id_mc        in com_api_type_pkg.t_long_id
    , i_qpr_card_type_id_mc    in com_api_type_pkg.t_tiny_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
    cursor cu_mc_iss_count is
        select count(*)
          from qpr_mc_iss_aggr mia
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where mia.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_MC_ISSUING', 'PS_MC_MAESTRO')
           and (qp.param_name = mia.param_name or qp.id = substr(mia.param_name, 1, instr(mia.param_name, '.') - 1))
           and qg.id = substr(mia.group_name, 1, instr(mia.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc
           and mia.card_type_id = i_qpr_card_type_id_mc
           and mia.oper_date between i_start_date and i_end_date
           and mia.inst_id = i_inst_id;

    cursor cu_mc_iss is
        select o.id as oper_id
             , o.oper_date
             , qg.group_name
             , qp.param_name
             , decode(opr_api_reversal_pkg.reversal_exists(o.id), 0, 'No', 'Yes') as reversal_exists
             , o.oper_amount/power(10,cur1.exponent) as oper_amount
             , cur1.name as oper_currency
             , nvl(o.sttl_amount, o.oper_amount)/power(10,cur2.exponent) as sttl_amount
             , cur2.name as sttl_currency
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
          from qpr_mc_iss_aggr mia
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where mia.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_MC_ISSUING', 'PS_MC_MAESTRO')
           and (qp.param_name = mia.param_name or qp.id = substr(mia.param_name, 1, instr(mia.param_name, '.') - 1))
           and qg.id = substr(mia.group_name, 1, instr(mia.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc
           and mia.card_type_id = i_qpr_card_type_id_mc
           and mia.oper_date between i_start_date and i_end_date
           and mia.inst_id = i_inst_id
         order by o.id;

    l_record_count           pls_integer                 := 0;
    l_record                 com_api_type_pkg.t_raw_tab;
    l_record_number          com_api_type_pkg.t_integer_tab;
    l_session_file_id        com_api_type_pkg.t_long_id;
    l_operation_id           com_api_type_pkg.t_number_tab;
    l_oper_date              com_api_type_pkg.t_date_tab;
    l_group_name             com_api_type_pkg.t_name_tab;
    l_param_name             com_api_type_pkg.t_name_tab;
    l_reversal_exists        com_api_type_pkg.t_dict_tab;
    l_oper_amount            com_api_type_pkg.t_money_tab;
    l_oper_currency          com_api_type_pkg.t_curr_code_tab;
    l_sttl_amount            com_api_type_pkg.t_money_tab;
    l_sttl_currency          com_api_type_pkg.t_curr_code_tab;
    l_card_number            com_api_type_pkg.t_card_number_tab;
    
    l_figures                com_api_type_pkg.t_name;
begin
    savepoint sp_qpr_mc_iss;

    prc_api_stat_pkg.log_start;

    open cu_mc_iss_count;
    fetch cu_mc_iss_count into l_record_count;
    close cu_mc_iss_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        l_record.delete;
        l_record_number.delete;
        l_record_count := l_record_count + 1;

        l_record(1) := 'MasterCard quarterly reports: set of transactions';
        l_record_number(1) := l_record_count;

        l_record_count := l_record_count + 1;

        select 'Issuing > '||
               get_text (
                   i_table_name     => 'net_card_type'
                   , i_column_name  => 'name'
                   , i_object_id    => i_qpr_card_type_id_mc
               ) || ' > ' ||
               qg.group_name || ' > ' ||
               qp.param_name
          into l_figures
          from qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
         where qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc;

        l_record(2) := 'Type of figures to be detailed: '||l_figures;
        l_record_number(2) := l_record_count;

        l_record_count := l_record_count + 1;

        l_record(3) := 'Reporting period: '||to_char(i_start_date,'dd/mm/yyyy')||' - '||to_char(i_end_date,'dd/mm/yyyy');
        l_record_number(3) := l_record_count;
        
        l_record_count := l_record_count + 1;

        l_record(4) := 'Operation ID;Operation date;Settlement type;Transaction type;Reversal;Transaction amount;Settlement amount;Card mask';
        l_record_number(4) := l_record_count;
        
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_record
          , i_num_tab       => l_record_number
        );

        open cu_mc_iss;
        loop
            fetch cu_mc_iss bulk collect into
                l_operation_id
              , l_oper_date
              , l_group_name
              , l_param_name
              , l_reversal_exists
              , l_oper_amount
              , l_oper_currency
              , l_sttl_amount
              , l_sttl_currency
              , l_card_number
            limit BULK_LIMIT;

            l_record.delete;
            l_record_number.delete;

            for i in 1..l_operation_id.count loop

                l_record(i) :=
                    to_char(l_operation_id(i))                              || ';' ||
                    to_char(l_oper_date(i), 'dd/mm/yyyy hh24:mi:ss')        || ';' ||
                    l_param_name(i)                                         || ';' ||
                    l_group_name(i)                                         || ';' ||
                    l_reversal_exists(i)                                    || ';' ||
                    to_char(l_oper_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_oper_currency(i)                                  || ';' ||
                    to_char(l_sttl_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_sttl_currency(i)                                  || ';' ||
                    l_card_number(i);

                l_record_count     := l_record_count + 1;
                l_record_number(i) := l_record_count;

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number
            );
            prc_api_stat_pkg.increase_current (
                i_current_count       => l_operation_id.count
              , i_excepted_count      => 0
            );

            exit when cu_mc_iss%notfound;
        end loop;

        close cu_mc_iss;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_qpr_mc_iss;
        if cu_mc_iss%isopen then
            close cu_mc_iss;
        end if;

        if cu_mc_iss_count%isopen then
            close cu_mc_iss_count;
        end if;

        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

procedure process_mc_acq (
    i_param_group_id_mc        in com_api_type_pkg.t_long_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
    cursor cu_mc_acq_count is
        select count(*)
          from qpr_mc_acq_aggr maa
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where maa.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_MC_ACQUIRING','PS_MC_ACQ_MAESTRO','PS_MC_CIRRUS_ACQ')
           and (qp.param_name = maa.param_name or qp.id = substr(maa.param_name, 1, instr(maa.param_name, '.') - 1))
           and qg.id = substr(maa.group_name, 1, instr(maa.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc
           and maa.oper_date between i_start_date and i_end_date
           and maa.inst_id = i_inst_id;

    cursor cu_mc_acq is
        select o.id as oper_id
             , o.oper_date
             , qg.group_name
             , qp.param_name
             , decode(opr_api_reversal_pkg.reversal_exists(o.id), 0, 'No', 'Yes') as reversal_exists
             , o.oper_amount/power(10,cur1.exponent) as oper_amount
             , cur1.name as oper_currency
             , nvl(o.sttl_amount, o.oper_amount)/power(10,cur2.exponent) as sttl_amount
             , cur2.name as sttl_currency
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
          from qpr_mc_acq_aggr maa
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where maa.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_MC_ACQUIRING','PS_MC_ACQ_MAESTRO','PS_MC_CIRRUS_ACQ')
           and (qp.param_name = maa.param_name or qp.id = substr(maa.param_name, 1, instr(maa.param_name, '.') - 1))
           and qg.id = substr(maa.group_name, 1, instr(maa.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc
           and maa.oper_date between i_start_date and i_end_date
           and maa.inst_id = i_inst_id
         order by 1;

    l_record_count           pls_integer                 := 0;
    l_record                 com_api_type_pkg.t_raw_tab;
    l_record_number          com_api_type_pkg.t_integer_tab;
    l_session_file_id        com_api_type_pkg.t_long_id;
    l_operation_id           com_api_type_pkg.t_number_tab;
    l_oper_date              com_api_type_pkg.t_date_tab;
    l_group_name             com_api_type_pkg.t_name_tab;
    l_param_name             com_api_type_pkg.t_name_tab;
    l_reversal_exists        com_api_type_pkg.t_dict_tab;
    l_oper_amount            com_api_type_pkg.t_money_tab;
    l_oper_currency          com_api_type_pkg.t_curr_code_tab;
    l_sttl_amount            com_api_type_pkg.t_money_tab;
    l_sttl_currency          com_api_type_pkg.t_curr_code_tab;
    l_card_number            com_api_type_pkg.t_card_number_tab;
    
    l_figures                com_api_type_pkg.t_name;
begin
    savepoint sp_qpr_mc_acq;

    prc_api_stat_pkg.log_start;

    open cu_mc_acq_count;
    fetch cu_mc_acq_count into l_record_count;
    close cu_mc_acq_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        l_record.delete;
        l_record_number.delete;
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'MasterCard quarterly reports: set of transactions'
        );
        
        l_record_count := l_record_count + 1;

        select 'Acquiring > '||
               qg.group_name || ' > ' ||
               qp.param_name
          into l_figures
          from qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
         where qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_mc;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Type of figures to be detailed: '||l_figures
        );
        
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Reporting period: '||to_char(i_start_date,'dd/mm/yyyy')||' - '||to_char(i_end_date,'dd/mm/yyyy')
        );
        
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Operation ID;Operation date;Settlement type;Transaction type;Reversal;Transaction amount;Settlement amount;Card mask'
        );
        
        open cu_mc_acq;
        loop
            fetch cu_mc_acq bulk collect into
                l_operation_id
              , l_oper_date
              , l_group_name
              , l_param_name
              , l_reversal_exists
              , l_oper_amount
              , l_oper_currency
              , l_sttl_amount
              , l_sttl_currency
              , l_card_number
            limit BULK_LIMIT;

            l_record.delete;
            l_record_number.delete;

            for i in 1..l_operation_id.count loop

                l_record(i) :=
                    to_char(l_operation_id(i))                              || ';' ||
                    to_char(l_oper_date(i), 'dd/mm/yyyy hh24:mi:ss')        || ';' ||
                    l_param_name(i)                                         || ';' ||
                    l_group_name(i)                                         || ';' ||
                    l_reversal_exists(i)                                    || ';' ||
                    to_char(l_oper_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_oper_currency(i)                                  || ';' ||
                    to_char(l_sttl_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_sttl_currency(i)                                  || ';' ||
                    l_card_number(i);

                l_record_count     := l_record_count + 1;
                l_record_number(i) := l_record_count;

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number
            );
            prc_api_stat_pkg.increase_current (
                i_current_count       => l_operation_id.count
              , i_excepted_count      => 0
            );

            exit when cu_mc_acq%notfound;
        end loop;

        close cu_mc_acq;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_qpr_mc_acq;
        if cu_mc_acq%isopen then
            close cu_mc_acq;
        end if;

        if cu_mc_acq_count%isopen then
            close cu_mc_acq_count;
        end if;

        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

procedure process_visa_iss (
    i_param_group_id_visa      in com_api_type_pkg.t_long_id
    , i_qpr_card_type_id_visa  in com_api_type_pkg.t_tiny_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
    cursor cu_visa_iss_count is
        select count(*)
          from qpr_visa_iss_aggr via
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where via.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name = 'PS_VISA_ISSUING'
           and qp.param_name = via.param_name
           and qg.id = substr(via.group_name, 1, instr(via.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa
           and via.card_type_id = i_qpr_card_type_id_visa
           and via.oper_date between i_start_date and i_end_date
           and via.inst_id = i_inst_id;

    cursor cu_visa_iss is
        select o.id as oper_id
             , o.oper_date
             , qg.group_name
             , qp.param_name
             , decode(opr_api_reversal_pkg.reversal_exists(o.id), 0, 'No', 'Yes') as reversal_exists
             , o.oper_amount/power(10,cur1.exponent) as oper_amount
             , cur1.name as oper_currency
             , nvl(o.sttl_amount, o.oper_amount)/power(10,cur2.exponent) as sttl_amount
             , cur2.name as sttl_currency
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
          from qpr_visa_iss_aggr via
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where via.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name = 'PS_VISA_ISSUING'
           and qp.param_name = via.param_name
           and qg.id = substr(via.group_name, 1, instr(via.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa
           and via.card_type_id = i_qpr_card_type_id_visa
           and via.oper_date between i_start_date and i_end_date
           and via.inst_id = i_inst_id
         order by o.id;

    l_record_count           pls_integer                 := 0;
    l_record                 com_api_type_pkg.t_raw_tab;
    l_record_number          com_api_type_pkg.t_integer_tab;
    l_session_file_id        com_api_type_pkg.t_long_id;
    l_operation_id           com_api_type_pkg.t_number_tab;
    l_oper_date              com_api_type_pkg.t_date_tab;
    l_group_name             com_api_type_pkg.t_name_tab;
    l_param_name             com_api_type_pkg.t_name_tab;
    l_reversal_exists        com_api_type_pkg.t_dict_tab;
    l_oper_amount            com_api_type_pkg.t_money_tab;
    l_oper_currency          com_api_type_pkg.t_curr_code_tab;
    l_sttl_amount            com_api_type_pkg.t_money_tab;
    l_sttl_currency          com_api_type_pkg.t_curr_code_tab;
    l_card_number            com_api_type_pkg.t_card_number_tab;
    
    l_figures                com_api_type_pkg.t_name;
begin
    savepoint sp_qpr_visa_iss;

    prc_api_stat_pkg.log_start;

    open cu_visa_iss_count;
    fetch cu_visa_iss_count into l_record_count;
    close cu_visa_iss_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        l_record.delete;
        l_record_number.delete;
        l_record_count := l_record_count + 1;

        l_record(1) := 'VISA quarterly reports: set of transactions';
        l_record_number(1) := l_record_count;

        l_record_count := l_record_count + 1;

        select 'Issuing > '||
               get_text (
                   i_table_name     => 'net_card_type'
                   , i_column_name  => 'name'
                   , i_object_id    => i_qpr_card_type_id_visa
               ) || ' > ' ||
               qg.group_name || ' > ' ||
               qp.param_name
          into l_figures
          from qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
         where qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa;

        l_record(2) := 'Type of figures to be detailed: '||l_figures;
        l_record_number(2) := l_record_count;

        l_record_count := l_record_count + 1;

        l_record(3) := 'Reporting period: '||to_char(i_start_date,'dd/mm/yyyy')||' - '||to_char(i_end_date,'dd/mm/yyyy');
        l_record_number(3) := l_record_count;
        
        l_record_count := l_record_count + 1;

        l_record(4) := 'Operation ID;Operation date;Settlement type;Transaction type;Reversal;Transaction amount;Settlement amount;Card mask';
        l_record_number(4) := l_record_count;
        
        prc_api_file_pkg.put_bulk(
            i_sess_file_id  => l_session_file_id
          , i_raw_tab       => l_record
          , i_num_tab       => l_record_number
        );

        open cu_visa_iss;
        loop
            fetch cu_visa_iss bulk collect into
                l_operation_id
              , l_oper_date
              , l_group_name
              , l_param_name
              , l_reversal_exists
              , l_oper_amount
              , l_oper_currency
              , l_sttl_amount
              , l_sttl_currency
              , l_card_number
            limit BULK_LIMIT;

            l_record.delete;
            l_record_number.delete;

            for i in 1..l_operation_id.count loop

                l_record(i) :=
                    to_char(l_operation_id(i))                              || ';' ||
                    to_char(l_oper_date(i), 'dd/mm/yyyy hh24:mi:ss')        || ';' ||
                    l_param_name(i)                                         || ';' ||
                    l_group_name(i)                                         || ';' ||
                    l_reversal_exists(i)                                    || ';' ||
                    to_char(l_oper_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_oper_currency(i)                                  || ';' ||
                    to_char(l_sttl_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_sttl_currency(i)                                  || ';' ||
                    l_card_number(i);

                l_record_count     := l_record_count + 1;
                l_record_number(i) := l_record_count;

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number
            );
            prc_api_stat_pkg.increase_current (
                i_current_count       => l_operation_id.count
              , i_excepted_count      => 0
            );

            exit when cu_visa_iss%notfound;
        end loop;

        close cu_visa_iss;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_qpr_visa_iss;
        if cu_visa_iss%isopen then
            close cu_visa_iss;
        end if;

        if cu_visa_iss_count%isopen then
            close cu_visa_iss_count;
        end if;

        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

procedure process_visa_acq (
    i_param_group_id_visa      in com_api_type_pkg.t_long_id
    , i_start_date             in date
    , i_end_date               in date
    , i_inst_id                in com_api_type_pkg.t_inst_id
)
is
    cursor cu_visa_acq_count is
        select count(*)
          from qpr_visa_acq_aggr vaa
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where vaa.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_VISA_MRC_ACQUIRING','PS_VISA_CASH_ACQUIRING')
           and qp.param_name = vaa.param_name
           and qg.id = substr(vaa.group_name, 1, instr(vaa.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa
           and vaa.oper_date between i_start_date and i_end_date
           and vaa.inst_id = i_inst_id;

    cursor cu_visa_acq is
        select o.id as oper_id
             , o.oper_date
             , qg.group_name
             , qp.param_name
             , decode(opr_api_reversal_pkg.reversal_exists(o.id), 0, 'No', 'Yes') as reversal_exists
             , o.oper_amount/power(10,cur1.exponent) as oper_amount
             , cur1.name as oper_currency
             , nvl(o.sttl_amount, o.oper_amount)/power(10,cur2.exponent) as sttl_amount
             , cur2.name as sttl_currency
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
          from qpr_visa_acq_aggr vaa
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where vaa.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name in ('PS_VISA_MRC_ACQUIRING','PS_VISA_CASH_ACQUIRING')
           and qp.param_name = vaa.param_name
           and qg.id = substr(vaa.group_name, 1, instr(vaa.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa
           and vaa.oper_date between i_start_date and i_end_date
           and vaa.inst_id = i_inst_id
         union all
        select o.id as oper_id
             , o.oper_date
             , qg.group_name
             , qp.param_name
             , decode(opr_api_reversal_pkg.reversal_exists(o.id), 0, 'No', 'Yes') as reversal_exists
             , o.oper_amount/power(10,cur1.exponent) as oper_amount
             , cur1.name as oper_currency
             , nvl(o.sttl_amount, o.oper_amount)/power(10,cur2.exponent) as sttl_amount
             , cur2.name as sttl_currency
             , iss_api_card_pkg.get_card_mask(oc.card_number) as card_number
          from qpr_visa_acq_aggr vaa
             , opr_operation o
             , opr_card oc
             , qpr_group_report qgr
             , qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
             , com_currency cur1
             , com_currency cur2
         where vaa.id = o.id
           and o.id = oc.oper_id
           and oc.participant_type = 'PRTYISS'
           and o.oper_currency = cur1.code
           and nvl(o.sttl_currency, o.oper_currency) = cur2.code
           and qgr.report_name = 'PS_VISA_MRC_ACQUIRING'
           and qp.param_name = vaa.subparam_name
           and qg.id = substr(vaa.group_name, 1, instr(vaa.group_name, '.') - 1)
           and qg.id = qgr.id
           and qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa
           and vaa.oper_date between i_start_date and i_end_date
           and vaa.inst_id = i_inst_id
         order by 1;

    l_record_count           pls_integer                 := 0;
    l_record                 com_api_type_pkg.t_raw_tab;
    l_record_number          com_api_type_pkg.t_integer_tab;
    l_session_file_id        com_api_type_pkg.t_long_id;
    l_operation_id           com_api_type_pkg.t_number_tab;
    l_oper_date              com_api_type_pkg.t_date_tab;
    l_group_name             com_api_type_pkg.t_name_tab;
    l_param_name             com_api_type_pkg.t_name_tab;
    l_reversal_exists        com_api_type_pkg.t_dict_tab;
    l_oper_amount            com_api_type_pkg.t_money_tab;
    l_oper_currency          com_api_type_pkg.t_curr_code_tab;
    l_sttl_amount            com_api_type_pkg.t_money_tab;
    l_sttl_currency          com_api_type_pkg.t_curr_code_tab;
    l_card_number            com_api_type_pkg.t_card_number_tab;
    
    l_figures                com_api_type_pkg.t_name;
begin
    savepoint sp_qpr_visa_acq;

    prc_api_stat_pkg.log_start;

    open cu_visa_acq_count;
    fetch cu_visa_acq_count into l_record_count;
    close cu_visa_acq_count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count     => l_record_count
    );

    if l_record_count > 0 then

        l_record_count := 0;

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
        );

        l_record.delete;
        l_record_number.delete;
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'VISA quarterly reports: set of transactions'
        );
        
        l_record_count := l_record_count + 1;

        select 'Acquiring > '||
               qg.group_name || ' > ' ||
               qp.param_name
          into l_figures
          from qpr_group qg
             , qpr_param_group qpg
             , qpr_param qp
         where qpg.group_id = qg.id
           and qpg.param_id = qp.id
           and qpg.id = i_param_group_id_visa;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Type of figures to be detailed: '||l_figures
        );
        
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Reporting period: '||to_char(i_start_date,'dd/mm/yyyy')||' - '||to_char(i_end_date,'dd/mm/yyyy')
        );
        
        l_record_count := l_record_count + 1;

        prc_api_file_pkg.put_line(
            i_sess_file_id  => l_session_file_id
          , i_raw_data      => 'Operation ID;Operation date;Settlement type;Transaction type;Reversal;Transaction amount;Settlement amount;Card mask'
        );
        
        open cu_visa_acq;
        loop
            fetch cu_visa_acq bulk collect into
                l_operation_id
              , l_oper_date
              , l_group_name
              , l_param_name
              , l_reversal_exists
              , l_oper_amount
              , l_oper_currency
              , l_sttl_amount
              , l_sttl_currency
              , l_card_number
            limit BULK_LIMIT;

            l_record.delete;
            l_record_number.delete;

            for i in 1..l_operation_id.count loop

                l_record(i) :=
                    to_char(l_operation_id(i))                              || ';' ||
                    to_char(l_oper_date(i), 'dd/mm/yyyy hh24:mi:ss')        || ';' ||
                    l_param_name(i)                                         || ';' ||
                    l_group_name(i)                                         || ';' ||
                    l_reversal_exists(i)                                    || ';' ||
                    to_char(l_oper_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_oper_currency(i)                                  || ';' ||
                    to_char(l_sttl_amount(i),'FM999999999999999990.00')     || ' ' ||
                        l_sttl_currency(i)                                  || ';' ||
                    l_card_number(i);

                l_record_count     := l_record_count + 1;
                l_record_number(i) := l_record_count;

            end loop;

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_record
              , i_num_tab       => l_record_number
            );
            prc_api_stat_pkg.increase_current (
                i_current_count       => l_operation_id.count
              , i_excepted_count      => 0
            );

            exit when cu_visa_acq%notfound;
        end loop;

        close cu_visa_acq;

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
    when others then
        rollback to sp_qpr_visa_acq;
        if cu_visa_acq%isopen then
            close cu_visa_acq;
        end if;

        if cu_visa_acq_count%isopen then
            close cu_visa_acq_count;
        end if;

        trc_log_pkg.error(sqlerrm);
        prc_api_stat_pkg.log_end(
            i_result_code   => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        raise;
end;

end;
/
