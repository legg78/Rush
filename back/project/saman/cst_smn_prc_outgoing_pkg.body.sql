create or replace package body cst_smn_prc_outgoing_pkg as

CRLF                     constant com_api_type_pkg.t_name := chr(13)||chr(10);
BULK_LIMIT               constant integer := 1000;
SEPARATE_CHAR_DEFAULT    constant com_api_type_pkg.t_byte_char := '|';
OUTPUT_DATE_FORMAT       constant cst_smn_api_calendars_pkg.t_date_full := cst_smn_api_calendars_pkg.JAL_DEF_DATE_FORMAT;
OUTPUT_TIME_FORMAT       constant cst_smn_api_calendars_pkg.t_date_full := 'hh24:mi:ss';
OUTPUT_SHORT_DATE_FORMAT constant cst_smn_api_calendars_pkg.t_date_full := 'YYMMDD';
OUTPUT_SHORT_TIME_FORMAT constant com_api_type_pkg.t_date_short := 'hh24miss';

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
                   and o.inst_id        = i_inst_id
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

function check_add_result_line(
    i_entity_type              in  com_api_type_pkg.t_dict_value
  , i_object_id                in  com_api_type_pkg.t_long_id
  , i_event_object_tab         in  t_entity_tab
) return com_api_type_pkg.t_boolean
is
begin
    
    return case
               when (i_entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
                     and i_event_object_tab(i_entity_type).event_id.exists(i_object_id)
                    )
                   then com_api_const_pkg.TRUE
               else 
                   com_api_const_pkg.FALSE
           end;
end check_add_result_line;

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
  , i_object_id                in     com_api_type_pkg.t_long_id
  , io_event_object_tab        in out t_entity_tab
  , io_event_tab               in out com_api_type_pkg.t_number_tab
)
is
begin
    for i in i_index .. i_entity_tab.last
    loop
        if i_entity_tab(i) = opr_api_const_pkg.ENTITY_TYPE_OPERATION
            and io_event_object_tab(i_entity_tab(i)).event_id.exists(i_object_id)
        then
            for n in 1 .. io_event_object_tab(i_entity_tab(i)).event_id(i_object_id).last
            loop
                if io_event_tab.exists(1) then
                    io_event_tab(io_event_tab.last + 1) := io_event_object_tab(i_entity_tab(i)).event_id(i_object_id)(n);
                else
                    io_event_tab(1) := io_event_object_tab(i_entity_tab(i)).event_id(i_object_id)(n);
                end if;
            end loop;
            clear_check_data(
                i_entity_type        => i_entity_tab(i)
              , i_index_element      => i_object_id
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

procedure proc_fin_to_shetab_detail_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value
  , i_proc_name                 in  com_api_type_pkg.t_name
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default null
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
) is
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.proc_fin_to_shetab_detail_exp: ';
        
    l_event_object_tab         t_entity_tab;
    
    l_event_tab                com_api_type_pkg.t_number_tab;
    l_entity_tab               com_api_type_pkg.t_dict_tab;
    l_operations_unloading     com_api_type_pkg.t_number_tab;

    l_param_tab                com_api_type_pkg.t_param_tab;
    
    l_operations_data_tab      opr_api_type_pkg.t_oper_external_tab;
    l_oper_participant_tab     opr_api_type_pkg.t_oper_ext_part_by_type_tab;
    l_oper_orig_party_tab      opr_api_type_pkg.t_oper_ext_part_by_type_tab;
    l_oper_participant_rec     opr_api_type_pkg.t_oper_external_part_rec;

    l_session_file_id          com_api_type_pkg.t_long_id;
    
    l_estimated_count          com_api_type_pkg.t_long_id    := 0;
    l_processed_count          com_api_type_pkg.t_long_id    := 0;
    l_excepted_count           com_api_type_pkg.t_long_id    := 0;
    l_rejected_count           com_api_type_pkg.t_long_id    := 0;
    
    l_ref_cursor               com_api_type_pkg.t_ref_cur;
    l_ref_party_cursor         com_api_type_pkg.t_ref_cur;
    l_party_count_data         com_api_type_pkg.t_byte_id;
    
    l_object_tab               com_api_type_pkg.t_object_tab;
    
    l_sysdate                  date;
    l_start_date               date;
    l_end_date                 date;
    
    l_increment_count          com_api_type_pkg.t_long_id := 0;
    
    l_request_count            com_api_type_pkg.t_short_id;
    
    l_full_export              com_api_type_pkg.t_boolean;
    
    procedure put_record_to_file(
        i_file_type                 in  com_api_type_pkg.t_dict_value
      , i_session_file_id           in  com_api_type_pkg.t_long_id
      , i_operations_data_rec       in  opr_api_type_pkg.t_oper_external_rec
      , i_oper_participant_tab      in  opr_api_type_pkg.t_oper_ext_part_by_type_tab
      , i_oper_orig_party_tab       in  opr_api_type_pkg.t_oper_ext_part_by_type_tab
    ) is
        l_separate_char             com_api_type_pkg.t_byte_char := nvl(i_separate_char, SEPARATE_CHAR_DEFAULT);
        l_record                    com_api_type_pkg.t_text;
        l_iss_flag                  com_api_type_pkg.t_sign := com_api_const_pkg.FALSE;
        l_dst_flag                  com_api_type_pkg.t_sign := com_api_const_pkg.FALSE;
        l_iss_orig_flag             com_api_type_pkg.t_sign := com_api_const_pkg.FALSE;
        l_statement_code            com_api_type_pkg.t_dict_value;
        l_shetab_optp_code          com_api_type_pkg.t_byte_char;
        l_shetab_func_optp_code     com_api_type_pkg.t_dict_value;
        l_shetab_trmn_type          com_api_type_pkg.t_dict_value;
        l_shetab_dg_trmn_type       com_api_type_pkg.t_byte_char;
    begin
        if i_oper_participant_tab.exists(com_api_const_pkg.PARTICIPANT_ISSUER) then
            l_iss_flag := com_api_const_pkg.TRUE;
        end if;
        if i_oper_orig_party_tab.exists(com_api_const_pkg.PARTICIPANT_ISSUER) then
            l_iss_orig_flag := com_api_const_pkg.TRUE;
        end if;
        if i_oper_participant_tab.exists(com_api_const_pkg.PARTICIPANT_DEST) then
            l_dst_flag := com_api_const_pkg.TRUE;
        end if;
        l_shetab_optp_code :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id        => opr_api_const_pkg.LOV_ID_OPERATION_TYPES
              , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_OPTP_CODE_SHETAB
              , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_OPTP_CODE_SHETAB
              , i_elem_value    => i_operations_data_rec.oper_type
              , i_mask_error    => com_api_const_pkg.TRUE
            )
        ;
        l_shetab_func_optp_code :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id        => opr_api_const_pkg.LOV_ID_OPERATION_TYPES
              , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_FNOT_CODE_SHETAB
              , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_FNOT_CODE_SHETAB
              , i_elem_value    => i_operations_data_rec.oper_type
              , i_mask_error    => com_api_const_pkg.TRUE
            )
        ;
        l_shetab_trmn_type :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id        => acq_api_const_pkg.LOV_ID_TERMINAL_TYPES
              , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_TRMT_CODE_SHETAB
              , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_TRMT_CODE_SHETAB
              , i_elem_value    => i_operations_data_rec.terminal_type
              , i_mask_error    => com_api_const_pkg.TRUE
            )
        ;
        l_shetab_dg_trmn_type :=
            com_api_array_pkg.conv_array_elem_v(
                i_lov_id        => acq_api_const_pkg.LOV_ID_TERMINAL_TYPES
              , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_TRMT_CODE_SHETAB
              , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_TRMT_DG_CODE_SHETAB
              , i_elem_value    => i_operations_data_rec.terminal_type
              , i_mask_error    => com_api_const_pkg.TRUE
            )
        ;
        if i_file_type = cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB then
            -- field #1
            l_record := i_operations_data_rec.oper_num || l_separate_char;
            -- field #2
            l_record := l_record || l_separate_char;
            -- field #3
            l_record := l_record || l_shetab_optp_code || l_separate_char;
            -- field #4
            l_record := l_record 
                     || cst_smn_api_calendars_pkg.get_jalali_date_str(
                            i_gregorian_date => i_operations_data_rec.oper_date
                          , i_jalali_format  => OUTPUT_DATE_FORMAT
                        )
                     || l_separate_char
            ;
            -- field #5
            l_record := l_record || to_char(i_operations_data_rec.oper_date, OUTPUT_TIME_FORMAT) || l_separate_char;
            -- field #6
            l_record := l_record || i_operations_data_rec.system_trace_audit_number || l_separate_char;
            -- field #7
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record ||
                    case l_shetab_func_optp_code
                        when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_TTA
                            then i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                        else i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                    end || l_separate_char
                ;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #8
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record
                         || iss_api_bin_pkg.get_bin(i_card_number => i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number).bin
                         || l_separate_char
                ;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #9
            l_record := l_record || i_operations_data_rec.terminal_number || l_separate_char;
            -- field #10
            l_record := l_record || i_operations_data_rec.oper_amount || l_separate_char;
            -- field #11
            l_record := l_record || l_shetab_trmn_type || l_separate_char;
            -- field #12
            l_record := l_record || l_separate_char;
            -- field #13
            if l_dst_flag = com_api_const_pkg.TRUE then
                if l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TF then
                    l_record := l_record ||
                        case l_shetab_func_optp_code
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_TFA
                                then i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_FIN
                                then i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                            else null
                        end || l_separate_char
                    ;
                elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TT then
                    l_record := l_record ||
                        case l_shetab_func_optp_code
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_TTA
                                then i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_FIN
                                then i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                            else null
                        end || l_separate_char
                    ;
                elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_PU then
                    -- cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_SSP - don't understand this
                    l_record := l_record || l_separate_char;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #14
            if l_shetab_func_optp_code in (cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFC, cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFP) then
                l_record := l_record || l_separate_char; -- don't understand Equal with Identifiers of main transaction receiver
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #15
            if l_shetab_func_optp_code in (cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFC, cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFP) then
                l_record := l_record || l_separate_char; -- don't understand Equal with tracking number of main transaction receiver
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #16
            if l_shetab_func_optp_code in (cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFC, cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFP) then
                l_record := l_record
                         || cst_smn_api_calendars_pkg.get_jalali_date_str(
                                i_gregorian_date => i_operations_data_rec.orig_oper_date
                              , i_jalali_format  => OUTPUT_DATE_FORMAT
                            )
                         || l_separate_char;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #17
            l_record := l_record || i_operations_data_rec.bin_amount || l_separate_char;
            -- field #18
            l_record := l_record || i_operations_data_rec.bin_currency || l_separate_char;
            -- field #19
            l_record := l_record || '0' || l_separate_char;
            -- field #20
            l_record := l_record 
                     || cst_smn_api_calendars_pkg.get_jalali_date_str(
                            i_gregorian_date => i_operations_data_rec.oper_date
                          , i_jalali_format  => OUTPUT_DATE_FORMAT
                        )
                     || l_separate_char
            ;
            -- field #21
            l_record := l_record || l_shetab_func_optp_code || l_separate_char;
            -- field #22
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record ||
                    case l_shetab_func_optp_code
                        when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_TTA
                            then null
                        else iss_api_card_pkg.get_card_mask(i_card_number => i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number)
                    end || l_separate_char
                ;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #23
            if l_shetab_func_optp_code in (cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFC, cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_RFP) then
                l_record := l_record || to_char(i_operations_data_rec.orig_oper_date, OUTPUT_TIME_FORMAT) || l_separate_char;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #24
            if l_dst_flag = com_api_const_pkg.TRUE or l_iss_orig_flag = com_api_const_pkg.TRUE then
                if l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TF
                   and l_dst_flag = com_api_const_pkg.TRUE
                then
                    l_record := l_record 
                             ||
                        case l_shetab_func_optp_code
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_FIN
                                then iss_api_card_pkg.get_card_mask(i_card_number => i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number)
                            else null
                        end || l_separate_char
                    ;
                elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TT
                      and l_iss_orig_flag = com_api_const_pkg.TRUE
                then
                    l_record := l_record ||
                        case l_shetab_func_optp_code
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_TTA
                                then iss_api_card_pkg.get_card_mask(i_card_number => i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number)
                            when cst_smn_api_const_pkg.SHETAB_FUNC_OPTP_CODE_FIN
                                then iss_api_card_pkg.get_card_mask(i_card_number => i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number)
                            else null
                        end || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || l_separate_char;
            end if;
        elsif i_file_type in (cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB, cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB) then
            -- field #1
            -- s1
            l_record := cst_smn_api_calendars_pkg.get_jalali_date_str(
                            i_gregorian_date => i_operations_data_rec.oper_date
                          , i_jalali_format  => OUTPUT_SHORT_DATE_FORMAT
                        )
                     || l_separate_char
            ;
            -- s2
            l_record := l_record || to_char(i_operations_data_rec.oper_date, OUTPUT_SHORT_TIME_FORMAT) || l_separate_char;
            -- s3
            l_record := l_record || l_shetab_dg_trmn_type || l_separate_char;
            -- s4
            l_record := l_record || i_operations_data_rec.system_trace_audit_number || l_separate_char;
            -- field #2
            l_record := l_record || '0000' || l_separate_char;
            -- field #3
            l_record := l_record || '8888' || l_separate_char;
            -- field #4
            l_record := l_record || '0' || l_separate_char;
            -- field #5
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record || i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number || l_separate_char;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #6
            l_record := l_record || i_operations_data_rec.oper_amount || l_separate_char;
            -- field #7
            if l_iss_flag = com_api_const_pkg.TRUE then
                if i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).debit_entry_impact = com_api_type_pkg.TRUE
                    and i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).credit_entry_impact = com_api_type_pkg.TRUE
                then
                    l_record := l_record || l_separate_char;
                elsif i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).debit_entry_impact = com_api_type_pkg.TRUE then
                    l_record := l_record || 'D' || l_separate_char;
                elsif i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).credit_entry_impact = com_api_type_pkg.TRUE then
                    l_record := l_record || 'C' || l_separate_char;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #8
            if l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_WD
                and l_shetab_trmn_type = cst_smn_api_const_pkg.SHETAB_TRMN_TYPE_ATM
            then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_WD_ATM;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_WD then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_WD_OTHER;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_PU
                and l_shetab_trmn_type = cst_smn_api_const_pkg.SHETAB_TRMN_TYPE_IPOS
            then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_PU_EPOS;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_PU then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_PU_OTHER;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_BI then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_BI;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_RF then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_RF;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TT then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT;
            elsif l_shetab_optp_code = cst_smn_api_const_pkg.SHETAB_OPTP_CODE_TF then
                l_statement_code := cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF;
            else
                -- don't understand transaction type - recipient and range of statement code for this case?
                l_statement_code := null;
            end if;
            l_record := l_record || l_statement_code || l_separate_char;
            -- field #9
            l_record := l_record || 'Y' || l_separate_char;
            -- field #10
            l_record := l_record || i_operations_data_rec.terminal_number || l_separate_char;
            -- field #11
            l_record := l_record || l_shetab_dg_trmn_type || l_separate_char;
            -- field #12
            l_record := l_record || 'N' || l_separate_char;
            -- field #13 -- don't understand transaction state
            l_record := l_record || l_separate_char;
            -- field #14 -- don't understand transaction tracking number
            l_record := l_record || l_separate_char;
            -- field #15
            l_record := l_record || i_operations_data_rec.agent_unique_id || l_separate_char;
            -- field #16
            l_record := l_record || '0000' || l_separate_char;
            -- field #17
            l_record := l_record || l_separate_char;
            -- field #18
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record
                         || nvl(
                                i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                              , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                            )
                         || l_separate_char
                ;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #19
            if l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT then
                if l_iss_orig_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                elsif l_iss_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            elsif l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF then
                if l_dst_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || '0' || l_separate_char;
            end if;
            -- field #20
            if l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT then
                if l_iss_orig_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                elsif l_iss_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            elsif l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF then
                if l_dst_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || '0' || l_separate_char;
            end if;
            -- field #21
            if l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT then
                if l_iss_orig_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                elsif l_iss_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            elsif l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF then
                if l_dst_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || '0' || l_separate_char;
            end if;
            -- field #22
            if l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT then
                if l_iss_orig_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                elsif l_iss_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            elsif l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF then
                if l_dst_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || '0' || l_separate_char;
            end if;
            -- field #23
            if l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TT then
                if l_iss_orig_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                elsif l_iss_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number
                                  , i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            elsif l_statement_code = cst_smn_api_const_pkg.SHETAB_STMT_CODE_TF then
                if l_dst_flag = com_api_const_pkg.TRUE then
                    l_record := l_record
                             || nvl(
                                    i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).card_number
                                  , i_oper_orig_party_tab(com_api_const_pkg.PARTICIPANT_DEST).account_number
                                )
                             || l_separate_char
                    ;
                else
                    l_record := l_record || l_separate_char;
                end if;
            else
                l_record := l_record || '0' || l_separate_char;
            end if;
            -- field #24
            l_record := l_record || i_operations_data_rec.acq_inst_bin || l_separate_char;
            -- field #25
            if l_iss_flag = com_api_const_pkg.TRUE then
                l_record := l_record || iss_api_bin_pkg.get_bin(i_card_number => i_oper_participant_tab(com_api_const_pkg.PARTICIPANT_ISSUER).card_number).bin || l_separate_char;
            else
                l_record := l_record || l_separate_char;
            end if;
            -- field #26
            l_record := l_record || '0' || l_separate_char;
            -- field #27
            l_record := l_record || '0' || l_separate_char;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => i_file_type
            );
        end if;
        
        prc_api_file_pkg.put_line(
            i_raw_data      => l_record
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_record || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end put_record_to_file;
begin
    prc_api_stat_pkg.log_start;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] full_export [#2] calendar [#3] calendar_date [#4] calendar_date_format [#5] array_operations_type_id [#6'
               || '], file_type [' || i_file_type
               || '], proc_name [' || i_proc_name
               || '], oper_currency [' || i_oper_currency
               || '], array_operations_type_id [' || i_array_operations_type_id
               || '], array_oper_statuses_id [' || i_array_oper_statuses_id
               || '], separate_char [' || i_separate_char
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_full_export
      , i_env_param3 => i_calendar
      , i_env_param4 => i_calendar_date
      , i_env_param5 => i_calendar_date_format
      , i_env_param6 => i_array_operations_type_id
    );
    
    l_full_export        := nvl(i_full_export, com_api_type_pkg.FALSE);
    
    if i_calendar_date is null then
        l_sysdate    := com_api_sttl_day_pkg.get_calc_date(
                            i_inst_id   => i_inst_id
                        )
        ;
    else
        case nvl(i_calendar, com_api_const_pkg.CALENDAR_GREGORIAN)
            when com_api_const_pkg.CALENDAR_JALALI
                then
                    l_sysdate :=
                        cst_smn_api_calendars_pkg.get_gregorian_from_jalali_str(
                            i_jalali_str    => i_calendar_date
                          , i_jalali_format => i_calendar_date_format
                        );
            when com_api_const_pkg.CALENDAR_GREGORIAN
                then
                    l_sysdate := to_date(i_calendar_date, i_calendar_date_format);
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'INVALID_CALENDAR'
                  , i_env_param1 => i_calendar
                );
        end case;
    end if;
    
    l_start_date := trunc(l_sysdate, 'DD');
    l_end_date   := l_start_date + 1 - com_api_const_pkg.ONE_SECOND;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Calculate date period - sysdate [#1] start_date [#2] end_date [#3]' 
      , i_env_param1 => l_sysdate
      , i_env_param2 => l_start_date
      , i_env_param3 => l_end_date
    );   
    if l_full_export = com_api_const_pkg.TRUE then
                    opr_api_external_pkg.get_operations_data(
                        i_inst_id                   => i_inst_id
                      , i_participant_type          => case i_file_type
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           else
                                                               null
                                                       end
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_object_tab                => l_object_tab
                      , i_oper_currency             => i_oper_currency
                      , i_array_operations_type_id  => i_array_operations_type_id
                      , i_array_oper_statuses_id    => i_array_oper_statuses_id
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_row_count                 => l_estimated_count
                      , o_ref_cursor                => l_ref_cursor
                    );
        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );
        
        if l_estimated_count > 0 then
            prc_api_file_pkg.open_file(
                o_sess_file_id  => l_session_file_id
              , i_file_type     => i_file_type
              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
              , io_params       => l_param_tab
            );
            loop
                fetch l_ref_cursor bulk collect into l_operations_data_tab
                limit BULK_LIMIT;
                for i in 1..l_operations_data_tab.count loop
                    l_oper_participant_tab.delete;
                    l_oper_orig_party_tab.delete;
                    opr_api_external_pkg.get_oper_participants_data(
                        i_inst_id              => i_inst_id
                      , i_oper_id              => l_operations_data_tab(i).oper_id
                      , i_mask_error           => com_api_const_pkg.TRUE
                      , o_row_count            => l_party_count_data
                      , o_ref_cursor           => l_ref_party_cursor
                    );
                    if l_party_count_data > 0 then
                        loop
                            fetch l_ref_party_cursor into l_oper_participant_rec;
                                l_oper_participant_tab(l_oper_participant_rec.participant_type) := l_oper_participant_rec;
                            exit when l_ref_party_cursor%notfound;
                        end loop;
                        close l_ref_party_cursor;
                        if l_operations_data_tab(i).original_id is not null then
                            opr_api_external_pkg.get_oper_participants_data(
                                i_inst_id              => i_inst_id
                              , i_oper_id              => l_operations_data_tab(i).original_id
                              , i_mask_error           => com_api_const_pkg.TRUE
                              , o_row_count            => l_party_count_data
                              , o_ref_cursor           => l_ref_party_cursor
                            );
                            if l_party_count_data > 0 then
                                loop
                                    fetch l_ref_party_cursor into l_oper_participant_rec;
                                        l_oper_orig_party_tab(l_oper_participant_rec.participant_type) := l_oper_participant_rec;
                                    exit when l_ref_party_cursor%notfound;
                                end loop;
                                close l_ref_party_cursor;
                            end if;
                        end if;
                        put_record_to_file(
                            i_file_type             => i_file_type
                          , i_session_file_id       => l_session_file_id
                          , i_operations_data_rec   => l_operations_data_tab(i)
                          , i_oper_participant_tab  => l_oper_participant_tab
                          , i_oper_orig_party_tab   => l_oper_orig_party_tab
                        );
                        l_processed_count := l_processed_count + 1;
                    end if;                            
                end loop;
                exit when l_ref_cursor%notfound;
            end loop;
            close l_ref_cursor;
        end if;
    elsif l_full_export = com_api_const_pkg.FALSE then
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_proc_name            => i_proc_name
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        if l_event_object_tab.count = 0 then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
        else
            for i in l_entity_tab.first .. l_entity_tab.last loop
                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'Incremental unload: count [#1] events  for entity [#2]'
                  , i_env_param1  => l_event_object_tab(l_entity_tab(i)).object_id.count
                  , i_env_param2  => l_entity_tab(i)
                );
            end loop;
            
            for i in l_entity_tab.first .. l_entity_tab.last loop
                l_request_count := ceil(l_event_object_tab(l_entity_tab(i)).object_id.count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := l_entity_tab(i);
                    l_object_tab(1).entity_type := l_entity_tab(i);
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_event_object_tab(l_entity_tab(i)).object_id.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_event_object_tab(l_entity_tab(i)).object_id(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_event_object_tab(l_entity_tab(i)).object_id(l);
                        end if;
                    end loop;
                    opr_api_external_pkg.get_operations_data(
                        i_inst_id                   => i_inst_id
                      , i_participant_type          => case i_file_type
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           else
                                                               null
                                                       end
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_object_tab                => l_object_tab
                      , i_oper_currency             => i_oper_currency
                      , i_array_operations_type_id  => i_array_operations_type_id
                      , i_array_oper_statuses_id    => i_array_oper_statuses_id
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_row_count                 => l_increment_count
                      , o_ref_cursor                => l_ref_cursor
                    );
                                        
                    if l_increment_count > 0 then
                        loop
                            fetch l_ref_cursor bulk collect into l_operations_data_tab
                            limit BULK_LIMIT;
                            
                            for m in 1..l_operations_data_tab.count loop
                                if check_add_result_line(
                                       i_entity_type              => l_entity_tab(i)
                                     , i_object_id                => l_operations_data_tab(m).oper_id
                                     , i_event_object_tab         => l_event_object_tab
                                   ) = com_api_const_pkg.TRUE
                                then
                                    if l_operations_unloading.exists(1) then
                                        l_operations_unloading(l_operations_unloading.last + 1) := l_operations_data_tab(m).oper_id;
                                    else
                                        l_operations_unloading(1) := l_operations_data_tab(m).oper_id;
                                    end if;
                                    
                                    l_estimated_count := l_estimated_count + 1;
                                    
                                    add_event_collection(
                                        i_index                  => i
                                      , i_entity_tab             => l_entity_tab
                                      , i_object_id              => l_operations_data_tab(m).oper_id
                                      , io_event_object_tab      => l_event_object_tab
                                      , io_event_tab             => l_event_tab
                                    );
                                end if;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end loop;
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
            if l_estimated_count > 0 then
                l_request_count := ceil(l_estimated_count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := opr_api_const_pkg.ENTITY_TYPE_OPERATION;
                    l_object_tab(1).entity_type := opr_api_const_pkg.ENTITY_TYPE_OPERATION;
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_operations_unloading.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_operations_unloading(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_operations_unloading(l);
                        end if;
                    end loop;
                    opr_api_external_pkg.get_operations_data(
                        i_inst_id                   => i_inst_id
                      , i_participant_type          => case i_file_type
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ACQUIRER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           when cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB
                                                               then com_api_const_pkg.PARTICIPANT_ISSUER
                                                           else
                                                               null
                                                       end
                      , i_start_date                => l_start_date
                      , i_end_date                  => l_end_date
                      , i_object_tab                => l_object_tab
                      , i_oper_currency             => i_oper_currency
                      , i_array_operations_type_id  => i_array_operations_type_id
                      , i_array_oper_statuses_id    => i_array_oper_statuses_id
                      , i_mask_error                => com_api_const_pkg.TRUE
                      , o_row_count                 => l_increment_count
                      , o_ref_cursor                => l_ref_cursor
                    );
                    if l_increment_count > 0 then
                        if l_session_file_id is null then
                            prc_api_file_pkg.open_file(
                                o_sess_file_id  => l_session_file_id
                              , i_file_type     => i_file_type
                              , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                              , io_params       => l_param_tab
                            );
                        end if;
                        loop
                            fetch l_ref_cursor bulk collect into l_operations_data_tab
                            limit BULK_LIMIT;
                                
                            for m in 1..l_operations_data_tab.count loop
                                l_oper_participant_tab.delete;
                                l_oper_orig_party_tab.delete;
                                opr_api_external_pkg.get_oper_participants_data(
                                    i_inst_id                    => i_inst_id
                                  , i_oper_id                    => l_operations_data_tab(m).oper_id
                                  , i_mask_error                 => com_api_const_pkg.TRUE
                                  , o_row_count                  => l_party_count_data
                                  , o_ref_cursor                 => l_ref_party_cursor
                                );
                                if l_party_count_data > 0 then
                                    loop
                                        fetch l_ref_party_cursor into l_oper_participant_rec;
                                            l_oper_participant_tab(l_oper_participant_rec.participant_type) := l_oper_participant_rec;
                                        exit when l_ref_party_cursor%notfound;
                                    end loop;
                                    close l_ref_party_cursor;
                                    if l_operations_data_tab(m).original_id is not null then
                                        opr_api_external_pkg.get_oper_participants_data(
                                            i_inst_id              => i_inst_id
                                          , i_oper_id              => l_operations_data_tab(m).original_id
                                          , i_mask_error           => com_api_const_pkg.TRUE
                                          , o_row_count            => l_party_count_data
                                          , o_ref_cursor           => l_ref_party_cursor
                                        );
                                        if l_party_count_data > 0 then
                                            loop
                                                fetch l_ref_party_cursor into l_oper_participant_rec;
                                                    l_oper_orig_party_tab(l_oper_participant_rec.participant_type) := l_oper_participant_rec;
                                                exit when l_ref_party_cursor%notfound;
                                            end loop;
                                            close l_ref_party_cursor;
                                        end if;
                                    end if;
                                    put_record_to_file(
                                        i_file_type             => i_file_type
                                      , i_session_file_id       => l_session_file_id
                                      , i_operations_data_rec   => l_operations_data_tab(m)
                                      , i_oper_participant_tab  => l_oper_participant_tab
                                      , i_oper_orig_party_tab   => l_oper_orig_party_tab
                                    );
                                        
                                l_processed_count := l_processed_count + 1;
                                end if;                                
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end if;
        end if;
    end if;

    if l_session_file_id is not null then
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;
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
    
    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
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
        
        l_estimated_count := nvl(l_estimated_count, 0);
        l_excepted_count  := l_estimated_count - l_processed_count;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
end proc_fin_to_shetab_detail_exp;

procedure proc_fin_to_shetab_aggr_exp(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_file_type                     in  com_api_type_pkg.t_dict_value
  , i_proc_name                     in  com_api_type_pkg.t_name
  , i_full_export                   in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                      in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date                 in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format          in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency                 in  com_api_type_pkg.t_curr_code           default null
  , i_array_oper_participant_type   in  com_api_type_pkg.t_medium_id           default null
  , i_array_operations_type_id      in  com_api_type_pkg.t_medium_id           default null
  , i_array_oper_statuses_id        in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char                 in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROC_FIN_TO_SHETAB_AGGR_EXP';
    LOG_PREFIX                 constant com_api_type_pkg.t_name := lower(PROC_NAME) || ': ';
        
    type t_aggr_curr_tab is table of com_api_type_pkg.t_money index by com_api_type_pkg.t_curr_code;
    type t_aggr_impact_tab is table of t_aggr_curr_tab index by com_api_type_pkg.t_byte_char;
    type t_aggr_trmt_tab is table of t_aggr_impact_tab index by com_api_type_pkg.t_dict_value;
    type t_aggr_prty_tab is table of t_aggr_trmt_tab index by com_api_type_pkg.t_dict_value;
    type t_aggr_optp_tab is table of t_aggr_prty_tab index by com_api_type_pkg.t_dict_value;
    
    type t_index_aggr_rec is record(
        oper_type       com_api_type_pkg.t_dict_value
      , participant     com_api_type_pkg.t_dict_value
      , terminal_type   com_api_type_pkg.t_dict_value
      , impact          com_api_type_pkg.t_sign
      , currency        com_api_type_pkg.t_curr_code
    );
    type t_index_aggr_tab is table of t_index_aggr_rec index by binary_integer;
    
    l_aggregate_tab            t_aggr_optp_tab;
    l_aggregate_index_tab      t_index_aggr_tab;
    
    l_event_object_tab         t_entity_tab;
    
    l_event_tab                com_api_type_pkg.t_number_tab;
    l_entity_tab               com_api_type_pkg.t_dict_tab;
    l_operations_unloading     com_api_type_pkg.t_number_tab;

    l_param_tab                com_api_type_pkg.t_param_tab;
    
    l_operations_aggr_data_tab opr_api_type_pkg.t_oper_external_aggr_tab;

    l_session_file_id          com_api_type_pkg.t_long_id;
    
    l_estimated_count          com_api_type_pkg.t_long_id    := 0;
    l_processed_count          com_api_type_pkg.t_long_id    := 0;
    l_excepted_count           com_api_type_pkg.t_long_id    := 0;
    l_rejected_count           com_api_type_pkg.t_long_id    := 0;
    
    l_ref_cursor               com_api_type_pkg.t_ref_cur;
    
    l_object_tab               com_api_type_pkg.t_object_tab;
    
    l_sysdate                  date;
    l_start_date               date;
    l_end_date                 date;
    
    l_increment_count          com_api_type_pkg.t_long_id := 0;
    
    l_request_count            com_api_type_pkg.t_short_id;
    
    l_full_export              com_api_type_pkg.t_boolean;
    
    procedure put_record_to_file(
        i_file_type                 in  com_api_type_pkg.t_dict_value
      , i_session_file_id           in  com_api_type_pkg.t_long_id
      , i_aggregate_index_rec       in  t_index_aggr_rec
      , i_amount                    in  com_api_type_pkg.t_money
    ) is
        l_separate_char        com_api_type_pkg.t_byte_char := nvl(i_separate_char, SEPARATE_CHAR_DEFAULT);
        l_record               com_api_type_pkg.t_text;
    begin
        if i_file_type = cst_smn_api_const_pkg.FILE_TYPE_DAILY_FIN_SHETAB then
            l_record :=
                com_api_array_pkg.conv_array_elem_v(
                    i_lov_id        => opr_api_const_pkg.LOV_ID_PARTICIPATING_PARTIES
                  , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_PRTY_CODE_SHETAB
                  , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_PRTY_CODE_SHETAB
                  , i_elem_value    => i_aggregate_index_rec.participant
                  , i_mask_error    => com_api_const_pkg.TRUE
                ) || l_separate_char;
            l_record := l_record ||
                com_api_array_pkg.conv_array_elem_v(
                    i_lov_id        => opr_api_const_pkg.LOV_ID_OPERATION_TYPES
                  , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_OPTP_CODE_SHETAB
                  , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_OPTP_CODE_SHETAB
                  , i_elem_value    => i_aggregate_index_rec.oper_type
                  , i_mask_error    => com_api_const_pkg.TRUE
                ) || l_separate_char;
            l_record := l_record ||
                com_api_array_pkg.conv_array_elem_v(
                    i_lov_id        => acq_api_const_pkg.LOV_ID_TERMINAL_TYPES
                  , i_array_type_id => cst_smn_api_const_pkg.ARRAY_TYPE_TRMT_CODE_SHETAB
                  , i_array_id      => cst_smn_api_const_pkg.ARRAY_LIST_TRMT_CODE_SHETAB
                  , i_elem_value    => i_aggregate_index_rec.terminal_type
                  , i_mask_error    => com_api_const_pkg.TRUE
                ) || l_separate_char;
            l_record := l_record || to_char(nvl(i_amount, 0), com_api_const_pkg.NUMBER_FORMAT) || l_separate_char;
            l_record := l_record ||
                case i_aggregate_index_rec.impact
                    when com_api_const_pkg.DEBIT
                        then 'D'
                    when com_api_const_pkg.CREDIT
                        then 'C'
                    else
                        null
                end;
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => i_file_type
            );
        end if;
        prc_api_file_pkg.put_line(
            i_raw_data      => l_record
          , i_sess_file_id  => i_session_file_id
        );
        prc_api_file_pkg.put_file(
            i_sess_file_id   => i_session_file_id
          , i_clob_content   => l_record || CRLF
          , i_add_to         => com_api_const_pkg.TRUE
        );
    end put_record_to_file;
    
    procedure add_aggr_data(
        i_oper_aggr_data_rec    in     opr_api_type_pkg.t_oper_external_aggr_rec
      , io_aggregate_tab        in out t_aggr_optp_tab
      , io_aggregate_index_tab  in out t_index_aggr_tab
    ) is
        l_indx    binary_integer;
        l_optp    com_api_type_pkg.t_dict_value;
        l_prty    com_api_type_pkg.t_dict_value;
        l_trmt    com_api_type_pkg.t_dict_value;
        l_impc    com_api_type_pkg.t_sign;
        l_curr    com_api_type_pkg.t_curr_code;
    begin
        l_optp    := i_oper_aggr_data_rec.oper_type;
        l_prty    := i_oper_aggr_data_rec.participant_type;
        l_trmt    := i_oper_aggr_data_rec.terminal_type;
        l_impc    := i_oper_aggr_data_rec.balance_impact;
        l_curr    := i_oper_aggr_data_rec.entry_currency;
        
        if io_aggregate_index_tab.count = 0 then
            io_aggregate_index_tab(1).oper_type     := l_optp;
            io_aggregate_index_tab(1).participant   := l_prty;
            io_aggregate_index_tab(1).terminal_type := l_trmt;
            io_aggregate_index_tab(1).impact        := l_impc;
            io_aggregate_index_tab(1).currency      := l_curr;
            io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
        else
            if io_aggregate_tab.exists(l_optp) then
                if io_aggregate_tab(l_optp).exists(l_prty) then
                    if io_aggregate_tab(l_optp)(l_prty).exists(l_trmt) then
                        if io_aggregate_tab(l_optp)(l_prty)(l_trmt).exists(l_impc) then
                            if io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc).exists(l_curr) then
                                io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := nvl(io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr), 0) + nvl(i_oper_aggr_data_rec.amount, 0);
                            else
                                l_indx := io_aggregate_index_tab.last + 1;
                                io_aggregate_index_tab(l_indx).oper_type     := l_optp;
                                io_aggregate_index_tab(l_indx).participant   := l_prty;
                                io_aggregate_index_tab(l_indx).terminal_type := l_trmt;
                                io_aggregate_index_tab(l_indx).impact        := l_impc;
                                io_aggregate_index_tab(l_indx).currency      := l_curr;
                                io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
                            end if;
                        else
                            l_indx := io_aggregate_index_tab.last + 1;
                            io_aggregate_index_tab(l_indx).oper_type     := l_optp;
                            io_aggregate_index_tab(l_indx).participant   := l_prty;
                            io_aggregate_index_tab(l_indx).terminal_type := l_trmt;
                            io_aggregate_index_tab(l_indx).impact        := l_impc;
                            io_aggregate_index_tab(l_indx).currency      := l_curr;
                            io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
                        end if;
                    else
                        l_indx := io_aggregate_index_tab.last + 1;
                        io_aggregate_index_tab(l_indx).oper_type     := l_optp;
                        io_aggregate_index_tab(l_indx).participant   := l_prty;
                        io_aggregate_index_tab(l_indx).terminal_type := l_trmt;
                        io_aggregate_index_tab(l_indx).impact        := l_impc;
                        io_aggregate_index_tab(l_indx).currency      := l_curr;
                        io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
                    end if;
                else
                    l_indx := io_aggregate_index_tab.last + 1;
                    io_aggregate_index_tab(l_indx).oper_type     := l_optp;
                    io_aggregate_index_tab(l_indx).participant   := l_prty;
                    io_aggregate_index_tab(l_indx).terminal_type := l_trmt;
                    io_aggregate_index_tab(l_indx).impact        := l_impc;
                    io_aggregate_index_tab(l_indx).currency      := l_curr;
                    io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
                end if;
            else
                l_indx := io_aggregate_index_tab.last + 1;
                io_aggregate_index_tab(l_indx).oper_type     := l_optp;
                io_aggregate_index_tab(l_indx).participant   := l_prty;
                io_aggregate_index_tab(l_indx).terminal_type := l_trmt;
                io_aggregate_index_tab(l_indx).impact        := l_impc;
                io_aggregate_index_tab(l_indx).currency      := l_curr;
                io_aggregate_tab(l_optp)(l_prty)(l_trmt)(l_impc)(l_curr) := i_oper_aggr_data_rec.amount;
            end if;
        end if;
    end add_aggr_data;
begin
    prc_api_stat_pkg.log_start;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Started with params - inst_id [#1] full_export [#2] calendar [#3] calendar_date [#4] calendar_date_format [#5] array_operations_type_id [#6'
               || '], array_oper_statuses_id [' || i_array_oper_statuses_id
               || '], array_oper_participant_type [' || i_array_oper_participant_type
               || '], proc_name [' || i_proc_name
               || '], file_type [' || i_file_type
               || '], oper_currency [' || i_oper_currency
               || '], separate_char [' || i_separate_char
               || ']'
      , i_env_param1 => i_inst_id
      , i_env_param2 => i_full_export
      , i_env_param3 => i_calendar
      , i_env_param4 => i_calendar_date
      , i_env_param5 => i_calendar_date_format
      , i_env_param6 => i_array_operations_type_id
    );
    
    l_full_export        := nvl(i_full_export, com_api_type_pkg.FALSE);
    
    if i_calendar_date is null then
        l_sysdate    := com_api_sttl_day_pkg.get_calc_date(
                            i_inst_id   => i_inst_id
                        )
        ;
    else
        case nvl(i_calendar, com_api_const_pkg.CALENDAR_GREGORIAN)
            when com_api_const_pkg.CALENDAR_JALALI
                then
                    l_sysdate :=
                        cst_smn_api_calendars_pkg.get_gregorian_from_jalali_str(
                            i_jalali_str    => i_calendar_date
                          , i_jalali_format => i_calendar_date_format
                        );
            when com_api_const_pkg.CALENDAR_GREGORIAN
                then
                    l_sysdate := to_date(i_calendar_date, i_calendar_date_format);
            else
                com_api_error_pkg.raise_error(
                    i_error      => 'INVALID_CALENDAR'
                  , i_env_param1 => i_calendar
                );
        end case;
    end if;
    
    l_start_date := trunc(l_sysdate, 'DD');
    l_end_date   := l_start_date + 1 - com_api_const_pkg.ONE_SECOND;
    
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Calculate date period - sysdate [#1] start_date [#2] end_date [#3]' 
      , i_env_param1 => l_sysdate
      , i_env_param2 => l_start_date
      , i_env_param3 => l_end_date
    );

    if l_full_export = com_api_const_pkg.TRUE then
        if i_file_type = cst_smn_api_const_pkg.FILE_TYPE_DAILY_FIN_SHETAB then
            opr_api_external_pkg.get_aggr_oper_transact_data(
                i_inst_id                    => i_inst_id
              , i_start_date                 => l_start_date
              , i_end_date                   => l_end_date
              , i_object_tab                 => l_object_tab
              , i_oper_currency              => i_oper_currency
              , i_array_oper_paricipant_type => i_array_oper_participant_type
              , i_array_operations_type_id   => i_array_operations_type_id
              , i_array_oper_statuses_id     => i_array_oper_statuses_id
              , i_aggr_operations_type       => com_api_const_pkg.TRUE
              , i_aggr_opr_participant       => com_api_const_pkg.TRUE
              , i_aggr_terminal_type         => com_api_const_pkg.TRUE
              , i_aggr_balance_impact        => com_api_const_pkg.TRUE
              , i_mask_error                 => com_api_const_pkg.TRUE
              , o_row_count                  => l_estimated_count
              , o_ref_cursor                 => l_ref_cursor
            );
        else
            com_api_error_pkg.raise_error(
                i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
              , i_env_param1 => i_file_type
            );
        end if;
        prc_api_stat_pkg.log_estimation(
            i_estimated_count   => l_estimated_count
        );
        
        if l_estimated_count > 0 then
            loop
                fetch l_ref_cursor bulk collect into l_operations_aggr_data_tab
                limit BULK_LIMIT;
                for i in 1..l_operations_aggr_data_tab.count loop
                    if l_operations_aggr_data_tab(i).oper_type is not null
                        and l_operations_aggr_data_tab(i).participant_type is not null
                        and l_operations_aggr_data_tab(i).terminal_type is not null
                        and l_operations_aggr_data_tab(i).balance_impact in (com_api_const_pkg.DEBIT, com_api_const_pkg.CREDIT)
                        and l_operations_aggr_data_tab(i).entry_currency is not null
                        and l_operations_aggr_data_tab(i).amount > 0
                    then  
                        add_aggr_data(
                            i_oper_aggr_data_rec    => l_operations_aggr_data_tab(i)
                          , io_aggregate_tab        => l_aggregate_tab
                          , io_aggregate_index_tab  => l_aggregate_index_tab
                        );
                    end if;
                end loop;
                exit when l_ref_cursor%notfound;
            end loop;
            close l_ref_cursor;
        end if;
        
    elsif l_full_export = com_api_const_pkg.FALSE then
        add_objects_in_tab(
            i_inst_id              => i_inst_id
          , i_entity_type          => opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_proc_name            => i_proc_name
          , i_sysdate              => l_sysdate
          , io_event_object_tab    => l_event_object_tab
          , io_entity_tab          => l_entity_tab
        );
        if l_event_object_tab.count = 0 then
            trc_log_pkg.debug(
                i_text        => LOG_PREFIX || 'The requested data [#1] was not found'
              , i_env_param1  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
            );
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
        else
            for i in l_entity_tab.first .. l_entity_tab.last loop
                trc_log_pkg.debug(
                    i_text        => LOG_PREFIX || 'Incremental unload: count [#1] events  for entity [#2]'
                  , i_env_param1  => l_event_object_tab(l_entity_tab(i)).object_id.count
                  , i_env_param2  => l_entity_tab(i)
                );
            end loop;
            
            for i in l_entity_tab.first .. l_entity_tab.last loop
                l_request_count := ceil(l_event_object_tab(l_entity_tab(i)).object_id.count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := l_entity_tab(i);
                    l_object_tab(1).entity_type := l_entity_tab(i);
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_event_object_tab(l_entity_tab(i)).object_id.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_event_object_tab(l_entity_tab(i)).object_id(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_event_object_tab(l_entity_tab(i)).object_id(l);
                        end if;
                    end loop;
                    opr_api_external_pkg.get_aggr_oper_transact_data(
                        i_inst_id                    => i_inst_id
                      , i_start_date                 => l_start_date
                      , i_end_date                   => l_end_date
                      , i_object_tab                 => l_object_tab
                      , i_oper_currency              => i_oper_currency
                      , i_array_oper_paricipant_type => i_array_oper_participant_type
                      , i_array_operations_type_id   => i_array_operations_type_id
                      , i_array_oper_statuses_id     => i_array_oper_statuses_id
                      , i_aggr_operations_type       => com_api_const_pkg.TRUE
                      , i_aggr_opr_participant       => com_api_const_pkg.TRUE
                      , i_aggr_terminal_type         => com_api_const_pkg.TRUE
                      , i_aggr_balance_impact        => com_api_const_pkg.TRUE
                      , i_mask_error                 => com_api_const_pkg.TRUE
                      , o_row_count                  => l_increment_count
                      , o_ref_cursor                 => l_ref_cursor
                    );
                    if l_increment_count > 0 then
                        loop
                            fetch l_ref_cursor bulk collect into l_operations_aggr_data_tab
                            limit BULK_LIMIT;
                            for m in 1..l_operations_aggr_data_tab.count loop
                                if l_operations_aggr_data_tab(m).oper_type is not null
                                    and l_operations_aggr_data_tab(m).participant_type is not null
                                    and l_operations_aggr_data_tab(m).terminal_type is not null
                                    and l_operations_aggr_data_tab(m).balance_impact in (com_api_const_pkg.DEBIT, com_api_const_pkg.CREDIT)
                                    and l_operations_aggr_data_tab(m).entry_currency is not null
                                    and l_operations_aggr_data_tab(m).amount > 0
                                then                                    
                                    l_estimated_count := l_estimated_count + 1;
                                end if;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                        for n in 1..l_object_tab(1).object_id.count loop
                            if l_operations_unloading.exists(1) then
                                l_operations_unloading(l_operations_unloading.last + 1) := l_object_tab(1).object_id(n);
                            else
                                l_operations_unloading(1) := l_object_tab(1).object_id(n);
                            end if;
                                        
                            add_event_collection(
                                i_index                  => i
                              , i_entity_tab             => l_entity_tab
                              , i_object_id              => l_object_tab(1).object_id(n)
                              , io_event_object_tab      => l_event_object_tab
                              , io_event_tab             => l_event_tab
                            );
                        end loop;
                    end if;
                end loop;
            end loop;
            prc_api_stat_pkg.log_estimation(
                i_estimated_count   => l_estimated_count
            );
            if l_estimated_count > 0 then
                l_request_count := ceil(l_estimated_count / BULK_LIMIT);
                for j in 1 .. l_request_count loop
                    if l_object_tab.exists(1) then
                        l_object_tab.delete;
                    end if;
                    l_object_tab(1).level_type  := opr_api_const_pkg.ENTITY_TYPE_OPERATION;
                    l_object_tab(1).entity_type := opr_api_const_pkg.ENTITY_TYPE_OPERATION;
                    for l in ((j - 1) * BULK_LIMIT + 1) .. least(l_operations_unloading.last, j * BULK_LIMIT)
                    loop
                        if not l_object_tab(1).object_id.exists(1) then
                            l_object_tab(1).object_id := num_tab_tpt(l_operations_unloading(l));
                        else
                            l_object_tab(1).object_id.extend;
                            l_object_tab(1).object_id(l_object_tab(1).object_id.last) := l_operations_unloading(l);
                        end if;
                    end loop;
                    opr_api_external_pkg.get_aggr_oper_transact_data(
                        i_inst_id                    => i_inst_id
                      , i_start_date                 => l_start_date
                      , i_end_date                   => l_end_date
                      , i_object_tab                 => l_object_tab
                      , i_oper_currency              => i_oper_currency
                      , i_array_oper_paricipant_type => i_array_oper_participant_type
                      , i_array_operations_type_id   => i_array_operations_type_id
                      , i_array_oper_statuses_id     => i_array_oper_statuses_id
                      , i_aggr_operations_type       => com_api_const_pkg.TRUE
                      , i_aggr_opr_participant       => com_api_const_pkg.TRUE
                      , i_aggr_terminal_type         => com_api_const_pkg.TRUE
                      , i_aggr_balance_impact        => com_api_const_pkg.TRUE
                      , i_mask_error                 => com_api_const_pkg.TRUE
                      , o_row_count                  => l_increment_count
                      , o_ref_cursor                 => l_ref_cursor
                    );
                    if l_increment_count > 0 then
                        loop
                            fetch l_ref_cursor bulk collect into l_operations_aggr_data_tab
                            limit BULK_LIMIT; 
                            for m in 1..l_operations_aggr_data_tab.count loop
                                if l_operations_aggr_data_tab(m).oper_type is not null
                                    and l_operations_aggr_data_tab(m).participant_type is not null
                                    and l_operations_aggr_data_tab(m).terminal_type is not null
                                    and l_operations_aggr_data_tab(m).balance_impact in (com_api_const_pkg.DEBIT, com_api_const_pkg.CREDIT)
                                    and l_operations_aggr_data_tab(m).entry_currency is not null
                                    and l_operations_aggr_data_tab(m).amount > 0
                                then  
                                    add_aggr_data(
                                        i_oper_aggr_data_rec    => l_operations_aggr_data_tab(m)
                                      , io_aggregate_tab        => l_aggregate_tab
                                      , io_aggregate_index_tab  => l_aggregate_index_tab
                                    );
                                end if;
                            end loop;
                            exit when l_ref_cursor%notfound;
                        end loop;
                        close l_ref_cursor;
                    end if;
                end loop;
            end if;
        end if;
    end if;
    if l_aggregate_index_tab.count > 0 then
        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_type     => i_file_type
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_param_tab
        );
        for i in l_aggregate_index_tab.first .. l_aggregate_index_tab.last
        loop
            put_record_to_file(
                i_file_type                 => i_file_type
              , i_session_file_id           => l_session_file_id
              , i_aggregate_index_rec       => l_aggregate_index_tab(i)
              , i_amount                    => l_aggregate_tab(l_aggregate_index_tab(i).oper_type)
                                                              (l_aggregate_index_tab(i).participant)
                                                              (l_aggregate_index_tab(i).terminal_type)
                                                              (l_aggregate_index_tab(i).impact)
                                                              (l_aggregate_index_tab(i).currency)
            );
            l_processed_count := l_processed_count + 1;
        end loop;
        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
        );
    end if;
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
    
    prc_api_stat_pkg.log_end(
        i_excepted_total   => l_excepted_count
      , i_processed_total  => l_processed_count
      , i_rejected_total   => l_rejected_count
      , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );
    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'Finished success'
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
        
        l_estimated_count := nvl(l_estimated_count, 0);
        l_excepted_count  := l_estimated_count - l_processed_count;
        
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_rejected_total   => l_rejected_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(code => sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;
         
end proc_fin_to_shetab_aggr_exp;

procedure proc_acq_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_911_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROC_ACQ_FIN_TO_SHETAB_EXP';
    l_oper_currency            com_api_type_pkg.t_curr_code;
begin
    l_oper_currency :=
        nvl(
            i_oper_currency
          , set_ui_value_pkg.get_system_param_v(
                i_param_name => 'NATIONAL_CURRENCY'
              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
            )
        )
    ;
    proc_fin_to_shetab_detail_exp(
        i_inst_id                   =>  i_inst_id
      , i_file_type                 =>  nvl(i_file_type, cst_smn_api_const_pkg.FILE_TYPE_ACQ_FIN_SHETAB)
      , i_proc_name                 =>  PROC_NAME
      , i_full_export               =>  i_full_export
      , i_calendar                  =>  i_calendar
      , i_calendar_date             =>  i_calendar_date
      , i_calendar_date_format      =>  i_calendar_date_format
      , i_oper_currency             =>  l_oper_currency
      , i_array_operations_type_id  =>  nvl(i_array_operations_type_id, cst_smn_api_const_pkg.ARRAY_OPER_TYPE_911_SHETAB)
      , i_array_oper_statuses_id    =>  i_array_oper_statuses_id
      , i_separate_char             =>  i_separate_char
    );
end proc_acq_fin_to_shetab_exp;

procedure proc_iss_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_912_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROC_ISS_FIN_TO_SHETAB_EXP';
    l_oper_currency            com_api_type_pkg.t_curr_code;
begin
    l_oper_currency :=
        nvl(
            i_oper_currency
          , set_ui_value_pkg.get_system_param_v(
                i_param_name => 'NATIONAL_CURRENCY'
              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
            )
        )
    ;
    proc_fin_to_shetab_detail_exp(
        i_inst_id                   =>  i_inst_id
      , i_file_type                 =>  nvl(i_file_type, cst_smn_api_const_pkg.FILE_TYPE_ISS_FIN_SHETAB)
      , i_proc_name                 =>  PROC_NAME
      , i_full_export               =>  i_full_export
      , i_calendar                  =>  i_calendar
      , i_calendar_date             =>  i_calendar_date
      , i_calendar_date_format      =>  i_calendar_date_format
      , i_oper_currency             =>  l_oper_currency
      , i_array_operations_type_id  =>  nvl(i_array_operations_type_id, cst_smn_api_const_pkg.ARRAY_OPER_TYPE_912_SHETAB)
      , i_array_oper_statuses_id    =>  i_array_oper_statuses_id
      , i_separate_char             =>  i_separate_char
    );
end proc_iss_fin_to_shetab_exp;

procedure proc_iss_scs_fin_to_shetab_exp(
    i_inst_id                   in  com_api_type_pkg.t_inst_id
  , i_file_type                 in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB
  , i_full_export               in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                  in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date             in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format      in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency             in  com_api_type_pkg.t_curr_code           default null
  , i_array_operations_type_id  in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_913_SHETAB
  , i_array_oper_statuses_id    in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char             in  com_api_type_pkg.t_byte_char
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROC_ISS_SCS_FIN_TO_SHETAB_EXP';
    l_oper_currency            com_api_type_pkg.t_curr_code;
begin
    l_oper_currency :=
        nvl(
            i_oper_currency
          , set_ui_value_pkg.get_system_param_v(
                i_param_name => 'NATIONAL_CURRENCY'
              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
            )
        )
    ;
    proc_fin_to_shetab_detail_exp(
        i_inst_id                   =>  i_inst_id
      , i_file_type                 =>  nvl(i_file_type, cst_smn_api_const_pkg.FILE_TYPE_ISS_SCS_FIN_SHETAB)
      , i_proc_name                 =>  PROC_NAME
      , i_full_export               =>  i_full_export
      , i_calendar                  =>  i_calendar
      , i_calendar_date             =>  i_calendar_date
      , i_calendar_date_format      =>  i_calendar_date_format
      , i_oper_currency             =>  l_oper_currency
      , i_array_operations_type_id  =>  nvl(i_array_operations_type_id, cst_smn_api_const_pkg.ARRAY_OPER_TYPE_913_SHETAB)
      , i_array_oper_statuses_id    =>  i_array_oper_statuses_id
      , i_separate_char             =>  i_separate_char
    );
end proc_iss_scs_fin_to_shetab_exp;

procedure proc_daily_fin_to_shetab_exp(
    i_inst_id                       in  com_api_type_pkg.t_inst_id
  , i_file_type                     in  com_api_type_pkg.t_dict_value          default cst_smn_api_const_pkg.FILE_TYPE_DAILY_FIN_SHETAB
  , i_full_export                   in  com_api_type_pkg.t_boolean             default com_api_type_pkg.FALSE
  , i_calendar                      in  com_api_type_pkg.t_dict_value          default null
  , i_calendar_date                 in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_calendar_date_format          in  cst_smn_api_calendars_pkg.t_date_full  default null
  , i_oper_currency                 in  com_api_type_pkg.t_curr_code           default null
  , i_array_oper_participant_type   in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_PRTY_921_SHETAB
  , i_array_operations_type_id      in  com_api_type_pkg.t_medium_id           default cst_smn_api_const_pkg.ARRAY_OPER_TYPE_921_SHETAB
  , i_array_oper_statuses_id        in  com_api_type_pkg.t_medium_id           default null
  , i_separate_char                 in  com_api_type_pkg.t_byte_char           
) is
    PROC_NAME                  constant com_api_type_pkg.t_name := $$PLSQL_UNIT || '.PROC_DAILY_FIN_TO_SHETAB_EXP';
    l_oper_currency            com_api_type_pkg.t_curr_code;
begin
    l_oper_currency :=
        nvl(
            i_oper_currency
          , set_ui_value_pkg.get_system_param_v(
                i_param_name => 'NATIONAL_CURRENCY'
              , i_data_type  => com_api_const_pkg.DATA_TYPE_CHAR
            )
        )
    ;
    proc_fin_to_shetab_aggr_exp(
        i_inst_id                       =>  i_inst_id
      , i_file_type                     =>  nvl(i_file_type, cst_smn_api_const_pkg.FILE_TYPE_DAILY_FIN_SHETAB)
      , i_proc_name                     =>  PROC_NAME
      , i_full_export                   =>  i_full_export
      , i_calendar                      =>  i_calendar
      , i_calendar_date                 =>  i_calendar_date
      , i_calendar_date_format          =>  i_calendar_date_format
      , i_oper_currency                 =>  l_oper_currency
      , i_array_oper_participant_type   =>  nvl(i_array_oper_participant_type, cst_smn_api_const_pkg.ARRAY_OPER_PRTY_921_SHETAB)
      , i_array_operations_type_id      =>  nvl(i_array_operations_type_id, cst_smn_api_const_pkg.ARRAY_OPER_TYPE_921_SHETAB)
      , i_array_oper_statuses_id        =>  i_array_oper_statuses_id
      , i_separate_char                 =>  i_separate_char
    );
end proc_daily_fin_to_shetab_exp;

end cst_smn_prc_outgoing_pkg;
/
