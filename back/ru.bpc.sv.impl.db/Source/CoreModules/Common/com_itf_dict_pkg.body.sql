create or replace package body com_itf_dict_pkg is

function execute_dict_query_2_0(
    i_array_dictionary_id  in            com_api_type_pkg.t_medium_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id       default null
  , i_entry_point          in            com_api_type_pkg.t_attr_name     default com_api_const_pkg.ENTRYPOINT_EXPORT
  , i_lang                 in            com_api_type_pkg.t_dict_value    default null
  , io_xml                 in out nocopy clob
) return com_api_type_pkg.t_short_id is
    l_fetched_count         com_api_type_pkg.t_count := 0;

    cursor cur_xml is
        with articles as
        (select t.dict, t.code
              , max(decode(t.column_name, com_api_const_pkg.TEXT_IN_NAME, t.lang))        as lang
              , max(decode(t.column_name, com_api_const_pkg.TEXT_IN_NAME, t.text))        as article_name
              , max(decode(t.column_name, com_api_const_pkg.TEXT_IN_DESCRIPTION, t.text)) as article_description
           from (select d.dict
                      , d.code
                      , i.lang
                      , i.column_name
                      , i.text
                      , row_number() over (partition by i.object_id, i.column_name
                                               order by decode(i.lang
                                                             , i_lang, -1
                                                             , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                        ) as rn
                   from com_dictionary d
                      , com_i18n       i
                  where (d.inst_id     = i_inst_id or d.inst_id = ost_api_const_pkg.DEFAULT_INST)
                    and d.id           = i.object_id
                    and i.table_name   = 'COM_DICTIONARY' 
                    and i.column_name in (com_api_const_pkg.TEXT_IN_NAME, com_api_const_pkg.TEXT_IN_DESCRIPTION)
                    and i.lang        in (i_lang, com_api_const_pkg.DEFAULT_LANGUAGE)
                ) t
          where t.rn = 1
          group by t.dict, t.code
        )
        select xmlelement(
                   "dictionaries"
                 , xmlattributes('http://sv.bpc.in/SVXP/dictionary/dictionaries' as "xmlns")
                 , xmlelement("file_id",   case i_entry_point when com_api_const_pkg.ENTRYPOINT_EXPORT then com_prc_dict_export_pkg.get_session_file_id when com_api_const_pkg.ENTRYPOINT_WEBSERVICE then null end)
                 , xmlelement("file_type", case i_entry_point when com_api_const_pkg.ENTRYPOINT_EXPORT then com_prc_dict_export_pkg.get_file_type       when com_api_const_pkg.ENTRYPOINT_WEBSERVICE then com_api_const_pkg.FILE_TYPE || com_api_const_pkg.DICTIONARY_DICT end)
                 , xmlagg(
                       xmlelement("dictionary"
                         , xmlelement("code", a.code)
                         , (select xmlagg(
                                       xmlelement(
                                           "dictionary_name"
                                         , xmlattributes(b.lang as "language")
                                         , xmlelement("name"       , b.article_name)
                                         , xmlelement("description", b.article_name)
                                       )
                                   )
                              from articles b
                             where b.dict = a.dict
                               and b.code = a.code
                           )
                         , xmlelement(
                               "articles"
                             , (select xmlagg(
                                           xmlelement(
                                               "article"
                                             , xmlelement("code", e.code)
                                             , (select xmlagg(
                                                           xmlelement(
                                                               "article_name"
                                                             , xmlattributes(c.lang as "language")
                                                             , xmlelement("name"       , c.article_name)
                                                             , xmlelement("description", c.article_description)
                                                           )
                                                       )
                                                  from articles c
                                                 where c.dict = e.dict
                                                   and c.code = e.code
                                               )
                                           ) order by e.code
                                       )
                                  from articles e
                                 where e.dict = a.code
                               )
                           )
                       ) order by a.code
                   )
               ).getclobval()
             , count(*)
          from articles a
         where dict = com_api_const_pkg.DICTIONARY_DICT
           and (a.dict || a.code in (select element_value from com_array_element where array_id = i_array_dictionary_id)
            or i_array_dictionary_id is null);

begin
    open  cur_xml;
    fetch cur_xml into io_xml, l_fetched_count;
    close cur_xml;
    return l_fetched_count;
end execute_dict_query_2_0;

function execute_dict_query(
    i_dict_version         in            com_api_type_pkg.t_name
  , i_array_dictionary_id  in            com_api_type_pkg.t_medium_id     default null
  , i_inst_id              in            com_api_type_pkg.t_inst_id       default null
  , i_entry_point          in            com_api_type_pkg.t_attr_name     default com_api_const_pkg.ENTRYPOINT_EXPORT
  , i_lang                 in            com_api_type_pkg.t_dict_value    default null
  , io_xml                 in out nocopy clob
) return com_api_type_pkg.t_short_id is
    l_result  com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text        => 'com_itf_dict_pkg.execute_dict_query: START with i_dict_version [#1], i_array_dictionary_id [#2], i_inst_id [#3], i_entry_point [#4], i_lang [#5]'
      , i_env_param1  => i_dict_version
      , i_env_param2  => i_array_dictionary_id
      , i_env_param3  => i_inst_id
      , i_env_param4  => i_entry_point
      , i_env_param5  => i_lang
    );

    if i_dict_version in ('1.0', '2.0', '2.1') then
        l_result := execute_dict_query_2_0(
                        i_array_dictionary_id  => i_array_dictionary_id
                      , i_inst_id              => i_inst_id
                      , i_entry_point          => i_entry_point
                      , i_lang                 => i_lang
                      , io_xml                 => io_xml
                    );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dict_version
        );
    end if;

    return l_result;

end execute_dict_query;

function execute_rate_query_2_0(
    i_count_query_only          in     com_api_type_pkg.t_boolean
  , i_get_rate_id_tab           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_inst_id                   in     com_api_type_pkg.t_inst_id        default null
  , i_eff_date                  in     date                              default null
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_base_rate_export          in     com_api_type_pkg.t_boolean        default null
  , i_rate_type                 in     com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , io_xml                      in out nocopy clob
  , io_rate_id_tab              in out nocopy num_tab_tpt
  , io_event_tab                in out com_api_type_pkg.t_number_tab
) return com_api_type_pkg.t_short_id is
    l_count  com_api_type_pkg.t_short_id := 0;
begin
    if i_get_rate_id_tab = com_api_type_pkg.TRUE then
        if i_full_export = com_api_type_pkg.TRUE then
            select r.id
              bulk collect into
                   io_rate_id_tab
              from com_rate r
             where r.status = com_api_rate_pkg.RATE_STATUS_VALID
               and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id)
               and (i_rate_type is null or r.rate_type = i_rate_type)
               and r.eff_date >= 
                     (select max(cr.eff_date)
                        from com_rate cr
                       where cr.src_currency = r.src_currency
                         and cr.dst_currency = r.dst_currency
                         and cr.rate_type = r.rate_type
                         and cr.inst_id = r.inst_id
                         and cr.eff_date <= i_eff_date
                         and nvl(cr.exp_date, i_eff_date) >= i_eff_date
                         and cr.status = com_api_rate_pkg.RATE_STATUS_VALID
                      );
                
        else
            select o.id
                 , r.id
              bulk collect into
                   io_event_tab
                 , io_rate_id_tab
              from evt_event_object o
                 , com_rate r
             where decode(o.status, 'EVST0001', o.procedure_name, null) = 'COM_PRC_RATE_PKG.UNLOAD_RATES'
               and o.eff_date      <= i_eff_date
               and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CURRENCY_RATE
               and o.object_id      = r.id
               and r.status         = com_api_rate_pkg.RATE_STATUS_VALID
               and (i_rate_type is null or r.rate_type = i_rate_type)
               and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id);

        end if;

    else
        trc_log_pkg.debug(
            i_text        => 'com_itf_rate_pkg.execute_rate_query_2_0: start with i_count_query_only [#1]'
          , i_env_param1  => i_count_query_only
        );

        select
            count(*)
          , case when i_count_query_only = com_api_type_pkg.FALSE then
                xmlelement("currency_rates", xmlattributes('http://sv.bpc.in/SVXP/dictionary/currencyRate' as "xmlns"),
                    xmlagg(
                        xmlelement("currency_rate",
                            xmlforest(
                                case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                when com_api_const_pkg.TRUE
                                then ost_api_institution_pkg.get_inst_number(r.inst_id)
                                else to_char(r.inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                end as "inst_id",
                                r.rate_type as "rate_type",
                                r.eff_date as "effective_date",
                                r.exp_date as "expiration_date",
                                xmlforest(
                                    r.src_scale as "scale",
                                    r.src_currency as "currency",
                                    r.src_exponent_scale as "exponent_scale"
                                ) as "src_currency",
                                xmlforest(
                                    r.dst_scale as "scale",
                                    r.dst_currency as "currency",
                                    r.dst_exponent_scale as "exponent_scale"
                                ) as "dst_currency",
                                com_cst_rate_pkg.get_rate(r.rate, r.eff_rate) as "rate",
                                r.inverted as "inverted"
                            )
                        )
                    )
                ).getclobval()
            end
          into l_count
             , io_xml
          from (
                select r.inst_id
                     , r.rate_type
                     , to_char(r.eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                     , to_char(r.exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                     , r.src_scale
                     , r.src_currency
                     , r.src_exponent_scale
                     , r.dst_scale
                     , r.dst_currency
                     , r.dst_exponent_scale
                     , r.rate
                     , r.inverted
                     , r.eff_rate
                  from com_rate r
                 where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                union  -- The subqueries can contain the duplicated records, therefore need "union".
                select inst_id
                     , rate_type
                     , to_char(eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                     , to_char(exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                     , src_scale
                     , src_currency
                     , src_exponent_scale
                     , dst_scale
                     , dst_currency
                     , dst_exponent_scale
                     , rate
                     , inverted 
                     , case
                           when inverted = com_api_type_pkg.TRUE then dst_scale * dst_exponent_scale / rate / src_scale / src_exponent_scale
                           else rate * dst_scale * dst_exponent_scale / src_scale / src_exponent_scale
                       end eff_rate
                  from (               
                        select r.inst_id
                             , r.rate_type
                             , r.eff_date
                             , r.exp_date
                             , r.src_scale
                             , r.src_currency
                             , r.src_exponent_scale
                             , 1 dst_scale
                             , f.dst_currency
                             , 1 dst_exponent_scale
                             , com_api_rate_pkg.get_rate (
                                      i_src_currency        => r.src_currency
                                    , i_dst_currency        => f.dst_currency
                                    , i_rate_type           => r.rate_type
                                    , i_inst_id             => r.inst_id
                                    , i_eff_date            => r.eff_date
                                    , i_mask_exception      => com_api_type_pkg.TRUE
                                    , i_exception_value     => null
                                ) rate
                             , r.inverted
                             , r.eff_rate
                          from com_rate r
                             , (
                                select distinct rs.src_currency, rd.dst_currency, rs.rate_type, rs.inst_id, t.base_currency
                                  from com_rate rs
                                     , com_rate_type t
                                     , com_rate rd
                                 where rs.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                                   and t.base_currency is not null
                                   and rs.rate_type = t.rate_type
                                   and rs.inst_id   = t.inst_id
                                   and t.base_currency = rs.dst_currency
                                   and rd.rate_type = t.rate_type
                                   and rd.inst_id   = t.inst_id
                                   and t.base_currency = rd.src_currency
                               ) f
                         where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                           and r.rate_type     = f.rate_type
                           and r.inst_id       = f.inst_id
                           and f.base_currency = r.dst_currency
                           and r.src_currency  = f.src_currency
                           and nvl(i_base_rate_export, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                       )
                 where rate is not null              
        ) r;

        trc_log_pkg.debug(
            i_text        => 'com_itf_rate_pkg.execute_rate_query_2_0: finish with l_count [#1]'
          , i_env_param1  => l_count
        );

    end if;

    return l_count;

end execute_rate_query_2_0;

function execute_rate_query_2_1(
    i_count_query_only          in     com_api_type_pkg.t_boolean
  , i_get_rate_id_tab           in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_inst_id                   in     com_api_type_pkg.t_inst_id        default null
  , i_eff_date                  in     date                              default null
  , i_full_export               in     com_api_type_pkg.t_boolean        default null
  , i_base_rate_export          in     com_api_type_pkg.t_boolean        default null
  , i_rate_type                 in     com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , io_xml                      in out nocopy clob
  , io_rate_id_tab              in out nocopy num_tab_tpt
  , io_event_tab                in out com_api_type_pkg.t_number_tab
) return com_api_type_pkg.t_short_id is
    l_count  com_api_type_pkg.t_short_id := 0;
begin
    if i_get_rate_id_tab = com_api_type_pkg.TRUE then
        if i_full_export = com_api_type_pkg.TRUE then
            select r.id
              bulk collect into
                   io_rate_id_tab
              from com_rate r
             where r.status = com_api_rate_pkg.RATE_STATUS_VALID
               and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id)
               and (i_rate_type is null or r.rate_type = i_rate_type)
               and r.eff_date >= 
                     (select max(cr.eff_date)
                        from com_rate cr
                       where cr.src_currency = r.src_currency
                         and cr.dst_currency = r.dst_currency
                         and cr.rate_type = r.rate_type
                         and cr.inst_id = r.inst_id
                         and cr.eff_date <= i_eff_date
                         and nvl(cr.exp_date, i_eff_date) >= i_eff_date
                         and cr.status = com_api_rate_pkg.RATE_STATUS_VALID
                      );
                
        else
            select o.id
                 , r.id
              bulk collect into
                   io_event_tab
                 , io_rate_id_tab
              from evt_event_object o
                 , com_rate r
             where decode(o.status, 'EVST0001', o.procedure_name, null) = 'COM_PRC_RATE_PKG.UNLOAD_RATES'
               and o.eff_date      <= i_eff_date
               and o.entity_type    = com_api_const_pkg.ENTITY_TYPE_CURRENCY_RATE
               and o.object_id      = r.id
               and r.status         = com_api_rate_pkg.RATE_STATUS_VALID
               and (i_rate_type is null or r.rate_type = i_rate_type)
               and (i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST or r.inst_id = i_inst_id);

        end if;

    else
        trc_log_pkg.debug(
            i_text        => 'com_itf_rate_pkg.execute_rate_query_2_1: start with i_count_query_only [#1]'
          , i_env_param1  => i_count_query_only
        );

        select
            count(*)
          , case when i_count_query_only = com_api_type_pkg.FALSE then
                xmlelement("currency_rates", xmlattributes('http://sv.bpc.in/SVXP/dictionary/currencyRate' as "xmlns"),
                    xmlagg(
                        xmlelement("currency_rate",
                            xmlforest(
                                case nvl(i_replace_inst_id_by_number, com_api_const_pkg.FALSE)
                                when com_api_const_pkg.TRUE
                                then ost_api_institution_pkg.get_inst_number(r.inst_id)
                                else to_char(r.inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)
                                end as "inst_id",
                                r.rate_type as "rate_type",
                                r.eff_date as "effective_date",
                                r.exp_date as "expiration_date",
                                xmlforest(
                                    r.src_scale as "scale",
                                    r.src_currency as "currency",
                                    r.src_exponent_scale as "exponent_scale"
                                ) as "src_currency",
                                xmlforest(
                                    r.dst_scale as "scale",
                                    r.dst_currency as "currency",
                                    r.dst_exponent_scale as "exponent_scale"
                                ) as "dst_currency",
                                com_cst_rate_pkg.get_rate(r.rate, r.eff_rate) as "rate",
                                r.inverted as "inverted"
                            )
                          , com_api_flexible_data_pkg.generate_xml(
                                i_entity_type => com_api_const_pkg.ENTITY_TYPE_CURRENCY_RATE
                              , i_standard_id => cmn_api_const_pkg.STANDARD_ID_SVXP_DICT
                              , i_object_id   => r.id
                            )
                        )
                    )
                ).getclobval()
            end
          into l_count
             , io_xml
          from (
                select r.id
                     , r.inst_id
                     , r.rate_type
                     , to_char(r.eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                     , to_char(r.exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                     , r.src_scale
                     , r.src_currency
                     , r.src_exponent_scale
                     , r.dst_scale
                     , r.dst_currency
                     , r.dst_exponent_scale
                     , r.rate
                     , r.inverted
                     , r.eff_rate
                  from com_rate r
                 where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                union  -- The subqueries can contain the duplicated records, therefore need "union".
                select id
                     , inst_id
                     , rate_type
                     , to_char(eff_date, com_api_const_pkg.XML_DATETIME_FORMAT) as eff_date
                     , to_char(exp_date, com_api_const_pkg.XML_DATETIME_FORMAT) as exp_date
                     , src_scale
                     , src_currency
                     , src_exponent_scale
                     , dst_scale
                     , dst_currency
                     , dst_exponent_scale
                     , rate
                     , inverted 
                     , case
                           when inverted = com_api_type_pkg.TRUE then dst_scale * dst_exponent_scale / rate / src_scale / src_exponent_scale
                           else rate * dst_scale * dst_exponent_scale / src_scale / src_exponent_scale
                       end eff_rate
                  from (               
                        select r.id
                             , r.inst_id
                             , r.rate_type
                             , r.eff_date
                             , r.exp_date
                             , r.src_scale
                             , r.src_currency
                             , r.src_exponent_scale
                             , 1 dst_scale
                             , f.dst_currency
                             , 1 dst_exponent_scale
                             , com_api_rate_pkg.get_rate (
                                      i_src_currency        => r.src_currency
                                    , i_dst_currency        => f.dst_currency
                                    , i_rate_type           => r.rate_type
                                    , i_inst_id             => r.inst_id
                                    , i_eff_date            => r.eff_date
                                    , i_mask_exception      => com_api_type_pkg.TRUE
                                    , i_exception_value     => null
                                ) rate
                             , r.inverted
                             , r.eff_rate
                          from com_rate r
                             , (
                                select distinct rs.src_currency, rd.dst_currency, rs.rate_type, rs.inst_id, t.base_currency
                                  from com_rate rs
                                     , com_rate_type t
                                     , com_rate rd
                                 where rs.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                                   and t.base_currency is not null
                                   and rs.rate_type = t.rate_type
                                   and rs.inst_id   = t.inst_id
                                   and t.base_currency = rs.dst_currency
                                   and rd.rate_type = t.rate_type
                                   and rd.inst_id   = t.inst_id
                                   and t.base_currency = rd.src_currency
                               ) f
                         where r.id in (select column_value from table(cast(io_rate_id_tab as num_tab_tpt)))
                           and r.rate_type     = f.rate_type
                           and r.inst_id       = f.inst_id
                           and f.base_currency = r.dst_currency
                           and r.src_currency  = f.src_currency
                           and nvl(i_base_rate_export, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE
                       )
                 where rate is not null              
        ) r;

        trc_log_pkg.debug(
            i_text        => 'com_itf_rate_pkg.execute_rate_query_2_1: finish with l_count [#1]'
          , i_env_param1  => l_count
        );

    end if;

    return l_count;

end execute_rate_query_2_1;

function execute_rate_query(
    i_count_query_only          in            com_api_type_pkg.t_boolean
  , i_get_rate_id_tab           in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_dict_version              in            com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
  , i_inst_id                   in            com_api_type_pkg.t_inst_id        default null
  , i_eff_date                  in            date                              default null
  , i_full_export               in            com_api_type_pkg.t_boolean        default null
  , i_base_rate_export          in            com_api_type_pkg.t_boolean        default null
  , i_rate_type                 in            com_api_type_pkg.t_dict_value     default null
  , i_replace_inst_id_by_number in            com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
  , i_entry_point               in            com_api_type_pkg.t_attr_name      default com_api_const_pkg.ENTRYPOINT_EXPORT
  , io_xml                      in out nocopy clob
  , io_rate_id_tab              in out nocopy num_tab_tpt
  , io_event_tab                in out        com_api_type_pkg.t_number_tab
) return com_api_type_pkg.t_short_id is
    l_result  com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text        => 'com_itf_rate_pkg.execute_rate_query: START with i_dict_version [#1], i_inst_id [#2], i_eff_date [#3], i_full_export [#4], i_base_rate_export [#5], i_entry_point [#6]'
      , i_env_param1  => i_dict_version
      , i_env_param2  => i_inst_id
      , i_env_param3  => to_char(i_eff_date, com_api_const_pkg.DATE_FORMAT)
      , i_env_param4  => i_full_export
      , i_env_param5  => i_base_rate_export
      , i_env_param6  => i_entry_point
    );

    if i_dict_version in ('1.0', '2.0') then
        l_result := execute_rate_query_2_0(
                        i_count_query_only          => i_count_query_only
                      , i_get_rate_id_tab           => i_get_rate_id_tab
                      , i_inst_id                   => i_inst_id
                      , i_eff_date                  => i_eff_date
                      , i_full_export               => i_full_export
                      , i_base_rate_export          => i_base_rate_export
                      , i_rate_type                 => i_rate_type
                      , i_replace_inst_id_by_number => i_replace_inst_id_by_number
                      , io_xml                      => io_xml
                      , io_rate_id_tab              => io_rate_id_tab
                      , io_event_tab                => io_event_tab
                    );

    elsif i_dict_version in ('2.1') then
        l_result := execute_rate_query_2_1(
                        i_count_query_only          => i_count_query_only
                      , i_get_rate_id_tab           => i_get_rate_id_tab
                      , i_inst_id                   => i_inst_id
                      , i_eff_date                  => i_eff_date
                      , i_full_export               => i_full_export
                      , i_base_rate_export          => i_base_rate_export
                      , i_rate_type                 => i_rate_type
                      , i_replace_inst_id_by_number => i_replace_inst_id_by_number
                      , io_xml                      => io_xml
                      , io_rate_id_tab              => io_rate_id_tab
                      , io_event_tab                => io_event_tab
                    );

    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dict_version
        );

    end if;

    return l_result;

end execute_rate_query;

function execute_mcc_query_2_0(
    i_lang                 in     com_api_type_pkg.t_dict_value default null
  , i_entry_point          in     com_api_type_pkg.t_attr_name  default com_api_const_pkg.ENTRYPOINT_EXPORT
  , o_xml                     out clob
) return com_api_type_pkg.t_short_id
is
    l_count com_api_type_pkg.t_count := 0;
    cursor cur_xml is
        with mcc_names as
                (select t.mcc
                      , t.tcc
                      , t.mcct
                      , t.visa
                      , t.object_id as id
                      , max(t.lang) as lang
                      , max(t.text) as text
                   from (select m.mcc
                              , m.tcc
                              , m.mastercard_cab_type mcct
                              , m.visa_mcg visa
                              , c.lang
                              , c.text
                              , c.object_id
                              , row_number() over (partition by c.object_id
                                                       order by decode(c.lang
                                                                     , i_lang, -1
                                                                     , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                                ) as rn
                           from com_mcc  m
                              , com_i18n c
                          where m.id = c.object_id
                            and c.table_name = 'COM_MCC'
                            and c.column_name = com_api_const_pkg.TEXT_IN_NAME
                            and (c.lang in (i_lang,com_api_const_pkg.DEFAULT_LANGUAGE)
                                    or i_lang is null)
                        ) t
                  where t.rn = 1
                  group by t.mcc, t.tcc, t.mcct, t.visa, t.object_id
                )
                select xmlelement(
                           "mcc"
                         , xmlattributes('http://sv.bpc.in/SVXP/dictionary/mcc' as "xmlns")
                         , xmlelement("file_id", case i_entry_point 
                                                     when com_api_const_pkg.ENTRYPOINT_EXPORT 
                                                         then com_prc_mcc_export_pkg.get_session_file_id 
                                                     when com_api_const_pkg.ENTRYPOINT_WEBSERVICE 
                                                         then null
                                                 end)
                         , xmlelement("file_type", case i_entry_point 
                                                       when com_api_const_pkg.ENTRYPOINT_EXPORT 
                                                           then com_prc_mcc_export_pkg.get_file_type
                                                       when com_api_const_pkg.ENTRYPOINT_WEBSERVICE 
                                                           then com_api_const_pkg.FILE_TYPE_MCC
                                                   end)
                         , xmlagg(
                               xmlelement(
                                   "record"
                                 , xmlelement("mcc", a.mcc)
                                 , xmlelement("tcc", a.tcc)
                                 , xmlelement("mastercard_cab_type", a.mcct)
                                 , xmlelement("visa_mcg", a.visa)
                                 , (select xmlagg(
                                               xmlelement(
                                                   "mcc_name"
                                                 , xmlattributes(b.lang as "language")
                                                 , xmlelement("name", b.text)
                                               ) order by b.rn
                                          )
                                     from (select c.lang
                                                , c.text 
                                                , c.object_id
                                                , row_number() over (partition by c.object_id
                                                                         order by decode(c.lang
                                                                                       , i_lang, -1
                                                                                       , com_api_const_pkg.DEFAULT_LANGUAGE, 0)
                                                  ) as rn
                                             from com_i18n c
                                            where c.table_name = 'COM_MCC'
                                              and c.column_name = com_api_const_pkg.TEXT_IN_NAME
                                              and (c.lang in (i_lang,com_api_const_pkg.DEFAULT_LANGUAGE)
                                                      or i_lang is null)
                                          ) b
                                    where b.object_id = a.id
                                   )
                               ) order by a.mcc
                           )
                       ).getclobval()
                     , count(*)
                  from mcc_names a;
begin
    open cur_xml;
    fetch cur_xml 
     into o_xml
        , l_count;
    close cur_xml;
    
    return l_count;
end execute_mcc_query_2_0;

function execute_mcc_query(
    i_dict_version         in     com_api_type_pkg.t_name
  , i_lang                 in     com_api_type_pkg.t_dict_value default null
  , i_entry_point          in     com_api_type_pkg.t_attr_name  default com_api_const_pkg.ENTRYPOINT_EXPORT
  , o_xml                     out clob
) return com_api_type_pkg.t_short_id
is
    l_id com_api_type_pkg.t_short_id;
begin
    if i_dict_version between '2.0' and '2.0' then
        l_id := execute_mcc_query_2_0(
                    i_lang        => i_lang
                  , i_entry_point => i_entry_point
                  , o_xml         => o_xml
                );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_dict_version
        ); 
    end if;

    return l_id;
end execute_mcc_query;

end com_itf_dict_pkg;
/
