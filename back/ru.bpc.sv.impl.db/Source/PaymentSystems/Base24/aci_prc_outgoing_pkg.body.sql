create or replace package body aci_prc_outgoing_pkg is
/************************************************************
 * Base24 outgoing files API <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 17.12.2013 <br />
 * Last changed by $Author: necheukhin $ <br />
 * $LastChangedDate:: 2014-05-28 18:38:40 +0300#$ <br />
 * Revision: $LastChangedRevision: 175003 $ <br />
 * Module: aci_prc_outgoing_pkg <br />
 * @headcom
 ************************************************************/
 
    BULK_LIMIT      constant integer := 400;
    
    function get_inst_id (
        i_inst_id               in com_api_type_pkg.t_inst_id
    ) return com_api_type_pkg.t_name is
    begin
        return com_api_array_pkg.conv_array_elem_v (
            i_array_type_id  => aci_api_const_pkg.BASE24_INST_ARRAY_TYPE
            , i_lov_id       => 1
            , i_elem_value   => to_char(i_inst_id)
            , i_mask_error   => com_api_type_pkg.TRUE
        );
    end;
    
    function get_network_id (
        i_network_id            in com_api_type_pkg.t_network_id
    ) return com_api_type_pkg.t_name is
    begin
        return com_api_array_pkg.conv_array_elem_v (
            i_array_type_id  => aci_api_const_pkg.BASE24_NETWORK_ARRAY_TYPE
            , i_lov_id       => 378
            , i_elem_value   => to_char(i_network_id)
            , i_mask_error   => com_api_type_pkg.TRUE
        );
    end;
    
    function get_card_type (
        i_bin                   in com_api_type_pkg.t_bin
    ) return com_api_type_pkg.t_name is
    begin
        return com_api_array_pkg.conv_array_elem_v (
            i_array_type_id  => aci_api_const_pkg.BASE24_CARD_TYPE_ARRAY_TYPE
            , i_lov_id       => 201
            , i_elem_value   => i_bin
            , i_mask_error   => com_api_type_pkg.TRUE
        );
    end;
    
    function get_card_status (
        i_card_status           in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_name is
    begin
        return com_api_array_pkg.conv_array_elem_v (
            i_array_type_id  => aci_api_const_pkg.BASE24_CARD_STATUS_ARRAY_TYPE
            , i_lov_id       => 1003
            , i_elem_value   => i_card_status
            , i_mask_error   => com_api_type_pkg.TRUE
        );
    end;
    
    function get_cardholder_title (
        i_title                 in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_name is
    begin
        return case i_title
        when 'PTTLMSTR' then '1'
        when 'PTTLMRSS' then '2'
        when 'PTTLDCTR' then '5'
        else '0'
        end;
    end;

    function get_date_by_type (
        i_inst_id               in com_api_type_pkg.t_inst_id
        , i_date_type           in com_api_type_pkg.t_dict_value
    ) return date is
    begin
        return 
            case i_date_type
            when com_api_const_pkg.DATE_PURPOSE_PROCESSING then
                get_sysdate
            else -- com_api_const_pkg.DATE_PURPOSE_BANK
                com_api_sttl_day_pkg.get_open_sttl_date (
                    i_inst_id => i_inst_id
                )
            end;
    end;
    
    procedure upload_crdacc (
        i_inst_id               in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date          in date := null
        --, i_end_date            in date := null
        --, i_shift_from          in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to            in com_api_type_pkg.t_tiny_id := 0
        , i_exclude_bin         in com_api_type_pkg.t_name := null
        , i_full_export         in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    ) is
        --l_start_date            date;
        --l_end_date              date;
        l_full_export           com_api_type_pkg.t_boolean := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_card_cur              aci_api_type_pkg.t_event_card_cur;
        l_card_tab              aci_api_type_pkg.t_event_card_tab;
        
        cursor l_events (
            i_proc_session_id   in com_api_type_pkg.t_long_id
        ) is
        select
            v.id
        from
            evt_event_object v
            , evt_event e
        where 
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_CRDACC'
            --and v.eff_date >= nvl(l_start_date, v.eff_date) 
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and (v.proc_session_id = i_proc_session_id or i_proc_session_id is null);

        l_event_object_id         com_api_type_pkg.t_number_tab;

        l_current_count           com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_session_file_id         com_api_type_pkg.t_long_id;
        l_rec_raw                 com_api_type_pkg.t_raw_tab;
        l_rec_num                 com_api_type_pkg.t_integer_tab;

        --l_crc                     integer;

        procedure open_file is
            l_params              com_api_type_pkg.t_param_tab;
        begin
            rul_api_param_pkg.set_param (
                i_name       => 'INST_ID'
                , i_value    => i_inst_id
                , io_params  => l_params
            );
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
                , i_file_type   => aci_api_const_pkg.FILE_TYPE_CAF
                , io_params     => l_params
            );
            --l_session_file_id := 123456;
            --dbms_output.put_line('open_file');
        end;

        procedure close_file (
            i_status              in com_api_type_pkg.t_dict_value
        ) is
        begin
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
                , i_status      => i_status
            );
            --dbms_output.put_line('close_file');
        end;

        procedure put_file is
        begin
            /*for j in 1 .. l_rec_raw.count loop
                dbms_output.put_line('record_number:'||l_rec_num(j));
                dbms_output.put_line(l_rec_raw(j));
            end loop;*/
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end;

        /*function get_date return date is
        begin
            return get_date_by_type (
                i_inst_id      => i_inst_id
                , i_date_type  => i_date_type
            );
        end;*/

    begin
        prc_api_stat_pkg.log_start;

        --l_start_date := trunc(nvl(i_start_date, get_date));
        --if nvl(i_shift_from, 0) != 0 then
        --    l_start_date := l_start_date + nvl(i_shift_from, 0);
        --end if;
        --l_end_date := trunc(nvl(i_end_date, l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;
        --l_end_date := l_end_date + nvl(i_shift_to, 0);

        --trc_log_pkg.debug ('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || com_api_type_pkg.convert_to_char(l_end_date)||']');
        --trc_log_pkg.debug ('i_shift_from[' ||i_shift_from || '] i_shift_to[' || i_shift_to||']');
        
        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => null
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;
                
                forall i in 1 .. l_event_object_id.count
                    update evt_event_object
                       set proc_session_id = get_session_id
                     where id = l_event_object_id(i);
                
                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;
        
        open l_card_cur for
        with ev as (
        select
            v.object_id
            , v.entity_type
            , e.event_type
        from
            evt_event_object v
            , evt_event e
        where 
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_CRDACC'
            --and v.eff_date >= nvl(l_start_date, v.eff_date) 
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and proc_session_id = get_session_id
            and l_full_export = 0 --com_api_type_pkg.FALSE
        )
        , xx as (
        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , iss_card_instance i
        where 
            v.entity_type = /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD
            and i.card_id = v.object_id
        group by
            i.card_id
            
        union

        select
            max(i2.id) keep (dense_rank first order by i2.seq_number desc) object_id
        from
            ev v
            , iss_card_instance i1
            , iss_card_instance i2
        where 
            v.entity_type = /*'ENTTCINS'*/iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            and i1.id = v.object_id
            and i2.card_id = i1.card_id
        group by
            i2.card_id
            
        union

        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) bject_id
        from
            ev v
            , prd_contract t
            , iss_card c
            , iss_card_instance i
        where 
            v.entity_type = /*'ENTTPROD'*/prd_api_const_pkg.ENTITY_TYPE_PRODUCT
            and t.product_id = v.object_id
            and t.id = c.contract_id
            and i.card_id = c.id
        group by
            i.card_id
            
        union
        
        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , acc_account_object a
            , iss_card c
            , iss_card_instance i
        where
            v.entity_type = /*'ENTTACCT'*/acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and a.account_id = v.object_id
            and a.entity_type = /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD
            and c.id = a.object_id
            and c.card_type_id != 1020
            and i.card_id = c.id
        group by
            i.card_id
            
        union
        
        select 
            max(i.id) keep(dense_rank last order by i.seq_number) object_id
        from
            iss_card_instance i
            , iss_card c
        where
            c.id = i.card_id
            and c.inst_id = i_inst_id
            and l_full_export = 1 --com_api_type_pkg.TRUE
        group by
            i.card_id

        )

        select
            oc.id
            , ci.id instance_id
            , oc.inst_id
            , ib.network_id
            , ib.bin
            , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
            , ci.seq_number
            , ci.status
            , ci.iss_date
            , ci.start_date
            , ci.expir_date
            , oc.card_type_id
            , ( select
                    min(cd.pvv)
                from
                    ev v 
                where (
                    (v.entity_type = /*'ENTTCINS'*/iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE and v.event_type in ('EVNT0142')) or
                    (l_full_export = 1/*com_api_type_pkg.TRUE*/)
                    )
                    and v.object_id = ci.id
            ) pvv
                
            , decode(ci.card_id, cp.card_id, cp.status) prev_status
            , decode(ci.card_id, cp.card_id, cp.iss_date) prev_iss_date
            , decode(ci.card_id, cp.card_id, cp.expir_date) prev_expir_date
            
            , (select count(1) from acc_account_object where object_id = oc.id and entity_type = /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD) account_count
            , ( select
                    count(1)
                from
                    iss_product_card_type pd
                where
                    pd.bin_id = ib.id
                    and pd.card_type_id = oc.card_type_id
                    and ci.seq_number between pd.seq_number_low and pd.seq_number_high
                    and pd.emv_appl_scheme_id is not null
            ) is_emv
            
            , com_api_currency_pkg.get_amount_str ( 
                i_amount            => fcl_api_limit_pkg.get_sum_limit('LMTP0129', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_curr_code       => fcl_api_limit_pkg.get_limit_currency('LMTP0129', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_mask_curr_code  => com_api_type_pkg.TRUE
                , i_format_mask     => 'FM999999999999999990'
                , i_mask_error      => com_api_type_pkg.TRUE
            ) spending_limit
            , com_api_currency_pkg.get_amount_str ( 
                i_amount            => fcl_api_limit_pkg.get_sum_limit('LMTP0107', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_curr_code       => fcl_api_limit_pkg.get_limit_currency('LMTP0107', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_mask_curr_code  => com_api_type_pkg.TRUE
                , i_format_mask     => 'FM999999999999999990'
                , i_mask_error      => com_api_type_pkg.TRUE
            ) withdrawals_limit
            , com_api_currency_pkg.get_amount_str ( 
                i_amount            => fcl_api_limit_pkg.get_sum_limit('LMTP0109', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_curr_code       => fcl_api_limit_pkg.get_limit_currency('LMTP0109', /*'ENTTCARD'*/iss_api_const_pkg.ENTITY_TYPE_CARD, oc.id, null, com_api_type_pkg.TRUE)
                , i_mask_curr_code  => com_api_type_pkg.TRUE
                , i_format_mask     => 'FM999999999999999990'
                , i_mask_error      => com_api_type_pkg.TRUE
            ) purchases_limit

            , ( select
                    max(o.oper_date)
                from
                    opr_participant p
                    , opr_operation o
                    , aci_atm_fin f
                where
                    p.card_id = oc.id
                    and p.participant_type = /*'PRTYISS'*/com_api_const_pkg.PARTICIPANT_ISSUER
                    and o.id = p.oper_id
                    and f.id = o.id
            ) atm_card_last_used
            , ( select
                    max(o.oper_date)
                from
                    opr_participant p
                    , opr_operation o
                    , aci_pos_fin f
                where
                    p.card_id = oc.id
                    and p.participant_type = /*'PRTYISS'*/com_api_const_pkg.PARTICIPANT_ISSUER
                    and o.id = p.oper_id
                    and f.id = o.id
            ) pos_card_last_used

            , (select max(extract_date) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'TLF' and is_incoming = 1) atm_last_extr_date
            , (select max(impact_timestamp) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'TLF' and is_incoming = 1) atm_last_imp_date
            , (select max(extract_date) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'PTLF' and is_incoming = 1) pos_last_extr_date
            
            , row_number() over(order by cn.card_number, oc.id, ci.id) rn
            , row_number() over(order by cn.card_number desc, oc.id desc, ci.id desc) rn_desc
            , row_number() over(partition by oc.inst_id order by cn.card_number, oc.id, ci.id) rn_inst
            , row_number() over(partition by oc.inst_id order by cn.card_number desc, oc.id desc, ci.id desc) rn_inst_desc
            
            , count(oc.id) over() cnt
        from
            xx t
            , iss_card_instance ci
            , iss_card_instance cp
            , iss_card oc
            , iss_card_instance_data cd
            , iss_bin ib
            , iss_card_number cn
        where
            ci.id = t.object_id
            and oc.id = ci.card_id
            and cp.id(+) = ci.preceding_card_instance_id
            and cd.card_instance_id(+) = ci.id
            and ib.id = ci.bin_id
            and cn.card_id = oc.id
            and (not regexp_like(ib.bin, i_exclude_bin) or i_exclude_bin is null)
        order by
            cn.card_number
            , oc.id
            , ci.id;
            
        loop
            fetch l_card_cur
            bulk collect into
            l_card_tab
            limit BULK_LIMIT;

            l_rec_raw.delete;
            l_rec_num.delete;

            for i in 1..l_card_tab.count loop

                if l_card_tab(i).record_number = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- set estimated count
                    prc_api_stat_pkg.log_estimation (
                        i_estimated_count  => l_card_tab(i).count
                    );

                    -- open file
                    open_file;

                    -- put header
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record count
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('FH', 2, 2)
                    -- ref^typ Refresh type
                    || com_api_type_pkg.pad_char('1', 1, 1)
                    -- appl Application
                    || com_api_type_pkg.pad_char('CF', 2, 2)
                    -- grp Refresh group
                    || com_api_type_pkg.pad_char('0001', 4, 4)
                    -- tape^dat Tape date
                    || com_api_type_pkg.pad_char(to_char(get_sysdate, 'yyyymmdd'), 8, 8)
                    -- tape^tim Tape time
                    || com_api_type_pkg.pad_number(to_char(get_sysdate, 'hh24mi'), 4, 4)
                    -- ln Logical network
                    || com_api_type_pkg.pad_char('PRO1', 4, 4)
                    -- rel^num Release number
                    || com_api_type_pkg.pad_number(60, 2, 2)
                    -- part^num Partition number
                    || com_api_type_pkg.pad_char(' ', 2, 2)
                    -- ATM
                    -- atm.lst^extr^dat last extracted date
                    || com_api_type_pkg.pad_char(to_char(l_card_tab(i).atm_last_extr_date, 'yymmdd'), 6, 6)
                    -- atm.imp^strt^dat indication impacting date
                    || com_api_type_pkg.pad_char(to_char(l_card_tab(i).atm_last_imp_date, 'yyyymmdd'), 8, 8)
                    -- atm.imp^strt^tim
                    || com_api_type_pkg.pad_char(to_char(l_card_tab(i).atm_last_imp_date, 'hh24missff6'), 12, 12)
                    -- POS
                    -- pos.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(l_card_tab(i).pos_last_extr_date, 'yymmdd'), 6, 6)
                    -- pos.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- pos.imp^strt^tim
                    || com_api_type_pkg.pad_char('', 12, 12)
                    -- TRL
                    -- tlr.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- tlr.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- tlr.imp^strt^tim.byte
                    || com_api_type_pkg.pad_char('', 12, 12)
                    -- imp^typ
                    || com_api_type_pkg.pad_char('1', 1, 1)
                    -- caf^expnt
                    || com_api_type_pkg.pad_char('0', 1, 1)
                    -- pre^auth^support
                    || com_api_type_pkg.pad_char('0', 1, 1)
                    -- user^fld2.byte
                    || com_api_type_pkg.pad_char('', 5, 5)
                    -- TB
                    -- tb.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- tb.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- tb.imp^strt^tim
                    || com_api_type_pkg.pad_char('', 12, 12)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                if l_card_tab(i).record_inst_number = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put block header
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('BH', 2, 2)
                    -- crd^iss FIID of the institution
                    || com_api_type_pkg.pad_char('', 4, 4)
                    -- end^range Account number end range
                    || com_api_type_pkg.pad_char('', 28, 28)
                    -- User field
                    || com_api_type_pkg.pad_char('', 1, 1)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                l_processed_count := l_processed_count + 1;

                -- put body
                l_rec_raw(l_rec_raw.count + 1) :=

                -- CAFXD
                --------
                
                -- segment 0 CAFXBASE-DISPLAY
                
                -- 0 seg0.lgth Segment length
                com_api_type_pkg.pad_number(346, 4, 4)
                -- 4 seg0.cnt Record number
                || com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                -- 13 seg0.prikey.pan PAN
                || com_api_type_pkg.pad_char(l_card_tab(i).card_number, 19, 19)
                -- 32 seg0.prikey.mbr^num Member number for the card
                || com_api_type_pkg.pad_number(0, 3, 3)
                -- 35 seg0.rec^typ Record type
                || com_api_type_pkg.pad_char('C', 1, 1)
                -- 36 seg0.crd^typ Card type
                || com_api_type_pkg.pad_char(get_card_type(l_card_tab(i).bin), 2, 2)
                -- 38 seg0.fiid Institution identifier
                || com_api_type_pkg.pad_char(get_inst_id(l_card_tab(i).inst_id), 4, 4)
                -- 42 seg0.crd^stat Card status
                || com_api_type_pkg.pad_char(get_card_status(l_card_tab(i).card_status), 1, 1)
                -- 43 seg0.pin^ofst PIN verification value
                ||
                case when l_card_tab(i).pvv is null then
                    com_api_type_pkg.pad_char('ZZZZZZZZZZZZZZZZ', 16, 16)
                else
                    com_api_type_pkg.pad_char(com_api_type_pkg.pad_number(l_card_tab(i).pvv, 4, 4), 16, 16)
                end
                -- 59 seg0.ttl^wdl^lmt Maximum amount of purchases and cash withdrawals allowed
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                -- 71 seg0.offl^wdl^lmt Maximum offline withdrawals amount
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                
                -- 83 seg0.ttl^cca^lmt Maximum of cash advances
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 95 seg0.offl^cca^lmt Maximum of cash advances offline
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                
                -- 107 seg0.aggr^lmt Maximum aggregate amount of cash disbursements
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                -- 119 seg0.offl^aggr^lmt Maximum aggregate amount of cash disbursements offline
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                
                -- 131 seg0.first^used^dat Card first used date YYMMDD
                || com_api_type_pkg.pad_char(' ', 6, 6)
                -- 137 seg0.last^reset^dat Card last reset date YYMMDD
                || com_api_type_pkg.pad_char(' ', 6, 6)
                -- 143 seg0.exp^dat Expiration date YYMM
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).card_expir_date, 'yymm'), 4, 4)
                -- 147 seg0.effective^dat Effective date YYMM
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).card_iss_date, 'yymm'), 4, 4)
                -- 151 seg0.user^fld1 Blank
                || com_api_type_pkg.pad_char(null, 1, 1)
                
                -- seg0.scnd^crd^data Reissued card
                -- 152 seg0.scnd^crd^data.exp^dat^2 Expiration date
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).prev_card_expir_date, 'yymm'), 4, 4)
                -- 156 seg0.scnd^crd^data.effective^dat^2 Effective date
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).prev_card_iss_date, 'yymm'), 4, 4)
                -- 160 seg0.scnd^crd^data.crd^stat^2 Card status
                || com_api_type_pkg.pad_char(get_card_status(l_card_tab(i).prev_card_status), 1, 1)
                -- 161 seg0.user^fld2 Blank
                || com_api_type_pkg.pad_char(null, 35, 35)
                -- 196 seg0.user^fld^aci Reserved ACI
                || com_api_type_pkg.pad_char(null, 50, 50)
                -- 246 seg0.user^fld^regn Reserved ACI regional
                || com_api_type_pkg.pad_char(null, 50, 50)
                -- 296 seg0.user^fld^cust Reserved ACI customer use only
                || com_api_type_pkg.pad_char(null, 50, 50)

                -- segment 1 ATMCAFX-DISPLAY
                
                -- 346 seg1.lgth Segment length
                || com_api_type_pkg.pad_number(88, 4, 4)
                -- 350 seg1.use^lmt The maximum number of times the card may be used to withdraw cash via BASE24-atm during a single usage accumulation period
                || com_api_type_pkg.pad_number(9999, 4, 4)
                -- 354 seg1.ttl^wdl^lmt The maximum amount of cash withdrawals allowed against non-credit accounts via BASE24-atm during a single usage accumulation period
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 366 seg1.offl^wdl^lmt The maximum amount of cash withdrawals allowed offline against non-credit accounts via BASE24-atm during a single usage accumulation period
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 378 seg1.ttl^cca^lmt The maximum amount of cash advances allowed against credit accounts via BASE24-atm during a single usage accumulation period
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 390 seg1.offl^cca^lmt The maximum amount of cash advances allowed offline against credit accounts via BASE24-atm during a single usage accumulation period
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 402 seg1.dep^cr^lmt The maximum amount of deposit credit the cardholder is allowed during a single usage accumulation period
                || com_api_type_pkg.pad_number(99999999, 10, 10)
                -- 412 seg1.last^used The date (YYMMDD) the card was last used via BASE24-atm
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).atm_card_last_used, 'YYMMDD'), 6, 6)
                -- 418 seg1.iss^txn^prfl This defines a general profile
                || com_api_type_pkg.pad_char('', 16, 16)
                
                -- segment 2 POSCAFX-DISPLAY
                
                -- 434 seg2.segx^lgth.lgth Segment length
                || com_api_type_pkg.pad_number(140, 4, 4)
                -- 438 seg2.segx^lgth.seg^data.id
                || com_api_type_pkg.pad_number(0, 4, 4)
                -- 442 seg2.segx^lgth.seg^data.b24^rsrvd
                || com_api_type_pkg.pad_number(null, 8, 8)
                -- 450 seg2.ttl^pur^lmt The maximum amount of purchases
                || com_api_type_pkg.pad_number(l_card_tab(i).purchases_limit, 12, 12)
                -- 462 seg2.offl^pur^lmt The maximum amount of purchases offline
                || com_api_type_pkg.pad_number(l_card_tab(i).purchases_limit, 12, 12)
                -- 474 seg2.ttl^cca^lmt The maximum amount of cash advances
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 486 seg2.offl^cca^lmt The maximum amount of cash advances offline
                || com_api_type_pkg.pad_number(l_card_tab(i).withdrawals_limit, 12, 12)
                -- 498 seg2.ttl^wdl^lmt The maximum amount of purchases and cash withdrawals
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                -- 510 seg2.offl^wdl^lmt The maximum amount of purchases and cash withdrawals offline
                || com_api_type_pkg.pad_number(l_card_tab(i).spending_limit, 12, 12)
                -- 522 seg2.use^lmt The maximum number of times the card may be used via BASE24-pos during a single usage accumulation period
                || com_api_type_pkg.pad_number(9999, 4, 4)
                -- 526 seg2.ttl^rfnd^cr^lmt The maximum amount of refunds/replenishment
                || com_api_type_pkg.pad_number(999999999999, 12, 12)
                -- 538 seg2.offl^rfnd^cr^lmt The maximum amount of refunds/replenishment offline
                || com_api_type_pkg.pad_number(999999999999, 12, 12)
                -- 550 seg2.rsn^cde A code indicating the reason the card is restricted.
--Valid values are:
--A = Referral
--B = Maybe
--C = Denial
--D = Signature restricted
--E = Country club
--F = Expired
--G = Commercial
                || com_api_type_pkg.pad_char('', 1, 1)
                -- 551 seg2.last^used The date (YYMMDD) the card was last used via BASE24-pos.
                || com_api_type_pkg.pad_number(to_char(l_card_tab(i).pos_card_last_used, 'YYMMDD'), 6, 6)
                -- 557 seg2.user^fld2 This field is not used and should be blank filled.
                || com_api_type_pkg.pad_char('', 1, 1)
                -- 558 seg2.iss^txn^prfl This defines a general profile
                || com_api_type_pkg.pad_char('', 16, 16)

                -- segment 9 EMVCAFX-DISPLAY
                
                ||
                case
                when l_card_tab(i).is_emv = com_api_type_pkg.FALSE then
                   -- 574 seg9.segx^lgth Segment lenght
                   com_api_type_pkg.pad_number(4, 4, 4)
                
                else
                   -- 574 seg9.segx^lgth Segment lenght
                   --com_api_type_pkg.pad_number(36, 4, 4)
                   com_api_type_pkg.pad_number(24, 4, 4)
                -- 578 seg9.atc^lmt Application Transaction Sequence Number Limit
                || com_api_type_pkg.pad_number(9999, 4, 4)
                -- 582 seg9.send^crd^blk This field determines whether a Card Block script should be sent to the device. 
--N = Do not send CARD BLOCK script command
--Y = Send CARD BLOCK script command.
                || com_api_type_pkg.pad_char('N', 1, 1)
                -- 583 seg9.send^put^data This field determines whether a PUT script command should be sent to the device. 
--N = Do not send PUT DATA script command
--Y = Send PUT DATA script command.
                || com_api_type_pkg.pad_char('N', 1, 1)
                -- 584 seg9.vlcty^lmts Velocity Limits for the card.
                || com_api_type_pkg.pad_number(0, 8, 8)
                -- 592 seg9.send^pin^unblk This field indicates the circumstances under which a "PIN Unblock" script command will be generated and returned by BASE24-atm. 
--0 - No action required
--1 - Implicit
--2 - Explicit 
--3 - Implicit and Explicit
                || com_api_type_pkg.pad_char('3', 1, 1)
                -- 593 seg9.send^pin^chng This field indicates the circumstances under which a "PIN Change" script command will be generated and returned by BASE24-atm.
--0 - Do not send script (current processing)
--1 - An EMV PIN Unblock transaction is received
--2 - An EMV PIN Change transaction is received
--3 - An EMV PIN Unblock transaction or an EMV PIN Change transaction is received.
                || com_api_type_pkg.pad_char('3', 1, 1)
                -- 594 seg9.pin^sync^act This field indicates whether synchronisation of the online and offline PIN is required for the card. 
--0 = PIN synchronisation not required (current processing)
--1 = PIN synchronisation required.
                || com_api_type_pkg.pad_char('1', 1, 1)
                -- 595 seg9.access^script^mgmt^sub^sys This field indicates when to access the Script Management Sub-System. 
--0 - Do not send script Management Sub-System
--1 - Access Script Management Sub-System.
                || com_api_type_pkg.pad_char('0', 1, 1)
                -- 596 seg9.iss^appl^data^frmt PIC X(1).
--0 Use the current value defined in CAF Issuer Application Data Format field
--3 Issuer Application Data format as recommended for Mastercard/Europay (M/Chip 4 format) cards.
                || com_api_type_pkg.pad_char('0', 1, 1)
                -- 597 seg9.action^table^index PIC X(1).
--Valid values are 1 to 4.
                || com_api_type_pkg.pad_char('1', 1, 1)
                -- 598 seg9.cap^apsn^1 This field contains the CAP Application PAN Sequence Number (APSN) of the primary card.
                --|| com_api_type_pkg.pad_char('', 2, 2)
                -- 600 seg9.cap^dki^1 This field contains the CAP Derivation Key Index (DKI) of the primary card.
                --|| com_api_type_pkg.pad_char('00', 2, 2)
                -- 602 seg9.cap^apsn^2 This field contains the CAP Application PAN Sequence Number (APSN) of the secondary card.
                --|| com_api_type_pkg.pad_char('', 2, 2)
                -- 604 seg9.cap^dki^2 This field contains the CAP Derivation Key Index (DKI) of the secondary card.
                --|| com_api_type_pkg.pad_char('00', 2, 2)
                -- 606 seg9.bad^cap^tkn^ovrrd^flg 
                --|| com_api_type_pkg.pad_char('N', 1, 1)
                -- 607 seg9.script^tplt^tag This field specifies the template tag to be used when an issuer script is sent to the card
--0 - Use CPF value
--1 - 71
--2 - 72
                --|| com_api_type_pkg.pad_char('2', 1, 1)
                -- 608 seg9.script^mac^lgth This field specifies the MAC length to be used when an issuer script is sent to the card. 
--0 - Use CPF value
--4 - 4 bytes
--6 - 6 bytes
--8 - 8 bytes
                --|| com_api_type_pkg.pad_char('0', 1, 1)
                -- 609 seg9.user^fld PIC X(1).
                --|| com_api_type_pkg.pad_char('', 1, 1)
                end

                -- segment 12 CRDCAFX-DISPLAY
                -- 610 seg12.seg^lgth Segment lenght
                || com_api_type_pkg.pad_number(6, 4, 4)
                || com_api_type_pkg.pad_number(0, 2, 2)
                
                
                -- segment 17 SSBBCAFX-DISPLAY
                -- seg17.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 18 SSBCCAFX-DISPLAY
                -- seg18.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 19 AVCAFX-DISPLAY
                -- seg19.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 22 PREAUTHCAFX-DISPLAY
                -- seg22.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 23 NCDCAFX-DISPLAY
                -- seg23.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 27 PFRD-TXN-CAFX-DISPLAY
                -- seg27.seg^lgth Segment length
                --|| com_api_type_pkg.pad_number(6, 4, 4)
                --|| com_api_type_pkg.pad_number(0, 2, 2)

                -- segment 31 ACCTCAFX-DISPLAY
                -- seg31.seg^lgth Segment length
                || com_api_type_pkg.pad_number(l_card_tab(i).account_count * 34 + 6, 4, 4)
                -- seg31.acct^cnt Account count
                || com_api_type_pkg.pad_number(l_card_tab(i).account_count, 2, 2)
                ;

                for acct in (
                    select
                        case a.account_type
                            when 'ACTP0100' then '01' -- 01-09 = Checking
                            when 'ACTP0130' then '31' -- 31-39 = Credit
                            else ''
                        end account_type
                        , a.account_number
                        , case a.status
                            when acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE then '3'
                            when acc_api_const_pkg.ACCOUNT_STATUS_CLOSED then '9'
                            when acc_api_const_pkg.ACCOUNT_STATUS_INCOLLECTION then '9'
                            when acc_api_const_pkg.ACCOUNT_STATUS_PENDING then '4'
                            when acc_api_const_pkg.ACCOUNT_STATUS_CREDITS then '4'
                            else ''
                        end account_status
                    from
                        acc_account_object o
                        , acc_account a
                    where
                        o.object_id = l_card_tab(i).card_id
                        and o.entity_type = 'ENTTCARD'
                        and a.id = o.account_id
                ) loop
                    l_rec_raw(l_rec_raw.count) := l_rec_raw(l_rec_raw.count)
                    -- seg31.acct[0:15].typ Account type
                    || com_api_type_pkg.pad_char(acct.account_type, 2, 2)
                    -- seg31.acct[0:15].num Account number
                    || com_api_type_pkg.pad_char(acct.account_number, 19, 19)
                    -- seg31.acct[0:15].stat Account status
                    || com_api_type_pkg.pad_char(acct.account_status, 1, 1)
                    -- seg31.acct[0:15].descr Account description
                    || com_api_type_pkg.pad_char(null, 10, 10)
                    -- seg31.acct[0:15].corp Account corp
                    || com_api_type_pkg.pad_char('', 1, 1)
                    -- seg31.acct[0:15].qual Account qual
                    || com_api_type_pkg.pad_char('', 1, 1);
                end loop;

                l_rec_num(l_rec_num.count + 1) := l_processed_count;

                if l_card_tab(i).record_inst_number_desc = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put block trailer
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^type Record Type
                    || com_api_type_pkg.pad_char('BT', 2, 2)
                    -- amt Verification amount
                    || com_api_type_pkg.pad_number(0, 18, 18)
                    -- num^recs Record number
                    || com_api_type_pkg.pad_number(l_card_tab(i).record_number, 9, 9)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                if l_card_tab(i).record_number_desc = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put trailer
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('FT', 2, 2)
                    -- num^recs Total record number
                    || com_api_type_pkg.pad_number(l_card_tab(i).record_number, 9, 9)
                    -- nxt^file Indicates whether another input file follows
                    || com_api_type_pkg.pad_char('0', 1, 1)
                    -- user^fld1 User field
                    || com_api_type_pkg.pad_char('', 3, 3)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;
            end loop;

            l_current_count := l_current_count + l_card_tab.count;

            -- put file record
            put_file;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
                , i_excepted_count  => 0
            );

            exit when l_card_cur%notfound;
        end loop;
        close l_card_cur;

        -- process event object
        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => get_session_id
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;
                
                evt_api_event_pkg.process_event_object (
                    i_event_object_id_tab => l_event_object_id
                );
                
                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;

        -- close file
        if l_current_count != 0 then
            close_file (
                i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        else
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_current_count
            );
        end if;
        prc_api_stat_pkg.log_end (
            i_processed_total  => l_current_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            if l_card_cur%isopen then
                close l_card_cur;
            end if;
            
            if l_session_file_id is not null then
                close_file (
                    i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;
    
    procedure upload_mmf (
        i_inst_id               in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date          in date := null
        --, i_end_date            in date := null
        --, i_shift_from          in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to            in com_api_type_pkg.t_tiny_id := 0
        , i_full_export         in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    ) is
        --l_start_date            date;
        --l_end_date              date;
        l_full_export           com_api_type_pkg.t_boolean := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_merchant_cur          aci_api_type_pkg.t_event_merchant_cur;
        l_merchant_tab          aci_api_type_pkg.t_event_merchant_tab;
        l_sysdate               date;
        
        cursor l_events (
            i_proc_session_id   in com_api_type_pkg.t_long_id
        ) is
        select
            v.id
        from
            evt_event_object v
            , evt_event e
        where
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF'
            --and v.eff_date >= nvl(l_start_date, v.eff_date)
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and (v.proc_session_id = i_proc_session_id or i_proc_session_id is null);

        l_event_object_id         com_api_type_pkg.t_number_tab;
        
        l_current_count           com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_session_file_id         com_api_type_pkg.t_long_id;
        l_rec_raw                 com_api_type_pkg.t_raw_tab;
        l_rec_num                 com_api_type_pkg.t_integer_tab;

        procedure open_file is
            l_params              com_api_type_pkg.t_param_tab;
        begin
            rul_api_param_pkg.set_param (
                i_name       => 'INST_ID'
                , i_value    => i_inst_id
                , io_params  => l_params
            );
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
                , i_file_type   => aci_api_const_pkg.FILE_TYPE_MMF
                , io_params     => l_params
            );
        end;

        procedure close_file (
            i_status              in com_api_type_pkg.t_dict_value
        ) is
        begin
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
                , i_status      => i_status
            );
        end;

        procedure put_file is
        begin
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end;

        /*function get_date return date is
        begin
            return get_date_by_type (
                i_inst_id      => i_inst_id
                , i_date_type  => i_date_type
            );
        end;*/

    begin
        prc_api_stat_pkg.log_start;

        l_sysdate := com_api_sttl_day_pkg.get_sysdate;

        --l_start_date := trunc(nvl(i_start_date, get_date));
        --if nvl(i_shift_from, 0) != 0 then
        --    l_start_date := l_start_date + nvl(i_shift_from, 0);
        --end if;
        --l_end_date := trunc(nvl(i_end_date, l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;
        --l_end_date := l_end_date + nvl(i_shift_to, 0);

        --trc_log_pkg.debug ('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || com_api_type_pkg.convert_to_char(l_end_date)||']');
        --trc_log_pkg.debug ('i_shift_from[' ||i_shift_from || '] i_shift_to[' || i_shift_to||']');

        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => null
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;
                
                forall i in 1 .. l_event_object_id.count
                    update evt_event_object
                       set proc_session_id = get_session_id
                     where id = l_event_object_id(i);
                
                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;
        
        open l_merchant_cur for
        with ev as (
        select
            v.object_id
            , v.entity_type
            , e.event_type
        from
            evt_event_object v
            , evt_event e
        where
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_MMF'
            --and v.eff_date >= nvl(l_start_date, v.eff_date)
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and proc_session_id = get_session_id
            and l_full_export = 0 --com_api_type_pkg.FALSE
        )
        , xx as (
        select
            m.id object_id
        from
            ev v
            , acq_merchant m
        where
            v.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
            and m.id = v.object_id

        union

        select
            m.id object_id
        from
            ev v
            , prd_contract t
            , acq_merchant m
        where
            v.entity_type = 'ENTTPROD' --prd_api_const_pkg.ENTITY_TYPE_PRODUCT
            and t.product_id = v.object_id
            and t.id = m.contract_id

        union

        select
            m.id object_id
        from
            ev v
            , acc_account_object a
            , acq_merchant m
        where
            v.entity_type = 'ENTTACCT' --acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and a.account_id = v.object_id
            and a.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
            and m.id = a.object_id
            
        union
        
        select
            m.id object_id
        from
            acq_merchant m
        where
            m.inst_id = i_inst_id
            and l_full_export = 1 --com_api_type_pkg.TRUE
        )
        select
            m.id
            , m.merchant_number
            , m.merchant_name
            , m.merchant_label
            , m.status
            , m.inst_id
            , m.mcc
            , ( select
                    com_api_i18n_pkg.get_text('com_mcc', 'name', id)
                from
                    com_mcc 
                where
                    mcc = m.mcc
                    and rownum = 1
            ) mcc_name
            
            , ad.country
            , ad.region_code
            , ad.city
            , ad.street
            , ad.house
            , ad.postal_code
            
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd 
                where
                    ct.id = co.contact_id 
                    and co.contact_type = 'CNTTCEOC'
                    and co.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                    and co.object_id = m.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0001'  -- com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) primary_mobile
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd 
                where
                    ct.id = co.contact_id 
                    and co.contact_type = 'CNTTSCNC'
                    and co.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                    and co.object_id = m.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0001'  --com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) secondary_mobile
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd 
                where
                    ct.id = co.contact_id 
                    and co.contact_type = 'CNTTCEOC' --com_api_const_pkg.CONTACT_TYPE_PRIMARY
                    and co.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                    and co.object_id = m.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0002'  --com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) email
            , com_ui_person_pkg.get_person_name(m.person_id, m.lang) contact_name
            
            , ac.account_number
            , ab.open_date account_open_date
            , ab.close_date account_close_date
            , (select min(posting_date) from acc_entry where account_id = ac.id) fist_operation
            , (select max(posting_date) from acc_entry where account_id = ac.id) last_operation
            , (select max(amount) keep(dense_rank last order by posting_date) from acc_entry where account_id = ac.id) last_amount
            , cu.customer_number
            
            , row_number() over(order by m.inst_id, m.merchant_number) rn
            , row_number() over(order by m.inst_id desc, m.merchant_number desc) rn_desc
            , row_number() over(partition by m.inst_id order by m.inst_id, m.merchant_number) rn_inst
            , row_number() over(partition by m.inst_id order by m.inst_id desc, m.merchant_number desc) rn_inst_desc
            
            , count(m.id) over() cnt
        from (
            select
                m.*
                , get_text('acq_merchant', 'label', m.id) merchant_label
                , acq_api_merchant_pkg.get_merchant_account_id(m.id) account_id
                , acq_api_merchant_pkg.get_merchant_address_id(m.id) address_id
                , l.lang
                , ( select
                        min(ct.person_id) keep(dense_rank first order by decode(co.contact_type,'CNTTCEOC', 1, 2))
                    from
                        com_contact_object co
                        , com_contact ct
                    where
                        co.object_id = m.id
                        and co.entity_type = 'ENTTMRCH' --acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                        and ct.id = co.contact_id
                ) person_id
            from
                xx t
                , acq_merchant m
                , ( select nvl(com_ui_user_env_pkg.get_user_lang, 'LANGENG') lang from dual) l
            where
                t.object_id = m.id
            ) m
            , prd_contract ct
            , prd_customer cu
            , acc_account ac
            , acc_balance ab
            , com_address ad
        where
            ad.id(+) = m.address_id
            and ad.lang(+) = m.lang
            and ac.id(+) = m.account_id
            and ab.account_id(+) = ac.id
            and ab.balance_type(+) = 'BLTP0001' --acc_api_const_pkg.BALANCE_TYPE_LEDGER
            and ct.id = m.contract_id
            and cu.id = ct.customer_id
        order by
            m.inst_id
            , m.merchant_number;
            
        loop
            fetch l_merchant_cur
            bulk collect into
            l_merchant_tab
            limit BULK_LIMIT;

            l_rec_raw.delete;
            l_rec_num.delete;

            for i in 1..l_merchant_tab.count loop

                if l_merchant_tab(i).record_number = 1 then
                    -- set estimated count
                    prc_api_stat_pkg.log_estimation (
                        i_estimated_count  => l_merchant_tab(i).count
                    );

                    -- open file
                    open_file;
                end if;
                
                l_processed_count := l_processed_count + 1;

                -- put body
                l_rec_raw(l_rec_raw.count + 1) := 
                -- 1 fiid Institution identifier
                com_api_type_pkg.pad_char(get_inst_id(l_merchant_tab(i).inst_id), 4, 4)
                -- 5 retl-id Indentifies the retailer or merchant that owns
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_number, 19, 19)
                -- 24 retl-clas Classify retailers
                || com_api_type_pkg.pad_char(null, 15, 15)
                -- 39 filter-fld Filter
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_number, 15, 15)
                -- 54 retl-dba-nam Merchant doing business as name
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_label, 40, 40)
                -- 94 retl-bus-nam Merchant business name
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_name, 40, 40)
                -- 134 store-num Store Number
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_number, 9, 9)
                -- 143 sic-code Standard industrial classification code
                || com_api_type_pkg.pad_char(l_merchant_tab(i).mcc, 4, 4)
                -- 147 e-com-ind E-commerce transactions accept
                || com_api_type_pkg.pad_char(null, 2, 2)
                -- 149 retl-addr-1 First line of the retailer's street address
                || com_api_type_pkg.pad_char(l_merchant_tab(i).city, 40, 40)
                -- 189 retl-addr-2 Second line of the retailer's street address
                || com_api_type_pkg.pad_char(l_merchant_tab(i).street, 40, 40)
                -- 229 retl-city Retailers city
                || com_api_type_pkg.pad_char(l_merchant_tab(i).city, 30, 30)
                -- 259 retl-st Retailers state
                || com_api_type_pkg.pad_char(l_merchant_tab(i).region_code, 3, 3)
                -- 262 retl-cntry Retailers country
                || com_api_type_pkg.pad_char(l_merchant_tab(i).country, 3, 3)
                -- 265 retl-postal-cde Retailers post code
                || com_api_type_pkg.pad_char(l_merchant_tab(i).postal_code, 16, 16)
                -- 281 cntct-nam Merchant contact name
                || com_api_type_pkg.pad_char(l_merchant_tab(i).contact_name, 40, 40)
                -- 321 cntct-phn-1 Merchant phone
                || com_api_type_pkg.pad_char(l_merchant_tab(i).primary_mobile, 20, 20)
                -- 341 cntct-phn-2 Merchant phone 2
                || com_api_type_pkg.pad_char(l_merchant_tab(i).secondary_mobile, 20, 20)
                -- 361 cntct-email-addr Merchant email
                || com_api_type_pkg.pad_char(l_merchant_tab(i).email, 40, 40)
                -- 401 stat Merchant status
                || com_api_type_pkg.pad_char(case when l_merchant_tab(i).merchant_status = acq_api_const_pkg.MERCHANT_STATUS_CLOSED then 'C' else 'O' end, 1, 1)
                -- 402 actvty-stat  Merchant activity status
                || com_api_type_pkg.pad_char(case when l_merchant_tab(i).merchant_status = acq_api_const_pkg.MERCHANT_STATUS_ACTIVE then '1' else '0' end, 1, 1)
                -- 403 opn-dat Account open date
                || com_api_type_pkg.pad_char(to_char(l_merchant_tab(i).account_open_date, 'ccyymmdd'), 8, 8)
                -- 411 first-actv-dat Account first operation date
                || com_api_type_pkg.pad_number(to_char(l_merchant_tab(i).fist_operation, 'ccyymmdd'), 8, 8)
                -- 419 last-actv-dat Account last operation date
                || com_api_type_pkg.pad_number(to_char(l_merchant_tab(i).last_operation, 'ccyymmdd'), 8, 8)
                -- 427 last-actv-amt Operation amount
                || com_api_type_pkg.pad_number(l_merchant_tab(i).last_amount, 16, 16)
                -- 443 clos-dat Account close date
                || com_api_type_pkg.pad_number(to_char(l_merchant_tab(i).account_close_date, 'ccyymmdd'), 8, 8)
                -- 451 clos-rsn-cde Reason code when account close
                || com_api_type_pkg.pad_char(null, 2, 2)
                -- 453 seasnl-cde Seasonal Code
                || com_api_type_pkg.pad_char(null, 1, 1)
                -- 454 own-typ Ownership type
                || com_api_type_pkg.pad_char(null, 1, 1)
                -- 455 own-chng-dat Ownership change date
                || com_api_type_pkg.pad_char(to_char(sysdate, 'ccyymmdd'), 8, 8)
                -- 463 own-nam Owner name
                || com_api_type_pkg.pad_char(null, 40, 40)
                -- 503 own-govt-id Owner government id
                || com_api_type_pkg.pad_char(null, 20, 20)
                -- 523 fi-ind Internal identifier
                || com_api_type_pkg.pad_char(null, 10, 10)
                -- 533 cust-num-1 Customer number 1
                || com_api_type_pkg.pad_char(l_merchant_tab(i).merchant_number, 20, 20)
                -- 553 cust-num-2 Customer number 2
                || com_api_type_pkg.pad_char(null, 20, 20)
                -- 573 setl-acct-detl-1 Settlement account 1
                || com_api_type_pkg.pad_char(null, 25, 25)
                -- 598 setl-acct-detl-2 Settlement account 2
                || com_api_type_pkg.pad_char(null, 25, 25)
                -- 623 expect-yy-vol Expected annual volume
                || com_api_type_pkg.pad_number(null, 16, 16)
                -- 639 expect-mm-vol Expected monthly volume
                || com_api_type_pkg.pad_number(null, 16, 16)
                -- 655 flr-lmt Floor limit
                || com_api_type_pkg.pad_number(null, 12, 12)
                -- 667 norm-bus-hh-strt Normal business hours start time
                || com_api_type_pkg.pad_number(null, 4, 4)
                -- 671 norm-bus-hh-end Normal business hours end time
                || com_api_type_pkg.pad_number(null, 4, 4)
                
                -- 675-872
                || com_api_type_pkg.pad_char(null, 198, 198)
                
                -- 873 expect-yy-vol-num Expected annual number of sales
                || com_api_type_pkg.pad_number(null, 8, 8)
                -- 881 expect-mm-vol-num expected monthly number of sales
                || com_api_type_pkg.pad_number(null, 8, 8)
                -- 889 typ-good-serv Primary goods or services offered 
                || com_api_type_pkg.pad_char(l_merchant_tab(i).mcc_name, 19, 19)
                -- 908 cust-mstr-amt Amount field to hold user-defined amount.              
                || com_api_type_pkg.pad_number(null, 16, 16)
                -- 924 cust-mstr-dat Date field to hold user-defined date
                || com_api_type_pkg.pad_char(null, 8, 8)
                -- 932 cust-mstr-fld1 Alphanumeric field to hold user-defined data
                || com_api_type_pkg.pad_char(null, 2, 2)
                -- 934 cust-mstr-fld2 Alphanumeric field to hold user-defined data
                || com_api_type_pkg.pad_char(null, 4, 4)
                ;
                
                l_rec_num(l_rec_num.count + 1) := l_processed_count;
            end loop;

            l_current_count := l_current_count + l_merchant_tab.count;

            -- put file record
            put_file;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
                , i_excepted_count  => 0
            );

            exit when l_merchant_cur%notfound;
        end loop;
        close l_merchant_cur;

        -- process event object
        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => get_session_id
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;

                evt_api_event_pkg.process_event_object (
                    i_event_object_id_tab => l_event_object_id
                );

                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;

        -- close file
        if l_current_count != 0 then
            close_file (
                i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        else
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_current_count
            );
        end if;
        prc_api_stat_pkg.log_end (
            i_processed_total  => l_current_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            if l_merchant_cur%isopen then
                close l_merchant_cur;
            end if;
            
            if l_session_file_id is not null then
                close_file (
                    i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;
    
    procedure upload_semf (
        i_inst_id               in com_api_type_pkg.t_inst_id
        --, i_date_type           in com_api_type_pkg.t_dict_value
        --, i_start_date          in date := null
        --, i_end_date            in date := null
        --, i_shift_from          in com_api_type_pkg.t_tiny_id := 0
        --, i_shift_to            in com_api_type_pkg.t_tiny_id := 0
        , i_exclude_bin         in com_api_type_pkg.t_name := null
        , i_full_export         in com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE
    ) is
        --l_start_date            date;
        --l_end_date              date;
        l_full_export           com_api_type_pkg.t_boolean := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_cardholder_cur        aci_api_type_pkg.t_event_cardholder_cur;
        l_cardholder_tab        aci_api_type_pkg.t_event_cardholder_tab;
        l_sysdate               date;
        
        cursor l_events (
            i_proc_session_id   in com_api_type_pkg.t_long_id
        ) is
        select
            v.id
        from
            evt_event_object v
            , evt_event e
        where
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_SEMF'
            --and v.eff_date >= nvl(l_start_date, v.eff_date)
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and (v.proc_session_id = i_proc_session_id or i_proc_session_id is null);

        l_event_object_id         com_api_type_pkg.t_number_tab;

        l_current_count           com_api_type_pkg.t_long_id := 0;
        l_processed_count         com_api_type_pkg.t_long_id := 0;
        l_session_file_id         com_api_type_pkg.t_long_id;
        l_rec_raw                 com_api_type_pkg.t_raw_tab;
        l_rec_num                 com_api_type_pkg.t_integer_tab;

        procedure open_file is
            l_params              com_api_type_pkg.t_param_tab;
        begin
            rul_api_param_pkg.set_param (
                i_name       => 'INST_ID'
                , i_value    => i_inst_id
                , io_params  => l_params
            );
            prc_api_file_pkg.open_file (
                o_sess_file_id  => l_session_file_id
                , i_file_type   => aci_api_const_pkg.FILE_TYPE_SEMF
                , io_params     => l_params
            );
        end;

        procedure close_file (
            i_status              com_api_type_pkg.t_dict_value
        ) is
        begin
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
                , i_status      => i_status
            );
        end;

        procedure put_file is
        begin
            prc_api_file_pkg.put_bulk (
                i_sess_file_id  => l_session_file_id
                , i_raw_tab     => l_rec_raw
                , i_num_tab     => l_rec_num
            );
            l_rec_raw.delete;
            l_rec_num.delete;
        end;

        /*function get_date return date is
        begin
            return get_date_by_type (
                i_inst_id      => i_inst_id
                , i_date_type  => i_date_type
            );
        end;*/

    begin
        prc_api_stat_pkg.log_start;

        l_sysdate := com_api_sttl_day_pkg.get_sysdate;

        --l_start_date := trunc(nvl(i_start_date, get_date));
        --if nvl(i_shift_from, 0) != 0 then
        --    l_start_date := l_start_date + nvl(i_shift_from, 0);
        --end if;
        --l_end_date := trunc(nvl(i_end_date, l_start_date)) + 1 - com_api_const_pkg.ONE_SECOND;
        --l_end_date := l_end_date + nvl(i_shift_to, 0);

        --trc_log_pkg.debug ('start_date[' ||com_api_type_pkg.convert_to_char(l_start_date) || '] l_end_date[' || com_api_type_pkg.convert_to_char(l_end_date)||']');
        --trc_log_pkg.debug ('i_shift_from[' ||i_shift_from || '] i_shift_to[' || i_shift_to||']');

        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => null
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;
                
                forall i in 1 .. l_event_object_id.count
                    update evt_event_object
                       set proc_session_id = get_session_id
                     where id = l_event_object_id(i);
                
                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;
        
        open l_cardholder_cur for
        with ev as (
        select
            v.object_id
            , v.entity_type
            , e.event_type
        from
            evt_event_object v
            , evt_event e
        where
            decode(v.status, 'EVST0001', v.procedure_name, null) = 'ACI_PRC_OUTGOING_PKG.UPLOAD_SEMF'
            --and v.eff_date >= nvl(l_start_date, v.eff_date)
            --and v.eff_date <= l_end_date
            and v.inst_id = i_inst_id
            and v.event_id = e.id
            and proc_session_id = get_session_id
            and l_full_export = 0 --com_api_type_pkg.FALSE
        )
        , xx as (
        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , iss_card_instance i
        where
            v.entity_type = 'ENTTCARD' --iss_api_const_pkg.ENTITY_TYPE_CARD
            and i.card_id = v.object_id
        group by
            i.card_id

        union

        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , iss_card_instance i
        where
            v.entity_type = 'ENTTCINS' --iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
            and i.id = v.object_id
        group by
            i.card_id

        union

        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , prd_contract t
            , iss_card c
            , iss_card_instance i
        where
            v.entity_type = 'ENTTPROD' --prd_api_const_pkg.ENTITY_TYPE_PRODUCT
            and t.product_id = v.object_id
            and t.id = c.contract_id
            and i.card_id = c.id
        group by
            i.card_id

        union

        select
            max(i.id) keep (dense_rank first order by i.seq_number desc) object_id
        from
            ev v
            , acc_account_object a
            , iss_card c
            , iss_card_instance i
        where
            v.entity_type = 'ENTTACCT' --acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
            and a.account_id = v.object_id
            and a.entity_type = 'ENTTCARD' --iss_api_const_pkg.ENTITY_TYPE_CARD
            and c.id = a.object_id
            and c.card_type_id != 1020
            and i.card_id = c.id
        group by
            i.card_id
            
        union
        
        select 
            max(i.id) keep(dense_rank last order by i.seq_number) object_id
        from
            iss_card_instance i
            , iss_card c
        where
            c.id = i.card_id
            and c.inst_id = i_inst_id
            and l_full_export = 1 --com_api_type_pkg.TRUE
        group by
            i.card_id

        )
        select
            oc.id
            , iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number
            , iss_api_token_pkg.decode_card_number(i_card_number => cnp.card_number) as prev_card_number
            , oc.inst_id
            , ib.bin

            , ch.cardholder_name
            , ( select
                    max(first_name || nvl2(second_name,  ' ' || second_name, null) || ' ' || surname) keep(dense_rank first order by decode(lang, get_user_lang, 1, 'LANGENG', 2, 3))
                from
                    com_person
                where
                    id = ch.person_id
            ) person_name
            , ( select
                    max(id_number) keep(dense_rank first order by id desc)
                from
                    com_id_object
                where
                    entity_type = com_api_const_pkg.ENTITY_TYPE_PERSON
                    and object_id = ch.person_id
                    and id_type = 'IDTP0045'
            ) national_id
            , ( select
                    min(p.birthday) keep(dense_rank first order by decode(p.lang, get_user_lang, 1, 'LANGENG', 2, 3))
                from
                    com_person p
                where
                    p.id = ch.person_id
            ) person_birth_date
            , ad.street
            , ad.house
            , ad.city
            , ad.country
            , ad.region_code
            , ad.postal_code
            , to_char(null) home_phone
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd
                where
                    ct.id = co.contact_id
                    and co.contact_type = 'CNTTSCNC' 
                    and co.entity_type = 'ENTTCRDH' --iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                    and co.object_id = ch.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0004'
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) work_phone
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd
                where
                    ct.id = co.contact_id
                    and co.contact_type = 'CNTTPRMC' --com_api_const_pkg.CONTACT_TYPE_PRIMARY
                    and co.entity_type = 'ENTTCRDH' --iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                    and co.object_id = ch.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0001'
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) mobile_mobile
            , ( select
                    min(cd.commun_address) keep(dense_rank first order by cd.start_date desc)
                from
                    com_contact ct, com_contact_object co, com_contact_data cd
                where
                    ct.id = co.contact_id
                    and co.contact_type = 'CNTTPRMC' --com_api_const_pkg.CONTACT_TYPE_PRIMARY
                    and co.entity_type = 'ENTTCRDH' --iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                    and co.object_id = cm.id
                    and ct.id = cd.contact_id
                    and cd.commun_method = 'CMNM0002'  --com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                    and (cd.end_date is null or cd.end_date > l_sysdate)
            ) email
            , cm.customer_number
            , ci.reg_date
            , ci.iss_date
            , count(ci.id) over (partition by ci.card_id) card_issued
            , ( select
                    b.open_date
                from
                    acc_balance b
                where
                    b.account_id = ac.account_id
                    and b.balance_type = 'BLTP0001' --acc_api_const_pkg.BALANCE_TYPE_LEDGER
            ) account_open_date
            
            , ( select
                    max(ol.oper_date) keep(dense_rank first order by ol.oper_date desc)
                from
                    opr_card cl
                    , opr_operation ol
                where
                    reverse(cl.card_number) = reverse(cn.card_number)
                    and ol.id = cl.oper_id
            ) last_card_request
            , ( select
                    max(ol.oper_date) keep(dense_rank first order by ol.oper_date desc)
                from
                    opr_card cl
                    , opr_operation ol
                where
                    reverse(cl.card_number) = reverse(cn.card_number)
                    and ol.id = cl.oper_id
                    and ol.oper_type = opr_api_const_pkg.OPERATION_TYPE_PIN_CHANGE
            ) last_pin_change

            , (select max(extract_date) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'TLF' and is_incoming = 1) atm_last_extr_date
            , (select max(impact_timestamp) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'TLF' and is_incoming = 1) atm_last_imp_date
            , (select max(extract_date) keep (dense_rank first order by extract_date desc) from aci_file where file_type = 'PTLF' and is_incoming = 1) pos_last_extr_date
            
            , row_number() over(order by cn.card_number asc, oc.id asc, ci.id asc) rn
            , row_number() over(order by cn.card_number desc, oc.id desc, ci.id desc) rn_desc
            , row_number() over(partition by oc.inst_id order by cn.card_number, oc.id, ci.id) rn_inst
            , row_number() over(partition by oc.inst_id order by cn.card_number desc, oc.id desc, ci.id desc) rn_inst_desc

            , count(oc.id) over() cnt
        from
            xx t
            , iss_card_instance ci
            , iss_card_instance cp
            , iss_card oc
            , iss_card_number cn
            , iss_bin ib
            , iss_card op
            , iss_card_number cnp
            , iss_cardholder ch
            , prd_customer cm
            , ( select
                    ca.id
                    , ca.lang
                    , cu.name country
                    , ca.region
                    , ca.city
                    , ca.street
                    , ca.house
                    , ca.apartment
                    , ca.postal_code
                    , ca.region_code
                    , ob.object_id
                    , row_number() over (partition by ob.object_id order by ob.address_id) rn
                from
                    com_address_vw ca
                    , com_address_object_vw ob
                    , com_country cu
                where
                    ca.id = ob.address_id
                    and ob.entity_type = 'ENTTCRDH' --iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
                    and cu.code(+) = ca.country
            ) ad
            , ( select
                    a.id account_id
                    , a.account_number
                    , o.object_id
                    , row_number() over (partition by o.object_id order by a.id desc) rn
                from
                    acc_account a
                    , acc_account_object o
                where
                    o.entity_type = 'ENTTCARD' --iss_api_const_pkg.ENTITY_TYPE_CARD
                    and o.account_id = a.id
            ) ac
        where
            ci.id = t.object_id
            and oc.id = ci.card_id
            and oc.id = cn.card_id
            and cp.id(+) = ci.preceding_card_instance_id
            and op.id(+) = cp.card_id
            and op.id(+) = cnp.card_id
            and ib.id = ci.bin_id
            and ch.id = oc.cardholder_id
            and cm.id = oc.customer_id
            and ad.object_id(+) = oc.cardholder_id
            and ad.rn(+) = 1
            and ac.object_id(+) = oc.id
            and ac.rn(+) = 1
            and (not regexp_like(ib.bin, i_exclude_bin) or i_exclude_bin is null)
        order by
            cn.card_number
            , oc.id
            , ci.id;
            
        loop
            fetch l_cardholder_cur
            bulk collect into
            l_cardholder_tab
            limit BULK_LIMIT;

            l_rec_raw.delete;
            l_rec_num.delete;

            for i in 1..l_cardholder_tab.count loop
                if l_cardholder_tab(i).record_number = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- set estimated count
                    prc_api_stat_pkg.log_estimation (
                        i_estimated_count  => l_cardholder_tab(i).count
                    );

                    -- open file
                    open_file;

                    -- put header
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record count
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('FH', 2, 2)
                    -- ref^typ Refresh type
                    || com_api_type_pkg.pad_char('1', 1, 1)
                    -- appl Application
                    || com_api_type_pkg.pad_char('SM', 2, 2)
                    -- grp Refresh group
                    || com_api_type_pkg.pad_char('0001', 4, 4)
                    -- tape^dat Tape date
                    || com_api_type_pkg.pad_char(to_char(get_sysdate, 'yyyymmdd'), 8, 8)
                    -- tape^tim Tape time
                    || com_api_type_pkg.pad_number(to_char(get_sysdate, 'hh24mi'), 4, 4)
                    -- ln Logical network
                    || com_api_type_pkg.pad_char('PRO1', 4, 4)
                    -- rel^num Release number
                    || com_api_type_pkg.pad_number(60, 2, 2)
                    -- part^num Partition number
                    || com_api_type_pkg.pad_char(' ', 2, 2)
                    -- ATM
                    -- atm.lst^extr^dat last extracted date
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- atm.imp^strt^dat indication impacting date
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- atm.imp^strt^tim
                    || com_api_type_pkg.pad_char(to_char(null, 'hh24missff6'), 12, 12)
                    -- POS
                    -- pos.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- pos.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- pos.imp^strt^tim
                    || com_api_type_pkg.pad_char('', 12, 12)
                    -- TRL
                    -- tlr.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- tlr.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- tlr.imp^strt^tim.byte
                    || com_api_type_pkg.pad_char('', 12, 12)
                    -- imp^typ
                    || com_api_type_pkg.pad_char('', 1, 1)
                    -- caf^expnt
                    || com_api_type_pkg.pad_char('', 1, 1)
                    -- pre^auth^support
                    || com_api_type_pkg.pad_char('', 1, 1)
                    -- user^fld2.byte
                    || com_api_type_pkg.pad_char('', 5, 5)
                    -- TB
                    -- tb.lst^extr^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yymmdd'), 6, 6)
                    -- tb.imp^strt^dat
                    || com_api_type_pkg.pad_char(to_char(null, 'yyyymmdd'), 8, 8)
                    -- tb.imp^strt^tim
                    || com_api_type_pkg.pad_char('', 12, 12)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                if l_cardholder_tab(i).record_inst_number = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put block header
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('BH', 2, 2)
                    -- crd^iss FIID of the institution
                    || com_api_type_pkg.pad_char('', 4, 4)
                    -- end^range Account number end range
                    || com_api_type_pkg.pad_char('', 28, 28)
                    -- User field
                    || com_api_type_pkg.pad_char('', 1, 1)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                l_processed_count := l_processed_count + 1;

                -- put body
                l_rec_raw(l_rec_raw.count + 1) :=
                -- 1 reccnt Record number
                com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                -- 10 rectyp Record Type
                || com_api_type_pkg.pad_char('F', 1, 1)
                -- 11 fiid Institution identifier
                || com_api_type_pkg.pad_char(get_inst_id(l_cardholder_tab(i).inst_id), 9, 9)
                -- 20 pan PAN
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).card_number, 19, 19)
                -- 39 prev-crd-num PAN prevision card
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).prev_card_number, 19, 19)
                -- 58 pri-nam Primary cardholder name
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).person_name, 40, 40)
                -- 98 pri-govt-id Primary cardholder social security number
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).national_id, 20, 20)
                -- 118 pri-dob Primary cardholder date of birth
                || com_api_type_pkg.pad_char(to_char(l_cardholder_tab(i).person_birth_date, 'yyyymmdd'), 8, 8)
                -- 126 sec-nam Secondary cardholder name
                || com_api_type_pkg.pad_char('', 40, 40)
                -- 166 adnl-nam The name of a third authorized user
                || com_api_type_pkg.pad_char('', 40, 40)
                -- 206 othr-name Primary cardholder's unique information
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).cardholder_name, 40, 40)
                -- 246 addr-1 Primary cardholder address 1
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).street, 40, 40)
                -- 286 addr-2 Primary cardholder address 2
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).house, 40, 40)
                -- 326 city Primary cardholder city
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).city, 30, 30)
                -- 356 st Primary cardholder state
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).region_code, 30, 30)
                -- 386 cntry Primary cardholder country iso code
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).country_code, 3, 3)
                -- 389 postal-cde Primary cardholder postal code
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).postal_code, 16, 16)
                -- 405 home-phn Primary cardholder home phone
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).home_phone, 20, 20)
                -- 425 wrk-phn Primary cardholder work phone
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).work_phone, 20, 20)
                -- 445 mob-phn Primary cardholder work phone
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).mobile_phone, 20, 20)
                -- 465 email-addr Primary cardholder email
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).email, 40, 40)
                -- 505 id Customer identifier
                || com_api_type_pkg.pad_char(l_cardholder_tab(i).national_id, 30, 30)
                -- 525 prod-typ Product type
                || com_api_type_pkg.pad_char(get_card_type(l_cardholder_tab(i).bin), 2, 2)
                -- 537 plastic-typ Plastic type
                || com_api_type_pkg.pad_char('01', 2, 2)
                -- 539 rqst-dat Date of last card request
                || com_api_type_pkg.pad_number(to_char(l_cardholder_tab(i).last_card_request, 'yyyymmdd'), 8, 8)
                -- 547 pin-chng Date of last pin change
                || com_api_type_pkg.pad_number(to_char(l_cardholder_tab(i).last_pin_change, 'yyyymmdd'), 8, 8)
                -- 555 last-iss Last issuer date
                || com_api_type_pkg.pad_number(to_char(l_cardholder_tab(i).reg_date, 'yyyymmdd'), 8, 8)
                -- 563 emboss Emboss date
                || com_api_type_pkg.pad_number(to_char(l_cardholder_tab(i).iss_date, 'yyyymmdd'), 8, 8)
                -- 571 last-crv Date of last CRV maintenance
                || com_api_type_pkg.pad_number(to_char(null, 'yyyymmdd'), 8, 8)
                -- 579 last-addr-chng Date of last address change
                || com_api_type_pkg.pad_number(to_char(null, 'yyyymmdd'), 8, 8)
                -- 587 last-stat-chng Date of last status change
                || com_api_type_pkg.pad_number(to_char(null, 'yyyymmdd'), 8, 8)
                -- 595 num-iss Number of cards issued
                || com_api_type_pkg.pad_number(l_cardholder_tab(i).card_issued, 2, 2)
                -- 597 blk-cde Blocked indicator
                || com_api_type_pkg.pad_char('0', 1, 1)
                -- Reclassification code
                || com_api_type_pkg.pad_char('', 1, 1)
                -- 599 bhvr-score Behavioral score
                || com_api_type_pkg.pad_char('0000', 4, 4)
                -- 603 cash-adv-amt Life high cash advance amount
                || com_api_type_pkg.pad_number('', 12, 12)
                -- 611 purch-amt Life high purchase amount.
                || com_api_type_pkg.pad_number('', 12, 12)
                -- 623 bal-amt Life high balance amount.
                || com_api_type_pkg.pad_number('', 12, 12)
                -- 639 opn-dat Primary card account open date
                || com_api_type_pkg.pad_number(to_char(l_cardholder_tab(i).account_open_date, 'yyyymmdd'), 8, 8)
                -- 647 cust-mstr-amt Amount field to hold any user defined customized amount.
                || com_api_type_pkg.pad_number(null, 16, 16)
                -- 663 cust-mstr-dat Date field to hold any user defined customized date.
                || com_api_type_pkg.pad_number(to_char(null, 'yyyymmdd'), 8, 8)
                -- 671 cust-mstr-fld1 Alphanumeric field to hold user defined data.
                || com_api_type_pkg.pad_char('00', 2, 2)
                -- 673 cust-mstr-fld2 Alphanumeric field to hold user defined data.
                || com_api_type_pkg.pad_char('0000', 4, 4)
                -- spaces
                || com_api_type_pkg.pad_char('', 18, 18)
                ;
                l_rec_num(l_rec_num.count + 1) := l_processed_count;

                if l_cardholder_tab(i).record_inst_number_desc = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put block trailer
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^type Record Type
                    || com_api_type_pkg.pad_char('BT', 2, 2)
                    -- amt Verification amount
                    || com_api_type_pkg.pad_number(0, 18, 18)
                    -- num^recs Record number
                    || com_api_type_pkg.pad_number(l_cardholder_tab(i).record_number, 9, 9)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

                if l_cardholder_tab(i).record_number_desc = 1 then
                    l_processed_count := l_processed_count + 1;

                    -- put trailer
                    l_rec_raw(l_rec_raw.count + 1) :=
                    -- rec^cnt Record number
                    com_api_type_pkg.pad_number(l_processed_count, 9, 9)
                    -- rec^typ Record Type
                    || com_api_type_pkg.pad_char('FT', 2, 2)
                    -- num^recs Total record number
                    || com_api_type_pkg.pad_number(l_cardholder_tab(i).record_number, 9, 9)
                    -- nxt^file Indicates whether another input file follows
                    || com_api_type_pkg.pad_char('0', 1, 1)
                    -- user^fld1 User field
                    || com_api_type_pkg.pad_char('', 3, 3)
                    ;
                    l_rec_num(l_rec_num.count + 1) := l_processed_count;
                end if;

            end loop;

            l_current_count := l_current_count + l_cardholder_tab.count;

            -- put file record
            put_file;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
                , i_excepted_count  => 0
            );

            exit when l_cardholder_cur%notfound;
        end loop;
        close l_cardholder_cur;

        -- process event object
        if l_full_export = com_api_type_pkg.FALSE then
            open l_events (
                i_proc_session_id  => get_session_id
            );
            loop
                fetch l_events
                bulk collect into
                l_event_object_id
                limit BULK_LIMIT;

                evt_api_event_pkg.process_event_object (
                    i_event_object_id_tab => l_event_object_id
                );

                exit when l_events%notfound;
            end loop;
            close l_events;
        end if;

        -- close file
        if l_current_count != 0 then
            close_file (
                i_status  => prc_api_const_pkg.FILE_STATUS_ACCEPTED
            );
        else
            prc_api_stat_pkg.log_estimation (
                i_estimated_count  => l_current_count
            );
        end if;
        prc_api_stat_pkg.log_end (
            i_processed_total  => l_current_count
            , i_result_code    => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );
    exception
        when others then
            if l_events%isopen then
                close l_events;
            end if;
            if l_cardholder_cur%isopen then
                close l_cardholder_cur;
            end if;
            
            if l_session_file_id is not null then
                close_file (
                    i_status  => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;

            prc_api_stat_pkg.log_end (
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error (
                    i_error         => 'UNHANDLED_EXCEPTION'
                    , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;

end;
/
