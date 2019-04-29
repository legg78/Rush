create or replace package body com_ui_object_pkg as
/*********************************************************
*  UI object descriptions <br />
*  Created by Filimonov A.(filimonov@bpcbt.com)  at 21.12.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: COM_UI_OBJECT_PKG <br />
*  @headcom
**********************************************************/
function get_object_desc(
    i_entity_type   in    com_api_type_pkg.t_dict_value
  , i_object_id     in    com_api_type_pkg.t_long_id
  , i_lang          in    com_api_type_pkg.t_dict_value default get_user_lang
  , i_enable_empty  in    com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_text is
    l_result            com_api_type_pkg.t_text;
    l_object_id         com_api_type_pkg.t_medium_id;
    l_entity_type       com_api_type_pkg.t_dict_value;
begin
    case i_entity_type

        when iss_api_const_pkg.ENTITY_TYPE_CARD then

            for rec in (select
                            a.card_mask
                          , get_text(
                                i_table_name  => 'net_card_type'
                              , i_column_name => 'name'
                              , i_object_id   => a.card_type_id
                              , i_lang        => i_lang
                            ) as card_type
                        from
                            iss_card a
                        where
                            a.id = i_object_id
                        )
            loop
                l_result := rec.card_type || ' ' || rec.card_mask;
            end loop;

        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
            for rec in (select
                            a.account_number
                          , get_article_text(
                              i_article => a.account_type
                            , i_lang => i_lang
                            ) as account_type
                          , get_text(
                              i_table_name  => 'com_currency'
                            , i_column_name => 'name'
                            , i_object_id   => c.id
                            , i_lang        => i_lang
                            ) as currency
                         from acc_account a
                            , com_currency c
                        where a.id   = i_object_id
                          and c.code = a.currency
                        )
            loop
                l_result := rec.account_number || ' ' || rec.currency || ' '|| rec.account_type;
            end loop;
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
            for rec in (select
                            a.merchant_name
                          , a.merchant_number
                        from
                            acq_merchant_vw a
                        where
                            a.id = i_object_id
                        )
            loop
                l_result := rec.merchant_name || ' ' || rec.merchant_number;
            end loop;
        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
            for rec in (
                select
                    get_article_text(
                        i_article =>  a.terminal_type
                      , i_lang    => i_lang
                    ) as terminal_type
                  , a.terminal_number
                  , com_api_address_pkg.get_address_string(
                        acq_api_terminal_pkg.get_terminal_address_id(
                            i_terminal_id => a.id
                        )
                    , i_lang         => i_lang
                    , i_enable_empty => i_enable_empty
                    ) as address
                from
                    acq_terminal_vw a
                where
                    a.id = i_object_id)
            loop
                l_result := rec.terminal_type || ' ' || rec.terminal_number || ' ' || rec.address;
            end loop;

        when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER then

            prd_api_customer_pkg.get_customer_object(
                i_customer_id => i_object_id
              , o_object_id   => l_object_id
              , o_entity_type => l_entity_type
              , i_mask_error  => com_api_type_pkg.TRUE
            );

            case l_entity_type

                when com_api_const_pkg.ENTITY_TYPE_PERSON then

                    l_result := com_ui_person_pkg.get_person_name(
                        i_person_id => l_object_id
                      , i_lang      => i_lang
                    );

                when com_api_const_pkg.ENTITY_TYPE_COMPANY then

                    l_result := get_text(
                        i_table_name  => 'com_company'
                      , i_column_name => 'label'
                      , i_object_id   => l_object_id
                      , i_lang        => i_lang
                    );

                when com_api_const_pkg.ENTITY_TYPE_UNDEFINED then
                    l_result := prd_api_customer_pkg.get_customer_number(i_object_id);
                    l_result := case when l_result is not null then l_result || ' - ' else null end;
                    l_result := l_result || get_article_desc(
                        i_article => l_entity_type
                      , i_lang    => i_lang
                    );

                else
                    l_result := null;
            end case;

        when iss_api_const_pkg.ENTITY_TYPE_CARDHOLDER then

            for rec in (
                select
                    a.person_id
                from
                    iss_cardholder_vw a
                where
                    a.id = i_object_id)
            loop
                l_result := com_ui_person_pkg.get_person_name(
                    i_person_id => rec.person_id
                  , i_lang      => i_lang
                );
            end loop;

        when net_api_const_pkg.ENTITY_TYPE_HOST then
            for rec in (
                select
                    get_text(
                        i_table_name  => 'net_network'
                      , i_column_name => 'name'
                      , i_object_id   => a.network_id
                      , i_lang        => i_lang
                    ) as network
                  , get_text(
                        i_table_name  => 'ost_institution'
                      , i_column_name => 'name'
                      , i_object_id   => a.inst_id
                      , i_lang        => i_lang
                    ) as inst
                from
                    net_member_vw a
                where
                    a.id = i_object_id
            ) loop
                l_result := rec.inst || ' ' || rec.network;
            end loop;

        when cmn_api_const_pkg.ENTITY_TYPE_CMN_DEVICE then

            for rec in (
                select
                    get_article_text(
                        i_article => a.communication_plugin
                      , i_lang    => i_lang
                    ) as protocol
                  , b.remote_address
                    || nvl2( b.remote_port, ':' || b.remote_port, b.remote_port)
                    || '->' || b.local_port as conn_desc
                from
                    cmn_device_vw a
                  , cmn_tcp_ip_vw b
                where
                    a.id = b.id
                and
                    a.id = i_object_id)
            loop
                l_result := rec.protocol || ' ' || rec.conn_desc;
            end loop;

        when com_api_const_pkg.ENTITY_TYPE_PERSON then
            l_result := com_ui_person_pkg.get_person_name(
                i_person_id => i_object_id
              , i_lang      => i_lang
            );

        when com_api_const_pkg.ENTITY_TYPE_COMPANY then
            l_result := get_text(
                i_table_name  => 'com_company'
              , i_column_name => 'label'
              , i_object_id   => i_object_id
              , i_lang        => i_lang
            );
        when acm_api_const_pkg.ENTITY_TYPE_ROLE then

            l_result := acm_api_role_pkg.get_role_name(
                i_role_id => i_object_id) ||
                ' ' ||
                get_text(
                    i_table_name  => 'acm_role'
                  , i_column_name => 'name'
                  , i_object_id   => i_object_id
                  , i_lang        => i_lang
                );
        when acm_api_const_pkg.ENTITY_TYPE_USER then
            for rec in (
                select a.user_name
                     , a.first_name
                     , a.second_name
                     , a.surname
                  from acm_ui_user_vw a
                 where a.user_id = i_object_id
                   and a.lang    = i_lang
            ) loop
                l_result :=
                    rec.user_name   || ' ' ||
                    rec.first_name  || ' ' ||
                    rec.second_name || ' ' ||
                    rec.surname;
            end loop;

        when acc_api_const_pkg.ENTITY_TYPE_MACROS then

            for rec in (
                select b.id
                  from acc_macros_vw a
                     , acc_macros_type b
                 where a.macros_type_id = b.id
                   and a.id             = i_object_id
            ) loop
                l_result := get_text(
                    i_table_name  => 'acc_macros_type'
                  , i_column_name => 'name'
                  , i_object_id   => rec.id
                  , i_lang        => i_lang
                ) || ' ' ||
                get_text(
                    i_table_name => 'acc_macros_type'
                  , i_column_name => 'description'
                  , i_object_id   => rec.id
                  , i_lang        => i_lang
                );
            end loop;
        when acc_api_const_pkg.ENTITY_TYPE_BUNCH then
            for rec in (
                select b.id
                  from acc_bunch a
                     , acc_bunch_type b
                 where a.bunch_type_id = b.id
                   and a.id = i_object_id
            ) loop
                l_result := get_text(
                    i_table_name  => 'acc_bunch_type'
                  , i_column_name => 'name'
                  , i_object_id   => rec.id
                  , i_lang        => i_lang
                ) || ' ' ||
                get_text(
                    i_table_name => 'acc_bunch_type'
                  , i_column_name => 'description'
                  , i_object_id   => rec.id
                  , i_lang        => i_lang
                );
            end loop;
        when acc_api_const_pkg.ENTITY_TYPE_TRANSACTION then
            for rec in (
                select a.transaction_type
                  from acc_entry a
                 where a.transaction_id = i_object_id
            ) loop
                l_result := get_article_text(
                    i_article => rec.transaction_type
                  , i_lang    => i_lang
                );
            end loop;
        when ost_api_const_pkg.ENTITY_TYPE_INSTITUTION then
            for rec in (
                select get_article_text(a.inst_type, i_lang)||' - '||name||' '||description as name
                  from ost_ui_institution_vw a
                 where id   = i_object_id
                   and lang = i_lang
            ) loop
                l_result := rec.name;
            end loop;
            
        when ost_api_const_pkg.ENTITY_TYPE_AGENT then
            for rec in (
                select get_article_text(a.agent_type, i_lang) || ' - ' || a.name || ', ' || i.name as name
                  from ost_ui_institution_vw i
                       , ost_ui_agent_vw a
                 where a.id   = i_object_id
                   and a.lang = i_lang
                   and a.inst_id = i.id
                   and i.lang = i_lang
            ) loop
                l_result := rec.name;
            end loop;
            
        when pmo_api_const_pkg.ENTITY_TYPE_SERVICE_PROVIDER  then
            for rec in (
                select get_article_text(i_entity_type)||' - '||region_code ||' ' ||label  as name
                  from pmo_ui_provider_vw
                 where id   = i_object_id
                   and lang = i_lang
            ) loop
                l_result := rec.name;
            end loop;
        when iss_api_const_pkg.ENTITY_TYPE_ISS_BIN then
            for rec in (
                select 'BIN' || ' ' || a.bin  as name
                  from iss_bin_vw a
                 where id   = i_object_id
            ) loop
                l_result := rec.name;
            end loop;
        when hsm_api_const_pkg.ENTITY_TYPE_HSM then
            for rec in (
                 select
                     get_article_text(
                         i_article => a.comm_protocol
                       , i_lang    => i_lang
                     ) as protocol
                   , get_article_text(
                         i_article => a.model_number
                       , i_lang    => i_lang
                     ) as model_number
                   , '#' || a.serial_number as serial_number 
                   , b.address || ':' || b.port as conn_desc                    
                 from
                     hsm_device_vw a,
                     hsm_tcp_ip_vw b
                 where
                     a.id = b.id and
                     a.id = i_object_id)
             loop
                 l_result := rec.protocol || ' ' || rec.model_number || ' ' ||   rec.serial_number || ' ' || rec.conn_desc;
             end loop;

        when prd_api_const_pkg.ENTITY_TYPE_CONTRACT then
            for rec in (select a.contract_number
                          from prd_contract_vw a
                         where a.id = i_object_id
                       )
            loop
                l_result := rec.contract_number;
            end loop;

        else
            l_result := null;
    end case;
    return l_result;

end get_object_desc;

end;
/
