create or replace package body amx_prc_merchant_pkg as

BULK_LIMIT        constant com_api_type_pkg.t_tiny_id := 1000;

type                       t_merchant_hrchy_rec is record(
    amx_hrchy_number       com_api_type_pkg.t_byte_char
  , amx_superior_merchant  com_api_type_pkg.t_merchant_number
  , amx_part_code          com_api_type_pkg.t_byte_char);

type                       t_merchant_hrchy_tab is table of t_merchant_hrchy_rec index by varchar2(15);
g_merchant_hrchy           t_merchant_hrchy_tab;


procedure fill_merchant_hierarchy(i_inst_id  in com_api_type_pkg.t_inst_id  default ost_api_const_pkg.DEFAULT_INST) is
begin
    g_merchant_hrchy.delete;
    for r in (select merchant_number
                   , case
                         when (lvl, max_lvl) in ((1, 1))                         then null
                         when lvl = max_lvl                                      then '02'
                         when (lvl, max_lvl) in ((1, 2), (2, 3), (3, 4), (3, 5)) then '06'
                         when lvl = 1 and max_lvl > 2                            then '08'
                         when (lvl, max_lvl) in ((3, 4), (4, 5))                 then '05'
                         when (lvl, max_lvl) in ((2, 5))                         then '07'
                     end                                                                    as amx_hrchy_number
                   , case
                         when (lvl, max_lvl) in ((1, 1)) then null
                                                         else superior_merchant
                     end                                                                    as amx_superior_merchant
                   , case
                         when (lvl, max_lvl) in ((1, 1)) then '01'
                         when lvl = 1                    then '02'
                                                         else '03'
                     end                                                                    as amx_part_code
                from (select merchant_number
                           , parent_id
                           , lvl
                           , max(lvl) over (partition by group_merchant) as max_lvl
                           , superior_merchant
                        from (select merchant_number
                                   , parent_id
                                   , level as lvl
                                   , connect_by_root id as group_merchant
                                   , connect_by_root merchant_number as superior_merchant
                                from acq_merchant
                               start with parent_id is null
                                 and (inst_id = i_inst_id or nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST)
                             connect by parent_id = prior id)))
    loop
        g_merchant_hrchy(r.merchant_number).amx_hrchy_number      := r.amx_hrchy_number;
        g_merchant_hrchy(r.merchant_number).amx_superior_merchant := r.amx_superior_merchant;
        g_merchant_hrchy(r.merchant_number).amx_part_code         := r.amx_part_code;
    end loop;
end fill_merchant_hierarchy;

function check_fields(
    i_merchant_rec    in amx_api_type_pkg.t_merchant_rec
) return com_api_type_pkg.t_boolean is
    l_result        com_api_type_pkg.t_boolean;
begin
    l_result := com_api_type_pkg.TRUE;

    if i_merchant_rec.se_mcc is null then
        trc_log_pkg.error(
            i_text          => 'Field MCC is empty for merchant id [#1]'
          , i_env_param1    => i_merchant_rec.se_id_code
        );
        l_result := com_api_type_pkg.FALSE;
    end if;

    if not g_merchant_hrchy.exists(i_merchant_rec.se_id_code) then
        trc_log_pkg.error(
            i_text          => 'Merchant id [#1] is not found in merchant hierarchy'
          , i_env_param1    => i_merchant_rec.se_id_code
        );
    end if;

    return l_result;

end check_fields;

function process_merchant(
    i_merchant_rec         in amx_api_type_pkg.t_merchant_rec
  , i_session_file_id      in com_api_type_pkg.t_long_id
  , i_full_export          in com_api_type_pkg.t_boolean
  , i_action_code          in com_api_type_pkg.t_module_code
  , i_file                 in amx_api_type_pkg.t_amx_file_rec
  , i_orig_inst_code       in com_api_type_pkg.t_cmid
  , i_dest_inst_code       in com_api_type_pkg.t_cmid
) return com_api_type_pkg.t_boolean is
    l_line                    com_api_type_pkg.t_text;
    l_street_h_ap             com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug('amx_prc_merchant_pkg.process_merchant start');
    if check_fields(i_merchant_rec  => i_merchant_rec) = com_api_type_pkg.FALSE then
        trc_log_pkg.debug(
            i_text  => 'Merchant with id ' || i_merchant_rec.se_id_code || ' was skipped, because it has error in field(s).'
        );
        return com_api_type_pkg.FALSE;
    end if;

    l_street_h_ap := trim(i_merchant_rec.se_street) || ' ' || trim(i_merchant_rec.se_house) || ' ' || trim(i_merchant_rec.se_apartment);

    l_line :=
        -- Field  1 Message Type Identifier X(4)
        amx_api_const_pkg.MTID_DC_DEMOGRAPHIC
        -- Field  2 File Sequence Number 9(6)
     || lpad(nvl(i_file.file_number, '0'), 6, '0')
        -- Field  3 Transmittal Date 9(8) CCYYMMDD
     || to_char(i_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE)
        -- Field  4 Transmittal Date 9(6) CCYYMMDD
     || to_char(i_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME)
        -- Field  5 Originating Institution Identification Code X(11)
     || lpad(nvl(i_orig_inst_code, '0'), 11, '0')
        -- Field  6 Forwarding Institution Identification Code X(11)
     || lpad(nvl(i_file.forw_inst_code, '0'), 11, '0')
        -- Field  7 Receiving Institution Identifier X(11)
     || lpad(nvl(i_file.receiv_inst_code, '0'), 11, '0')
        -- Field  8 Destination Institution Identification Code X(11)
     || lpad(nvl(i_dest_inst_code, '0'), 11, '0')
        -- Field  9 Action Code X(3)
     || i_action_code
        -- Field 10 Message number 9(8)
     || lpad(nvl(i_merchant_rec.message_number, '0'), 8, '0')
        -- Field 11 File Name Code X(17)
     || rpad(amx_api_const_pkg.FILE_NAME_CODE_SEDEMOV2, 17, ' ')
        -- Field 12 Reject Reason Codes 1-10 X(40)
     || rpad(' ',  40, ' ')
        -- Field 13 Function Code X(3)
     || rpad(nvl(to_char(i_merchant_rec.function_code), ' '),  3, ' ')
        -- Field 14 Processing Code X(6)
     || amx_api_const_pkg.PROC_CODE_DEMOGRAPHIC
        -- Field 15 Transport Data X(25)
     || rpad(' ',  25, ' ')
        -- Field 16 Message Transaction Sequence Number 9(6)
     || amx_api_const_pkg.MESSAGE_TRANSACTION_SN
        -- Field 17 Record Hash Value 9(10)
     || rpad('0',  10, '0')
        -- Field 18 Systems Trace Audit Number 9(6)
     || rpad('0',   6, '0')
        -- Field 19 Card Acceptor Identification Code X(15)
     || rpad(lpad(i_merchant_rec.se_id_code, 10, '0'), 15, ' ')
        -- Field 20 Filler X(3)
     || rpad(' ',   3, ' ')
        -- Field 21 Card Acceptor Name X(38)
     || rpad(substr(trim(i_merchant_rec.se_name), 1, 38), 38, ' ')
        -- Field 22 Filler X(42)
     || rpad(' ',  42, ' ')
        -- Field 23 Card Acceptor Address Line 1-4 X(38)
     || rpad(nvl(substr(l_street_h_ap,   1, 38), ' '), 38, ' ')
        -- Field 24 Card Acceptor Address Line 1-4 X(38)
     || rpad(nvl(substr(l_street_h_ap,  39, 38), ' '), 38, ' ')
        -- Field 25 Card Acceptor Address Line 1-4 X(38)
     || rpad(nvl(substr(l_street_h_ap,  77, 38), ' '), 38, ' ')
        -- Field 26 Card Acceptor Address Line 1-4 X(38)
     || rpad(nvl(substr(l_street_h_ap, 115, 38), ' '), 38, ' ')
        -- Field 27 Card Acceptor City X(21)
     || rpad(nvl(substr(i_merchant_rec.se_city, 1, 21), ' '), 21, ' ')
        -- Field 28 Card Acceptor Postal Code X(15)
     || rpad(nvl(substr(i_merchant_rec.se_postal_code, 1, 15), ' '), 15, ' ')
        -- Field 29 Card Acceptor Region Code X(3)
     || lpad(nvl(i_merchant_rec.se_region, '0'), 3, '0')
        -- Field 30 Card Acceptor Country Code X(3)
     || i_merchant_rec.se_country
        -- Field 31 Status Code X(1)
     || case i_full_export
            when com_api_type_pkg.TRUE then amx_api_const_pkg.SE_STATUS_CODE_ACTIVE
            else
                case
                    when i_merchant_rec.cancel_eff_date is not null then amx_api_const_pkg.SE_STATUS_CODE_CANCELED
                    else amx_api_const_pkg.SE_STATUS_CODE_ACTIVE
                end
        end
        -- Field 32 Active Effective date X(8) CCYYMMDD
     || nvl(to_char(i_merchant_rec.active_eff_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE)
        -- Field 33 Canceled Effective Date X(8) CCYYMMDD
     || case i_full_export
             when com_api_type_pkg.TRUE then rpad(' ', 8, ' ')
             else nvl(to_char(i_merchant_rec.cancel_eff_date, amx_api_const_pkg.FORMAT_OUT_DATE), rpad(' ', 8, ' '))
        end
        -- Field 34 Reinstated Effective Date X(8) CCYYMMDD
     || rpad(' ', 8, ' ')
        -- Field 35 Status Reason Code x(2)
     || case i_full_export
            when com_api_type_pkg.TRUE then rpad(' ', 2, ' ')
            else
                case
                    when i_merchant_rec.cancel_eff_date is not null then nvl(i_merchant_rec.status_reason_code, '01')
                    else rpad(' ', 2, ' ')
                end
        end
        -- Field 36 Role Type Code X(3)
     || amx_api_const_pkg.ROLE_TYPE_CODE_CARD_ACCEPT
        -- Field 37 Merchant Category Code X(4)
     || rpad(nvl(i_merchant_rec.se_mcc, ' '), 4, ' ')
        -- Field 38 Filler X(2)
     || rpad(' ', 2, ' ')
        -- Field 39 Card Acceptor Full Recourse Status X(1)
     || nvl(i_merchant_rec.se_full_recourse_status, amx_api_const_pkg.VALUE_N)
        -- Field 40 Card Acceptor High Risk Indicator X(1)
     || nvl(i_merchant_rec.se_high_risk_indicator, amx_api_const_pkg.VALUE_N)
        -- Field 41 Hierarchy Level Number X(2)
     || nvl(g_merchant_hrchy(i_merchant_rec.se_id_code).amx_hrchy_number, '  ')
        -- Field 42 New Hierarchy Superior Merchant X(15)
     || rpad(nvl(g_merchant_hrchy(i_merchant_rec.se_id_code).amx_superior_merchant, ' '), 15, ' ')
        -- Field 43 New Hierarchy Effective Date X(8) CCYYMMDD
     || amx_api_const_pkg.DEFAULT_DATE
        -- Field 44 New Hierarchy End Date X(8) CCYYMMDD
     || amx_api_const_pkg.END_DATE
        -- Field 45 New Hierarchy Participant Code X(2)
     || g_merchant_hrchy(i_merchant_rec.se_id_code).amx_part_code
        -- Fields 46-47 Filler X(1 + 3)
     || rpad(' ',   4, ' ')
        -- Field 48 New Relationship Superior Merchant X(15)
     || rpad(' ',  15, ' ')
        -- Field 49 New Relationship Effective Date X(8) CCYYMMDD
     || rpad(' ',   8, ' ')
        -- Field 50 New Relationship End Date X(8) CCYYMMDD
     || rpad(' ',   8, ' ')
        -- Field 51 Contactless Payment Acceptor X(1)
     || amx_api_const_pkg.VALUE_N
        -- Field 52 American Express MNA Indicator X(1)
     || amx_api_const_pkg.VALUE_N
        -- Field 53 S/E Floor Limit Currency X(3)
     || rpad(' ',   3, ' ')
        -- Field 54 S/E Floor Limit Amount X(15)
     || rpad(' ',  15, ' ')
        -- Field 55 Base Discount Rate X(15)
     || rpad(' ',  15, ' ')
        -- Fields 56-62 Filler X(3 + 3 + 3 + 3 + 3 + 8 + 8)
     || rpad(' ', 31, ' ')
        -- Field 63 Card Acceptor Telephone Number X(20)
     || rpad(nvl(i_merchant_rec.phone_number, ' '), 20, ' ')
        -- Field 64 Filler X(722)
     || rpad(' ', 722, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;
    trc_log_pkg.debug('amx_prc_merchant_pkg.process_merchant end');

    return com_api_type_pkg.TRUE;

end process_merchant;

procedure generate_header(
    i_network_id        in     com_api_type_pkg.t_tiny_id
  , i_orig_inst_code    in     com_api_type_pkg.t_cmid
  , i_forw_inst_code    in     com_api_type_pkg.t_cmid
  , i_receiv_inst_code  in     com_api_type_pkg.t_cmid
  , i_dest_inst_code    in     com_api_type_pkg.t_cmid
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_action_code       in     varchar2 default null
  , i_session_file_id   in     com_api_type_pkg.t_long_id
  , o_file                 out amx_api_type_pkg.t_amx_file_rec
) is
    l_line                     com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(i_text  => 'amx_prc_merchant_pkg.process_file_header start');

    o_file.id                := i_session_file_id;
    o_file.is_incoming       := com_api_type_pkg.FALSE;
    o_file.is_rejected       := com_api_type_pkg.FALSE;
    o_file.network_id        := i_network_id;
    o_file.transmittal_date  := trunc(com_api_sttl_day_pkg.get_sysdate);
    o_file.inst_id           := i_inst_id;
    o_file.forw_inst_code    := i_forw_inst_code;
    o_file.receiv_inst_code  := i_receiv_inst_code;
    o_file.action_code       := i_action_code;
    o_file.session_file_id   := i_session_file_id;

    amx_api_file_pkg.generate_file_number(
        i_cmid                => o_file.forw_inst_code
      , i_transmittal_date    => o_file.transmittal_date
      , i_inst_id             => o_file.inst_id
      , i_network_id          => o_file.network_id
      , i_action_code         => o_file.action_code
      , o_file_number         => o_file.file_number
    );

    o_file.reject_code       := null;
    o_file.receipt_file_id   := null;
    o_file.reject_msg_id     := null;

    l_line := l_line || amx_api_const_pkg.MTID_DC_HEADER;
    l_line := l_line || lpad(o_file.file_number, 6, '0');
    l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE);
    l_line := l_line || nvl(to_char(o_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);
    l_line := l_line || rpad(i_orig_inst_code, 11, ' ');
    l_line := l_line || rpad(o_file.forw_inst_code, 11, ' ');
    l_line := l_line || rpad(o_file.receiv_inst_code, 11, ' ');
    l_line := l_line || rpad(i_dest_inst_code, 11, ' ');
    l_line := l_line || rpad(i_action_code, 3, ' ');
    l_line := l_line || lpad('1', 8, '0');
    l_line := l_line || rpad(amx_api_const_pkg.FILE_NAME_CODE_SEDEMOV2, 17, ' ');
    l_line := l_line || rpad(' ', 40, ' ');
    l_line := l_line || rpad(' ', 1264, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(i_text  => 'amx_prc_merchant_pkg.process_file_header end');

end generate_header;

procedure generate_trailer(
    i_rec_number          in     com_api_type_pkg.t_short_id
  , i_session_file_id     in     com_api_type_pkg.t_long_id
  , i_orig_inst_code      in     com_api_type_pkg.t_cmid
  , i_dest_inst_code      in     com_api_type_pkg.t_cmid
  , io_file               in out amx_api_type_pkg.t_amx_file_rec
) is
    l_line                       com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug (i_text  => 'amx_prc_outgoing_pkg.process_file_trailer start');

    l_line := l_line || amx_api_const_pkg.MTID_DC_TRAILER;
    l_line := l_line || lpad(io_file.file_number, 6, '0');
    l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_DATE), amx_api_const_pkg.DEFAULT_DATE);
    l_line := l_line || nvl(to_char(io_file.transmittal_date, amx_api_const_pkg.FORMAT_OUT_TIME), amx_api_const_pkg.DEFAULT_TIME);
    l_line := l_line || rpad(i_orig_inst_code, 11, ' ');
    l_line := l_line || rpad(io_file.forw_inst_code, 11, ' ');
    l_line := l_line || rpad(io_file.receiv_inst_code, 11, ' ');
    l_line := l_line || rpad(i_dest_inst_code, 11, ' ');
    l_line := l_line || rpad(io_file.action_code, 3, ' ');
    l_line := l_line || lpad(i_rec_number, 8, '0');
    l_line := l_line || rpad(amx_api_const_pkg.FILE_NAME_CODE_SEDEMOV2, 17, ' ');
    l_line := l_line || rpad(' ', 40, ' ');
    l_line := l_line || rpad(' ', 1264, ' ');

    if l_line is not null then
        prc_api_file_pkg.put_line(
            i_raw_data      => l_line
          , i_sess_file_id  => i_session_file_id
        );
    end if;

    trc_log_pkg.debug(i_text  => 'amx_prc_outgoing_pkg.process_file_trailer end');

end generate_trailer;

procedure process(
    i_inst_id          in com_api_type_pkg.t_inst_id      default ost_api_const_pkg.DEFAULT_INST
  , i_full_export      in com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_amx_action_code  in com_api_type_pkg.t_module_code  default null
  , i_lang             in com_api_type_pkg.t_dict_value   default null
) is
    l_lang                 com_api_type_pkg.t_dict_value;
    l_full_export          com_api_type_pkg.t_boolean;
    l_action_code          com_api_type_pkg.t_module_code;
    l_record_count         com_api_type_pkg.t_long_id   := 0;
    l_processed_count      com_api_type_pkg.t_long_id   := 0;
    l_excepted_count       com_api_type_pkg.t_long_id   := 0;
    l_estimated_count      com_api_type_pkg.t_long_id   := 0;
    l_total_proc_count     com_api_type_pkg.t_long_id   := 0;
    l_total_except_count   com_api_type_pkg.t_long_id   := 0;
    l_merchant_tab         amx_api_type_pkg.t_merchant_tab;
    l_param_tab            com_api_type_pkg.t_param_tab;
    l_session_file_id      com_api_type_pkg.t_long_id;
    l_sysdate              date;
    l_file                 amx_api_type_pkg.t_amx_file_rec;

    l_inst_id              com_api_type_pkg.t_inst_id_tab;
    l_host_id              com_api_type_pkg.t_number_tab;
    l_standard_id          com_api_type_pkg.t_number_tab;
    l_event_tab            num_tab_tpt;
    l_merchant_id          num_tab_tpt;

    l_cmid                 com_api_type_pkg.t_cmid;
    l_orig_cmid            com_api_type_pkg.t_cmid;
    l_forw_cmid            com_api_type_pkg.t_cmid;
    l_recv_cmid            com_api_type_pkg.t_cmid;
    l_dest_cmid            com_api_type_pkg.t_cmid;

    cursor evt_objects_merchant_cur(i_inst_id com_api_type_pkg.t_inst_id) is
        select o.id
          from evt_event_object o
             , acq_merchant m
             , evt_event e
         where o.split_hash  in (select split_hash from com_api_split_map_vw)
           and decode(o.status, evt_api_const_pkg.EVENT_STATUS_READY, o.procedure_name, null) = amx_api_const_pkg.AMX_PRC_MERCHANT_PKG_PROCESS
           and o.eff_date    <= l_sysdate
           and o.object_id    = m.id
           and o.entity_type  = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.event_id     = e.id
           and e.event_type  in (acq_api_const_pkg.EVENT_MERCHANT_CREATION, acq_api_const_pkg.EVENT_MERCHANT_CLOSE, acq_api_const_pkg.EVENT_MERCHANT_CHANGE)
           and o.inst_id      = i_inst_id
           and m.inst_id      = o.inst_id;

    cursor evt_merchants(i_inst_id com_api_type_pkg.t_inst_id) is
        select m.id
          from evt_event_object o
             , acq_merchant m
             , evt_event e
         where o.split_hash in (select split_hash from com_api_split_map_vw)
           and decode(o.status, evt_api_const_pkg.EVENT_STATUS_READY, o.procedure_name, null) = amx_api_const_pkg.AMX_PRC_MERCHANT_PKG_PROCESS
           and o.object_id   = m.id
           and o.eff_date    <= l_sysdate
           and o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
           and o.event_id    = e.id
           and e.event_type in (acq_api_const_pkg.EVENT_MERCHANT_CREATION, acq_api_const_pkg.EVENT_MERCHANT_CLOSE, acq_api_const_pkg.EVENT_MERCHANT_CHANGE)
           and o.inst_id     = i_inst_id
           and m.inst_id     = o.inst_id;

    cursor evt_merchant_cur(i_inst_id  com_api_type_pkg.t_inst_id) is
        select rownum                                                              as message_number
             , case when a.date_cls is not null                        then amx_api_const_pkg.FUNC_CODE_DELETE_RECORD
                    when a.date_upd is not null and a.date_cls is null then amx_api_const_pkg.FUNC_CODE_CHANGE_RECORD
                                                                       else amx_api_const_pkg.FUNC_CODE_ADD_RECORD
               end                                                                 as function_code
             , m.merchant_number                                                   as se_id_code
             , m.merchant_name                                                     as se_name
             , b.street                                                            as se_street
             , b.house                                                             as se_house
             , b.apartment                                                         as se_apartment
             , b.city                                                              as se_city
             , b.postal_code                                                       as se_postal_code
             , null                                                                as region_code         -- ?? length=3
             , b.country                                                           as country_code
             , a.date_act                                                          as a_eff_date
             , a.date_cls                                                          as c_eff_date
             , null                                                                as status_reason_code  -- ??
             , m.mcc                                                               as se_mcc
             , null                                                                as se_full_recourse_status
             , null                                                                as se_high_risk_indicator
             , n.commun_address                                                    as phone_number
          from acq_merchant m
             , prd_contract r
             , prd_customer s
             , (select object_id as merchant_id, date_act, date_upd, date_cls
                  from (select object_id, event_id, max(eff_date) as eff_date
                          from evt_event_object
                         where id in (select column_value as id from table(cast(l_event_tab as num_tab_tpt)))
                         group by object_id, event_id
                         union
                        select object_id, event_id, max(eff_date) as eff_date
                          from evt_event_object
                         where event_id = 1024
                           and object_id in (select column_value as object_id from table(cast(l_merchant_id as num_tab_tpt)))
                         group by object_id, event_id)
                 pivot (max(eff_date) for event_id in (1024 as date_act, 1023 as date_upd, 1053 as date_cls))) a
             , (select a.id
                     , o.address_type
                     , a.country
                     , a.region
                     , a.city
                     , a.street
                     , a.house
                     , a.apartment
                     , a.postal_code
                     , a.place_code
                     , a.region_code
                     , a.lang
                     , o.object_id
                     , row_number() over (partition by o.object_id, o.address_type order by decode(a.lang, l_lang, -1, 'LANGENG', 0, o.address_id)) rn
                  from com_address_object o
                     , com_address a
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and a.id          = o.address_id
               ) b
             , (select o.object_id
                     , d.commun_method
                     , d.commun_address
                     , row_number() over (partition by o.object_id, o.contact_type order by decode(c.preferred_lang, l_lang, -1, 'LANGENG', 0, o.contact_id)) rn
                  from com_contact_object o
                     , com_contact        c
                     , com_contact_data   d
                 where o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and c.id            = o.contact_id
                   and c.id            = d.contact_id
                   and d.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                   and o.contact_type  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
               ) n
         where m.id           = a.merchant_id
           and m.inst_id      = evt_merchant_cur.i_inst_id
           and b.object_id    = m.id
           and b.rn           = 1
           and n.object_id(+) = m.id
           and n.rn(+)        = 1
           and r.id           = m.contract_id
           and r.customer_id  = s.id;

    cursor all_merchant_cur(i_inst_id  com_api_type_pkg.t_inst_id) is
        select rownum                                                              as message_number
             , amx_api_const_pkg.FUNC_CODE_ADD_RECORD                              as function_code
             , m.merchant_number                                                   as se_id_code
             , m.merchant_name                                                     as se_name
             , a.street                                                            as se_street
             , a.house                                                             as se_house
             , a.apartment                                                         as se_apartment
             , a.city                                                              as se_city
             , a.postal_code                                                       as se_postal_code
             , null                                                                as region_code         -- ?? length=3
             , a.country                                                           as country_code
             , (select max(eff_date)
                  from evt_event_object
                 where event_id  = 1024
                   and object_id = m.id)                                           as a_eff_date
             , null                                                                as c_eff_date
             , null                                                                as status_reason_code
             , m.mcc                                                               as se_mcc
             , null                                                                as se_full_recourse_status
             , null                                                                as se_high_risk_indicator
             , n.commun_address                                                    as phone_number
          from acq_merchant m
             , prd_contract r
             , prd_customer s
             , (select a.id
                     , o.address_type
                     , a.country
                     , a.region
                     , a.city
                     , a.street
                     , a.house
                     , a.apartment
                     , a.postal_code
                     , a.place_code
                     , a.region_code
                     , a.lang
                     , o.object_id
                     , row_number() over (partition by o.object_id, o.address_type order by decode(a.lang, l_lang, -1, com_api_const_pkg.DEFAULT_LANGUAGE, 0, o.address_id)) rn
                  from com_address_object o
                     , com_address        a
                 where o.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and a.id          = o.address_id
               ) a
             , (select o.object_id
                     , d.commun_method
                     , d.commun_address
                     , row_number() over (partition by o.object_id, o.contact_type order by decode(c.preferred_lang, l_lang, -1, com_api_const_pkg.DEFAULT_LANGUAGE, 0, o.contact_id)) rn
                  from com_contact_object o
                     , com_contact        c
                     , com_contact_data   d
                 where o.entity_type   = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                   and c.id            = o.contact_id
                   and c.id            = d.contact_id
                   and d.commun_method = com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
                   and o.contact_type  = com_api_const_pkg.CONTACT_TYPE_PRIMARY
               ) n
         where m.status       in (acq_api_const_pkg.MERCHANT_STATUS_ACTIVE, acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED)
           and a.object_id(+)  = m.id
           and a.rn(+)         = 1
           and n.object_id(+)  = m.id
           and n.rn(+)         = 1
           and m.inst_id       = all_merchant_cur.i_inst_id
           and r.id            = m.contract_id
           and r.customer_id   = s.id;

    cursor all_cur_count(i_inst_id  com_api_type_pkg.t_inst_id) is
        select count(*)
          from acq_merchant m
         where m.status       in (acq_api_const_pkg.MERCHANT_STATUS_ACTIVE, acq_api_const_pkg.MERCHANT_STATUS_SUSPENDED)
           and m.inst_id       = i_inst_id;

    procedure register_session_file(
        i_inst_id          in     com_api_type_pkg.t_inst_id
      , i_network_id       in     com_api_type_pkg.t_tiny_id
      , i_acq_bin          in     com_api_type_pkg.t_dict_value
      , o_session_file_id     out com_api_type_pkg.t_long_id
    ) is
        l_params                  com_api_type_pkg.t_param_tab;
    begin
        l_params.delete;
        rul_api_param_pkg.set_param(
            i_name       => 'INST_ID'
          , i_value      => to_char(i_inst_id)
          , io_params    => l_params
        );
        rul_api_param_pkg.set_param(
            i_name       => 'NETWORK_ID'
          , i_value      => i_network_id
          , io_params    => l_params
        );
        rul_api_param_pkg.set_param(
            i_name       => 'ACQ_BIN'
          , i_value      => i_acq_bin
          , io_params    => l_params
        );
        rul_api_param_pkg.set_param(
            i_name       => 'KEY_INDEX'
          , i_value      => i_acq_bin
          , io_params    => l_params
        );

        prc_api_file_pkg.open_file(
            o_sess_file_id  => o_session_file_id
          , i_file_type     => amx_api_const_pkg.FILE_TYPE_CLEARING_AMEX
          , io_params       => l_params
        );

    end register_session_file;

begin
    trc_log_pkg.debug(i_text  => 'AmEx unload merchant start');
    prc_api_stat_pkg.log_start;

    l_lang              := nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE);
    l_full_export       := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_action_code       := nvl(i_amx_action_code, amx_api_const_pkg.ACTION_CODE_TEST);
    l_sysdate           := get_sysdate;

    select m.id host_id
         , r.inst_id
         , s.standard_id
      bulk collect into
           l_host_id
         , l_inst_id
         , l_standard_id
      from net_network   n
         , net_member    m
         , net_interface i
         , net_member    r
         , cmn_standard_object s
     where n.id             = amx_api_const_pkg.TARGET_NETWORK
       and n.id             = m.network_id
       and n.inst_id        = m.inst_id
       and s.object_id      = m.id
       and s.entity_type    = net_api_const_pkg.ENTITY_TYPE_HOST
       and s.standard_type  = cmn_api_const_pkg.STANDART_TYPE_NETW_CLEARING
       and (r.inst_id       = i_inst_id or nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST) = ost_api_const_pkg.DEFAULT_INST)
       and r.id             = i.consumer_member_id
       and i.host_member_id = m.id;

    if l_full_export = com_api_type_pkg.TRUE then
        for i in 1..l_host_id.count loop
            open  all_cur_count(l_inst_id(i));
            fetch all_cur_count into l_record_count;
            close all_cur_count;
            l_estimated_count := l_estimated_count + l_record_count;
        end loop;
    else
        for i in 1..l_host_id.count loop
            open  evt_merchants(l_inst_id(i));
            fetch evt_merchants bulk collect into l_merchant_id;
            close evt_merchants;
            l_merchant_id     := set(l_merchant_id);
            l_estimated_count := l_estimated_count + l_merchant_id.count;
        end loop;
    end if;

    trc_log_pkg.debug(
        i_text        => 'Estimated count [#1]'
      , i_env_param1  => l_estimated_count
    );

    prc_api_stat_pkg.log_estimation(
        i_estimated_count     => l_estimated_count
    );

    if l_estimated_count > 0 or l_full_export = com_api_type_pkg.FALSE then
        for j in 1..l_host_id.count loop
            l_orig_cmid       := cmn_api_standard_pkg.get_varchar_value(
                                     i_inst_id       => l_inst_id(j)
                                   , i_standard_id   => l_standard_id(j)
                                   , i_object_id     => l_host_id(j)
                                   , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                                   , i_param_name    => amx_api_const_pkg.CMID_ACQUIRING
                                   , i_param_tab     => l_param_tab
                                 );
            l_forw_cmid       := l_orig_cmid;
            l_recv_cmid       := cmn_api_standard_pkg.get_varchar_value(
                                     i_inst_id       => l_inst_id(j)
                                   , i_standard_id   => l_standard_id(j)
                                   , i_object_id     => l_host_id(j)
                                   , i_entity_type   => net_api_const_pkg.ENTITY_TYPE_HOST
                                   , i_param_name    => amx_api_const_pkg.CMID_DEMOGRAPHIC
                                   , i_param_tab     => l_param_tab
                                 );
            l_dest_cmid       := l_recv_cmid;

            trc_log_pkg.debug(
                i_text        => 'Found orig_cmid [#1], recv_cmid [#2], host [#3], standard [#4]'
              , i_env_param1  => l_orig_cmid
              , i_env_param2  => l_recv_cmid
              , i_env_param3  => l_host_id(j)
              , i_env_param4  => l_standard_id(j)
            );

            fill_merchant_hierarchy(l_inst_id(j));

            trc_log_pkg.debug(
                i_text        => 'Built merchant hierarchy for institution id [#1]'
              , i_env_param1  => l_inst_id(j)
            );

            if l_full_export = com_api_type_pkg.TRUE then
                open  all_cur_count(l_inst_id(j));
                fetch all_cur_count into l_record_count;
                close all_cur_count;

                trc_log_pkg.debug(
                    i_text  => 'For inst_id ' || l_inst_id(j) || ' count of records = ' || l_record_count
                );

                if l_record_count > 0 then
                    l_processed_count := 0;
                    l_excepted_count  := 0;
                    l_session_file_id := null;

                    register_session_file(
                        i_inst_id         => l_inst_id(j)
                      , i_network_id      => amx_api_const_pkg.TARGET_NETWORK
                      , i_acq_bin         => l_cmid
                      , o_session_file_id => l_session_file_id
                    );

                    generate_header(
                        i_network_id        => amx_api_const_pkg.TARGET_NETWORK
                      , i_orig_inst_code    => l_orig_cmid
                      , i_forw_inst_code    => l_forw_cmid
                      , i_receiv_inst_code  => l_recv_cmid
                      , i_dest_inst_code    => l_dest_cmid
                      , i_inst_id           => l_inst_id(j)
                      , i_action_code       => l_action_code
                      , i_session_file_id   => l_session_file_id
                      , o_file              => l_file
                    );

                    open all_merchant_cur(l_inst_id(j));
                    loop
                        fetch all_merchant_cur
                         bulk collect into
                              l_merchant_tab
                        limit BULK_LIMIT;

                        for i in 1..l_merchant_tab.count loop
                            if process_merchant(
                                   i_merchant_rec     => l_merchant_tab(i)
                                 , i_session_file_id  => l_session_file_id
                                 , i_full_export      => l_full_export
                                 , i_action_code      => i_amx_action_code
                                 , i_file             => l_file
                                 , i_orig_inst_code   => l_orig_cmid
                                 , i_dest_inst_code   => l_dest_cmid
                                ) = com_api_type_pkg.FALSE then

                                l_excepted_count := l_excepted_count + 1;

                            else
                                l_processed_count := l_processed_count + 1;
                            end if;

                        end loop;

                        trc_log_pkg.debug(
                            i_text  => 'l_processed_count = ' || l_processed_count || ', l_merchant_tab.count = '|| l_merchant_tab.count || ', l_excepted_count = ' || l_excepted_count
                        );

                        exit when all_merchant_cur%notfound;
                    end loop;
                    close all_merchant_cur;

                    trc_log_pkg.debug(
                        i_text  => 'l_processed_count = ' || l_processed_count || ', l_excepted_count = ' || l_excepted_count
                    );

                    l_total_proc_count   := l_total_proc_count + l_processed_count;
                    l_total_except_count := l_total_except_count + l_excepted_count;

                    prc_api_stat_pkg.log_current(
                        i_current_count   => l_total_proc_count
                      , i_excepted_count  => l_total_except_count
                    );

                    generate_trailer(
                        i_rec_number       => l_total_proc_count
                      , i_session_file_id  => l_session_file_id
                      , i_orig_inst_code   => l_orig_cmid
                      , i_dest_inst_code   => l_dest_cmid
                      , io_file            => l_file
                    );

                    trc_log_pkg.debug(
                        i_text  => 'l_total_proc_count = ' || l_total_proc_count || ', l_total_except_count = ' || l_total_except_count
                    );

                    if l_processed_count = 0 and l_excepted_count > 0 then
                        prc_api_file_pkg.remove_file(
                            i_sess_file_id  => l_session_file_id
                          , i_file_type     => amx_api_const_pkg.FILE_TYPE_CLEARING_AMEX
                        );
                    else
                        prc_api_file_pkg.close_file(
                            i_sess_file_id  => l_session_file_id
                          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                        );
                    end if;

                end if;

            else
                open  evt_objects_merchant_cur(l_inst_id(j));
                fetch evt_objects_merchant_cur bulk collect into l_event_tab;
                close evt_objects_merchant_cur;

                trc_log_pkg.debug(
                    i_text  => 'For inst_id ' || l_inst_id(j) || ' count of events = ' || l_event_tab.count
                );

                open  evt_merchants(l_inst_id(j));
                fetch evt_merchants bulk collect into l_merchant_id;
                close evt_merchants;
                l_merchant_id  := set(l_merchant_id);
                l_record_count := l_merchant_id.count;

                trc_log_pkg.debug(
                    i_text  => 'For inst_id ' || l_inst_id(j) || ' count of records of merchants = ' || l_record_count
                );
                
                l_processed_count := 0;
                l_excepted_count  := 0;
                l_session_file_id := null;
                    
                register_session_file(
                    i_inst_id         => l_inst_id(j)
                  , i_network_id      => amx_api_const_pkg.TARGET_NETWORK
                  , i_acq_bin         => l_cmid
                  , o_session_file_id => l_session_file_id
                );

                generate_header(
                    i_network_id        => amx_api_const_pkg.TARGET_NETWORK
                  , i_orig_inst_code    => l_orig_cmid
                  , i_forw_inst_code    => l_forw_cmid
                  , i_receiv_inst_code  => l_recv_cmid
                  , i_dest_inst_code    => l_dest_cmid
                  , i_inst_id           => l_inst_id(j)
                  , i_action_code       => l_action_code
                  , i_session_file_id   => l_session_file_id
                  , o_file              => l_file
                );

                open evt_merchant_cur(l_inst_id(j));
                fetch evt_merchant_cur
                 bulk collect into
                      l_merchant_tab;

                for i in 1..l_merchant_tab.count loop
                    if process_merchant(
                           i_merchant_rec     => l_merchant_tab(i)
                         , i_session_file_id  => l_session_file_id
                         , i_full_export      => l_full_export
                         , i_action_code      => i_amx_action_code
                         , i_file             => l_file
                         , i_orig_inst_code   => l_orig_cmid
                         , i_dest_inst_code   => l_dest_cmid
                        ) = com_api_type_pkg.FALSE then

                        l_excepted_count := l_excepted_count + 1;

                    else
                        l_processed_count := l_processed_count + 1;        
                    end if;

                end loop;
                close evt_merchant_cur;

                generate_trailer(
                    i_rec_number       => l_total_proc_count
                  , i_session_file_id  => l_session_file_id
                  , i_orig_inst_code   => l_orig_cmid
                  , i_dest_inst_code   => l_dest_cmid
                  , io_file            => l_file
                );

                l_total_proc_count   := l_total_proc_count + l_processed_count; 
                l_total_except_count := l_total_except_count + l_excepted_count;

                prc_api_stat_pkg.log_current(
                    i_current_count     => l_total_proc_count
                    , i_excepted_count  => l_total_except_count
                );

                trc_log_pkg.debug(
                    i_text  => 'l_total_proc_count = ' || l_total_proc_count || ', l_total_except_count = ' || l_total_except_count
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_event_tab
                );

            end if;

--            end if;
        end loop;
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total  => l_total_proc_count
    );

    trc_log_pkg.debug(i_text  => 'AmEx unload merchant end');

exception
    when others then
        if all_merchant_cur%isopen then
            close all_merchant_cur;
        end if;

        if evt_merchant_cur%isopen then
            close evt_merchant_cur;
        end if;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if l_session_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_session_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;

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

end amx_prc_merchant_pkg;
/
