create or replace package body prs_api_card_pkg is
/************************************************************
 * API for cards <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 22.10.2010 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-09-09 14:26:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_card_pkg <br />
 * @headcom
 ************************************************************/
    CRLF           constant com_api_type_pkg.t_oracle_name := chr(13) || chr(10);
    ENTITY_PERSON  constant com_api_type_pkg.t_dict_value  := 'ENTTPERS';

    -- todo
    procedure put_lines(p_msg in varchar2) is
        v_msg varchar2(32767) := p_msg;
        v_255 varchar2(255);
        v_eol number;
    begin
        if length(v_msg) > 255 then
            while v_msg is not null loop
                v_255 := substr(v_msg, 1, 255);
                v_eol := instr(v_255, ' ', -1);
                if v_eol = 0 then
                    v_eol := 255;
                else
                    v_255 := substr(v_255, 1, v_eol);
                end if;
                dbms_output.put_line(v_255);
                v_msg := substr(v_msg, v_eol + 1);
            end loop;
        else
            dbms_output.put_line(v_msg);
        end if;
    end;

    procedure enum_cards (
        o_perso_cur             out sys_refcursor
        , o_row_count           out com_api_type_pkg.t_long_id
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_card_instance_id    in com_api_type_pkg.t_medium_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_order_clause        in com_api_type_pkg.t_text
        , i_is_first_call       in com_api_type_pkg.t_boolean
        , i_ignore_slave_count  in com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
    ) is
        l_embossing_request     com_api_type_pkg.t_dict_value;
        l_pin_mailer_request    com_api_type_pkg.t_dict_value;
        l_lang                  com_api_type_pkg.t_dict_value := coalesce(i_lang, get_user_lang);

        FROM_PLACEHOLDER        constant com_api_type_pkg.t_oracle_name := '##FROM##';
        WHERE_PLACEHOLDER       constant com_api_type_pkg.t_oracle_name := '##WHERE##';
        COUNT_PLACEHOLDER       constant com_api_type_pkg.t_oracle_name := '##CARD_COUNT##';
        BCARD_PLACEHOLDER       constant com_api_type_pkg.t_oracle_name := '##BATCH_CARD_ID##';
        IS_LEAF_PLACEHOLDER     constant com_api_type_pkg.t_oracle_name := '##IS_LEAF##';
        ORDER_BY_PLACEHOLDER    constant com_api_type_pkg.t_oracle_name := '##ORDER_BY##';
        COLUMN_PLACEHOLDER      constant com_api_type_pkg.t_oracle_name := '##COLUMN_LIST##';

        COLUMN_COUNT            constant com_api_type_pkg.t_text :=
'select /*+ INDEX ( ci ISS_CARD_STATUS_CSTE0100_NDX ) */'
 ||'ci.rowid row_id';
        ORDER_BY_STMT           constant com_api_type_pkg.t_text :=
            ' order by ' || ORDER_BY_PLACEHOLDER;

        l_column_list           com_api_type_pkg.t_sql_statement :=
'select /*+ INDEX ( ci ISS_CARD_STATUS_CSTE0100_NDX ) */'
 ||'ci.rowid row_id'
    -- card_instance
 ||', ci.id card_instance_id'
 ||', ci.card_id'
 ||', ci.seq_number'
 ||', ci.reg_date'
 ||', ci.iss_date'
 ||', ci.start_date'
 ||', ci.expir_date'
 ||', ci.cardholder_name'
 ||', ci.company_name'
 ||', ci.pin_request'
 ||', ci.embossing_request'
 ||', ci.pin_mailer_request'
 ||', ci.status'
 ||', ci.perso_priority'
 ||', ci.perso_method_id'
 ||', ci.bin_id'
 ||', ci.blank_type_id'
 ||', ci.reissue_reason'
    -- card
 ||', oc.card_mask'
 ||', oc.inst_id'
 ||', get_text(''ost_institution'', ''name'', oc.inst_id, x.user_lang) inst_name'
 ||', oc.card_type_id'
 ||', get_text(''net_card_type'', ''name'', oc.card_type_id, x.user_lang) card_type_name'
 ||', oc.cardholder_id'
 ||', ct.product_id'
 ||', prd.product_number'
 ||', get_text(''prd_product'', ''label'', ct.product_id, x.user_lang) as product_name'
 ||', ct.agent_id as contract_agent_id'
 ||', oc.customer_id'
 ||', cm.customer_number'
 ||', oc.contract_id'
 ||', oc.category'
 ||', oc.split_hash'
-- card_number
 ||', iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number) as card_number'
-- card_instance_data
 ||', cd.pvv'
 ||', cd.kcolb_nip'
 ||', cd.pvv pvv2'
 ||', cd.pin_offset'
-- com_person
 ||', nvl(pt.id, pcm.id) as person_id'
 ||', nvl(pt.first_name, pcm.first_name) as first_name'
 ||', nvl(pt.second_name, pcm.second_name) as second_name'
 ||', nvl(pt.surname, pcm.surname) as surname'
 ||', nvl(pt.suffix, pcm.suffix) as suffix'
 ||', nvl(pt.gender, pcm.gender) as gender'
 ||', nvl(pt.birthday, pcm.birthday) as birthday'
-- com_person_id
-- ||', pi.id_type'
 ||', get_article_text(pi.id_type, x.user_lang) id_type'
 ||', pi.id_number'
 ||', pi.id_series'
-- prs_batch
 ||', bt.hsm_device_id hsm_device_id'
 ||', '|| COUNT_PLACEHOLDER ||' card_count'
-- prs_batch_card
 ||', '|| BCARD_PLACEHOLDER ||' batch_card_id'
-- cardholder address
 ||', nvl2(ad.id, ad.street, adc.street) as street'
 ||', nvl2(ad.id, ad.house, adc.house) as house'
 ||', nvl2(ad.id, ad.apartment, adc.apartment) as apartment'
 ||', nvl2(ad.id, ad.postal_code, adc.postal_code) as postal_code'
 ||', nvl2(ad.id, ad.city, adc.city) as city'
 ||', nvl2(ad.id, ad.country, adc.country) as country'
 ||', nvl2(ad.id, com_api_i18n_pkg.get_text(''com_country'', ''name'', ad.country_id, ad.country_lang), com_api_i18n_pkg.get_text(''com_country'', ''name'', adc.country_id, adc.country_lang)) as country_name'
 ||', nvl2(ad.id, ad.region_code, adc.region_code) as region_code'
 ||', ci.agent_id'
 ||', get_text(''ost_agent'', ''name'', ci.agent_id, x.user_lang) agent_name'
 ||', ost_ui_agent_pkg.get_agent_number(ci.agent_id) agent_number'
 ||', pd.state perso_state'
 ||', pd.emv_appl_scheme_id'
 ||', ci.icc_instance_id'
 ||', '|| IS_LEAF_PLACEHOLDER ||' slave_count'
 ||', x.user_lang lang'
 ||', ( select distinct first_value(a.account_number) over (order by o.usage_order, o.is_pos_default desc, o.is_atm_default desc ) '
    || '  from acc_account_object o, acc_account a '
    || ' where a.id = o.account_id '
      || ' and o.entity_type = ''' || iss_api_const_pkg.ENTITY_TYPE_CARD || ''''
      || ' and o.object_id = oc.id'
      || ' and a.status != ''' || acc_api_const_pkg.ACCOUNT_STATUS_CLOSED || ''' ) as card_account '
 ||', (select case when count(id) > 1 then 1 else 0 end from iss_card_instance where card_id = oc.id) is_renewal'
 ||', es.type emv_scheme_type '
 ||', ci.card_uid '
 ||', pd.uid_format_id ' 
 ||', ci.embossed_surname '
 ||', ci.embossed_first_name '
 ||', ci.embossed_second_name '
 ||', ci.embossed_title '
 ||', ci.embossed_line_additional '
 ||', ci.supplementary_info_1 '
 ||', ci.cardholder_photo_file_name '
 ||', ci.cardholder_sign_file_name '
 ||', nvl(cch.preferred_lang, ccu.preferred_lang) as preferred_lang '
 ;

    l_cursor_stmt               com_api_type_pkg.t_sql_statement :=
COLUMN_PLACEHOLDER || '
from'
  ||' iss_card_instance ci'
  ||' , iss_card oc'
  ||' , iss_card_number cn'
  ||' , iss_card_instance_data cd'
  ||' , prd_contract ct'
  ||' , prd_product prd'
  ||' , iss_product_card_type pd'
  ||' , prs_blank_type bl'
  ||' , iss_cardholder ch'
  ||' , (select id, min(lang) keep(dense_rank first order by decode(lang, '''||l_lang||''', 1, '''||com_api_const_pkg.LANGUAGE_ENGLISH||''', 2, 3)) lang'
      ||' from com_person group by id) pt2'
  ||' , com_person pt'
  ||' , prd_customer cm'
  ||' , (select id, min(lang) keep(dense_rank first order by decode(lang, '''||l_lang||''', 1, '''||com_api_const_pkg.LANGUAGE_ENGLISH||''', 2, 3)) lang'
      ||' from com_person group by id) pcm2'
  ||' , com_person pcm'
  ||' , (select'
         ||' object_id'
         ||' , max(id) id'
      ||' from'
      ||'  com_id_object'
      ||' group by'
         ||' object_id'
  ||'  ) d'
  ||' , com_id_object pi'
  ||' , (select'
         ||' ca.id'
         ||' , ca.lang'
         ||' , ca.country'
         ||' , ca.region'
         ||' , ca.city'
         ||' , ca.street'
         ||' , ca.house'
         ||' , ca.apartment'
         ||' , ca.postal_code'
         ||' , ca.region_code'
         ||' , ct.id as country_id'
         ||' , ca.lang as country_lang'
         ||' , ob.object_id'
         ||' , row_number() over (partition by ob.object_id order by decode(ob.address_type, ''ADTPSTDL'', -1, ob.address_id)) rn'
      ||' from'
         ||' com_address ca'
         ||' , com_address_object ob'
         ||' , com_country ct'
     ||' where'
          ||' ca.id = ob.address_id'
          ||' and ob.entity_type = ''ENTTCRDH'''
          ||' and ct.code(+) = ca.country'
  ||' ) ad'
  ||' , (select'
         ||' ca.id'
         ||' , ca.lang'
         ||' , ca.country'
         ||' , ca.region'
         ||' , ca.city'
         ||' , ca.street'
         ||' , ca.house'
         ||' , ca.apartment'
         ||' , ca.postal_code'
         ||' , ca.region_code'
         ||' , ct.id as country_id'
         ||' , ca.lang as country_lang'
         ||' , ob.object_id'
         ||' , row_number() over (partition by ob.object_id order by decode(ob.address_type, ''ADTPSTDL'', -1, ob.address_id)) rn'
      ||' from'
         ||' com_address ca'
         ||' , com_address_object ob'
         ||' , com_country ct'
     ||' where'
          ||' ca.id = ob.address_id'
          ||' and ob.entity_type = ''ENTTCUST'''
          ||' and ct.code(+) = ca.country'
  ||' ) adc'
  ||' , (select'
         ||' co.object_id'
         ||' , cc.preferred_lang'
         ||' , row_number() over (partition by co.object_id order by nvl2(cc.preferred_lang, 0, 1), cc.id desc) rn'
      ||' from'
         ||' com_contact cc'
         ||' , com_contact_object co'
     ||' where'
          ||' cc.id = co.contact_id'
          ||' and co.entity_type = ''ENTTCRDH'''
  ||' ) cch'
  ||' , (select'
         ||' co.object_id'
         ||' , cc.preferred_lang'
         ||' , row_number() over (partition by co.object_id order by nvl2(cc.preferred_lang, 0, 1), cc.id desc) rn'
      ||' from'
         ||' com_contact cc'
         ||' , com_contact_object co'
     ||' where'
          ||' cc.id = co.contact_id'
          ||' and co.entity_type = ''ENTTCUST'''
  ||' ) ccu'
  ||', emv_appl_scheme es'
  ||', (select'
          ||' :batch_id batch_id'
          ||' , :embossing_request embossing_request'
          ||' , :pin_mailer_request pin_mailer_request'
          ||' , :user_lang user_lang'
          ||' , :card_instance_id card_instance_id'
       ||' from'
           ||' dual) x'
|| FROM_PLACEHOLDER ||' '
||'where'
  ||' oc.id = ci.card_id'
  ||' and oc.id = cn.card_id'
  ||' and cd.card_instance_id(+) = ci.id'
  ||' and decode(ci.state, ''' || iss_api_const_pkg.CARD_STATE_PERSONALIZATION || ''', ''' || iss_api_const_pkg.CARD_STATE_PERSONALIZATION
      || ''') = ''' || iss_api_const_pkg.CARD_STATE_PERSONALIZATION || ''''
  ||' and ct.id = oc.contract_id'
  ||' and bl.id(+) = ci.blank_type_id'
  ||' and ch.id(+) = oc.cardholder_id'
  ||' and ch.inst_id(+) = oc.inst_id'
  ||' and pt2.id(+) = ch.person_id'
  ||' and pt.id(+) = pt2.id'
  ||' and pt.lang(+) = pt2.lang'
  ||' and d.object_id(+) = pt.id'
  ||' and pi.id(+) = d.id'
  ||' and ad.object_id(+) = oc.cardholder_id'
  ||' and ad.rn(+) = 1'
  ||' and adc.object_id(+) = oc.customer_id'
  ||' and adc.rn(+) = 1'
  ||' and cch.object_id(+) = oc.cardholder_id'
  ||' and cch.rn(+) = 1'
  ||' and ccu.object_id(+) = oc.customer_id'
  ||' and ccu.rn(+) = 1'
  ||' and prd.id = ct.product_id'
  ||' and pd.bin_id = ci.bin_id'
  ||' and pd.product_id = ct.product_id'
  ||' and pd.card_type_id = oc.card_type_id'
  ||' and ci.seq_number between pd.seq_number_low and pd.seq_number_high'
  ||' and es.id(+) = pd.emv_appl_scheme_id'
  ||' and cm.id = ct.customer_id'
  ||' and pcm2.id(+) = decode(cm.entity_type, '''||ENTITY_PERSON||''', cm.object_id, null)'
  ||' and pcm.id(+) = pcm2.id'
  ||' and pcm.lang(+) = pcm2.lang'
  || WHERE_PLACEHOLDER;

    begin
        trc_log_pkg.debug (
            i_text         => 'Enum card count for personalization'
        );                

        l_embossing_request := nvl(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS);
        l_pin_mailer_request := nvl(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT);


        if i_is_first_call = com_api_type_pkg.TRUE then
            l_cursor_stmt := 'select xx.* from (' || l_cursor_stmt || ') xx';
        else
            l_cursor_stmt := 'select row_number() over (order by '|| ORDER_BY_PLACEHOLDER ||'), xx.* from (' || l_cursor_stmt || ') xx';
        end if;

        if i_card_instance_id is null then

            trc_log_pkg.debug (
                i_text          => 'batch[#1] card_instance_id[#2] embossing_request[#3] pin_mailer_request[#4]'
                , i_env_param1  => i_batch_id
                , i_env_param2  => i_card_instance_id
                , i_env_param3  => l_embossing_request
                , i_env_param4  => l_pin_mailer_request
            );

            l_column_list := replace(l_column_list, COUNT_PLACEHOLDER, 'bt.card_count');
            l_column_list := replace(l_column_list, BCARD_PLACEHOLDER, 'bc.id');

            if i_ignore_slave_count = com_api_type_pkg.TRUE then
                l_cursor_stmt := replace(l_cursor_stmt, IS_LEAF_PLACEHOLDER, 'null');
            else
                -- This subquery does not use index. It is not used in the "itf_prc_cardgen_pkg.generate_without_batch" process.
                -- Used in "prs_prc_perso_pkg.generate_with_batch" and "prs_prc_perso_pkg.generate_without_batch" yet.
                l_column_list := replace(l_column_list, IS_LEAF_PLACEHOLDER, '(select count(e.id) from iss_card_instance e where e.icc_instance_id = ci.id)');
            end if;

            l_cursor_stmt := replace(l_cursor_stmt, FROM_PLACEHOLDER, ', prs_batch bt, prs_batch_card bc');
            l_cursor_stmt := replace(l_cursor_stmt, WHERE_PLACEHOLDER, '
and bt.id = bc.batch_id
and bt.id = x.batch_id
and bt.status in (''' || prs_api_const_pkg.BATCH_STATUS_INITIAL || ''', ''' || prs_api_const_pkg.BATCH_STATUS_IN_PROGRESS || ''')
and oc.inst_id = bt.inst_id
and ci.id = bc.card_instance_id
and ci.embossing_request = decode(x.embossing_request, ''' || iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS || ''', ci.embossing_request, x.embossing_request)
and ci.pin_mailer_request = decode(x.pin_mailer_request, ''' || iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT || ''', ci.pin_mailer_request, x.pin_mailer_request) ');

        else

            l_embossing_request :=
            case when l_embossing_request = iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS then
                iss_api_const_pkg.EMBOSSING_REQUEST_CHIP
            else
                l_embossing_request
            end;

            trc_log_pkg.debug (
                i_text          => 'batch[#1] card_instance_id[#2] embossing_request[#3] pin_mailer_request[#4]'
                , i_env_param1  => i_batch_id
                , i_env_param2  => i_card_instance_id
                , i_env_param3  => l_embossing_request
                , i_env_param4  => l_pin_mailer_request
            );

            l_cursor_stmt := replace(l_cursor_stmt, FROM_PLACEHOLDER, ', prs_batch bt');
            l_cursor_stmt := replace(l_cursor_stmt, WHERE_PLACEHOLDER, '
and bt.id = x.batch_id
and ci.icc_instance_id = x.card_instance_id
and ci.embossing_request = decode(x.embossing_request, ''' || iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS || ''', ci.embossing_request, x.embossing_request)
and ci.pin_mailer_request = decode(x.pin_mailer_request, ''' || iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT || ''', ci.pin_mailer_request, x.i_pin_mailer_request) ');

        end if;

        if i_is_first_call = com_api_type_pkg.TRUE then
            l_cursor_stmt := replace(l_cursor_stmt, COLUMN_PLACEHOLDER, COLUMN_COUNT);
        else
            l_cursor_stmt := replace(l_cursor_stmt, COLUMN_PLACEHOLDER, l_column_list);
            l_cursor_stmt := l_cursor_stmt || ORDER_BY_STMT;
        end if;

        if i_order_clause is null then
            l_cursor_stmt := replace(l_cursor_stmt, ORDER_BY_PLACEHOLDER, 'blank_type_id, card_instance_id');
        else
            l_cursor_stmt := replace(l_cursor_stmt, ORDER_BY_PLACEHOLDER, i_order_clause);
        end if;

        -- make cursor
        l_cursor_stmt := replace(l_cursor_stmt, COUNT_PLACEHOLDER, 'null');
        l_cursor_stmt := replace(l_cursor_stmt, BCARD_PLACEHOLDER, 'null');
        l_cursor_stmt := replace(l_cursor_stmt, IS_LEAF_PLACEHOLDER, 'null');
        l_cursor_stmt := replace(l_cursor_stmt, FROM_PLACEHOLDER, '');
        l_cursor_stmt := replace(l_cursor_stmt, WHERE_PLACEHOLDER, '');

        if i_is_first_call = get_true then
            l_cursor_stmt := 'select count(1) from ('|| l_cursor_stmt || ')';
        end if;

        --put_lines(l_cursor_stmt);

        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.enum_card: l_cursor_stmt = '
                                          || substr(l_cursor_stmt, 1, 3900)
        );
        trc_log_pkg.debug(
            i_text => lower($$PLSQL_UNIT) || '.enum_card: l_cursor_stmt = '
                                          || substr(l_cursor_stmt, 3901, 3900)
        );

        if i_is_first_call = com_api_type_pkg.TRUE then
            execute immediate l_cursor_stmt
            into o_row_count
            using
            i_batch_id
            , l_embossing_request
            , l_pin_mailer_request
            , l_lang
            , i_card_instance_id;
        else
            open o_perso_cur for l_cursor_stmt
            using
            i_batch_id
            , l_embossing_request
            , l_pin_mailer_request
            , l_lang
            , i_card_instance_id;
        end if;
    exception
        when others then
            trc_log_pkg.debug(
                substr(
                    lower($$PLSQL_UNIT) || '.enum_card:' || CRLF ||
                    'l_cursor_stmt = ' || CRLF || l_cursor_stmt || CRLF ||
                    'l_column_list = ' || CRLF || l_column_list
                  , 1, 4000
                )
            );
            raise;
    end;

    procedure enum_card_for_perso (
        o_perso_cur             out sys_refcursor
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_order_clause        in com_api_type_pkg.t_text
        , i_ignore_slave_count  in com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
    ) is
        l_row_count             com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text         => 'Enum card for personalization'
        );

        enum_cards (
            o_perso_cur             => o_perso_cur
            , o_row_count           => l_row_count
            , i_batch_id            => i_batch_id
            , i_card_instance_id    => null
            , i_embossing_request   => i_embossing_request
            , i_pin_mailer_request  => i_pin_mailer_request
            , i_lang                => i_lang
            , i_order_clause        => i_order_clause
            , i_is_first_call       => com_api_type_pkg.FALSE
            , i_ignore_slave_count  => i_ignore_slave_count
        );
    end;

    procedure enum_child_card_for_perso (
        o_perso_cur             out sys_refcursor
        , i_batch_id            in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_card_instance_id    in com_api_type_pkg.t_medium_id
    ) is
        l_row_count             com_api_type_pkg.t_long_id;
    begin
        trc_log_pkg.debug (
            i_text         => 'Enum child card for personalization'
        );

        enum_cards (
            o_perso_cur             => o_perso_cur
            , o_row_count           => l_row_count
            , i_batch_id            => i_batch_id
            , i_card_instance_id    => i_card_instance_id
            , i_embossing_request   => i_embossing_request
            , i_pin_mailer_request  => i_pin_mailer_request
            , i_lang                => i_lang
            , i_order_clause        => null
            , i_is_first_call       => com_api_type_pkg.FALSE
        );

    end;

    function estimate_card_for_perso (
        i_batch_id              in com_api_type_pkg.t_short_id
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_ignore_slave_count  in com_api_type_pkg.t_boolean    := com_api_type_pkg.FALSE
    ) return com_api_type_pkg.t_long_id is
        l_result                com_api_type_pkg.t_long_id;
        l_perso_cur             sys_refcursor;
    begin
        trc_log_pkg.debug (
            i_text         => 'Estimate card count for personalization'
        );

        enum_cards (
            o_perso_cur             => l_perso_cur
            , o_row_count           => l_result
            , i_batch_id            => i_batch_id
            , i_card_instance_id    => null
            , i_embossing_request   => i_embossing_request
            , i_pin_mailer_request  => i_pin_mailer_request
            , i_lang                => i_lang
            , i_order_clause        => null
            , i_is_first_call       => com_api_type_pkg.TRUE
            , i_ignore_slave_count  => i_ignore_slave_count
        );

        trc_log_pkg.debug (
            i_text          => 'Estimate card count [#1]'
            , i_env_param1  => l_result
        );

        return l_result;
    end;

    function enum_sort_condition (
        i_sort_id               in com_api_type_pkg.t_tiny_id
    ) return com_api_type_pkg.t_text is
    begin
        trc_log_pkg.debug (
            i_text          => 'Enum sort condition for sort id [#1]'
            , i_env_param1  => i_sort_id
        );

        for rec in (
            select condition
              from prs_sort
             where id = i_sort_id
        ) loop
            trc_log_pkg.debug (
                i_text          => 'Order condition [#1]'
                , i_env_param1  => rec.condition
            );
            return rec.condition;
        end loop;

        trc_log_pkg.debug (
            i_text  => 'Order condition not found'
        );
        return '';
    end;

    procedure mark_ok_perso (
        i_rowid                 in com_api_type_pkg.t_rowid_tab
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_id                  in com_api_type_pkg.t_number_tab
        , i_pvv                 in com_api_type_pkg.t_number_tab
        , i_pin_offset          in com_api_type_pkg.t_cmid_tab
        , i_pvk_index           in com_api_type_pkg.t_number_tab
        , i_pin_block           in com_api_type_pkg.t_varchar2_tab
        , i_pin_block_format    in com_api_type_pkg.t_dict_tab
        , i_iss_date            in com_api_type_pkg.t_date_tab
        , i_state               in com_api_type_pkg.t_dict_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text         => 'Mark card and save pin block/pvv'
        );

        forall i in 1 .. i_rowid.count
            update
                iss_card_instance
            set
                embossing_request = decode(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS, embossing_request)
                , pin_mailer_request = decode(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT, pin_mailer_request)
                , pin_request = decode(pin_request, iss_api_const_pkg.PIN_REQUEST_GENERATE, iss_api_const_pkg.PIN_REQUEST_DONT_GENERATE, pin_request)
                , state = case when
                          decode(i_embossing_request, iss_api_const_pkg.EMBOSSING_REQUEST_EMBOSS, iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS, embossing_request) = iss_api_const_pkg.EMBOSSING_REQUEST_DONT_EMBOSS
                          and decode(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_PRINT, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT, pin_mailer_request) = iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT
                               then i_state(i)
                          else
                              state
                          end
                , iss_date = nvl(i_iss_date(i), com_api_sttl_day_pkg.get_sysdate)
            where
                rowid = i_rowid(i);

        forall i in 1 .. i_id.count
            merge into
                iss_card_instance_data dst
            using (
                select
                    i_id(i)                  card_instance_id
                    , i_pin_block(i)         pin_block
                    , i_pin_block_format(i)  pin_block_format
                    , i_pvv(i)               pvv
                    , i_pin_offset(i)        pin_offset
                    , i_pvk_index(i)         pvk_index
                from dual
            ) src
            on (
                src.card_instance_id = dst.card_instance_id
            )
            when matched then
                update
                set
                    dst.kcolb_nip          = src.pin_block
                    , dst.pin_block_format = src.pin_block_format
                    , dst.pvv              = src.pvv
                    , dst.pin_offset       = src.pin_offset
                    , dst.pvk_index        = src.pvk_index
            when not matched then
                insert (
                    dst.card_instance_id
                    , dst.kcolb_nip
                    , dst.pin_block_format
                    , dst.pvv
                    , dst.pin_offset
                    , dst.pvk_index
                ) values (
                    src.card_instance_id
                    , src.pin_block
                    , src.pin_block_format
                    , src.pvv
                    , src.pin_offset
                    , src.pvk_index
                );
    end;

    procedure mark_ok_perso (
        i_id                    in com_api_type_pkg.t_medium_id
        , i_pvv                 in com_api_type_pkg.t_tiny_id
        , i_pin_offset          in com_api_type_pkg.t_cmid
        , i_pvk_index           in com_api_type_pkg.t_tiny_id
        , i_pin_block           in com_api_type_pkg.t_name
        , i_pin_block_format    in com_api_type_pkg.t_dict_value
    ) is
    begin
        merge into
            iss_card_instance_data dst
        using (
            select
                i_id                    card_instance_id
                , i_pin_block           pin_block
                , i_pin_block_format    pin_block_format
                , i_pvv                 pvv
                , i_pin_offset          pin_offset
                , i_pvk_index           pvk_index
            from dual
        ) src
        on (
            src.card_instance_id = dst.card_instance_id
        )
        when matched then
            update
            set
                dst.kcolb_nip          = src.pin_block
                , dst.pin_block_format = src.pin_block_format
                , dst.pvv              = src.pvv
                , dst.pin_offset       = src.pin_offset
                , dst.pvk_index        = src.pvk_index
        when not matched then
            insert (
                dst.card_instance_id
                , dst.kcolb_nip
                , dst.pin_block_format
                , dst.pvv
                , dst.pin_offset
                , dst.pvk_index
            ) values (
                src.card_instance_id
                , src.pin_block
                , src.pin_block_format
                , src.pvv
                , src.pin_offset
                , src.pvk_index
            );
    end;

    procedure get_batch_cards (
        o_perso_cur                out sys_refcursor
      , i_batch_id              in     com_api_type_pkg.t_short_id
      , i_pin_mailer_request    in     com_api_type_pkg.t_dict_value
      , i_lang                  in     com_api_type_pkg.t_dict_value
    ) is
        l_pin_mailer_request    com_api_type_pkg.t_dict_value;
        l_lang                  com_api_type_pkg.t_dict_value := coalesce(i_lang, get_user_lang);
    begin
        trc_log_pkg.debug (
            i_text         => 'Enum card count for personalization'
        );                

        l_pin_mailer_request := nvl(i_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT);

        trc_log_pkg.debug (
            i_text          => 'batch [#1], pin_mailer_request [#2], lang [#3]'
            , i_env_param1  => i_batch_id
            , i_env_param2  => l_pin_mailer_request
            , i_env_param3  => l_lang
        );

        open o_perso_cur for
            select -- card_instance
                   ci.id card_instance_id
                 , ci.card_id
                 , ci.seq_number
                 , ci.reg_date
                 , ci.iss_date
                 , ci.start_date
                 , ci.expir_date
                 , ci.cardholder_name
                 , ci.company_name
                 , ci.pin_request
                 , ci.embossing_request
                 , ci.pin_mailer_request
                 , ci.status
                 , ci.perso_priority
                 , ci.perso_method_id
                 , ci.bin_id
                 , ci.blank_type_id
                 , ci.reissue_reason
                   -- card
                 , oc.card_mask
                 , oc.inst_id
                 , oc.card_type_id
                 , oc.cardholder_id
                 , ct.product_id
                 , ct.agent_id contract_agent_id
                 , oc.customer_id
                 , oc.contract_id
                 , oc.category
                 , oc.split_hash
                   -- card_number
                 , cn.card_number  -- It's card token. Method "iss_api_token_pkg.decode_card_number" will be called after in method "itf_prc_cardgen_pkg.process"
                   -- prs_batch
                 , bt.hsm_device_id hsm_device_id
                 , bt.card_count card_count
                   -- prs_batch_card
                 , bc.id batch_card_id
                   -- other
                 , ci.agent_id
                 , ci.icc_instance_id
                 , l_lang lang
                 , ci.card_uid 
                 , ci.embossed_surname
                 , ci.embossed_first_name
                 , ci.embossed_second_name
                 , ci.embossed_title
                 , ci.embossed_line_additional
                 , ci.supplementary_info_1
                 , ci.cardholder_photo_file_name
                 , ci.cardholder_sign_file_name
              from prs_batch         bt
                 , prs_batch_card    bc
                 , iss_card_instance ci
                 , iss_card          oc
                 , iss_card_number   cn
                 , prd_contract      ct
             where bt.id       = i_batch_id
               and bt.status  in (prs_api_const_pkg.BATCH_STATUS_INITIAL
                                , prs_api_const_pkg.BATCH_STATUS_IN_PROGRESS)
               and bc.batch_id = bt.id
               and ci.id       = bc.card_instance_id
               and ci.state    = iss_api_const_pkg.CARD_STATE_PERSONALIZATION
               and ci.pin_mailer_request = decode(l_pin_mailer_request, iss_api_const_pkg.PIN_MAILER_REQUEST_DONT_PRINT, ci.pin_mailer_request, l_pin_mailer_request)
               and oc.id       = ci.card_id
               and oc.inst_id  = ci.inst_id
               and cn.card_id  = oc.id
               and ct.id       = oc.contract_id
             order by bc.id;

    end get_batch_cards;

end prs_api_card_pkg;
/
