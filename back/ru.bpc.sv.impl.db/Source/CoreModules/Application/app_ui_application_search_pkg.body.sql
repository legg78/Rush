create or replace package body app_ui_application_search_pkg is

type t_search_param_rec is record (
    -- Global search mode:
    tab_name                  com_api_type_pkg.t_name
  , privil_limitation         com_api_type_pkg.t_full_desc
  , lang                      com_api_type_pkg.t_dict_value
  , appl_id_from              com_api_type_pkg.t_long_id
  , appl_id_to                com_api_type_pkg.t_long_id
  , default_inst_name         com_api_type_pkg.t_name
  , current_user_id           com_api_type_pkg.t_short_id

    -- Common searched fields
  , inst_id                   com_api_type_pkg.t_inst_id
  , appl_status               com_api_type_pkg.t_dict_value
  , date_from                 date
  , date_to                   date
  , customer_number           com_api_type_pkg.t_name
  , contract_number           com_api_type_pkg.t_name
  , account_number            com_api_type_pkg.t_name
  , appl_number               com_api_type_pkg.t_name
  , appl_id                   com_api_type_pkg.t_long_id
  , flow_id                   com_api_type_pkg.t_tiny_id

    -- Issuer searched fields
  , card_number               com_api_type_pkg.t_card_number

    -- Acquirer searched fields
  , merchant_number           com_api_type_pkg.t_name
  , terminal_number           com_api_type_pkg.t_name

  -- Other searched fields
  , appl_type                 com_api_type_pkg.t_dict_value
  , appl_types                com_api_type_pkg.t_full_desc
  , reject_code               com_api_type_pkg.t_dict_value
  , entity_type               com_api_type_pkg.t_dict_value
  , object_id                 com_api_type_pkg.t_long_id
  , appl_prioritized          com_api_type_pkg.t_boolean

  -- User management fields
  , user_id                   com_api_type_pkg.t_short_id
  , user_name                 com_api_type_pkg.t_name
  , role_id                   com_api_type_pkg.t_tiny_id
  , role_name                 com_api_type_pkg.t_name
);

procedure get_ref_cur_base(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , io_row_count        in out  com_api_type_pkg.t_long_id
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt
  , i_is_first_call     in      com_api_type_pkg.t_boolean
) is
    LOG_PREFIX         constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_ref_cur_base';

    l_param_rec                 t_search_param_rec;
    l_column_list               com_api_type_pkg.t_text;
    l_ref_source                com_api_type_pkg.t_text;

    l_order_by                  com_api_type_pkg.t_name;
    l_name                      com_api_type_pkg.t_name;
    l_sysdate                   date;
    l_is_used_sorting           com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text        => LOG_PREFIX || ': START with i_tab_name [#1], i_is_first_call [#2]'
      , i_env_param1  => i_tab_name
      , i_env_param2  => i_is_first_call
    );

    utl_data_pkg.print_table(i_param_tab => i_param_tab); -- dumping collection, DEBUG logging level is required

    l_sysdate                     := com_api_sttl_day_pkg.get_sysdate;
    l_param_rec.current_user_id   := com_ui_user_env_pkg.get_user_id;

    l_column_list  :=
        'select ap.id'
      ||     ', ap.seqnum'
      ||     ', ap.appl_type'
      ||     ', ap.flow_id'
      ||     ', ap.appl_status'
      ||     ', ap.reject_code'
      ||     ', ap.agent_id'
      ||     ', ap.inst_id'
      ||     ', ap.session_file_id'
      ||     ', ap.file_rec_num'
      ||     ', ap.resp_session_file_id'
      ||     ', ap.appl_number'
      ||     ', ap.appl_prioritized as appl_prioritized'
      ||     ', x.p_default_inst_name'
      ||     ', (select min(h.change_date+0) from app_history h where h.appl_id = ap.id) as created'
      ||     ', (select max(h.change_date+0) from app_history h where h.appl_id = ap.id) as last_updated'
      ||     ', x.p_lang as lang';

    l_ref_source :=
         ' from app_application ap'
      ||     ', (select :p_inst_id           as p_inst_id'
      ||             ', :p_lang              as p_lang'
      ||             ', :p_appl_status       as p_appl_status'
      ||             ', :p_date_from         as p_date_from'
      ||             ', :p_date_to           as p_date_to'
      ||             ', :p_appl_id_from      as p_appl_id_from'
      ||             ', :p_appl_id_to        as p_appl_id_to'
      ||             ', :p_customer_number   as p_customer_number'
      ||             ', :p_contract_number   as p_contract_number'
      ||             ', :p_account_number    as p_account_number'
      ||             ', :p_appl_number       as p_appl_number'
      ||             ', :p_appl_id           as p_appl_id'
      ||             ', :p_flow_id           as p_flow_id'
      ||             ', :p_card_number       as p_card_number'
      ||             ', :p_merchant_number   as p_merchant_number'
      ||             ', :p_terminal_number   as p_terminal_number'
      ||             ', :p_appl_type         as p_appl_type'
      ||             ', :p_reject_code       as p_reject_code'
      ||             ', :p_entity_type       as p_entity_type'
      ||             ', :p_object_id         as p_object_id'
      ||             ', :p_default_inst_name as p_default_inst_name'
      ||             ', :p_current_user_id   as p_current_user_id'
      ||             ', :p_user_id           as p_user_id'
      ||             ', :p_user_name         as p_user_name'
      ||             ', :p_role_id           as p_role_id'
      ||             ', :p_role_name         as p_role_name'
      ||             ', :p_appl_prioritized  as p_appl_prioritized'
      ||         ' from dual) x'
      ||        ' where (exists (select agent_id from acm_user_agent_mvw ag where ag.user_id = x.p_current_user_id and ag.agent_id = ap.agent_id)'
      ||        '      or ap.appl_type = ''' || app_api_const_pkg.APPL_TYPE_INSTITUTION || ''')' 
      ||          ' and ap.is_template != 1';

    -- Use table's column instead of calculated column in "Order by" clause
    if i_sorting_tab is not null then
        if i_sorting_tab.count = 1 and upper(i_sorting_tab(1).name) = 'ID' then
            l_is_used_sorting := com_api_const_pkg.TRUE;

        elsif com_ui_object_search_pkg.is_used_sorting(
               i_is_first_call => i_is_first_call
             , i_sorting_count => i_sorting_tab.count
             , i_row_count     => io_row_count
             , i_mask_error    => com_api_type_pkg.FALSE
           ) = com_api_type_pkg.TRUE
        then
            l_is_used_sorting := com_api_const_pkg.TRUE;
        else
            l_is_used_sorting := com_api_const_pkg.FALSE;
        end if;

        if l_is_used_sorting = com_api_const_pkg.TRUE then
            trc_log_pkg.debug(LOG_PREFIX || 'Sorting by:');
            utl_data_pkg.print_table(i_param_tab => i_sorting_tab);

            if i_sorting_tab.count > 0 then
                for i in 1 .. i_sorting_tab.count loop
                    l_order_by := l_order_by
                                  || case
                                         when l_order_by is not null
                                         then ','
                                         else 'order by '
                                     end
                                  || case upper(i_sorting_tab(i).name)
                                      when 'INST_NAME'
                                      then 'INST_ID'
                                      when 'FLOW_NAME'
                                      then 'FLOW_ID'
                                      when 'APPL_DESCRIPTION'
                                      then '1'        -- Do not sorting by "Appl_description"
                                      else upper(i_sorting_tab(i).name)
                                  end
                                  || ' ' || i_sorting_tab(i).char_value;
                end loop;
            end if;

            trc_log_pkg.debug(LOG_PREFIX || 'l_order_by: ' || l_order_by);
        end if;
    end if;

    if l_order_by is null then
        l_order_by := 'order by a.id desc';
    end if;

    if i_param_tab is not null then
        for i in 1 .. i_param_tab.count loop
            l_name := upper(i_param_tab(i).name);

            if    l_name = 'INST_ID'            then  l_param_rec.inst_id           := i_param_tab(i).number_value;
            elsif l_name = 'LANG'               then  l_param_rec.lang              := i_param_tab(i).char_value;
            elsif l_name = 'APPL_STATUS'        then  l_param_rec.appl_status       := i_param_tab(i).char_value;
            elsif l_name = 'APP_DATE_FROM'      then  l_param_rec.date_from         := i_param_tab(i).date_value;
            elsif l_name = 'APP_DATE_TO'        then  l_param_rec.date_to           := i_param_tab(i).date_value;
            elsif l_name = 'CUSTOMER_NUMBER'    then  l_param_rec.customer_number   := i_param_tab(i).char_value;
            elsif l_name = 'CONTRACT_NUMBER'    then  l_param_rec.contract_number   := i_param_tab(i).char_value;
            elsif l_name = 'ACCOUNT_NUMBER'     then  l_param_rec.account_number    := i_param_tab(i).char_value;
            elsif l_name = 'APPL_NUMBER'        then  l_param_rec.appl_number       := i_param_tab(i).char_value;
            elsif l_name = 'ID'                 then  l_param_rec.appl_id           := i_param_tab(i).number_value;
            elsif l_name = 'FLOW_ID'            then  l_param_rec.flow_id           := i_param_tab(i).number_value;
            elsif l_name = 'MERCHANT_NUMBER'    then  l_param_rec.merchant_number   := i_param_tab(i).char_value;
            elsif l_name = 'TERMINAL_NUMBER'    then  l_param_rec.terminal_number   := i_param_tab(i).char_value;
            elsif l_name = 'APPL_TYPE'          then  l_param_rec.appl_type         := i_param_tab(i).char_value;
            elsif l_name = 'APPL_TYPES'         then  l_param_rec.appl_types        := i_param_tab(i).char_value;
            elsif l_name = 'REJECT_CODE'        then  l_param_rec.reject_code       := i_param_tab(i).char_value;
            elsif l_name = 'PRIVIL_LIMITATION'  then  l_param_rec.privil_limitation := i_param_tab(i).char_value;
            elsif l_name = 'ENTITY_TYPE'        then  l_param_rec.entity_type       := i_param_tab(i).char_value;
            elsif l_name = 'OBJECT_ID'          then  l_param_rec.object_id         := i_param_tab(i).number_value;
            elsif l_name = 'USER_ID'            then  l_param_rec.user_id           := i_param_tab(i).number_value;
            elsif l_name = 'USER_NAME'          then  l_param_rec.user_name         := i_param_tab(i).char_value;
            elsif l_name = 'ROLE_ID'            then  l_param_rec.role_id           := i_param_tab(i).number_value;
            elsif l_name = 'ROLE_NAME'          then  l_param_rec.role_name         := i_param_tab(i).char_value;
            elsif l_name = 'APPL_PRIORITIZED'   then  l_param_rec.appl_prioritized  := i_param_tab(i).number_value;
            elsif l_name = 'CARD_NUMBER'        then
                if iss_api_token_pkg.is_token_enabled = com_api_type_pkg.FALSE then
                    l_param_rec.card_number := i_param_tab(i).char_value;
                else
                    l_param_rec.card_number :=  iss_api_token_pkg.encode_card_number(i_card_number => i_param_tab(i).char_value);
                end if;
            end if;
        end loop;
    end if;

    l_param_rec.lang              := coalesce(l_param_rec.lang, com_ui_user_env_pkg.get_user_lang);
    l_param_rec.default_inst_name := com_api_label_pkg.get_label_text(
                                         i_name => 'SYS_INST_NAME'
                                       , i_lang => l_param_rec.lang
                                     );

    if l_param_rec.appl_id      is not null
       or l_param_rec.object_id is not null
    then
        null;
    elsif l_param_rec.date_from is null then
        com_api_error_pkg.raise_error(
            i_error      => 'REQUIRED_PARAMETER_IS_NOT_SPECIFIED'
          , i_env_param1 => 'APPDATEFROM'
        );
    end if;

    if l_param_rec.appl_id           is not null then
        l_ref_source                 := l_ref_source || ' and ap.id = x.p_appl_id';

    elsif l_param_rec.object_id      is not null then
        l_ref_source                 := l_ref_source
                                     || ' and ap.id in ('
                                     || 'select ao.appl_id'
                                     ||  ' from app_object ao'
                                     || ' where ao.object_id = x.p_object_id'
                                     ||   ' and ao.entity_type   = x.p_entity_type'
                                     || ') ';
    else

        if l_param_rec.date_to       is null then
            l_param_rec.date_to      := trunc(l_sysdate) + 1 - com_api_const_pkg.ONE_SECOND;
        end if;

        l_param_rec.appl_id_from     := com_api_id_pkg.get_from_id(l_param_rec.date_from);
        l_param_rec.appl_id_to       := com_api_id_pkg.get_till_id(l_param_rec.date_to);
        l_ref_source                 := l_ref_source || ' and ap.id between x.p_appl_id_from and x.p_appl_id_to';

        if l_param_rec.inst_id       is not null then
            l_ref_source             := l_ref_source || ' and ap.inst_id = x.p_inst_id';
        end if;

        if l_param_rec.appl_status   is not null then
            l_ref_source             := l_ref_source || ' and ap.appl_status = x.p_appl_status';
        end if;

        if instr(l_param_rec.appl_number, '%') != 0 then
            l_ref_source             := l_ref_source || ' and ap.appl_number like x.p_appl_number';
        elsif l_param_rec.appl_number   is not null then
            l_ref_source             := l_ref_source || ' and ap.appl_number = x.p_appl_number';
        end if;

        if l_param_rec.flow_id       is not null then
            l_ref_source             := l_ref_source || ' and ap.flow_id = x.p_flow_id';
        end if;

        if l_param_rec.appl_type     is not null then
            l_ref_source             := l_ref_source || ' and ap.appl_type = x.p_appl_type';
        end if;

        if l_param_rec.appl_types    is not null then
            l_ref_source             := l_ref_source || ' and ap.appl_type in (' || l_param_rec.appl_types || ')';
        end if;

        if l_param_rec.reject_code   is not null then
            l_ref_source             := l_ref_source || ' and ap.reject_code = x.p_reject_code';
        end if;

        if l_param_rec.appl_prioritized is not null then
            l_ref_source             := l_ref_source || ' and ap.appl_prioritized = x.p_appl_prioritized';
        end if;

    /*
        if i_tab_name = 'ISSUING' then
        elsif i_tab_name = 'ACQUIRING' then
        else
            com_api_error_pkg.raise_error(
                i_error => 'INVALID_TAB_NAME'
            );
        end if;
    */

        if l_param_rec.entity_type is not null
           and l_param_rec.object_id is not null
        then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select ao.appl_id'
                         ||  ' from app_object ao'
                         || ' where ao.object_id = x.p_object_id'
                         ||   ' and ao.entity_type   = x.p_entity_type'
                         || ') ';
        end if;

        if l_param_rec.merchant_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_MERCHANT_NUMBER
                         ||   ' and apd.element_value = x.p_merchant_number'
                         || ') ';
        end if;

        if l_param_rec.terminal_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_TERMINAL_NUMBER
                         ||   ' and apd.element_value = x.p_terminal_number'
                         || ') ';
        end if;

        if l_param_rec.card_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_CARD_NUMBER
                         || case
                                when instr(l_param_rec.card_number, '%') != 0
                                then ' and apd.element_value like x.p_card_number'
                                else ' and apd.element_value = x.p_card_number'
                            end
                         || ') ';
        end if;

        if l_param_rec.customer_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_CUSTOMER_NUMBER
                         || case
                                when instr(l_param_rec.customer_number, '%') != 0
                                then ' and apd.element_value like x.p_customer_number'
                                else ' and apd.element_value = x.p_customer_number'
                            end
                         || ') ';
        end if;

        if l_param_rec.account_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_ACCOUNT_NUMBER
                         ||   ' and apd.element_value = x.p_account_number'
                         || ') ';
        end if;

        if l_param_rec.contract_number is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_CONTRACT_NUMBER
                         ||   ' and apd.element_value = x.p_contract_number'
                         || ') ';
        end if;

        if l_param_rec.user_id is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_USER_ID
                         ||   ' and apd.element_value = x.p_user_id'
                         || ') ';
        end if;

        if l_param_rec.user_name is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_USER_NAME
                         ||   ' and apd.element_value = x.p_user_name'
                         || ') ';
        end if;

        if l_param_rec.role_id is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_ROLE_ID
                         ||   ' and apd.element_value = x.p_role_id'
                         || ') ';
        end if;

        if l_param_rec.role_name is not null then
            l_ref_source := l_ref_source
                         || ' and ap.id in ('
                         || 'select apd.appl_id'
                         ||  ' from app_data apd'
                         || ' where apd.element_id = ' || app_api_const_pkg.ELEMENT_ROLE_NAME
                         ||   ' and apd.element_value = x.p_role_name'
                         || ') ';
        end if;

    end if;  -- if l_param_rec.appl_id is not null

    -- Extra condition (limitation) is defined by privileges
    if l_param_rec.privil_limitation is not null then
        l_ref_source := l_ref_source || ' and ' || l_param_rec.privil_limitation;
    end if;

    com_ui_object_search_pkg.start_search(
        i_is_first_call => i_is_first_call
    );

    if  i_is_first_call = com_api_const_pkg.TRUE then

        l_ref_source := 'select count(1) ' || l_ref_source;

        execute immediate l_ref_source
           into io_row_count
          using l_param_rec.inst_id
              , l_param_rec.lang
              , l_param_rec.appl_status
              , l_param_rec.date_from
              , l_param_rec.date_to
              , l_param_rec.appl_id_from
              , l_param_rec.appl_id_to
              , l_param_rec.customer_number
              , l_param_rec.contract_number
              , l_param_rec.account_number
              , l_param_rec.appl_number
              , l_param_rec.appl_id
              , l_param_rec.flow_id
              , l_param_rec.card_number
              , l_param_rec.merchant_number
              , l_param_rec.terminal_number
              , l_param_rec.appl_type
              , l_param_rec.reject_code
              , l_param_rec.entity_type
              , l_param_rec.object_id
              , l_param_rec.default_inst_name
              , l_param_rec.current_user_id
              , l_param_rec.user_id
              , l_param_rec.user_name
              , l_param_rec.role_id
              , l_param_rec.role_name
              , l_param_rec.appl_prioritized;

    else
        l_ref_source :=
            'select m.*'
          ||     ', app_api_application_pkg.get_appl_description('
          ||          ' i_appl_id => m.id'
          ||         ', i_flow_id => m.flow_id'
          ||         ', i_lang    => m.lang'
          ||       ') as appl_description'
          ||     ', com_api_i18n_pkg.get_text(''app_flow'', ''label'', m.flow_id, m.lang) as flow_name'
          ||     ', case m.inst_id'
          ||          ' when ' || ost_api_const_pkg.DEFAULT_INST || ' then m.p_default_inst_name'
          ||          ' else com_ui_object_search_pkg.get_inst_name(m.inst_id)'
          ||      ' end as inst_name'
          || ' from ('
          ||  'select t.*'
          ||       ', rownum as rn'
          ||   ' from ('
          ||      'select a.* '
          ||       ' from ('
          ||             l_column_list  || l_ref_source
          ||       ' ) a ' || l_order_by
          ||    ') t) m where m.rn between :p_first_row and :p_last_row';

        open o_ref_cur for l_ref_source
          using l_param_rec.inst_id
              , l_param_rec.lang
              , l_param_rec.appl_status
              , l_param_rec.date_from
              , l_param_rec.date_to
              , l_param_rec.appl_id_from
              , l_param_rec.appl_id_to
              , l_param_rec.customer_number
              , l_param_rec.contract_number
              , l_param_rec.account_number
              , l_param_rec.appl_number
              , l_param_rec.appl_id
              , l_param_rec.flow_id
              , l_param_rec.card_number
              , l_param_rec.merchant_number
              , l_param_rec.terminal_number
              , l_param_rec.appl_type
              , l_param_rec.reject_code
              , l_param_rec.entity_type
              , l_param_rec.object_id
              , l_param_rec.default_inst_name
              , l_param_rec.current_user_id
              , l_param_rec.user_id
              , l_param_rec.user_name
              , l_param_rec.role_id
              , l_param_rec.role_name
              , l_param_rec.appl_prioritized
              , i_first_row
              , i_last_row;

    end if;

    com_ui_object_search_pkg.finish_search(
        i_is_first_call => i_is_first_call
      , i_row_count     => io_row_count
      , i_sql_statement => l_ref_source
    );

exception
    when others then
        com_ui_object_search_pkg.finish_search(
            i_is_first_call => i_is_first_call
          , i_row_count     => io_row_count
          , i_sql_statement => l_ref_source
          , i_is_failed     => com_api_type_pkg.TRUE
          , i_sqlerrm_text  => SQLERRM
        );
        raise;
end;

procedure get_ref_cur(
    o_ref_cur              out  com_api_type_pkg.t_ref_cur
  , i_row_count         in      com_api_type_pkg.t_medium_id  default null
  , i_first_row         in      com_api_type_pkg.t_long_id
  , i_last_row          in      com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
  , i_sorting_tab       in      com_param_map_tpt             default null
) is
    l_row_count         com_api_type_pkg.t_long_id  := i_row_count;
begin
    get_ref_cur_base(
        o_ref_cur           => o_ref_cur
      , io_row_count        => l_row_count
      , i_first_row         => i_first_row
      , i_last_row          => i_last_row
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => i_sorting_tab
      , i_is_first_call     => com_api_const_pkg.FALSE
    );
end;

procedure get_row_count(
    o_row_count            out  com_api_type_pkg.t_long_id
  , i_tab_name          in      com_api_type_pkg.t_name
  , i_param_tab         in      com_param_map_tpt
) is
    l_ref_cur           com_api_type_pkg.t_ref_cur;
    l_sorting_tab       com_param_map_tpt;
begin
    get_ref_cur_base(
        o_ref_cur           => l_ref_cur
      , io_row_count        => o_row_count
      , i_first_row         => null
      , i_last_row          => null
      , i_tab_name          => i_tab_name
      , i_param_tab         => i_param_tab
      , i_sorting_tab       => l_sorting_tab
      , i_is_first_call     => com_api_const_pkg.TRUE
    );
end;

end app_ui_application_search_pkg;
/
