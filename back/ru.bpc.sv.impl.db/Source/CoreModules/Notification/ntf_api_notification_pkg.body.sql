create or replace package body ntf_api_notification_pkg is
/***********************************************************
* API for notifications. <br>
* Created by Kopachev D.(kopachev@bpc.ru)  at 17.09.2010  <br>
* Last changed by $Author: krukov $ <br>
* $LastChangedDate:: 2011-06-17 17:03:12 +0400#$  <br>
* Revision: $LastChangedRevision: 10160 $ <br>
* Module: NTF_API_NOTIFICATION_PKG <br>
* @headcom
*************************************************************/

g_notif_object       ntf_api_type_pkg.t_notif_object_tab;

g_delivery_address   com_api_type_pkg.t_full_desc;

procedure clear_global_data is
begin
    g_notif_object.delete;
end;

function get_gl_delivery_address
    return com_api_type_pkg.t_full_desc is
begin
    return g_delivery_address;
end;

function get_object_id (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_party_type              in      com_api_type_pkg.t_dict_value
  , i_ntf_entity              in      com_api_type_pkg.t_dict_value
  , o_product_id                 out  com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_long_id is
    l_object_id               com_api_type_pkg.t_long_id;
begin
    trc_log_pkg.debug (
        i_text          => 'Getting [#4] object for source entity type[#1][#2][#3]'
        , i_env_param1  => i_entity_type
        , i_env_param2  => i_object_id
        , i_env_param3  => i_party_type
        , i_env_param4  => i_ntf_entity
    );

    -- find in cache
    if g_notif_object.exists(i_ntf_entity) then
        return g_notif_object(i_ntf_entity);
    end if;

    case i_entity_type
    when iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select c.id
                 , n.product_id
              into l_object_id
                 , o_product_id
              from prd_customer c
                 , prd_contract n
             where c.id = i_object_id
               and n.id = c.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;
    when iss_api_const_pkg.ENTITY_TYPE_CARD then
        if i_ntf_entity in (
            iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
        ) then

            select decode(i_ntf_entity, iss_api_const_pkg.ENTITY_TYPE_CUSTOMER, c.customer_id, c.cardholder_id)
                 , n.product_id
              into l_object_id
                 , o_product_id
              from iss_card c
                 , prd_contract n
             where c.id = i_object_id
               and n.id = c.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE then
        if i_ntf_entity in (
            iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER
          , iss_api_const_pkg.ENTITY_TYPE_CUSTOMER
        ) then

            select decode(i_ntf_entity, iss_api_const_pkg.ENTITY_TYPE_CUSTOMER, c.customer_id, c.cardholder_id)
                 , n.product_id
              into l_object_id
                 , o_product_id
              from iss_card c
                 , iss_card_instance i
                 , prd_contract n
             where i.id = i_object_id
               and c.id = i.card_id
               and n.id = c.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select a.customer_id
                 , n.product_id
              into l_object_id
                 , o_product_id
              from acc_account a
                 , prd_contract n
             where a.id = i_object_id
               and n.id = a.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select n.customer_id
                 , n.product_id
              into l_object_id
                 , o_product_id
              from acq_terminal_vw t
                 , prd_contract n
             where t.id = i_object_id
               and n.id = t.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        if i_ntf_entity = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select n.customer_id
                 , n.product_id
              into l_object_id
                 , o_product_id
              from acq_merchant m
                 , prd_contract n
             where m.id = i_object_id
               and n.id = m.contract_id;
        elsif i_ntf_entity = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            l_object_id := i_object_id;
            select n.product_id
              into o_product_id
              from acq_merchant m
                 , prd_contract n
             where m.id = i_object_id
               and n.id = m.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when pmo_api_const_pkg.ENTITY_TYPE_PAYMENT_ORDER then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select o.customer_id
                 , n.product_id
              into l_object_id
                 , o_product_id
              from pmo_order o
                 , prd_customer_vw t
                 , prd_contract n
             where o.id = i_object_id
               and t.id = o.customer_id
               and n.id = t.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when opr_api_const_pkg.ENTITY_TYPE_OPERATION then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select decode(nvl(i_party_type, com_api_const_pkg.PARTICIPANT_ISSUER), com_api_const_pkg.PARTICIPANT_ISSUER, o.customer_id, o.dst_customer_id)
                 , n.product_id
              into l_object_id
                 , o_product_id
              from opr_operation_participant_vw o
                 , prd_customer_vw t
                 , prd_contract n
             where o.id = i_object_id
               and t.id = decode(nvl(i_party_type, com_api_const_pkg.PARTICIPANT_ISSUER), com_api_const_pkg.PARTICIPANT_ISSUER, o.customer_id, o.dst_customer_id)
               and n.id = t.contract_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when crd_api_const_pkg.ENTITY_TYPE_INVOICE then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            select a.customer_id
                 , c.product_id
              into l_object_id
                 , o_product_id
              from crd_invoice i
                 , acc_account a
                 , prd_contract c
             where i.id = i_object_id
               and i.account_id = a.id
               and a.contract_id = c.id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;
    when lty_api_const_pkg.ENTITY_TYPE_BONUS then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select a.customer_id
                 , c.product_id
              into l_object_id
                 , o_product_id
              from acc_macros m
                 , acc_account a
                 , prd_contract c
             where m.id = i_object_id
               and m.account_id = a.id
               and a.contract_id = c.id;
        elsif i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
            select c.cardholder_id
                 , cn.product_id
              into l_object_id
                 , o_product_id
              from acc_macros m
                 , opr_participant p
                 , iss_card c
                 , prd_contract cn
             where m.id = i_object_id
               and m.object_id = p.oper_id
               and m.entity_type = opr_api_const_pkg.ENTITY_TYPE_OPERATION
               and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER
               and p.card_id = c.id
               and c.contract_id = cn.id;
        else
            com_api_error_pkg.raise_error(
                i_error       => 'UNKNOWN_ENTITY_TYPE'
              , i_env_param1  => i_ntf_entity
            );
        end if;

    when dpp_api_const_pkg.ENTITY_TYPE_INSTALMENT then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select ac.customer_id
                 , pp.product_id
              into l_object_id
                 , o_product_id
              from dpp_instalment i
                 , dpp_payment_plan pp
                 , acc_account ac
             where i.id     = i_object_id
               and pp.id    = i.dpp_id
               and ac.id    = pp.account_id;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;

    when app_api_const_pkg.ENTITY_TYPE_APPLICATION then
        if i_ntf_entity = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select object_id
                 , product_id
              into l_object_id
                 , o_product_id
              from (
                    select a.object_id
                         , c.product_id
                         , row_number() over (order by a.object_id) rn
                      from app_object a
                      join prd_customer p on a.object_id = p.id
                      join prd_contract c on p.contract_id = c.id
                     where a.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                       and a.appl_id = i_object_id
                   )
             where rn = 1;
        else
            com_api_error_pkg.raise_error (
                i_error         => 'UNKNOWN_ENTITY_TYPE'
                , i_env_param1  => i_ntf_entity
            );
        end if;
    when dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN then
        if i_ntf_entity = iss_api_const_pkg.ENTITY_TYPE_CUSTOMER then
            select ac.customer_id
                 , pp.product_id
              into l_object_id
                 , o_product_id
              from dpp_payment_plan pp
                 , acc_account ac
             where pp.id    = i_object_id
               and ac.id    = pp.account_id;
        else
            com_api_error_pkg.raise_error (
                i_error       => 'UNKNOWN_ENTITY_TYPE'
              , i_env_param1  => i_ntf_entity
            );
        end if;
    else
        com_api_error_pkg.raise_error (
            i_error        => 'UNKNOWN_ENTITY_TYPE'
            , i_env_param1 => i_ntf_entity
        );

    end case;

    -- set cache
    g_notif_object(i_ntf_entity) := l_object_id;

    return l_object_id;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error        => 'ENTITY_TYPE_NOT_FOUND'
            , i_env_param1 => i_ntf_entity
            , i_env_param2 => i_object_id
        );
end get_object_id;

function get_entity_lang (
    i_entity_type             in      com_api_type_pkg.t_dict_value
    , i_object_id             in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_dict_value is
    l_lang                    com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'Getting entity language - entity_type[#1] object_id[#2]'
        , i_env_param1  => i_entity_type
        , i_env_param2  => i_object_id
    );

    case
    when i_entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        select get_def_lang
          into l_lang
          from prd_customer c
         where c.id = i_object_id;

    when i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then
        select get_def_lang
          into l_lang
          from iss_cardholder c
         where c.id = i_object_id;

    else
        l_lang := null;
    end case;
    return l_lang;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error        => 'ENTITY_TYPE_NOT_FOUND'
            , i_env_param1 => i_entity_type
            , i_env_param2 => i_object_id
        );
end get_entity_lang;

procedure get_contact_address (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , i_commun_method           in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
  , o_lang                       out  com_api_type_pkg.t_dict_value
) is
    l_sysdate  date;
begin
    trc_log_pkg.debug (
        i_text       => 'Getting contact address. i_commun_method [#1]'
      , i_env_param1 => i_commun_method
    );

    l_sysdate := com_api_sttl_day_pkg.get_sysdate;

    select commun_address
         , preferred_lang
      into o_address
         , o_lang
      from (
               select c.commun_address
                    , a.preferred_lang
                 from com_contact_data c
                    , com_contact a
                    , com_contact_object b
                where b.object_id     = i_object_id
                  and b.entity_type   = i_entity_type
                  and b.contact_type  = i_contact_type
                  and a.id            = b.contact_id
                  and c.contact_id    = a.id
                  and c.commun_method = i_commun_method
                  -- and (c.end_date is null or c.end_date > l_sysdate)
                  and l_sysdate between nvl(c.start_date, l_sysdate - 1) and nvl(c.end_date, l_sysdate + 1)
                order by c.id desc
       )
       where rownum < 2;

exception
    when no_data_found then
        o_address := null;
end get_contact_address;

procedure get_email_address (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
  , o_lang                       out  com_api_type_pkg.t_dict_value
) is
begin
    get_contact_address (
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_contact_type  => i_contact_type
      , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_EMAIL
      , o_address       => o_address
      , o_lang          => o_lang
    );
end get_email_address;

procedure get_mobile_number (
    i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
  , o_lang                       out  com_api_type_pkg.t_dict_value
) is
begin
    get_contact_address (
        i_entity_type   => i_entity_type
      , i_object_id     => i_object_id
      , i_contact_type  => i_contact_type
      , i_commun_method => com_api_const_pkg.COMMUNICATION_METHOD_MOBILE
      , o_address       => o_address
      , o_lang          => o_lang
    );
end get_mobile_number;

procedure format_delivery_address (
    i_procedure_name          in      com_api_type_pkg.t_full_desc
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
  , o_lang                       out  com_api_type_pkg.t_dict_value
  , o_address                    out  com_api_type_pkg.t_full_desc
) is
    l_statement             com_api_type_pkg.t_text := '(i_entity_type=>:entity_type, i_object_id=>:object_id, i_contact_type=>:contact_type, o_address=>:address, o_lang=>:lang)';
begin
    begin
        execute immediate 'begin ' || i_procedure_name || l_statement || '; end;'
          using in i_entity_type, in i_object_id, in i_contact_type, out o_address, out o_lang;
    exception
        when others then
            trc_log_pkg.error(
                i_text        => 'ERROR_EXECUTING_PROCEDURE'
              , i_env_param1  => l_statement
              , i_env_param2  => i_entity_type
              , i_env_param3  => i_object_id
              , i_env_param4  => i_contact_type
              , i_env_param5  => sqlerrm
            );
    end;
end format_delivery_address;

function get_delivery_address (
    i_address                 in      com_api_type_pkg.t_full_desc
  , i_channel_id              in      com_api_type_pkg.t_tiny_id
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_contact_type            in      com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_full_desc is
    l_lang                  com_api_type_pkg.t_dict_value;
    l_address               com_api_type_pkg.t_full_desc;
begin
    if i_address is not null then
        return i_address;
    end if;

    for proc in (
        select address_source procedure_name
          from ntf_channel_vw
         where id = i_channel_id
           and address_source is not null
    ) loop
        format_delivery_address (
            i_procedure_name  => proc.procedure_name
          , i_entity_type     => i_entity_type
          , i_object_id       => i_object_id
          , i_contact_type    => i_contact_type
          , o_lang            => l_lang
          , o_address         => l_address
        );
    end loop;

    return l_address;
end get_delivery_address;

function process_template (
    i_notif_id                in      com_api_type_pkg.t_short_id
    , i_report_id             in      com_api_type_pkg.t_short_id
    , i_channel_id            in      com_api_type_pkg.t_tiny_id
    , i_lang                  in      com_api_type_pkg.t_dict_value
    , i_entity_type           in      com_api_type_pkg.t_dict_value
    , i_object_id             in      com_api_type_pkg.t_long_id
    , i_inst_id               in      com_api_type_pkg.t_inst_id
    , i_eff_date              in      date
    , i_event_type            in      com_api_type_pkg.t_dict_value
    , i_notify_party_type     in      com_api_type_pkg.t_dict_value default null
    , i_src_entity_type       in      com_api_type_pkg.t_dict_value default null
    , i_src_object_id         in      com_api_type_pkg.t_long_id    default null
    , i_param_tab             in      com_api_type_pkg.t_param_tab
) return clob is
    l_resultset             sys_refcursor;
    l_text                  clob;
    l_params                com_api_type_pkg.t_param_tab := i_param_tab;
    l_data_source           clob;
    l_source_type           com_api_type_pkg.t_dict_value;
begin
    trc_log_pkg.debug (
        i_text          => 'Process template - notif_id[#1] report_id[#2] channel_id[#3] lang[#4]'
        , i_env_param1  => i_notif_id
        , i_env_param2  => i_report_id
        , i_env_param3  => i_channel_id
        , i_env_param4  => i_lang
    );

    for rec in (
        select t.report_template_id template_id
          from ntf_template_vw t
         where t.notif_id = i_notif_id
           and t.channel_id = i_channel_id
           and t.lang = i_lang
    ) loop

        trc_log_pkg.debug (
            i_text          => 'Report [#1] template [#1]'
            , i_env_param1  => i_report_id
            , i_env_param2  => rec.template_id
        );

        -- parameters
        rul_api_param_pkg.set_param (
            i_name       => 'I_ENTITY_TYPE'
            , i_value    => i_entity_type
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_OBJECT_ID'
            , i_value    => i_object_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_INST_ID'
            , i_value    => i_inst_id
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_EFF_DATE'
            , i_value    => i_eff_date
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_EVENT_TYPE'
            , i_value    => i_event_type
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_NOTIFY_PARTY_TYPE'
            , i_value    => i_notify_party_type
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_SRC_ENTITY_TYPE'
            , i_value    => i_src_entity_type
            , io_params  => l_params
        );
        rul_api_param_pkg.set_param (
            i_name       => 'I_SRC_OBJECT_ID'
            , i_value    => i_src_object_id
            , io_params  => l_params
        );

        begin
            select data_source
                 , source_type
              into l_data_source
                 , l_source_type
              from rpt_report
             where id = i_report_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       =>  'REPORT_NOT_FOUND'
                  , i_env_param1  =>  i_report_id
                );
        end;

        rpt_api_run_pkg.process_report (
            i_report_id      => i_report_id
            , i_template_id  => rec.template_id
            , i_parameters   => l_params
            , io_data_source => l_data_source
            , i_source_type  => l_source_type
            , o_resultset    => l_resultset
            , o_xml          => l_text
        );

        return l_text;
    end loop;

    com_api_error_pkg.raise_error (
        i_error        => 'NOTIFICATION_TEMPLATE_NOT_FOUND'
        , i_env_param1 => i_notif_id
        , i_env_param2 => i_channel_id
        , i_env_param3 => i_lang
    );

    return empty_clob();
end process_template;

procedure make_notification_param(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_param_tab               in      com_api_type_pkg.t_param_tab
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) is
    l_processed_count com_api_type_pkg.t_count := 0;
begin
    make_notification_param(
        i_inst_id                  => i_inst_id
        , i_event_type             => i_event_type
        , i_entity_type            => i_entity_type
        , i_object_id              => i_object_id
        , i_eff_date               => i_eff_date
        , i_param_tab              => i_param_tab
        , i_urgency_level          => i_urgency_level
        , i_notify_party_type      => i_notify_party_type
        , i_src_entity_type        => i_src_entity_type
        , i_src_object_id          => i_src_object_id
        , i_delivery_address       => i_delivery_address
        , i_delivery_time          => i_delivery_time
        , i_ignore_missing_service => i_ignore_missing_service
        , io_processed_count       => l_processed_count
    );

end make_notification_param;

/*
    i_entity_type, i_object_id - mandatory input parameter, notification report is building on it
  , i_src_entity_type, i_src_object_id - optional input parameter, by which notification service and receiving contacts are searching
    These two groups of parameters both are equal respectively except of null values - in this case their values are defined in the procedure itself.  
*/
procedure make_notification_param(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_param_tab               in      com_api_type_pkg.t_param_tab
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , io_processed_count        in out  com_api_type_pkg.t_count
) is
    l_param_tab          com_api_type_pkg.t_param_tab := i_param_tab;
    l_scheme             com_api_type_pkg.t_tiny_id;
    l_event_entity_type  com_api_type_pkg.t_dict_value   := i_entity_type;
    l_event_object_id    com_api_type_pkg.t_long_id      := i_object_id;
    l_src_entity_type    com_api_type_pkg.t_dict_value;
    l_src_object_id      com_api_type_pkg.t_long_id;
    l_dst_entity_type    com_api_type_pkg.t_dict_value;
    l_dst_object_id      com_api_type_pkg.t_long_id;
    l_product_id         com_api_type_pkg.t_short_id;
    l_lang               com_api_type_pkg.t_dict_value;
    l_text               clob;
    l_id                 com_api_type_pkg.t_long_id;
    l_delivery_address   com_api_type_pkg.t_full_desc;
    l_customer_id        com_api_type_pkg.t_medium_id;
    l_processed_count    com_api_type_pkg.t_count := 0;
    l_procedure_name     com_api_type_pkg.t_full_desc;
    l_address_pattern    com_api_type_pkg.t_full_desc;
    l_mess_max_length    com_api_type_pkg.t_tiny_id;
    l_srv_active         com_api_type_pkg.t_boolean;
    l_notif_addr_rec_tab ntf_api_type_pkg.t_notif_addr_rec_tab;
    l_index              com_api_type_pkg.t_short_id;
    l_dup_addr           com_api_type_pkg.t_boolean := com_api_type_pkg.FALSE;
    l_attr_name_scheme   com_api_type_pkg.t_name;
    l_attr_name_use_fee  com_api_type_pkg.t_name;
    l_sysdate            date := get_sysdate();

begin

    trc_log_pkg.debug (
        i_text        => 'Make notification [#1][#2][#3][#4][#5][#6]'
      , i_env_param1  => i_inst_id
      , i_env_param2  => i_event_type
      , i_env_param3  => i_entity_type
      , i_env_param4  => i_object_id
      , i_env_param5  => to_char(i_eff_date, 'dd.mm.yyyy hh24:mi:ss')
      , i_env_param6  => i_notify_party_type
    );

    clear_global_data;
    l_notif_addr_rec_tab.delete;

    if i_src_entity_type is null or i_src_object_id is null then
        -- find source entity for authorization
        begin
            if i_event_type = ntf_api_const_pkg.EVENT_TYPE_ISS_AUTH then
                select nvl(card_id, nvl(account_id, nvl(customer_id, i_object_id)))
                     , case
                           when card_id is not null then iss_api_const_pkg.ENTITY_TYPE_CARD
                           when account_id is not null then acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                           when customer_id is not null then prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           else i_entity_type
                       end
                  into l_src_object_id
                     , l_src_entity_type
                  from opr_participant
                 where oper_id = l_event_object_id
                   and participant_type = com_api_const_pkg.PARTICIPANT_ISSUER;

            elsif i_event_type = ntf_api_const_pkg.EVENT_TYPE_ACQ_AUTH then
                select nvl(terminal_id, nvl(merchant_id, nvl(customer_id, i_object_id)))
                     , case
                           when terminal_id is not null then acq_api_const_pkg.ENTITY_TYPE_TERMINAL
                           when merchant_id is not null then acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                           when customer_id is not null then prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                           else i_entity_type
                       end
                  into l_src_object_id
                     , l_src_entity_type
                  from opr_participant
                 where oper_id          = l_event_object_id
                   and participant_type = com_api_const_pkg.PARTICIPANT_ACQUIRER;
            elsif i_event_type in (ntf_api_const_pkg.EVENT_TYPE_LTY_CREATE_BONUS) then
                select b.object_id
                     , b.entity_type
                  into l_src_object_id
                     , l_src_entity_type
                  from lty_bonus b
                 where b.id = l_event_object_id;
            elsif i_event_type in (ntf_api_const_pkg.EVENT_TYPE_LTY_SPEND_BONUS) then
                select o.object_id
                     , o.entity_type
                  into l_src_object_id
                     , l_src_entity_type
                  from acc_macros m
                     , acc_account_object o
                 where m.id = l_event_object_id
                   and m.account_id = o.account_id;
            elsif i_event_type in (dpp_api_const_pkg.ENTITY_TYPE_PAYMENT_PLAN) then
                select o.object_id
                     , o.entity_type
                  into l_src_object_id
                     , l_src_entity_type
                  from dpp_payment_plan pp
                     , acc_account_object o
                 where pp.id         = l_event_object_id
                   and pp.account_id = o.account_id;
            else
                l_src_entity_type   := l_event_entity_type;
                l_src_object_id     := l_event_object_id;

            end if;
        exception
            when no_data_found then
                l_src_entity_type   := l_event_entity_type;
                l_src_object_id     := l_event_object_id;
        end;
    else
        l_src_entity_type   := i_src_entity_type;
        l_src_object_id     := i_src_object_id;
    end if;

    if l_src_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT or i_event_type = ACC_API_CONST_PKG.EVENT_MIN_THRESHOLD_OVERCOMING then
        l_attr_name_scheme   := ntf_api_const_pkg.ACQ_NOTIFICATION_SCHEME;
        l_attr_name_use_fee  := ntf_api_const_pkg.ACQ_SERVICE_NOTIFICATION_FEE;
    else
        l_attr_name_scheme   := ntf_api_const_pkg.NOTIFICATION_SCHEME;
        l_attr_name_use_fee  := ntf_api_const_pkg.NOTIFICATION_SERVICE_USE_FEE;
    end if;

    l_customer_id := get_object_id (
        i_entity_type   => l_src_entity_type
        , i_object_id   => l_src_object_id
        , i_party_type  => i_notify_party_type
        , i_ntf_entity  => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
        , o_product_id  => l_product_id
    );

    l_scheme :=
        prd_api_product_pkg.get_attr_value_number (
            i_product_id        => l_product_id
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
          , i_object_id         => l_customer_id
          , i_attr_name         => l_attr_name_scheme
          , i_params            => l_param_tab
          , i_inst_id           => i_inst_id
          , i_use_default_value => i_ignore_missing_service
          , i_mask_error        => i_ignore_missing_service
        );

    if l_src_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
        and prd_api_service_pkg.get_active_service_id(
                i_entity_type => l_src_entity_type
              , i_object_id   => l_src_object_id
              , i_attr_name   => l_attr_name_use_fee
              , i_eff_date    => com_api_sttl_day_pkg.get_calc_date(i_inst_id => i_inst_id)
              , i_mask_error  => com_api_type_pkg.TRUE
              , i_inst_id     => i_inst_id
            ) is not null
    then
        l_srv_active := com_api_type_pkg.TRUE;
    else
        l_srv_active := com_api_type_pkg.FALSE;
    end if;

    -- unique entity type for notification
    for entity in (
        select distinct e.entity_type
          from ntf_scheme_vw s
             , ntf_scheme_event_vw e
         where s.id = e.scheme_id
           and (s.inst_id = i_inst_id
                or
                s.inst_id = ost_api_const_pkg.DEFAULT_INST
                )
           and s.id = l_scheme
           and e.event_type = i_event_type
    ) loop
        begin
            l_dst_entity_type := entity.entity_type;
            l_dst_object_id := get_object_id (
                i_entity_type   => l_src_entity_type
                , i_object_id   => l_src_object_id
                , i_party_type  => i_notify_party_type
                , i_ntf_entity  => l_dst_entity_type
                , o_product_id  => l_product_id
            );

            l_processed_count := 0;

            trc_log_pkg.debug (
                i_text        => 'Cursor parameters: l_dst_entity_type:l_dst_object_id[#1] l_scheme[#2] i_event_type [#3] l_src_object_id [#4] l_srv_active [#5] l_sysdate [#6]'
              , i_env_param1  => l_dst_entity_type || ':' || l_dst_object_id
              , i_env_param2  => l_scheme
              , i_env_param3  => i_event_type
              , i_env_param4  => l_src_object_id
              , i_env_param5  => l_srv_active
              , i_env_param6  => to_char(l_sysdate, com_api_const_pkg.LOG_DATE_FORMAT)
            );

            for event in (
                select scheme_id
                     , event_id
                     , entity_type
                     , object_id
                     , notif_id
                     , report_id
                     , channel_id
                     , delivery_time
                     , delivery_address
                     , is_customizable
                     , contact_type
                     , priority
                     , row_number() over(order by event_id) row_number
                     , count(event_id) over() event_cnt
                  from (
                    select t.*
                         , dense_rank() over (partition by t.delivery_address, t.channel_id order by t.delivery_address, t.priority) as rank
                         , dense_rank() over (partition by t.entity_type, t.object_id, t.contact_type order by t.custom_object_id)   as custom_object_rank
                         , count(t.custom_object_id) over (partition by t.entity_type, t.object_id)                                  as count_custom_object_id
                      from (
                        select e.scheme_id
                             , e.id event_id
                             , e.entity_type
                             , l_dst_object_id object_id
                             , e.notif_id
                             , n.report_id
                             , decode(c.status, ntf_api_const_pkg.STATUS_ALWAYS_SEND, c.channel_id, e.channel_id) channel_id
                             , decode(c.status, ntf_api_const_pkg.STATUS_ALWAYS_SEND, c.delivery_time, e.delivery_time) delivery_time
                             , ntf_api_notification_pkg.get_delivery_address(
                                   i_address      => c.delivery_address
                                 , i_channel_id   => decode(c.status, ntf_api_const_pkg.STATUS_ALWAYS_SEND, c.channel_id, e.channel_id)
                                 , i_entity_type  => e.entity_type
                                 , i_object_id    => l_dst_object_id
                                 , i_contact_type => e.contact_type
                             ) delivery_address
                             , e.is_customizable
                             , e.contact_type
                             , e.priority
                             , o.id as custom_object_id
                          from ntf_scheme_vw s
                             , ntf_scheme_event_vw e
                             , ntf_notification_vw n
                             , ntf_custom_event_vw c
                             , ntf_custom_object_vw o
                         where s.id           = e.scheme_id
                           and s.scheme_type  = ntf_api_const_pkg.CUSTOMER_NOTIFICATION_SCHEME
                           and e.event_type   = i_event_type
                           and e.entity_type  = l_dst_entity_type
                           and ( (e.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND)
                              or (e.status = ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE and l_dst_entity_type != iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER)
                              or (e.status = ntf_api_const_pkg.STATUS_SEND_SERVICE_ACTIVE and l_srv_active = com_api_type_pkg.TRUE)
                           )
                           and s.id                 = l_scheme
                           and n.id                 = e.notif_id
                           and nvl(c.event_type(+),   e.event_type)   = e.event_type
                           and nvl(c.contact_type(+), e.contact_type) = e.contact_type
                           and c.entity_type(+)     = e.entity_type
                           and c.object_id(+)       = l_dst_object_id
                           and l_sysdate between coalesce(c.start_date(+), l_sysdate) and coalesce(c.end_date(+), l_sysdate)
                           and o.custom_event_id(+) = c.id
                           and o.object_id(+)       = l_src_object_id
                           and nvl(o.is_active, com_api_type_pkg.TRUE) = com_api_type_pkg.TRUE
                           and ( i_delivery_time is null
                              or (i_delivery_time is not null
                                  and to_char(i_delivery_time, 'hh24') between to_number(substr(e.delivery_time, 1, 2)) and to_number(substr(e.delivery_time, 4, 2))
                                 )
                               )
                      order by c.start_date desc
                             , c.event_type
                    ) t
                 )
                 where (rank = 1 or priority is null)
                   and custom_object_rank = 1
                   and (count_custom_object_id = 0 or custom_object_id is not null)
                 order by event_id
            ) loop
                begin
                    trc_log_pkg.debug (
                        i_text        => 'Process notification scheme[#1] event[#2]'
                      , i_env_param1  => event.scheme_id
                      , i_env_param2  => event.event_id
                    );

                    trc_log_pkg.debug (
                        i_text        => 'Query columns:'
                                         || ' entity_type ['      || event.entity_type      || ']'
                                         || ' object_id ['        || event.object_id        || ']'
                                         || ' notif_id ['         || event.notif_id         || ']'
                                         || ' report_id ['        || event.report_id        || ']'
                                         || ' channel_id ['       || event.channel_id       || ']'
                                         || ' delivery_time ['    || event.delivery_time    || ']'
                                         || ' delivery_address [' || event.delivery_address || ']'
                                         || ' is_customizable ['  || event.is_customizable  || ']'
                                         || ' contact_type ['     || event.contact_type     || ']'
                                         || ' priority ['         || event.priority         || ']'
                                         || ' row_number ['       || event.row_number       || ']'
                                         || ' event_cnt ['        || event.event_cnt        || ']'
                    );

                    begin
                        select address_source
                             , address_pattern
                             , mess_max_length
                          into l_procedure_name
                             , l_address_pattern
                             , l_mess_max_length
                          from ntf_channel_vw
                         where id = event.channel_id
                           and address_source is not null;
                    exception
                        when no_data_found then
                            com_api_error_pkg.raise_error (
                                i_error         => 'UNKNOWN_CHANNEL_MESSAGE_DELIVERY'
                              , i_env_param1    => event.channel_id
                              , i_env_param2    => event.entity_type
                              , i_env_param3    => event.object_id
                              , i_env_param4    => event.contact_type
                            );
                    end;

                    --need for getting l_lang only
                    format_delivery_address (
                        i_procedure_name  => l_procedure_name
                      , i_entity_type     => event.entity_type
                      , i_object_id       => event.object_id
                      , i_contact_type    => event.contact_type
                      , o_lang            => l_lang
                      , o_address         => l_delivery_address
                    );

                    l_lang := nvl(l_lang, get_def_lang);
                    l_delivery_address := nvl(i_delivery_address, event.delivery_address);

                    --save delivery address
                    g_delivery_address := l_delivery_address;

                    -- check address
                    if l_address_pattern is not null then
                        -- event.delivery_address
                        null;
                    end if;

                    if l_delivery_address is null then
                        com_api_error_pkg.raise_error(
                            i_error         => 'UNDEFINED_DELIVERY_ADDRESS'
                          , i_env_param1    => event.channel_id
                          , i_env_param2    => event.entity_type
                          , i_env_param3    => event.object_id
                        );
                    end if;

                    -- processing template
                    l_text :=
                        process_template(
                            i_notif_id           => event.notif_id
                          , i_report_id          => event.report_id
                          , i_channel_id         => event.channel_id
                          , i_lang               => l_lang
                          , i_entity_type        => l_event_entity_type
                          , i_object_id          => l_event_object_id
                          , i_inst_id            => i_inst_id
                          , i_eff_date           => i_eff_date
                          , i_event_type         => i_event_type
                          , i_notify_party_type  => i_notify_party_type
                          , i_src_entity_type    => l_src_entity_type
                          , i_src_object_id      => l_src_object_id
                          , i_param_tab          => l_param_tab 
                        );

                    -- cut message
                    --if l_mess_max_length is not null then
                    --    l_text := dbms_lob.substr(l_text, l_mess_max_length);
                    --end if;

                    -- processing delivery address
                    trc_log_pkg.debug (
                        i_text        => 'delivery address: #1 text: #2'
                      , i_env_param1  => l_delivery_address
                      , i_env_param2  => dbms_lob.substr(l_text, 200)
                    );

                    --check duplicate address
                    if l_notif_addr_rec_tab.first is not null then
                        for l_index in l_notif_addr_rec_tab.first..l_notif_addr_rec_tab.last loop
                            if l_notif_addr_rec_tab.exists(l_index) then
                                if l_notif_addr_rec_tab(l_index).notif_id = event.notif_id
                                and l_notif_addr_rec_tab(l_index).delivery_address = l_delivery_address then
                                    l_dup_addr := com_api_type_pkg.TRUE;
                                    exit;
                                end if;
                            end if;
                        end loop;
                    end if;

                    if l_dup_addr = com_api_type_pkg.TRUE then
                        l_dup_addr := com_api_type_pkg.FALSE;
                        trc_log_pkg.debug (
                            i_text        => 'duplicate address: #1, notif_id: #2'
                          , i_env_param1  => l_delivery_address
                          , i_env_param2  => event.notif_id
                        );
                        continue;
                    else
                        l_notif_addr_rec_tab(nvl(l_notif_addr_rec_tab.count, 0) + 1).notif_id := event.notif_id;
                        l_notif_addr_rec_tab(l_notif_addr_rec_tab.count).delivery_address     := l_delivery_address;
                        trc_log_pkg.debug (
                            i_text        => 'add to tabl: #1, notif_id: #2'
                          , i_env_param1  => l_delivery_address
                          , i_env_param2  => event.notif_id
                        );
                    end if;

                    -- create message
                    if nvl(l_text, empty_clob()) <> empty_clob() then

                        ntf_api_message_pkg.create_message (
                            o_id                  => l_id
                            , i_channel_id        => event.channel_id
                            , i_text              => l_text
                            , i_lang              => l_lang
                            , i_delivery_address  => l_delivery_address
                            , i_delivery_date     => i_eff_date
                            , i_urgency_level     => i_urgency_level
                            , i_inst_id           => i_inst_id
                            , i_event_type        => i_event_type
                            , i_entity_type       => l_src_entity_type
                            , i_object_id         => l_src_object_id
                            , i_delivery_time     => event.delivery_time
                        );
                        io_processed_count := io_processed_count + 1;
                    end if;

                    l_processed_count := l_processed_count + 1;
                exception
                    when com_api_error_pkg.e_application_error then
                        if l_processed_count = 0 and event.row_number = event.event_cnt then
                            raise;
                        end if;
                end;
            end loop;

        end;
    end loop;

    trc_log_pkg.debug (
        i_text          => 'Make notification - ok'
    );

    clear_global_data;

exception
    when others then
        clear_global_data;
        raise;
end make_notification_param;

procedure make_notification(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
) is
    l_param_tab          com_api_type_pkg.t_param_tab;
begin
    make_notification_param(
        i_inst_id                => i_inst_id
      , i_event_type             => i_event_type
      , i_entity_type            => i_entity_type
      , i_object_id              => i_object_id
      , i_eff_date               => i_eff_date
      , i_param_tab              => l_param_tab
      , i_urgency_level          => i_urgency_level
      , i_notify_party_type      => i_notify_party_type
      , i_src_entity_type        => i_src_entity_type
      , i_src_object_id          => i_src_object_id
      , i_delivery_address       => i_delivery_address
      , i_delivery_time          => i_delivery_time
      , i_ignore_missing_service => i_ignore_missing_service
    );
end make_notification;

procedure make_notification(
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_urgency_level           in      com_api_type_pkg.t_tiny_id    := null
  , i_notify_party_type       in      com_api_type_pkg.t_dict_value := null
  , i_src_entity_type         in      com_api_type_pkg.t_dict_value := null
  , i_src_object_id           in      com_api_type_pkg.t_long_id    := null
  , i_delivery_address        in      com_api_type_pkg.t_full_desc  := null
  , i_delivery_time           in      date                          := null
  , i_ignore_missing_service  in      com_api_type_pkg.t_boolean    default com_api_type_pkg.FALSE
  , io_processed_count        in out  com_api_type_pkg.t_count
) is
    l_param_tab          com_api_type_pkg.t_param_tab;
begin
    make_notification_param(
        i_inst_id                => i_inst_id
      , i_event_type             => i_event_type
      , i_entity_type            => i_entity_type
      , i_object_id              => i_object_id
      , i_eff_date               => i_eff_date
      , i_param_tab              => l_param_tab
      , i_urgency_level          => i_urgency_level
      , i_notify_party_type      => i_notify_party_type
      , i_src_entity_type        => i_src_entity_type
      , i_src_object_id          => i_src_object_id
      , i_delivery_address       => i_delivery_address
      , i_delivery_time          => i_delivery_time
      , i_ignore_missing_service => i_ignore_missing_service
      , io_processed_count       => io_processed_count
    );
end make_notification;

function get_user_notification_tab(
    i_user_list             in      com_api_type_pkg.t_text
  , i_role_list             in      com_api_type_pkg.t_text
) return t_user_notification_tab
result_cache
relies_on (acm_user_role, acm_role_role, acm_role)
is
    l_user_notification_tab    t_user_notification_tab;
begin
    -- Important: this method has option "result_cache", therefore this method can not call the BackOffice objects
    -- (package method, package variable, function, view and etc).

    select distinct
           user_id
         , role_id
         , notif_scheme_id
      bulk collect into l_user_notification_tab
      from (
          select d.user_id
               , d.role_id
               , r.notif_scheme_id
             from acm_user_role d
                , acm_role r
            where r.id = d.role_id
              and r.notif_scheme_id is not null
              and (i_user_list is null or instr(i_user_list, ',' || to_char(d.user_id) || ',') != 0)
              and (i_role_list is null or instr(i_role_list, ',' || to_char(d.role_id) || ',') != 0)
          union all
          select user_id
               , role_id
               , notif_scheme_id
            from (
                select connect_by_root a.user_id as user_id
                     , b.child_role_id           as role_id
                     , r.notif_scheme_id
                  from acm_user_role a
                     , acm_role_role b
                     , acm_role r
                 where b.parent_role_id   = a.role_id
                   and r.id               = b.child_role_id
                   and r.notif_scheme_id is not null
                   and (i_user_list is null or instr(i_user_list, ',' || to_char(a.user_id) || ',') != 0)
                 connect by prior b.child_role_id = b.parent_role_id
            )
           where (i_role_list is null or instr(i_role_list, ',' || to_char(role_id) || ',') != 0)
      );

    return l_user_notification_tab;

end get_user_notification_tab;

procedure make_user_notification (
    i_inst_id                 in      com_api_type_pkg.t_inst_id
  , i_event_type              in      com_api_type_pkg.t_dict_value
  , i_entity_type             in      com_api_type_pkg.t_dict_value
  , i_object_id               in      com_api_type_pkg.t_long_id
  , i_eff_date                in      date
  , i_user_list               in      num_tab_tpt default null
  , i_role_list               in      num_tab_tpt default null
) is
    l_processed_count  com_api_type_pkg.t_count := 0;
begin
    make_user_notification(
        i_inst_id                => i_inst_id
      , i_event_type             => i_event_type
      , i_entity_type            => i_entity_type
      , i_object_id              => i_object_id
      , i_eff_date               => i_eff_date
      , i_user_list              => i_user_list
      , i_role_list              => i_role_list
      , io_processed_count       => l_processed_count
    );
end make_user_notification;

procedure make_user_notification (
    i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_event_type            in      com_api_type_pkg.t_dict_value
  , i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_eff_date              in      date
  , i_user_list             in      num_tab_tpt default null
  , i_role_list             in      num_tab_tpt default null
  , io_processed_count      in out  com_api_type_pkg.t_count
) is
    l_params                        com_api_type_pkg.t_param_tab;
    l_lang                          com_api_type_pkg.t_dict_value;
    l_text                          clob;
    l_id                            com_api_type_pkg.t_long_id;
    l_delivery_address              com_api_type_pkg.t_full_desc;
    l_procedure_name                com_api_type_pkg.t_full_desc;
    l_address_pattern               com_api_type_pkg.t_full_desc;
    l_mess_max_length               com_api_type_pkg.t_tiny_id;
    l_processed_count               com_api_type_pkg.t_count      := 0;

    l_person_id                     com_api_type_pkg.t_medium_id;
    l_user_notification_tab         t_user_notification_tab;
    l_user_list                     com_api_type_pkg.t_text;
    l_role_list                     com_api_type_pkg.t_text;
    l_process_id                    com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug (
        i_text          => 'Make user notification [#1][#2][#3][#4][#5]'
        , i_env_param1  => i_inst_id
        , i_env_param2  => i_event_type
        , i_env_param3  => i_entity_type
        , i_env_param4  => i_object_id
        , i_env_param5  => to_char(i_eff_date, 'mm/dd/yyyy hh24:mi:ss')
    );

    if i_entity_type  = prc_api_const_pkg.ENTITY_TYPE_PROCESS then
        l_process_id := i_object_id;
    end if;

    if i_user_list.count > 0 then
        l_user_list := ',';
        for i in 1 .. i_user_list.count loop
            l_user_list := l_user_list || i_user_list(i) || ',';
        end loop;
    end if;

    if i_role_list.count > 0 then
        l_role_list := ',';
        for i in 1 .. i_role_list.count loop
            l_role_list := l_role_list || i_role_list(i) || ',';
        end loop;
    end if;

    l_user_notification_tab := get_user_notification_tab(
                                   i_user_list => l_user_list
                                 , i_role_list => l_role_list
                               );

    for r_scheme in (
        select e.id           as scheme_event_id
             , e.scheme_id
             , e.event_type
             , e.entity_type
             , e.contact_type
             , e.notif_id
             , (select n.report_id from ntf_notification n where n.id = e.notif_id) as report_id
             , e.channel_id
             , e.delivery_time
             , e.is_customizable
             , e.is_batch_send
          from ntf_scheme_event e
             , ntf_scheme s
         where e.event_type       = i_event_type
           and e.entity_type      = com_api_const_pkg.ENTITY_TYPE_USER
           and e.status           = ntf_api_const_pkg.STATUS_ALWAYS_SEND
           and s.id               = e.scheme_id
           and s.scheme_type      = ntf_api_const_pkg.USER_NOTIFICATION_SCHEME
           and s.inst_id         in (i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    ) loop
        for i in 1 .. l_user_notification_tab.count loop

            if l_user_notification_tab(i).notif_scheme_id = r_scheme.scheme_id then

                select u.person_id
                  into l_person_id
                  from acm_user u
                 where u.id = l_user_notification_tab(i).user_id;

                l_params.delete;
                rul_api_param_pkg.set_param (
                    i_name          => 'INST_ID'
                    , i_value       => i_inst_id
                    , io_params     => l_params
                );
                rul_api_param_pkg.set_param (
                    i_name          => 'PROCESS_ID'
                    , i_value       => l_process_id
                    , io_params     => l_params
                );
                rul_api_param_pkg.set_param (
                    i_name          => 'ROLE_ID'
                    , i_value       => l_user_notification_tab(i).role_id
                    , io_params     => l_params
                );
                rul_api_param_pkg.set_param (
                    i_name          => 'USER_ID'
                    , i_value       => l_user_notification_tab(i).user_id
                    , io_params     => l_params
                );

                for rec2 in (
                    select coalesce(user_status,           role_status)                               as status
                         , coalesce(user_channel_id,       role_channel_id,      r_scheme.channel_id) as channel_id
                         , coalesce(user_delivery_address, role_delivery_address)                     as delivery_address
                         , coalesce(user_delivery_time,    role_delivery_time)                        as delivery_time
                         , coalesce(user_mod_id,           role_mod_id)                               as mod_id
                      from (
                          select cu.status            as user_status
                               , cu.id                as user_custom_id
                               , cu.channel_id        as user_channel_id
                               , cu.delivery_address  as user_delivery_address
                               , cu.delivery_time     as user_delivery_time
                               , cu.mod_id            as user_mod_id
                               , cr.id                as role_custom_id
                               , cr.status            as role_status
                               , cr.channel_id        as role_channel_id
                               , cr.delivery_address  as role_delivery_address
                               , cr.delivery_time     as role_delivery_time
                               , cr.mod_id role_mod_id
                            from ntf_scheme_event se
                               , ntf_custom_event cu
                               , ntf_custom_event cr
                           where se.id             = r_scheme.scheme_event_id
                             and cu.event_type(+)  = se.event_type
                             and cu.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_USER
                             and cu.object_id(+)   = l_user_notification_tab(i).user_id
                             and cr.event_type(+)  = se.event_type
                             and cr.entity_type(+) = com_api_const_pkg.ENTITY_TYPE_ROLE
                             and cr.object_id(+)   = l_user_notification_tab(i).role_id
                           )
                     where coalesce(user_status, role_status, ntf_api_const_pkg.STATUS_ALWAYS_SEND) = ntf_api_const_pkg.STATUS_ALWAYS_SEND
                ) loop
                    begin
                        trc_log_pkg.debug (
                            i_text          => 'Asserting modifier [#1]'
                            , i_env_param1  => rec2.mod_id
                        );

                        if rec2.mod_id is null
                           or
                           rul_api_mod_pkg.check_condition (
                               i_mod_id    => rec2.mod_id
                               , i_params  => l_params
                           ) = com_api_const_pkg.TRUE
                        then
                            trc_log_pkg.debug (
                                i_text  => 'Modifier asserted OK'
                            );

                            begin
                                select address_source
                                     , address_pattern
                                     , mess_max_length
                                  into l_procedure_name
                                     , l_address_pattern
                                     , l_mess_max_length
                                  from ntf_channel_vw
                                 where id = rec2.channel_id
                                   and address_source is not null;
                            exception
                                when no_data_found then
                                    com_api_error_pkg.raise_error (
                                        i_error         => 'UNKNOWN_CHANNEL_MESSAGE_DELIVERY'
                                      , i_env_param1    => rec2.channel_id
                                      , i_env_param2    => com_api_const_pkg.ENTITY_TYPE_PERSON
                                      , i_env_param3    => l_person_id
                                      , i_env_param4    => r_scheme.contact_type
                                    );
                            end;

                            if rec2.channel_id = ntf_api_const_pkg.CHANNEL_GUI_NOTIFICATION then
                                format_delivery_address(
                                    i_procedure_name  => l_procedure_name
                                  , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_USER
                                  , i_object_id       => l_user_notification_tab(i).user_id
                                  , i_contact_type    => r_scheme.contact_type
                                  , o_lang            => l_lang
                                  , o_address         => l_delivery_address
                                );
                            else
                                format_delivery_address(
                                    i_procedure_name  => l_procedure_name
                                  , i_entity_type     => com_api_const_pkg.ENTITY_TYPE_PERSON
                                  , i_object_id       => l_person_id
                                  , i_contact_type    => r_scheme.contact_type
                                  , o_lang            => l_lang
                                  , o_address         => l_delivery_address
                                );
                            end if;

                            l_lang             := coalesce(l_lang,                get_def_lang);
                            l_delivery_address := coalesce(rec2.delivery_address, l_delivery_address);

                            -- check address
                            if l_address_pattern is not null then
                                -- l_delivery_address
                                null;
                            end if;

                            if l_delivery_address is null then
                                com_api_error_pkg.raise_error(
                                    i_error         => 'UNDEFINED_DELIVERY_ADDRESS'
                                  , i_env_param1    => rec2.channel_id
                                  , i_env_param2    => com_api_const_pkg.ENTITY_TYPE_USER
                                  , i_env_param3    => l_user_notification_tab(i).user_id
                                );
                            end if;

                            -- processing template
                            l_text := process_template(
                                          i_notif_id          => r_scheme.notif_id
                                        , i_report_id         => r_scheme.report_id
                                        , i_channel_id        => rec2.channel_id
                                        , i_lang              => l_lang
                                        , i_entity_type       => i_entity_type
                                        , i_object_id         => i_object_id
                                        , i_inst_id           => i_inst_id
                                        , i_eff_date          => i_eff_date
                                        , i_event_type        => i_event_type
                                        , i_notify_party_type => null
                                        , i_param_tab         => l_params
                                      );

                            -- cut message
                            --if l_mess_max_length is not null then
                            --    l_text := dbms_lob.substr(l_text, l_mess_max_length);
                            --end if;

                            -- processing delivery address
                            trc_log_pkg.debug (
                                i_text  => 'delivery address: '||l_delivery_address||' text: '||dbms_lob.substr(l_text, 200)
                            );

                            -- create message
                            if nvl(l_text, empty_clob()) != empty_clob() then
                                ntf_api_message_pkg.create_message (
                                    o_id                  => l_id
                                  , i_channel_id          => nvl(rec2.channel_id, r_scheme.channel_id)
                                  , i_text                => l_text
                                  , i_lang                => l_lang
                                  , i_delivery_address    => l_delivery_address
                                  , i_inst_id             => i_inst_id
                                  , i_event_type          => i_event_type
                                  , i_entity_type         => i_entity_type
                                  , i_object_id           => i_object_id
                                  , i_delivery_time       => rec2.delivery_time
                                );

                                io_processed_count := io_processed_count + 1;
                            end if;

                            exit;
                        end if;

                    exception
                        when com_api_error_pkg.e_application_error then
                            if l_processed_count = 0 and i = l_user_notification_tab.count then
                               raise;
                            end if;
                    end;
                end loop;

                l_processed_count := l_processed_count + 1;

            end if;
        end loop;
    end loop;

    trc_log_pkg.debug (
        i_text          => 'Make notification - ok. Processed [#1]'
        , i_env_param1  => l_processed_count
    );

end make_user_notification;

/*
 * It returns cursor with notification settings of a specified entity object that should be notified.
 * @param i_dst_entity_type     type of entity that should be notified
 * @param i_dst_object_id       entity object of type <i_dst_entity_type>
 */
procedure get_notification_settings(
    i_dst_entity_type       in     com_api_type_pkg.t_dict_value
  , i_dst_object_id         in     com_api_type_pkg.t_long_id
  , o_ref_cursor               out sys_refcursor
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_notification_settings: ';
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START dst_entity_type=' || i_dst_entity_type || ' dst_object_id=' || i_dst_object_id
    );
    l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                     i_entity_type => i_dst_entity_type
                   , i_object_id   => i_dst_object_id
                 );

    open o_ref_cursor for
        select
            id
          , scheme_id
          , notif_id
          , report_id
          , channel_id
          , delivery_time
          , delivery_address
          , contact_type
          , priority
          , status
          , event_type
          from (
              select c.id
                   , se.scheme_id
                   , se.notif_id
                   , n.report_id
                   , case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.channel_id else se.channel_id end as channel_id
                   , case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.delivery_time else se.delivery_time end as delivery_time
                   , ntf_api_notification_pkg.get_delivery_address(
                         i_address      => c.delivery_address
                       , i_channel_id   => case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.channel_id else se.channel_id end
                       , i_entity_type  => se.entity_type
                       , i_object_id    => c.object_id
                       , i_contact_type => se.contact_type
                   ) as delivery_address
                   , se.contact_type
                   , se.priority
                   , nvl(c.status, se.status) as status
                   , se.event_type
                   , row_number()  over (partition by se.notif_id, c.scheme_event_id, c.entity_type, c.object_id,  co.entity_type, co.object_id, co.is_active order by c.id desc) rn
                from ntf_scheme s
                join ntf_scheme_event se on se.scheme_id  = s.id
                join ntf_notification n  on n.id          = se.notif_id
                join ntf_custom_event c  on nvl(c.scheme_event_id, se.id) = se.id
                                        and (c.event_type   is null or c.event_type   = se.event_type)
                                        and (c.contact_type is null or c.contact_type = se.contact_type)
                                        and c.entity_type = se.entity_type
                                        and c.channel_id  = se.channel_id
                left join ntf_custom_object co on co.custom_event_id = c.id
               where s.scheme_type = ntf_api_const_pkg.CUSTOMER_NOTIFICATION_SCHEME --'NTFS0010'
                 and s.inst_id     = l_inst_id
                 and c.entity_type = i_dst_entity_type
                 and c.object_id   = i_dst_object_id
                 and get_sysdate between coalesce(c.start_date, get_sysdate)
                                     and coalesce(c.end_date, get_sysdate)
               )
         where not (rn > 1
               and event_type = ISS_API_CONST_PKG.EVENT_3D_SECURE_AUTH_REQUEST);  -- 'EVNT1800'

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED, no data found'
        );
        raise;
end get_notification_settings;

procedure get_obj_notification_settings(
    i_dst_entity_type       in     com_api_type_pkg.t_dict_value
  , i_dst_object_id         in     com_api_type_pkg.t_long_id
  , o_ref_cursor               out sys_refcursor
) is
    l_inst_id                      com_api_type_pkg.t_inst_id;
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_obj_notification_settings: ';
begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START dst_entity_type=' || i_dst_entity_type || ' dst_object_id=' || i_dst_object_id
    );
    l_inst_id := ost_api_institution_pkg.get_object_inst_id(
                     i_entity_type => i_dst_entity_type
                   , i_object_id   => i_dst_object_id
                 );

    open o_ref_cursor for
        select
            id
          , scheme_id
          , notif_id
          , report_id
          , channel_id
          , delivery_time
          , delivery_address
          , contact_type
          , priority
          , status
          , event_type
          from (
              select c.id
                   , se.scheme_id
                   , se.notif_id
                   , n.report_id
                   , case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.channel_id else se.channel_id end as channel_id
                   , case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.delivery_time else se.delivery_time end as delivery_time
                   , ntf_api_notification_pkg.get_delivery_address(
                         i_address      => c.delivery_address
                       , i_channel_id   => case when c.status = ntf_api_const_pkg.STATUS_ALWAYS_SEND then c.channel_id else se.channel_id end
                       , i_entity_type  => se.entity_type
                       , i_object_id    => c.object_id
                       , i_contact_type => se.contact_type
                   ) as delivery_address
                   , se.contact_type
                   , se.priority
                   , nvl(c.status, se.status) as status
                   , se.event_type
                   , row_number()  over (partition by se.notif_id, c.scheme_event_id, c.entity_type, c.object_id, co.entity_type, co.object_id, co.is_active order by c.id desc) rn
                from ntf_scheme s
                join ntf_scheme_event se on se.scheme_id  = s.id
                join ntf_notification n  on n.id          = se.notif_id
                join ntf_custom_event c  on nvl(c.scheme_event_id, se.id) = se.id
                                        and (c.event_type   is null or c.event_type   = se.event_type)
                                        and (c.contact_type is null or c.contact_type = se.contact_type)
                                        and c.entity_type = se.entity_type
                                        and c.channel_id  = se.channel_id
                left join ntf_custom_object co on co.custom_event_id = c.id
               where s.scheme_type  = ntf_api_const_pkg.CUSTOMER_NOTIFICATION_SCHEME --'NTFS0010'
                 and s.inst_id      = l_inst_id
                 and co.entity_type = i_dst_entity_type
                 and co.object_id   = i_dst_object_id
                 and get_sysdate between coalesce(c.start_date, get_sysdate)
                                     and coalesce(c.end_date, get_sysdate)
               )
         where not (rn > 1
               and event_type = ISS_API_CONST_PKG.EVENT_3D_SECURE_AUTH_REQUEST);  -- 'EVNT1800'

exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'FAILED, no data found'
        );
        raise;
end get_obj_notification_settings;

procedure get_user_name(
    i_user_id               in     com_api_type_pkg.t_short_id
  , o_user_name            out     com_api_type_pkg.t_name
) is
begin
    o_user_name := acm_api_user_pkg.get_user_name(i_user_id => i_user_id);
end;

procedure get_customer_push_number(
    i_entity_type           in     com_api_type_pkg.t_dict_value
  , i_object_id             in     com_api_type_pkg.t_long_id
  , i_event_type            in     com_api_type_pkg.t_dict_value      default null
  , i_contact_type          in     com_api_type_pkg.t_dict_value      default null
  , o_address              out     com_api_type_pkg.t_name
  , o_lang                 out     com_api_type_pkg.t_dict_value
) is

    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.get_customer_push_number: ';

    l_customer_id     com_api_type_pkg.t_medium_id;

begin

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || 'START with params: i_entity_type [' || i_entity_type
               || '] i_object_id [' || i_object_id
               || '] i_event_type [' || i_event_type
               || '] i_contact_type [' || i_contact_type
               || ']'
    );

    l_customer_id := prd_api_customer_pkg.get_customer_id(
                         i_entity_type        => i_entity_type
                       , i_object_id          => i_object_id
                       , i_mask_error         => com_api_type_pkg.FALSE
                     );

    select nvl(da.delivery_address, c.customer_number)
      into o_address
      from prd_customer c
      left join
           (select ce.delivery_address
                 , ce.customer_id
                 , row_number() over(
                       partition by ce.customer_id
                           order by
                                 case
                                     when ce.event_type = i_event_type
                                         then 0
                                     when ce.event_type is null
                                         then 1
                                     else 2
                                 end
                               , ce.id desc
                   ) as rnk
              from ntf_custom_event ce
             where ce.entity_type = i_entity_type
               and ce.object_id   = i_object_id
               and ce.channel_id  = ntf_api_const_pkg.CHANNEL_PUSH
               and ce.delivery_address is not null
               and (ce.event_type is null
                    or ce.event_type = nvl(i_event_type, ce.event_type)
                   )
           ) da
        on c.id = da.customer_id and 1 = da.rnk
     where c.id = l_customer_id
    ;

    trc_log_pkg.debug(
        i_text => LOG_PREFIX || ' o_address=' || o_address
    );

    if o_address is null then

        raise no_data_found;

    end if;

    o_lang := nvl(get_user_lang(), com_api_const_pkg.LANGUAGE_ENGLISH);

    trc_log_pkg.debug(i_text => LOG_PREFIX || 'FINISH success');

exception
    when no_data_found then

        com_api_error_pkg.raise_error(
            i_error         => 'UNDEFINED_DELIVERY_ADDRESS'
          , i_env_param1    => ntf_api_const_pkg.CHANNEL_PUSH
          , i_env_param2    => i_entity_type
          , i_env_param3    => i_object_id
        );

end get_customer_push_number;

procedure get_postal_address (
    i_entity_type           in      com_api_type_pkg.t_dict_value
  , i_object_id             in      com_api_type_pkg.t_long_id
  , i_contact_type          in      com_api_type_pkg.t_dict_value
  , o_address                  out  com_api_type_pkg.t_name
  , o_lang                     out  com_api_type_pkg.t_dict_value
) is
    l_address_id      com_api_type_pkg.t_medium_id;
    l_inst_id         com_api_type_pkg.t_inst_id;
begin
    begin
        select o.address_id
          into l_address_id
          from com_address_object o
         where o.object_id = i_object_id
           and o.entity_type = i_entity_type
           and o.address_type = i_contact_type;

        l_inst_id := ost_api_institution_pkg.get_object_inst_id(
            i_entity_type  => i_entity_type
          , i_object_id    => i_object_id
          , i_mask_errors  => com_api_const_pkg.FALSE
        );
    exception
        when no_data_found then
            trc_log_pkg.error(
                i_text        => 'ADDRESS_NOT_FOUND'
              , i_env_param1  => i_entity_type
              , i_env_param2  => i_object_id
              , i_env_param3  => i_contact_type
            );
            l_address_id := null;
        when others then
            trc_log_pkg.error(sqlerrm);
    end;
    if l_address_id is not null then
        o_address := com_api_address_pkg.get_address_string(
                         i_address_id        => l_address_id
                       , i_inst_id           => l_inst_id
                     );
        o_lang    := com_ui_user_env_pkg.get_user_lang;
    end if;
end get_postal_address;

end ntf_api_notification_pkg;
/
