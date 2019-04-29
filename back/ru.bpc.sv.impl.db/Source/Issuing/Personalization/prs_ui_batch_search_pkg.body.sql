create or replace package body prs_ui_batch_search_pkg is

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base';
    CRLF               constant com_api_type_pkg.t_name := chr(13) || chr(10);
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_cardholder_name           com_api_type_pkg.t_name;
    l_card_number               com_api_type_pkg.t_name;
    l_date_from                 date;
    l_date_to                   date;
    l_status                    com_api_type_pkg.t_name;
    l_reissue_reason            com_api_type_pkg.t_name;
    l_batch_name                com_api_type_pkg.t_name;
    l_privil_limitation         com_api_type_pkg.t_full_desc;
    l_card_uid                  com_api_type_pkg.t_name;

    COLUMN_LIST        constant com_api_type_pkg.t_text :=
    'select b.id'                   ||
         ', b.seqnum'               ||
         ', b.inst_id'              ||
         ', b.batch_name'           ||
         ', b.status'               ||
         ', b.hsm_device_id hsm_id' ||
         ', b.product_id'           ||
         ', b.card_type_id'         ||
         ', b.blank_type_id'        ||
         ', b.status_date'          ||
         ', b.perso_priority'       ||
         ', b.agent_id'             ||
         ', b.sort_id'              ||
         ', b.card_count'           ||
         ', b.reissue_reason'       ||
         ', p.product_number'       ||
         ', p_lang lang'            ||
         ', a.agent_number'
    ;

    l_ref_source            com_api_type_pkg.t_text :=
      ' from prs_batch b'                                ||
          ', prd_product p'                              ||
          ', ost_agent a'                                ||
          ', (select :p_lang p_lang'                     ||
          '       , :p_batch_name p_batch_name'          ||
          '       , :p_date_from p_date_from'            ||
          '       , :p_date_to p_date_to'                ||
          '       , :p_card_number p_card_number'        ||
          '       , :p_cardholder_name p_cardholder_name'||
          '       , :p_inst_id p_inst_id'                ||
          '       , :p_status p_status'                  ||
          '       , :p_reissue_reason p_reissue_reason'  ||
          '       , :p_card_uid p_card_uid '               ||
          '    from dual) x '                            ||
      'where b.product_id = p.id(+) '                    ||
        'and b.agent_id = a.id(+) '                      ||
        'and b.inst_id in (select inst_id from acm_cu_inst_vw) '
    ;

    function get_sorting_param return com_api_type_pkg.t_name
    is
        l_result            com_api_type_pkg.t_name;
    begin
        select nvl2(list, 'order by '||list, '')
          into l_result
          from (select rtrim(xmlagg(xmlelement(e,name||' '||char_value,',').extract('//text()')),',') list
                  from table(cast(i_sorting_tab as com_param_map_tpt))
               );

        return l_result;
    exception
        when no_data_found then
            return null;
    end;

    -- This function does NOT return a param value, it returns string with filtering clause
    function get_string(
        i_param_name        in      com_api_type_pkg.t_name
      , i_is_format         in      com_api_type_pkg.t_boolean      default com_api_const_pkg.TRUE
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select
          case
              --------------------------------------------------------------
              when i_is_format = com_api_const_pkg.FALSE then
                  'p_'||lower(i_param_name)
              --------------------------------------------------------------
              when date_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              when char_value is not null and substr(char_value, 1, 1) = '%' then
                  ' and reverse(lower(nvl('||lower(i_param_name)||',''%''))) '||nvl(condition, 'like')||' reverse(lower(p_'||lower(i_param_name)||'))'
              when char_value is not null and instr(char_value, '%') != 0 then
                  ' and lower(nvl('||lower(i_param_name)||',''%'')) '||nvl(condition, 'like')||' lower(p_'||lower(i_param_name)||')'
              when char_value is not null then
                  ' and lower('||lower(i_param_name)||') '||nvl(condition, '=')||' lower(p_'||lower(i_param_name)||')'
              when number_value is not null then
                  ' and '||lower(i_param_name)||' '||nvl(condition, '=')||' p_'||lower(i_param_name)
              else null
          end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

        trc_log_pkg.debug(LOG_PREFIX || '->get_string [' || l_result || ']');
        return l_result;
    exception
        when no_data_found then
            return null;
    end;

    function card_number_condition(
        i_field_name        in     com_api_type_pkg.t_oracle_name
    ) return com_api_type_pkg.t_name
    is
        l_result            com_api_type_pkg.t_name;
    begin
        select case
                   when iss_api_token_pkg.is_token_enabled() = com_api_type_pkg.FALSE then
                       ' and reverse(' || i_field_name || ') like reverse(x.p_card_number)'
                   else
                       ' and reverse(' || i_field_name || ')' ||
                           ' like reverse(''%'' || substr(x.p_card_number, -'||iss_api_const_pkg.LENGTH_OF_PLAIN_PAN_ENDING || '))' ||
                       ' and iss_api_token_pkg.decode_card_number(i_card_number => ' || i_field_name || ') like x.p_card_number'
               end
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt)) t
         where t.name = 'CARD_NUMBER';

        trc_log_pkg.debug(LOG_PREFIX || '->card_number_condition [' || l_result || ']');
        return l_result;
    end;

    function get_char_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return com_api_type_pkg.t_name is
        l_result            com_api_type_pkg.t_name;
    begin
        select char_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
    end;

    function get_date_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return date is
        l_result            date;
    begin
        select date_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
    end;

    function get_number_value(
        i_param_name        in      com_api_type_pkg.t_name
    ) return number is
        l_result            number;
    begin
        select number_value
          into l_result
          from table(cast(i_param_tab as com_param_map_tpt))
         where name = i_param_name;

         return l_result;
    exception
        when no_data_found then
            return null;
    end;

begin
    trc_log_pkg.debug(LOG_PREFIX || ': START with i_tab_name [' || i_tab_name
                                 || '], i_is_first_call [' || i_is_first_call || ']');
    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    if i_tab_name = 'BATCH' then
        l_inst_id := get_number_value('INST_ID');
        if l_inst_id is not null then
            l_ref_source := l_ref_source
                         || ' and (b.inst_id = x.p_inst_id or x.p_inst_id = ' || ost_api_const_pkg.DEFAULT_INST || ') ';
        end if;

        l_cardholder_name := upper(get_char_value('CARDHOLDER_NAME'));
        if l_cardholder_name is not null then
            l_ref_source := l_ref_source
                         || ' and b.id in ('
                         || 'select c.batch_id from prs_batch_card c, iss_card_instance i'
                         || ' where c.card_instance_id = i.id'
                         ||   ' and i.cardholder_name like x.p_cardholder_name'
                         || ') ';
        end if;

        l_card_number := get_char_value('CARD_NUMBER');
        if l_card_number is not null then
            l_ref_source := l_ref_source
                         || ' and b.id in ('
                         || 'select c.batch_id from prs_batch_card c, iss_card_instance i, iss_card_number n'
                         || ' where c.card_instance_id = i.id and i.card_id = n.card_id'
                         ||   card_number_condition(i_field_name => 'n.card_number')
                         || ') ';
        end if;

        l_date_from := get_date_value('DATE_FROM');
        if l_date_from is not null then
            l_ref_source := l_ref_source || ' and b.status_date > x.p_date_from ';
        end if;

        l_date_to := get_date_value('DATE_TO');
        if l_date_to is not null then
            l_ref_source := l_ref_source || ' and b.status_date < x.p_date_to ';
        end if;

        l_status := get_char_value('STATUS');
        if l_status is not null then
            l_ref_source := l_ref_source || ' and b.status = x.p_status ';
        end if;

        l_batch_name := get_string('BATCH_NAME');
        if l_batch_name is not null then
            l_ref_source := l_ref_source || l_batch_name;
        end if;

        l_reissue_reason := get_char_value('REISSUE_REASON');
        if l_reissue_reason is not null then
            l_ref_source := l_ref_source || ' and b.reissue_reason = x.p_reissue_reason ';
        end if;

        l_card_uid := get_char_value('CARD_UID');
        if l_card_uid is not null then
            l_ref_source := l_ref_source
                         || ' and b.id in ('
                         || 'select c.batch_id from prs_batch_card c, iss_card_instance i'
                         || ' where c.card_instance_id = i.id'
                         ||   ' and reverse(i.card_uid) like reverse(x.p_card_uid)'
                         || ') ';
        end if;
        
    else
        com_api_error_pkg.raise_error(
            i_error => 'INVALID_TAB_NAME'
        );
    end if;

    -- Extra condition (limitation) is defined by privileges
    l_privil_limitation := get_char_value('PRIVIL_LIMITATION');
    if l_privil_limitation is not null then
        l_ref_source := l_ref_source || ' and ' || l_privil_limitation;
    end if;

    if  i_is_first_call = com_api_const_pkg.TRUE then

        execute immediate 'select count(1) ' || l_ref_source
        into o_row_count
        using
            get_char_value('LANG')
          , get_char_value('BATCH_NAME')
          , l_date_from
          , l_date_to
          , l_card_number
          , l_cardholder_name 
          , l_inst_id 
          , l_status 
          , l_reissue_reason 
          , l_card_uid
        ;
    else
        l_ref_source :=
            'select b.* '                                                                            ||
                 ', prs_api_card_pkg.enum_sort_condition (b.sort_id) sort_condition'                 ||
                 ', get_text(''ost_institution'', ''name'', b.inst_id, b.lang) inst_name'            ||
                 ', get_text(''hsm_device'', ''description'', b.hsm_id, b.lang) hsm_description'     ||
                 ', get_text(''prd_product'', ''label'', b.product_id, b.lang) product_name'         ||
                 ', get_text(''net_card_type'', ''name'', b.card_type_id, b.lang) card_type_name'    ||
                 ', get_text(''prs_blank_type'', ''name'', b.blank_type_id, b.lang) blank_type_name' ||
                 ', get_text(''ost_agent'', ''name'', b.agent_id, b.lang) agent_name'                ||
                 ', get_text(''prs_sort'', ''label'', b.sort_id, b.lang) sort_label'                 ||
             ' from ('                                                                               ||
                     ' select * from ( '                                                             ||
                              ' select a.*, rownum rn '                                              ||
                                 'from ( '                                                           ||
                                      ' select * from ('                                             ||
                                          'select * from ('                                          ||
                                              COLUMN_LIST  || l_ref_source                           ||
                                          ') '                                                       ||
                                      ') '  || get_sorting_param()                                   ||
                              ') a '                                                                 ||
                     ' ) where rn between :p_first_row and :p_last_row '                             ||
             ') b';

        open o_ref_cur for l_ref_source
        using
            get_char_value('LANG')
          , get_char_value('BATCH_NAME')
          , l_date_from
          , l_date_to
          , l_card_number
          , l_cardholder_name 
          , l_inst_id 
          , l_status 
          , l_reissue_reason 
          , l_card_uid
          , i_first_row
          , i_last_row;
    end if;

    trc_log_pkg.debug(LOG_PREFIX || ': ' || CRLF || substr(l_ref_source, 1, 3900));
exception
    when others then
        trc_log_pkg.debug(substr(LOG_PREFIX || 'FAILED with l_ref_source is:' || CRLF || l_ref_source, 1, 3900));
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_first_row         in      com_api_type_pkg.t_tiny_id
  , i_last_row          in      com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
) is
    l_row_count         com_api_type_pkg.t_tiny_id;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , o_row_count         => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_tiny_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , o_row_count         => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end;

procedure get_batch_counts(
    i_batch_id          in      com_api_type_pkg.t_short_id
  , o_card_count           out  com_api_type_pkg.t_short_id
  , o_pin_count            out  com_api_type_pkg.t_short_id
  , o_pin_mailer_count     out  com_api_type_pkg.t_short_id
  , o_embossing_count      out  com_api_type_pkg.t_short_id
) is
begin
    select count(distinct c.card_instance_id)
         , count(decode(c.pin_request, iss_api_const_pkg.PIN_REQUEST_GENERATE, 1))
         , count(decode(c.pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT, 1))
         , count(decode(c.embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS, 1))
      into o_card_count
         , o_pin_count
         , o_pin_mailer_count
         , o_embossing_count
      from prs_batch_card c
     where c.batch_id = i_batch_id;
end;

end;
/
