create or replace package body rpt_api_document_pkg as
/*********************************************************
 *  API for report documents <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 23.04.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Module: RPT_API_DOCUMENT_PKG <br />
 *  @headcom
 **********************************************************/

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_xml                   in      clob
) is
    l_count                 simple_integer := 0;
    l_document_type         com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text         => 'add_document Start: io_document_id[#1] i_document_number[#2] i_document_type[#3] i_document_date[#4]'
        , i_env_param1  => io_document_id
        , i_env_param2  => i_document_number
        , i_env_param3  => i_document_type
        , i_env_param4  => to_char(i_document_date, get_date_format)
    );

    select
        count(a.id)
        , min(document_type)
    into
        l_count
        , l_document_type
    from
        rpt_document a
    where
        a.id = nvl(io_document_id, 0);
        
    trc_log_pkg.debug (
        i_text          => 'add_document found document: l_count[#1] l_document_type[#2]'
        , i_env_param1  => l_count
        , i_env_param2  => l_document_type
    );

    if l_document_type is null and i_report_id is not null then
        begin
            select document_type
              into l_document_type
              from rpt_report
             where id = i_report_id;

            trc_log_pkg.debug (
                i_text          => 'add_document found document type: l_document_type[#1]'
                , i_env_param1  => l_document_type
            );
        exception
            when no_data_found then
                com_api_error_pkg.raise_error (
                    i_error         => 'REPORT_NOT_FOUND'
                    , i_env_param1  => i_report_id
                );
        end;
    end if;

    if l_count = 0 then
        if i_document_number is not null then
            select count(1)
              into l_count
              from rpt_document
             where document_number      = i_document_number
               and trunc(document_date) = trunc(nvl(i_document_date, com_api_sttl_day_pkg.get_sysdate))
               and document_type        = nvl(l_document_type, i_document_type)
               and inst_id              = i_inst_id;

            if l_count > 0 then
                com_api_error_pkg.raise_error(
                    i_error       =>  'DOCUMENT_NUMBER_DUPLICATED'
                  , i_env_param1  =>  i_document_type
                  , i_env_param2  =>  i_document_number
                  , i_env_param3  =>  nvl(i_document_date, com_api_sttl_day_pkg.get_sysdate)
                  , i_env_param4  =>  i_inst_id
                );
            end if;
        end if;

        io_document_id := com_api_id_pkg.get_id(
                              i_seq  => rpt_document_seq.nextval
                            , i_date => com_api_sttl_day_pkg.get_sysdate()
                          );
        o_seqnum := 1;

        trc_log_pkg.debug (
            i_text => 'io_document_id [' || io_document_id || ']'
        );

        insert into rpt_document_vw (
            id
            , seqnum
            , document_type
            , document_number
            , document_date
            , entity_type
            , object_id
            , inst_id
            , start_date
            , end_date
            , status
        ) values (
            io_document_id
            , o_seqnum
            , nvl(l_document_type, i_document_type)
            , i_document_number
            , nvl(i_document_date, com_api_sttl_day_pkg.get_sysdate)
            , i_entity_type
            , i_object_id
            , i_inst_id
            , i_start_date
            , i_end_date
            , i_status
        );
    else
        update
            rpt_document_vw
        set
            document_type = l_document_type
        where
            id = io_document_id
            and document_type is null
            and l_document_type is not null;
    end if;

    merge into
        rpt_document_content_vw dst
    using (
        select
            io_document_id document_id
            , i_content_type content_type
            , i_report_id report_id
            , i_template_id template_id
            , i_file_name file_name
            , i_mime_type mime_type
            , i_save_path save_path
            , i_xml document_content
        from
            dual
    ) src
    on (
        src.document_id = dst.document_id
        and src.content_type = dst.content_type
    )
    when matched then
        update
        set
            dst.report_id = src.report_id
            , dst.template_id = src.template_id
            , dst.file_name = src.file_name
            , dst.mime_type = src.mime_type
            , dst.document_content = src.document_content
    when not matched then
        insert (
            dst.id
            , dst.document_id
            , dst.content_type
            , dst.report_id
            , dst.template_id
            , dst.file_name
            , dst.mime_type
            , dst.save_path
            , dst.document_content
        ) values (
            com_api_id_pkg.get_id(
                i_seq  => rpt_document_content_seq.nextval
              , i_date => com_api_sttl_day_pkg.get_sysdate()
            )
            , src.document_id
            , src.content_type
            , src.report_id
            , src.template_id
            , src.file_name
            , src.mime_type
            , src.save_path
            , src.document_content
        );

    trc_log_pkg.debug (
        i_text          => 'add_document Finish: io_document_id[#1]'
        , i_env_param1  => io_document_id
    );
end;

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_param_tab             in      com_api_type_pkg.t_param_tab
) is
    l_data_source           clob;
    l_resultset             sys_refcursor;
    l_xml                   clob;
    l_template_id           com_api_type_pkg.t_short_id;
    l_lang                  com_api_type_pkg.t_dict_value;
    l_template              rpt_api_type_pkg.t_template_rec;
    l_file_name             com_api_type_pkg.t_name;
    l_save_path             com_api_type_pkg.t_full_desc;
    l_run_hash              com_api_type_pkg.t_name;
    l_run_id                com_api_type_pkg.t_long_id;
    l_report_exists         pls_integer;
    l_document_exists       pls_integer;
    l_signatur_exists       pls_integer;
    l_first_run_id         com_api_type_pkg.t_long_id;
begin

    if i_report_id is not null then
        begin
            select data_source
              into l_data_source
              from rpt_report
             where id = i_report_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       =>  'REPORT_NOT_FOUND'
                  , i_env_param1  =>  i_report_id
                );
        end;

        if i_template_id is null then
            l_template := rpt_api_template_pkg.get_template(
                i_report_id     => i_report_id
                , i_mask_error  => com_api_type_pkg.TRUE
            );

            l_template_id := l_template.id;
        else
            l_template_id := i_template_id;
        end if; 

        begin
            select lang
              into l_lang
              from rpt_template
             where id = l_template_id;
        exception
            when no_data_found then
                l_lang := get_def_lang;
        end;

        rpt_api_run_pkg.get_document_data(
            i_report_id         => i_report_id
          , i_param_tab         => i_param_tab
          , i_name_format_id    => null
          , i_inst_id           => i_inst_id
          , o_file_name         => l_file_name
          , o_save_path         => l_save_path
          , o_run_hash          => l_run_hash
          , o_first_run_id      => l_first_run_id
          , io_document_id      => io_document_id
          , i_content_type      => i_content_type
        );

        rpt_api_run_pkg.process_report(
            i_report_id         => i_report_id
          , i_template_id       => null
          , i_parameters        => i_param_tab
          , i_source_type       => rpt_api_const_pkg.REPORT_SOURCE_XML
          , i_lang              => l_lang
          , io_data_source      => l_data_source
          , o_resultset         => l_resultset
          , o_xml               => l_xml
        );

        if l_resultset%isopen then
            close l_resultset;
        end if;

        select existsnode(xmlparse(document l_xml), '/report/datasource/report')
             , existsnode(xmlparse(document l_xml), '/report/datasource/document')
             , existsnode(xmlparse(document l_xml), '/report/datasource/signatureRequisites')
          into l_report_exists
             , l_document_exists
             , l_signatur_exists
          from dual;

        if l_report_exists = 1 then
            select com_api_const_pkg.XML_HEADER || extract(xmlparse(document l_xml), '/report/datasource/report').getclobval()
              into l_xml
              from dual;
        elsif l_document_exists = 1 then
            select com_api_const_pkg.XML_HEADER || extract(xmlparse(document l_xml), '/report/datasource/document').getclobval()
              into l_xml
              from dual;
        elsif l_signatur_exists = 1 then
            select com_api_const_pkg.XML_HEADER || extract(xmlparse(document l_xml), '/report/datasource/signatureRequisites').getclobval()
              into l_xml
              from dual;
        end if;
        
        rpt_api_template_pkg.apply_xslt (
            i_report_id      => i_report_id
            , io_xml_source  => l_xml
        );
    end if;
    
    add_document(
        io_document_id      => io_document_id
      , o_seqnum            => o_seqnum
      , i_content_type      => i_content_type
      , i_document_type     => i_document_type
      , i_entity_type       => i_entity_type
      , i_object_id         => i_object_id
      , i_report_id         => i_report_id
      , i_template_id       => l_template_id
      , i_file_name         => nvl(i_file_name, l_file_name)
      , i_mime_type         => i_mime_type
      , i_save_path         => nvl(i_save_path, l_save_path)
      , i_document_date     => i_document_date
      , i_document_number   => i_document_number
      , i_inst_id           => i_inst_id
      , i_start_date        => i_start_date
      , i_end_date          => i_end_date
      , i_status            => i_status
      , i_xml               => l_xml
    );

    
    if i_report_id is not null then
        rpt_api_run_pkg.register_report_run(
            o_run_id            => l_run_id
          , i_report_id         => i_report_id
          , i_param_tab         => i_param_tab
          , i_run_hash          => l_run_hash
          , i_document_id       => io_document_id
          , i_status            => rpt_api_const_pkg.REPORT_STATUS_GENERATED
        );
    end if;
exception
    when others then
        if l_resultset%isopen then
            close l_resultset;
        end if;
        raise;
end;

procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
) is
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    rul_api_param_pkg.set_param('I_OBJECT_ID', i_object_id, l_param_tab);
    
    rpt_api_document_pkg.add_document(
        io_document_id     => io_document_id
      , o_seqnum           => o_seqnum
      , i_content_type     => i_content_type
      , i_document_type    => i_document_type
      , i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_report_id        => i_report_id
      , i_template_id      => i_template_id
      , i_file_name        => i_file_name
      , i_mime_type        => i_mime_type
      , i_save_path        => i_save_path
      , i_document_date    => i_document_date
      , i_document_number  => i_document_number
      , i_inst_id          => i_inst_id
      , i_start_date       => i_start_date
      , i_end_date         => i_end_date
      , i_status           => i_status
      , i_param_tab        => l_param_tab
    );
end;


procedure add_document(
    io_document_id          in out  com_api_type_pkg.t_long_id
  , o_seqnum                   out  com_api_type_pkg.t_seqnum
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_report_id             in      com_api_type_pkg.t_short_id     default null
  , i_template_id           in      com_api_type_pkg.t_short_id     default null
  , i_file_name             in      com_api_type_pkg.t_name         default null
  , i_mime_type             in      com_api_type_pkg.t_dict_value   default null
  , i_save_path             in      com_api_type_pkg.t_full_desc    default null
  , i_document_date         in      date                            default null
  , i_document_number       in      com_api_type_pkg.t_name         default null
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_start_date            in      date                            default null
  , i_end_date              in      date                            default null
  , i_status                in      com_api_type_pkg.t_dict_value   default null
  , i_param_map             in      com_param_map_tpt               
) is
    l_param_tab             com_api_type_pkg.t_param_tab;
begin
    if i_param_map is not null then
        for i in 1..i_param_map.count loop
            if i_param_map(i).char_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).char_value, l_param_tab);
                
            elsif i_param_map(i).number_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).number_value, l_param_tab);
                
            elsif i_param_map(i).date_value is not null then
                rul_api_param_pkg.set_param(upper(i_param_map(i).name), i_param_map(i).date_value, l_param_tab);
                
            else
                null;
            end if;          
        end loop;
    end if;
    
    rpt_api_document_pkg.add_document(
        io_document_id     => io_document_id
      , o_seqnum           => o_seqnum
      , i_content_type     => i_content_type
      , i_document_type    => i_document_type
      , i_entity_type      => i_entity_type
      , i_object_id        => i_object_id
      , i_report_id        => i_report_id
      , i_template_id      => i_template_id
      , i_file_name        => i_file_name
      , i_mime_type        => i_mime_type
      , i_save_path        => i_save_path
      , i_document_date    => i_document_date
      , i_document_number  => i_document_number
      , i_inst_id          => i_inst_id
      , i_start_date       => i_start_date
      , i_end_date         => i_end_date
      , i_status           => i_status
      , i_param_tab        => l_param_tab
    );
end;

procedure modify_document(
    i_document_id      in      com_api_type_pkg.t_long_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_content_type     in      com_api_type_pkg.t_dict_value
  , i_report_id        in      com_api_type_pkg.t_short_id     default null
  , i_template_id      in      com_api_type_pkg.t_short_id     default null
  , i_file_name        in      com_api_type_pkg.t_name         default null
  , i_mime_type        in      com_api_type_pkg.t_dict_value   default null
  , i_save_path        in      com_api_type_pkg.t_full_desc    default null
  , i_document_date    in      date                            default null
  , i_document_number  in      com_api_type_pkg.t_name         default null
  , i_document_type    in      com_api_type_pkg.t_dict_value   default null
  , i_start_date       in      date                            default null
  , i_end_date         in      date                            default null
  , i_status           in      com_api_type_pkg.t_dict_value   default null
  , i_content          in      clob                            default null
) is
    l_count            pls_integer;
begin

    if i_document_number is not null then
        select count(1)
          into l_count
          from rpt_document a
             , rpt_document b
         where a.document_number      = nvl(i_document_number, b.document_number)
           and trunc(a.document_date) = trunc(nvl(i_document_date, b.document_date))
           and a.document_type        = b.document_type
           and a.inst_id              = b.inst_id
           and a.id                  != b.id
           and b.id                   = i_document_id;
                   
        if l_count > 0 then
            com_api_error_pkg.raise_error(
                i_error       =>  'DOCUMENT_NUMBER_DUPLICATED'
              , i_env_param1  =>  i_document_type
              , i_env_param2  =>  i_document_number
              , i_env_param3  =>  nvl(i_document_date, com_api_sttl_day_pkg.get_sysdate)
            );
        end if;
            
    end if;

    select seqnum
      into io_seqnum
      from rpt_document 
     where id = i_document_id;

    io_seqnum := io_seqnum + 1;

    update rpt_document a
       set a.seqnum        = io_seqnum
         , a.document_type = nvl(i_document_type, a.document_type)
         , document_number = nvl(i_document_number, document_number)
         , document_date   = nvl(i_document_date, document_date)
         , start_date      = nvl(i_start_date, a.start_date)
         , end_date        = nvl(i_end_date, a.end_date)
         , status          = nvl(i_status, a.status)
     where a.id            = i_document_id;

    for rec in (
        select b.id
             , b.report_id
             , b.template_id
             , b.file_name
             , b.mime_type
             , b.save_path
             , b.document_content
          from rpt_document_content b
         where b.document_id  = i_document_id
           and b.content_type = i_content_type
    ) loop
        update rpt_document_content_vw b
           set b.document_content = nvl(i_content, rec.document_content)
             , b.report_id        = nvl(i_report_id, rec.report_id)
             , b.template_id      = nvl(i_template_id, rec.template_id)
             , b.file_name        = nvl(i_file_name, rec.file_name)
             , b.mime_type        = nvl(i_mime_type, rec.mime_type)
             , b.save_path        = nvl(i_save_path, rec.save_path)
         where b.id               = rec.id;
        return;
    end loop;

    insert into rpt_document_content_vw b(
        id
      , document_id
      , content_type
      , report_id
      , template_id
      , file_name
      , mime_type
      , save_path
      , document_content
    ) values (
        com_api_id_pkg.get_id(
            i_seq  => rpt_document_content_seq.nextval
          , i_date => com_api_sttl_day_pkg.get_sysdate()
        )
      , i_document_id
      , i_content_type
      , i_report_id
      , i_template_id
      , i_file_name
      , i_mime_type
      , i_save_path
      , i_content
    );

end;

function get_document (
    i_document_id           in com_api_type_pkg.t_short_id
  , i_content_type          in com_api_type_pkg.t_dict_value
) return rpt_api_type_pkg.t_document_rec is
    l_result               rpt_api_type_pkg.t_document_rec;
begin
    select
        a.id
      , a.seqnum
      , document_type
      , document_number
      , document_date
      , entity_type
      , object_id
      , report_id
      , template_id
      , file_name
      , mime_type
      , save_path
      , inst_id
      , start_date
      , end_date
      , status
    into
        l_result
    from
        rpt_document a
      , rpt_document_content b
    where
        a.id = i_document_id
    and
        a.id = b.document_id
    and
        b.document_id = i_document_id
    and
        b.content_type = i_content_type;

    return l_result;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error         => 'REPORT_DOCUMENT_NOT_FOUND'
            , i_env_param1  => i_document_id
        );
end;

procedure add_document_type(
    o_id                       out  com_api_type_pkg.t_tiny_id
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_is_report             in      com_api_type_pkg.t_boolean
) is
begin
    o_id := rpt_document_type_seq.nextval;
    
    insert into rpt_document_type(
        id
      , document_type
      , content_type
      , is_report
    ) values (
        o_id
      , i_document_type
      , i_content_type
      , i_is_report
    );
end;

procedure modify_document_type(
    i_id                    in      com_api_type_pkg.t_tiny_id
  , i_document_type         in      com_api_type_pkg.t_dict_value
  , i_content_type          in      com_api_type_pkg.t_dict_value
  , i_is_report             in      com_api_type_pkg.t_boolean
) is
begin
    update
        rpt_document_type a
    set
        a.document_type = i_document_type
      , a.content_type  = i_content_type
      , a.is_report     = i_is_report
    where
        a.id = i_id;
end;

procedure show_document(
    o_xml                  out  clob
  , i_object_id         in      com_api_type_pkg.t_long_id
) is
begin
    select extract(xmlparse(document c.document_content), '*').getclobval()
      into o_xml
      from rpt_document d
         , rpt_document_content c
     where d.id = i_object_id
       and c.document_id   = d.id
       and c.content_type  = rpt_api_const_pkg.CONTENT_TYPE_PRINT_FORM;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error => 'REPORT_DOCUMENT_NOT_FOUND'
          , i_env_param1 => i_object_id
        );
end;


procedure get_content(
    o_xml                  out  clob
  , i_document_id       in      com_api_type_pkg.t_long_id
  , i_content_type      in      com_api_type_pkg.t_dict_value
) is
begin
    select extract(xmlparse(document c.document_content), '*').getclobval()
      into o_xml
      from rpt_document d
         , rpt_document_content c
     where d.id            = i_document_id
       and c.document_id   = d.id
       and c.content_type  = i_content_type;
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'REPORT_DOCUMENT_NOT_FOUND'
          , i_env_param1  => i_document_id
        );
end get_content;

end;
/
