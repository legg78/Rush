create or replace package body atm_api_notification_pkg as

procedure report_atm_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_notify_party_type in     com_api_type_pkg.t_dict_value    default null
) is
    l_result            xmltype;
begin
    trc_log_pkg.debug(
        i_text       => 'ATM event notification report [#1] [#2] [#3] [#4] [#5] [#6]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
      , i_env_param6 => i_eff_date
    );
    
    with previous_status as (
        select l.atm_part_type
             , l.dict
             , l.status
             , com_api_dictionary_pkg.get_article_desc(
                                          i_article => l.status
                                        , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE
                                      ) status_desc
          from (select distinct
                       l.atm_part_type
                     , substr(l.status, 1, 4) as dict
                     , first_value(l.status) over (
                           partition by
                               l.atm_part_type
                             , substr(l.status, 1, 4)
                           order by
                               l.change_date desc
                       ) as status
                  from atm_status_log l
                 where l.terminal_id = i_object_id
                   and l.change_date < i_eff_date
                ) l
    )
    select xmlelement("report"
             , xmlelement("terminal_number", qt.terminal_number)
             , xmlelement("atm_address", com_api_address_pkg.get_address_string(
                                             i_address_id => acq_api_terminal_pkg.get_terminal_address_id(
                                                                 i_terminal_id => t.id
                                                               , i_lang        => i_lang
                                                             )
                                         )
               )
             , xmlelement("event_type"
                 , xmlelement("code", i_event_type)
                 , xmlelement("name", com_api_dictionary_pkg.get_article_text(
                                          i_article => i_event_type
                                        , i_lang    => i_lang
                                      )
                   )
               )
             , xmlelement("card_reader_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_CARD_READER)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.card_reader_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Receipt Printer (G) [HCDT]
             , xmlelement("rcpt_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
                                             and v.dict          = atm_api_const_pkg.PRINTER_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.rcpt_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("rcpt_paper_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
                                             and v.dict          = atm_api_const_pkg.PAPER_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.rcpt_paper_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("rcpt_ribbon_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
                                             and v.dict          = atm_api_const_pkg.RIBBON_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.rcpt_ribbon_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("rcpt_head_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
                                             and v.dict          = atm_api_const_pkg.HEAD_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.rcpt_head_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("rcpt_knife_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_RECEIPT_PRINTER
                                             and v.dict          = atm_api_const_pkg.KNIFE_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.rcpt_knife_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Journal Printer (H) [HCDT]
             , xmlelement("jrnl_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
                                             and v.dict          = atm_api_const_pkg.JRNL_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.jrnl_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("jrnl_paper_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
                                             and v.dict          = atm_api_const_pkg.PAPER_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.jrnl_paper_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("jrnl_ribbon_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
                                             and v.dict          = atm_api_const_pkg.RIBBON_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.jrnl_ribbon_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("jrnl_head_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_JOURNAL_PRINTER
                                             and v.dict          = atm_api_const_pkg.HEAD_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.jrnl_head_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Eletronic Journal
             , xmlelement("ejrnl_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_ELECTRON_JOURNAL
                                             and v.dict          = atm_api_const_pkg.EJRN_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.ejrnl_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("ejrnl_space_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_ELECTRON_JOURNAL
                                             and v.dict         != atm_api_const_pkg.EJRN_STATUS_DICT) -- unknown dictionary
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.ejrnl_space_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Statement Printer (V) [HCDT]
             , xmlelement("stmt_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.STPR_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("stmt_paper_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.PAPER_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_paper_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("stmt_ribbon_stat"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.RIBBON_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_ribbon_stat
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("stmt_head_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.HEAD_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_head_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("stmt_knife_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.KNIFE_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_knife_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("stmt_capt_bin_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_STMT_PRINTER
                                             and v.dict          = atm_api_const_pkg.STMT_CAPT_BIN_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.stmt_capt_bin_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Other ARM parts
             , xmlelement("tod_clock_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_TOD_CLOCK)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.tod_clock_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("depository_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_ENV_DEPOSITORY)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.depository_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("night_safe_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_NIGHT_SAFE_DPST)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.night_safe_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("encryptor_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_ENCRYPTOR)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.encryptor_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("tscreen_keyb_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_CARDHLDR_DISPLAY)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.tscreen_keyb_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("voice_guidance_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_VOICE_GUIDANCE)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.voice_guidance_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("camera_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_SECURITY_CAMERA)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.camera_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("bunch_acpt_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_NOTE_ACCEPTOR)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.bunch_acpt_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("envelope_disp_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_ENV_DISPENSER)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.envelope_disp_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("cheque_module_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_CHK_PROCESS_MOD)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.cheque_module_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("barcode_reader_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_BARCODE_READER)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.barcode_reader_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("coin_disp_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_COIN_DISPENSER)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.coin_disp_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("dispenser_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.atm_part_type = atm_api_const_pkg.ATM_PART_TYPE_DISPENSER)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.dispenser_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("workflow_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.dict = atm_api_const_pkg.WORKFLOW_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.workflow_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("service_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.dict = atm_api_const_pkg.SERVICE_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.service_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
             , xmlelement("connection_status"
                 , xmlelement("previous", (select v.status_desc
                                            from previous_status v
                                           where v.dict = atm_api_const_pkg.CONECTION_STATUS_DICT)
                   )
                 , xmlelement("current", com_api_dictionary_pkg.get_article_desc(
                                                i_article => td.connection_status
                                              , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                   )
               )
               -- Dispensers
             , (select xmlagg(
                           xmlelement("dispenser"
                             , xmlelement("disp_number",     d.disp_number)
                             , xmlelement("dispenser_type"  
                                 , xmlelement("code", d.dispenser_type)
                                 , xmlelement("name", com_api_dictionary_pkg.get_article_text(
                                                          i_article => d.dispenser_type
                                                        , i_lang    => i_lang
                                                      )
                                   )
                               )
                             , xmlelement("face_value",      d.face_value)
                             , xmlelement("currency",        d.currency)
                             , xmlelement("note_loaded",     dd.note_loaded)
                             , xmlelement("note_dispensed",  dd.note_dispensed)
                             , xmlelement("note_remained",   dd.note_remained)
                             , xmlelement("note_rejected",   dd.note_rejected)
                             , xmlelement("cassette_status", 
                                              com_api_dictionary_pkg.get_article_desc(
                                                    i_article => dd.cassette_status
                                                  , i_lang    => com_api_const_pkg.DEFAULT_LANGUAGE)
                                         )
                           )
                           order by d.disp_number
                       )
                  from atm_dispenser d
                  left join atm_dispenser_dynamic dd on dd.id = d.id
                 where d.terminal_id = t.id
               )
           )
      into l_result
      from atm_terminal t
      join acq_terminal qt              on qt.id = t.id  
      left join atm_terminal_dynamic td on td.id = t.id
     where t.id = i_object_id;

    o_xml := l_result.getclobval();
exception
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end report_atm_event;

end;
/
