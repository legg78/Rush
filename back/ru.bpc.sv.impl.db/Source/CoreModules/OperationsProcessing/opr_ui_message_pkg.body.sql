create or replace package body opr_ui_message_pkg is

    procedure get_ref_cur_base (
        o_ref_cur                 out com_api_type_pkg.t_ref_cur
        , o_row_count             out com_api_type_pkg.t_tiny_id
        , i_first_row             in com_api_type_pkg.t_tiny_id
        , i_last_row              in com_api_type_pkg.t_tiny_id
        , i_param_tab             in com_param_map_tpt
        , i_is_first_call         in com_api_type_pkg.t_boolean
    ) is
        l_oper_id                 com_api_type_pkg.t_long_id;
        l_tech_msg_type           com_api_type_pkg.t_name;
        l_lang                    com_api_type_pkg.t_name;
        
        l_sel_source              com_api_type_pkg.t_lob_data;
        l_ref_source              com_api_type_pkg.t_lob_data;
        
        function get_char_value(
            i_param_name        in      com_api_type_pkg.t_name
        ) return com_api_type_pkg.t_name
        is
            l_result            com_api_type_pkg.t_name;
        begin
            select char_value
              into l_result
              from table(cast(i_param_tab as com_param_map_tpt))
             where upper(name) = upper(i_param_name);

             return l_result;
        exception
            when no_data_found then
                return null;
             when others then
                trc_log_pkg.debug('get_char_value FAILED with i_param_name ['||i_param_name||']');
                raise;
        end;

        function get_date_value(
            i_param_name        in      com_api_type_pkg.t_name
        ) return date
        is
            l_result            date;
        begin
            select date_value
              into l_result
              from table(cast(i_param_tab as com_param_map_tpt))
             where upper(name) = upper(i_param_name);

            return l_result;
        exception
            when no_data_found then
                return null;
            when others then
                trc_log_pkg.debug('get_date_value FAILED with i_param_name ['||i_param_name||']');
                raise;
        end;

        function get_number_value(
            i_param_name        in      com_api_type_pkg.t_name
        ) return number
        is
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
            when others then
                trc_log_pkg.debug('get_number_value FAILED with i_param_name ['||i_param_name||']');
                raise;
        end;
        
    begin
        l_sel_source := 
'select'
  ||' com_api_label_pkg.get_label_text(''ATM_MESSAGE'', l.lang) as name'
  ||', to_char(a.message_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_atm_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_atm a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''CHRONOPAY_GATEWAY_MESSAGE'', l.lang) as name'
  ||', to_char(null) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_cnpy_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_cnpy a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''CYBERPLAT_BASED_REQUESTS'', l.lang) as name'
  ||', a.action as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_cyberplat_in_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_cyberplat_in a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''E_PAY_MESSAGE'', l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_epay_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_epay a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ISO8583POS_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_iso8583pos_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_iso8583pos a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ISO8583BIC_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_iso8583bic_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_iso8583bic a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''MASTERCARD_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_mastercard_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_mastercard a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''SVIP_MESSAGE'',  l.lang) as name'
  ||', a.message_name as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.message_name as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_svip_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_svip a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''VISA_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_visa_basei_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_visa_basei a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''VISA_SMS_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_visa_sms_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_visa_sms a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''WAY4_MESSAGE'',  l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_way4_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aup_way4 a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''MASTERCARD_CLEARING_MESSAGE'',  l.lang) as name'
  ||', a.mti || ''/'' || a.de024 as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''mcw_ui_fin_msg_vw'' as view_name'
  ||', l.lang'
  ||', a.de012 as oper_date'
||' from'
  ||' mcw_fin a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''VISA_CLEARING_MESSAGE'',  l.lang) as name'
  ||', a.trans_code as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''vis_ui_fin_message_vw'' as view_name'
  ||', l.lang'
  ||', a.oper_date as oper_date'
||' from'
  ||' vis_fin_message a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''AUTHORIZATIONS_MESSAGE'',  l.lang) as name'
  ||', a.resp_code as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aut_ui_auth_msg_vw'' as view_name'
  ||', l.lang'
  ||', a.device_date as oper_date'
||' from'
  ||' aut_auth a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''MASTERCARD_CLEARING_ADDENDUM_MESSAGE'',  l.lang) as name'
  ||', a.mti || ''/'' || a.de024 as tech_msg_type'
  ||', a.fin_id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''mcw_ui_add_msg_vw'' as view_name'
  ||', l.lang'
  ||', b.de012 as oper_date'
||' from'
  ||' mcw_add a'
  ||', mcw_fin b'
  ||', com_language_vw l'
||' where'
    ||' a.fin_id = b.id'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ACI_ATM_FIN_MESSAGE'', l.lang) as name'
  ||', a.authx_type as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aci_ui_atm_fin_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aci_atm_fin a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ACI_POS_FIN_MESSAGE'', l.lang) as name'
  ||', a.authx_typ as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aci_ui_pos_fin_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aci_pos_fin a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ACI_ATM_CASH_MESSAGE'', l.lang) as name'
  ||', a.term_cash_admin_cde as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aci_ui_atm_cash_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aci_atm_cash a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ACI_ATM_SETL_TTL_MESSAGE'', l.lang) as name'
  ||', a.setl_ttl_admin_cde as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aci_ui_atm_setl_ttl_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aci_atm_setl_ttl a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''ACI_ATM_SETL_MESSAGE'', l.lang) as name'
  ||', a.term_setl_admin_cde as tech_msg_type'
  ||', a.id as oper_id'
  ||', to_number(null) as tech_id'
  ||', to_char(null) as time_mark'
  ||', ''aci_ui_atm_setl_msg_vw'' as view_name'
  ||', l.lang'
  ||', to_date(null) as oper_date'
||' from'
  ||' aci_atm_setl a'
  ||', com_language_vw l'
||' union'
||' select'
  ||' com_api_label_pkg.get_label_text(''SV2SV_MESSAGE'', l.lang) as name'
  ||', to_char(a.iso_msg_type) as tech_msg_type'
  ||', a.auth_id as oper_id'
  ||', a.tech_id as tech_id'
  ||', a.time_mark as time_mark'
  ||', ''aup_ui_sv2sv_msg_vw'' as view_name'
  ||', l.lang'
  ||', a.trans_date as oper_date'
||' from'
  ||' aup_sv2sv a'
  ||', com_language_vw l'
  || opr_cst_message_pkg.get_message_source
  ;

        l_ref_source := 
        'select'
        || ' o.name, o.tech_msg_type, o.oper_id, o.tech_id, o.time_mark, o.view_name, o.lang, o.oper_date'
        || ' from ('
        || l_sel_source
        || ') o, (select :oper_id oper_id, :tech_msg_type tech_msg_type, :lang lang from dual) x'
        || ' where 1=1';
        
        l_oper_id := get_number_value('OPER_ID');
        if l_oper_id is not null then
            l_ref_source := l_ref_source || ' and o.oper_id = x.oper_id';
        end if;
        l_tech_msg_type := get_char_value('TECH_MSG_TYPE');
        if l_tech_msg_type is not null then
            l_ref_source := l_ref_source || ' and o.tech_msg_type = x.tech_msg_type';
        end if;
        l_lang := get_char_value('LANGUAGE');
        if l_lang is not null then
            l_ref_source := l_ref_source || ' and o.lang = x.lang';
        end if;
        
        if i_is_first_call = com_api_const_pkg.TRUE then
            l_ref_source := 'select count(1) from (' || l_ref_source || ')';
--dbms_output.put_line(l_ref_source);
            execute immediate l_ref_source into o_row_count using l_oper_id, l_tech_msg_type, l_lang;
        else
            l_ref_source := l_ref_source || ' order by o.time_mark, o.oper_date';
            
            l_ref_source :=
            'select b.name, b.tech_msg_type, b.oper_id, b.tech_id, b.time_mark, b.view_name, b.lang, b.oper_date'
           ||' from ( select * from ('
                  || ' select a.*, rownum rn from ('|| l_ref_source ||') a'
                  || ') where rn between :p_first_row and :p_last_row'
              || ') b'
            ||' order by b.rn';
--dbms_output.put_line(l_ref_source);
            open o_ref_cur for l_ref_source using l_oper_id, l_tech_msg_type, l_lang, i_first_row, i_last_row;
        end if;
    end;

    procedure get_ref_cur (
        o_ref_cur                 out com_api_type_pkg.t_ref_cur
        , i_first_row             in com_api_type_pkg.t_tiny_id
        , i_last_row              in com_api_type_pkg.t_tiny_id
        , i_param_tab             in com_param_map_tpt
    ) is
        l_row_count         com_api_type_pkg.t_tiny_id;
    begin
        get_ref_cur_base (
            o_ref_cur          => o_ref_cur
            , o_row_count      => l_row_count
            , i_first_row      => i_first_row
            , i_last_row       => i_last_row
            , i_param_tab      => i_param_tab
            , i_is_first_call  => com_api_const_pkg.FALSE
        );
    end;
    
    procedure get_row_count (
        o_row_count               out com_api_type_pkg.t_tiny_id
        , i_param_tab             in com_param_map_tpt
    ) is
        l_ref_cur                 com_api_type_pkg.t_ref_cur;
    begin
        get_ref_cur_base (
            o_ref_cur          => l_ref_cur
            , o_row_count      => o_row_count
            , i_first_row      => null
            , i_last_row       => null
            , i_param_tab      => i_param_tab
            , i_is_first_call  => com_api_const_pkg.TRUE
        );
    end;

end;
/
