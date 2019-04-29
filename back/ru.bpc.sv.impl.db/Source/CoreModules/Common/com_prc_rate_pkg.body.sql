create or replace package body com_prc_rate_pkg as
/*********************************************************
 *  Process for load currency rates <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.06.2013 <br />
 *  Last changed by $Author: truschelev $ <br />
 *  $LastChangedDate:: 2015-11-10 18:15:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 13781 $ <br />
 *  Module: com_prc_rate_pkg   <br />
 *  @headcom
 **********************************************************/
    BULK_LIMIT                  constant integer := 400;
    CRLF                        constant com_api_type_pkg.t_name := chr(13)||chr(10);

    procedure load_rates_2_0(
        i_unload_file       in      com_api_type_pkg.t_boolean        default null
    ) is
        l_rates                     sys_refcursor;

        l_inst_id                   com_api_type_pkg.t_inst_id_tab;
        l_rate_type                 com_api_type_pkg.t_dict_tab;
        l_effective_date            com_api_type_pkg.t_date_tab;
        l_expiration_date           com_api_type_pkg.t_date_tab;
        l_src_scale                 com_api_type_pkg.t_number_tab;
        l_src_currency              com_api_type_pkg.t_curr_code_tab;
        l_src_exponent_scale        com_api_type_pkg.t_number_tab;
        l_dst_scale                 com_api_type_pkg.t_number_tab;
        l_dst_currency              com_api_type_pkg.t_curr_code_tab;
        l_dst_exponent_scale        com_api_type_pkg.t_number_tab;
        l_inverted                  com_api_type_pkg.t_boolean_tab;
        l_rate                      com_api_type_pkg.t_number_tab;

        l_id                        com_api_type_pkg.t_short_id;
        l_seqnum                    com_api_type_pkg.t_tiny_id;
        l_count                     number;

        l_excepted_count            com_api_type_pkg.t_long_id := 0;
        l_processed_count           com_api_type_pkg.t_long_id := 0;
            
        l_sess_file_id              com_api_type_pkg.t_long_id;
        
        l_file                      clob;
        l_response_content          xmltype;
        l_file_params               com_api_type_pkg.t_param_tab;

        procedure enum_rates(
            o_rates               in out sys_refcursor
          , i_content             in     xmltype
        ) is
        begin
            open o_rates for
                select
                    inst_id
                    , rate_type
                    , to_date(effective_date, com_api_const_pkg.XML_DATETIME_FORMAT) effective_date
                    , to_date(expiration_date, com_api_const_pkg.XML_DATETIME_FORMAT) expiration_date
                    , src_scale
                    , src_currency
                    , src_exponent_scale
                    , dst_scale
                    , dst_currency
                    , dst_exponent_scale
                    , nvl(inverted, 0) inverted
                    , rate
                from
                    xmltable(xmlnamespaces(default 'http://sv.bpc.in/SVXP')
                        , '/currency_rates/currency_rate'
                        passing i_content
                        columns
                            inst_id               integer        path 'inst_id'
                            , rate_type           varchar2(8)    path 'rate_type'
                            , effective_date      varchar2(100)  path 'effective_date'
                            , expiration_date     varchar2(100)  path 'expiration_date'
                            , src_scale           number         path 'src_currency/scale'
                            , src_currency        varchar2(3)    path 'src_currency/currency'
                            , src_exponent_scale  number         path 'src_currency/exponent_scale'
                            , dst_scale           number         path 'dst_currency/scale'
                            , dst_currency        varchar2(3)    path 'dst_currency/currency'
                            , dst_exponent_scale  number         path 'dst_currency/exponent_scale'
                            , inverted            integer        path 'inverted'
                            , rate                number         path 'rate'
                    ) c;
        end enum_rates;

    begin
        savepoint load_currency_rates;

        prc_api_stat_pkg.log_start;

        -- get files
        for r in (
            select
                s.file_name
              , s.file_xml_contents xml_content
            from
                prc_session_file s
                , prc_file_attribute_vw a
                , prc_file_vw f
            where
                s.session_id       = prc_api_session_pkg.get_session_id
                and s.file_attr_id = a.id
                and f.id           = a.file_id
                and f.file_purpose = prc_api_const_pkg.FILE_PURPOSE_IN
                and f.file_nature  = prc_api_const_pkg.FILE_NATURE_XML
            order by
                s.id
        ) loop
            trc_log_pkg.debug(
                i_text        => 'Process file [#1]'
              , i_env_param1  => r.file_name
            );

            enum_rates(
                o_rates     => l_rates
              , i_content   => r.xml_content
            );

            loop
               fetch l_rates
               bulk collect into
                  l_inst_id
                , l_rate_type
                , l_effective_date
                , l_expiration_date
                , l_src_scale
                , l_src_currency
                , l_src_exponent_scale
                , l_dst_scale
                , l_dst_currency
                , l_dst_exponent_scale
                , l_inverted
                , l_rate
                limit BULK_LIMIT;

                for i in 1 .. l_inst_id.count loop
                    begin
                        com_api_rate_pkg.set_rate(
                            o_id            => l_id
                          , o_seqnum        => l_seqnum
                          , o_count         => l_count
                          , i_src_currency  => l_src_currency(i)
                          , i_dst_currency  => l_dst_currency(i)
                          , i_rate_type     => l_rate_type(i)
                          , i_inst_id       => l_inst_id(i)
                          , i_eff_date      => l_effective_date(i)
                          , i_rate          => l_rate(i)
                          , i_inverted      => l_inverted(i)
                          , i_src_scale     => l_src_scale(i)
                          , i_dst_scale     => l_dst_scale(i)
                          , i_exp_date      => l_expiration_date(i)
                        );

                        if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                            select xmlconcat(
                                       l_response_content
                                     , xmlelement("currency_rate",
                                            xmlelement("inst_id",   l_inst_id(i)),
                                            xmlelement("rate_type",   l_rate_type(i)),
                                            xmlelement("effective_date", l_effective_date(i)),
                                            xmlelement("expiration_date", l_expiration_date(i)),
                                            xmlelement("src_currency",
                                                xmlelement("scale", l_src_scale(i)),
                                                xmlelement("currency", l_src_currency(i)),
                                                xmlelement("exponent_scale", l_src_exponent_scale(i))),
                                            xmlelement("dst_currency",
                                                xmlelement("scale", l_dst_scale(i)),
                                                xmlelement("currency", l_dst_currency(i)),
                                                xmlelement("exponent_scale", l_dst_exponent_scale(i))),
                                            xmlelement("rate", l_rate(i)),
                                            xmlelement("inverted", l_inverted(i)),
                                            xmlelement("result_code", prc_api_const_pkg.INCOM_FILE_REC_SUCCESS)
                                       )
                                   )
                              into l_response_content
                              from dual;
                        end if;
                                
                        l_processed_count := l_processed_count + 1;

                    exception
                        when others then
                            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                                if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
                                    select xmlconcat(
                                               l_response_content
                                             , xmlelement("currency_rate",
                                                    xmlelement("inst_id",   l_inst_id(i)),
                                                    xmlelement("rate_type",   l_rate_type(i)),
                                                    xmlelement("effective_date", l_effective_date(i)),
                                                    xmlelement("expiration_date", l_expiration_date(i)),
                                                    xmlelement("src_currency",
                                                        xmlelement("scale", l_src_scale(i)),
                                                        xmlelement("currency", l_src_currency(i)),
                                                        xmlelement("exponent_scale", l_src_exponent_scale(i))),
                                                    xmlelement("dst_currency",
                                                        xmlelement("scale", l_dst_scale(i)),
                                                        xmlelement("currency", l_dst_currency(i)),
                                                        xmlelement("exponent_scale", l_dst_exponent_scale(i))),
                                                    xmlelement("rate", l_rate(i)),
                                                    xmlelement("inverted", l_inverted(i)),
                                                    xmlelement("result_code", prc_api_const_pkg.INCOM_FILE_REC_ERROR),
                                                    xmlelement("error_code", com_api_error_pkg.get_last_error)
                                               )
                                           )
                                      into l_response_content
                                      from dual;
                                end if;
                                l_excepted_count := l_excepted_count + 1;
                            else
                                raise;
                            end if;
                    end;
                end loop;

                prc_api_stat_pkg.log_current(
                    i_current_count   => l_processed_count
                  , i_excepted_count  => l_excepted_count
                );
                exit when l_rates%notfound;
            end loop;

            close l_rates;

            if nvl(i_unload_file, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE then
            
                rul_api_param_pkg.set_param(
                    i_name      => 'ORIGINAL_FILE_NAME'
                  , i_value     => r.file_name
                  , io_params   => l_file_params
                );
            
                prc_api_file_pkg.open_file(
                    o_sess_file_id  => l_sess_file_id
                  , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
                  , io_params       => l_file_params
                );
                
                l_file := com_api_const_pkg.XML_HEADER
                            || '<currency_rates>'
                            || l_response_content.getclobval()
                            || '</currency_rates>';


                prc_api_file_pkg.put_file(
                    i_sess_file_id  => l_sess_file_id
                  , i_clob_content  => l_file
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_sess_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                );
                
                l_file := null;
                l_response_content := null;
            
            end if;
        end loop;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count  => l_processed_count
        );

        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_excepted_count
          , i_processed_total  => l_processed_count
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        prc_api_stat_pkg.log_end(
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

    exception
        when others then
            rollback to savepoint load_currency_rates;

            if l_rates%isopen then
                close l_rates;
            end if;

            prc_api_stat_pkg.log_end(
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;

            raise;

    end load_rates_2_0;

    procedure load_rates(
        i_dict_version      in      com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
      , i_unload_file       in      com_api_type_pkg.t_boolean        default null
    ) is
    begin
        trc_log_pkg.debug(
            i_text        => 'com_prc_rate_pkg.load_rates: START with i_dict_version [#1], i_unload_file [#2]'
          , i_env_param1  => i_dict_version
          , i_env_param2  => i_unload_file
        );

        if i_dict_version between '1.0' and '2.0' then
            load_rates_2_0(
               i_unload_file  => i_unload_file
            );
        else
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'VERSION_IS_NOT_SUPPORTED'
              , i_env_param1  => i_dict_version
            );
        end if;
    end load_rates;

    procedure unload_rates(
        i_dict_version              in     com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
      , i_inst_id                in     com_api_type_pkg.t_inst_id        default null
      , i_eff_date                  in     date                              default null
      , i_full_export               in     com_api_type_pkg.t_boolean        default null
      , i_base_rate_export          in     com_api_type_pkg.t_boolean        default null
      , i_rate_type                 in     com_api_type_pkg.t_dict_value     default null
      , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
    ) is
        l_session_file_id           com_api_type_pkg.t_long_id;
        l_file                      clob;
        l_file_type                 com_api_type_pkg.t_dict_value;
        l_full_export               com_api_type_pkg.t_boolean;
        l_estimated_count           com_api_type_pkg.t_count := 0;
        l_temp                      com_api_type_pkg.t_short_id;
        l_eff_date                  date;

        l_event_tab                 com_api_type_pkg.t_number_tab;
        l_rate_id_tab               num_tab_tpt;

        l_processed_count           com_api_type_pkg.t_count := 0;
        l_total_processed           com_api_type_pkg.t_count := 0;
        l_current_count             com_api_type_pkg.t_count := 0;
        l_params                    com_api_type_pkg.t_param_tab;

    begin
        savepoint unload_currency_rates;

        trc_log_pkg.debug(
            i_text        => 'com_prc_rate_pkg.unload_rates: START with i_dict_version [#1], i_inst_id [#2] i_eff_date [#3] i_full_export [#4] i_base_rate_export [#5] i_rate_type [#6]'
          , i_env_param1  => i_dict_version
          , i_env_param2  => i_inst_id
          , i_env_param3  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
          , i_env_param4  => i_full_export
          , i_env_param5  => i_base_rate_export
          , i_env_param6  => i_rate_type
        );

        prc_api_stat_pkg.log_start;
        l_full_export   := nvl(i_full_export, com_api_type_pkg.FALSE);
        l_eff_date      := nvl(i_eff_date, com_api_sttl_day_pkg.get_sysdate);
        
        l_temp := 
            com_itf_dict_pkg.execute_rate_query(
                i_count_query_only          => com_api_type_pkg.FALSE
              , i_get_rate_id_tab           => com_api_const_pkg.TRUE
              , i_dict_version              => i_dict_version
              , i_inst_id                   => nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
              , i_eff_date                  => l_eff_date
              , i_full_export               => l_full_export
              , i_base_rate_export          => i_base_rate_export
              , i_rate_type                 => i_rate_type
              , i_replace_inst_id_by_number => com_api_type_pkg.FALSE
              , i_entry_point               => com_api_const_pkg.ENTRYPOINT_EXPORT
              , io_xml                      => l_file
              , io_rate_id_tab              => l_rate_id_tab
              , io_event_tab                => l_event_tab
            );
        l_estimated_count := l_rate_id_tab.count;

        prc_api_stat_pkg.log_estimation(
            i_estimated_count => l_estimated_count
        );
        trc_log_pkg.debug(
            i_text        => 'Estimated count [#1]'
          , i_env_param1  => l_estimated_count
        );

        for inst in (
            select i.id 
              from ost_institution_vw i
             where (i.id = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST or i_inst_id is null)
               and i.id != ost_api_const_pkg.UNIDENTIFIED_INST
        ) loop
  
            l_temp := com_itf_dict_pkg.execute_rate_query(
                          i_count_query_only          => null
                        , i_get_rate_id_tab           => com_api_const_pkg.TRUE
                        , i_dict_version              => i_dict_version
                        , i_inst_id                   => inst.id
                        , i_eff_date                  => l_eff_date
                        , i_full_export               => l_full_export
                        , i_base_rate_export          => null
                        , i_rate_type                 => i_rate_type
                        , i_replace_inst_id_by_number => com_api_type_pkg.FALSE
                        , i_entry_point               => com_api_const_pkg.ENTRYPOINT_EXPORT
                        , io_xml                      => l_file
                        , io_rate_id_tab              => l_rate_id_tab
                        , io_event_tab                => l_event_tab
                      );

            l_current_count := l_rate_id_tab.count;

            trc_log_pkg.debug(
                i_text => 'l_rate_id_tab.count = '|| l_current_count || ' inst.id=' || inst.id
            );

            l_processed_count := com_itf_dict_pkg.execute_rate_query(
                                     i_count_query_only          => com_api_type_pkg.FALSE
                                   , i_get_rate_id_tab           => com_api_const_pkg.FALSE
                                   , i_dict_version              => i_dict_version
                                   , i_inst_id                   => inst.id
                                   , i_eff_date                  => l_eff_date
                                   , i_full_export               => l_full_export
                                   , i_base_rate_export          => i_base_rate_export
                                   , i_rate_type                 => i_rate_type
                                   , i_replace_inst_id_by_number => com_api_type_pkg.FALSE
                                   , i_entry_point               => com_api_const_pkg.ENTRYPOINT_EXPORT
                                   , io_xml                      => l_file
                                   , io_rate_id_tab              => l_rate_id_tab
                                   , io_event_tab                => l_event_tab
                                 );

            if l_processed_count > l_current_count
               and nvl(i_base_rate_export, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
            then
                l_estimated_count := l_estimated_count + (l_processed_count - l_current_count);
                prc_api_stat_pkg.log_estimation(
                    i_estimated_count => l_estimated_count
                );
            end if;

            if l_processed_count > 0 then
                l_total_processed := l_total_processed + l_processed_count;
                rul_api_param_pkg.set_param(
                    i_name     => 'INST_ID'
                  , i_value    => inst.id
                  , io_params  => l_params
                );

                prc_api_file_pkg.open_file(
                    o_sess_file_id => l_session_file_id
                  , i_file_type    => l_file_type
                  , io_params      => l_params
                );

                l_file := com_api_const_pkg.XML_HEADER || CRLF || l_file;

                prc_api_file_pkg.put_file(
                    i_sess_file_id  => l_session_file_id
                  , i_clob_content  => l_file
                );

                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
                  , i_record_count  => l_processed_count
                );

                trc_log_pkg.debug('file saved, inst_id=' || inst.id || ', cnt=' 
                                || l_processed_count || ', length=' || length(l_file));

            end if;
            
            if l_full_export = com_api_type_pkg.FALSE then
                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab => l_event_tab
                );
            end if;

        end loop;
        prc_api_stat_pkg.log_end(
            i_excepted_total   => l_estimated_count - l_total_processed
          , i_processed_total  => l_total_processed
          , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
        );

        trc_log_pkg.debug(
            i_text        => 'com_prc_rate_pkg.unload_rates: FINISH with l_processed_count [#1]'
          , i_env_param1  => l_processed_count
        );

    exception
        when others then
            rollback to savepoint unload_currency_rates;

            prc_api_stat_pkg.log_end(
                i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
            );

            if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
                raise;
            elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_fatal_error(
                    i_error       => 'UNHANDLED_EXCEPTION'
                  , i_env_param1  => sqlerrm
                );
            end if;

            raise;
    end;

end;
/
