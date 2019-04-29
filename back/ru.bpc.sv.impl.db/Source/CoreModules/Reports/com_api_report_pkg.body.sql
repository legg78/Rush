create or replace package body com_api_report_pkg is

function get_subject(
    i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_name 
is
    l_result            com_api_type_pkg.t_name;
    l_account_number    com_api_type_pkg.t_account_number;
    
begin
    if i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        select account_number 
          into l_account_number
          from acc_account 
         where id = i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error           => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1      => i_entity_type
        );
    end if;

    l_result := 'Notification of account ' || l_account_number;

    return l_result;
end get_subject;

procedure notification_with_attach_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_start_date        in     date
  , i_end_date          in     date
  , i_document_type     in     com_api_type_pkg.t_dict_value
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
) is
    l_result                    xmltype;
    l_attach                    xmltype;
    l_subject                   com_api_type_pkg.t_full_desc;
    l_lang                      com_api_type_pkg.t_dict_value;
    l_eff_date                  date;
begin
     trc_log_pkg.debug(
        i_text       => 'Notification with attachment event [#1] [#2] [#3] [#4] [#5]'
      , i_env_param1 => i_event_type
      , i_env_param2 => i_lang
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_entity_type
      , i_env_param5 => i_object_id
    );

    l_lang     := nvl(i_lang, get_user_lang);
    l_eff_date := nvl(i_eff_date, get_sysdate);

    if i_entity_type <> acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_TYPE_NOT_SUPPORTED'
          , i_env_param1 => i_entity_type
        );
    end if;

    l_subject := get_subject(
        i_entity_type  => i_entity_type
      , i_object_id    => i_object_id
    );

    --attachment
    begin
        select xmlagg(
                    xmlelement("attachment",
                        xmlelement("attachment_path", t.attach_path)
                      , xmlelement("attachment_name", t.file_name)
                    )
                )
        into l_attach
        from (
        select c.file_name
             , c.save_path attach_path
          from rpt_document d
             , rpt_document_content c
         where object_id     = i_object_id
           and entity_type   = i_entity_type
           and document_type = i_document_type
           and c.document_id = d.id
        ) t;

    exception
        when no_data_found then
            null; --error?
    end;

    select
        xmlelement("report"
          , xmlelement("subject",              l_subject)
          , xmlelement("attachments",          l_attach)
          , xmlelement("customer_number",      t.customer_number)
          , xmlelement("first_name",           t.first_name)
          , xmlelement("second_name",          t.second_name)
          , xmlelement("surname",              t.surname)
          , xmlelement("document_type",        i_document_type)
          , xmlelement("start_date" ,          to_char(i_start_date, 'DD/MM/YYYY'))
          , xmlelement("end_date" ,            to_char(i_end_date,   'DD/MM/YYYY'))
          , xmlelement("entity_type",          i_entity_type)
          , xmlelement("object_id",            i_object_id)
        )
    into l_result
    from (
        select s.customer_number
             , com_ui_person_pkg.get_first_name(i_person_id => s.object_id, i_lang => l_lang) first_name
             , com_ui_person_pkg.get_second_name(i_person_id => s.object_id, i_lang => l_lang) second_name
             , com_ui_person_pkg.get_surname(i_person_id => s.object_id, i_lang => l_lang) surname
          from acc_account a
             , prd_customer s 
         where a.id           = i_object_id
           and a.customer_id  = s.id
    ) t;

    o_xml := l_result.getclobval();

    trc_log_pkg.debug (
        i_text       => 'end'
    );

exception
    when com_api_error_pkg.e_application_error or com_api_error_pkg.e_fatal_error then
        raise;
    when others then
        com_api_error_pkg.raise_fatal_error(
            i_error      => 'UNHANDLED_EXCEPTION'
          , i_env_param1 => sqlerrm
        );
end notification_with_attach_event;

end com_api_report_pkg;
/
