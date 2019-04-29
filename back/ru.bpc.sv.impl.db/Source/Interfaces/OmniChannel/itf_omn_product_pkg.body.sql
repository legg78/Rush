create or replace package body itf_omn_product_pkg is
/*********************************************************
 *  Product export process <br />
 *  Created by Fomichev Andrey (fomichev@bpcbt.com) at 03.08.2018 <br />
 *  Last changed by $Author: fomichev $ <br />
 *  $LastChangedDate:: 2018-08-03 13:34:00 +0400#$ <br />
 *  Module: itf_omn_product_pkg <br />
 *  @headcom
 **********************************************************/

function generate_service_block(
    i_product_service_id in com_api_type_pkg.t_short_id
  , i_lang               in com_api_type_pkg.t_dict_value
) return xmltype is
begin
    return generate_service_block(
                                  i_product_service_id => i_product_service_id
                                , i_lang               => i_lang
                                , i_omni_iss_version   => null
                                 );
end generate_service_block;

function generate_service_block(
    i_product_service_id  in     com_api_type_pkg.t_short_id
  , i_lang                in     com_api_type_pkg.t_dict_value
  , i_omni_iss_version    in     com_api_type_pkg.t_name
) return xmltype is
    l_service_block       xmltype;
begin
    if i_product_service_id is null then
        return null;
    end if;

    select
        xmlelement("product_service"
          , xmlconcat(
                xmlelement("service_number"  , s1.service_number)
              , xmlelement("service_type_id" , s1.service_type_id)
              , xmlelement("service_status"  , s1.status)
              , xmlelement("min_count"       , ps1.min_count)
              , xmlelement("max_count"       , ps1.max_count)
              , (select xmlagg(
                            xmlelement("service_name"
                              , xmlattributes(l.lang as "language")
                              , xmlelement("name"       , get_text(i_table_name  => 'prd_service'
                                                                 , i_column_name => 'label'
                                                                 , i_object_id   => ps1.service_id
                                                                 , i_lang        => l.lang
                                                          )
                                )
                              , xmlelement("description", get_text(i_table_name  => 'prd_service'
                                                                 , i_column_name => 'description'
                                                                 , i_object_id   => ps1.service_id
                                                                 , i_lang => l.lang
                                                          )
                                )
                            )
                        )
                   from com_language_vw l
                  where (l.lang = i_lang or i_lang is null)
                )
               , generate_attribute_block(i_product_id => ps1.product_id, i_product_service_id => i_product_service_id)
            ) service_block
        )
    into l_service_block
    from prd_product_service  ps1
       , prd_service          s1
       , prd_service_type     st1
   where ps1.id             = i_product_service_id
     and s1.service_type_id = st1.id
     and s1.id              = ps1.service_id;

    return l_service_block;

exception
    when others then
        trc_log_pkg.debug('Error when generate service block on service_id = ' || i_product_service_id);
        return null;
end generate_service_block;

function generate_cycle_block(
    i_cycle_id       in  com_api_type_pkg.t_short_id
) return xmltype
is
    l_cycle_block    xmltype;
begin

    if i_cycle_id is null then
        return null;
    end if;

    select xmlelement("value_cycle"
             , xmlelement("cycle_length_type", fc.length_type)
             , xmlelement("cycle_length",      fc.cycle_length)
             , decode(fc.trunc_type,   null, null, xmlelement("cycle_trunc_type",  fc.trunc_type))
             , decode(fc.workdays_only,null, null, xmlelement("workdays_only",     fc.workdays_only))
             , (
                   select xmlagg(
                              xmlelement("shift"
                                , xmlelement("shift_type",         fcs.shift_type)
                                , xmlelement("shift_priority",     fcs.priority)
                                , xmlelement("shift_sign",         fcs.shift_sign)
                                , xmlelement("shift_length_type",  fcs.length_type)
                                , xmlelement("shift_length",       fcs.shift_length)
                              )
                          )
                     from fcl_cycle_shift fcs
                     where fcs.id = i_cycle_id
               )
           )
      into l_cycle_block
      from fcl_cycle fc
     where fc.id = i_cycle_id;

    return l_cycle_block;

exception
    when others then
        trc_log_pkg.error('Error when generate cycle block on cycle_id = ' || i_cycle_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_cycle_block;

function generate_limit_block(
    i_limit_id       in  com_api_type_pkg.t_long_id
) return xmltype
is
    l_limit_block    xmltype;
begin

    if i_limit_id is null then
        return null;
    end if;

    select xmlelement("value_limit"
                    , xmlelement("limit_sum_value",    fl.sum_limit)
                    , decode(fl.count_limit,  -1, null, xmlelement("limit_count_value",  fl.count_limit))
                    , decode(fl.check_type, null, null, xmlelement("limit_check_type",   fl.check_type))
                    , xmlelement("currency",           fl.currency)
                    , decode(fl.limit_base, null, null, xmlelement("limit_base",         fl.limit_base))
                    , decode(fl.limit_rate, null, null, xmlelement("limit_rate",         fl.limit_rate))
                    , generate_cycle_block(
                          i_cycle_id => fl.cycle_id
                      )
           )
      into l_limit_block
      from fcl_limit fl
     where fl.id = i_limit_id;

    return l_limit_block;

exception
    when others then
        trc_log_pkg.error('Error when generate limit block on limit_id = ' || i_limit_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_limit_block;

function generate_attribute_block(
    i_product_id         in com_api_type_pkg.t_short_id
  , i_product_service_id in com_api_type_pkg.t_short_id
)
return xmltype is
    DEFAULT_CHAR          constant com_api_type_pkg.t_name := '-';
    l_eff_date date := com_api_sttl_day_pkg.get_sysdate;
    l_attr_val_block      xmltype;
begin
    trc_log_pkg.debug($$PLSQL_UNIT||' '||$$PLSQL_LINE||' '||i_product_id||' '||i_product_service_id);
    select
           xmlagg(
                  xmlelement("attribute_value"
                                        , xmlelement("attribute_name",     x.attr_name)
                                        , case when x.mod_id is null
                                               then xmlelement("start_date",    to_char(x.start_date, com_api_const_pkg.XML_DATE_FORMAT))
                                          else null
                                           end
                                        , case when x.end_date is not null and x.mod_id is null
                                               then xmlelement("end_date", to_char(x.end_date, com_api_const_pkg.XML_DATE_FORMAT))
                                               else null
                                           end
                                        , case when x.data_type = com_api_const_pkg.DATA_TYPE_CHAR and x.attr_entity_type is null and x.mod_id is null
                                               then xmlelement("value_char", x.attr_value)
                                               else null
                                           end
                                        , case when x.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and x.attr_entity_type is null and x.mod_id is null
                                               then xmlelement("value_num", to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT))
                                               else null
                                           end
                                        , case when x.data_type = com_api_const_pkg.DATA_TYPE_DATE and x.attr_entity_type is null and x.mod_id is null
                                               then xmlelement("value_date", to_char(to_date(x.attr_value, com_api_const_pkg.DATE_FORMAT), com_api_const_pkg.XML_DATETIME_FORMAT))
                                               else null
                                           end
                                        , case
                                              when x.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_CYCLE and x.mod_id is null
                                              then generate_cycle_block(i_cycle_id => to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT))
                                              else null
                                           end
                                        , case
                                              when x.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT and x.mod_id is null
                                              then generate_limit_block(i_limit_id => to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT))
                                              else null
                                          end
                                        , case
                                              when x.attr_entity_type = fcl_api_const_pkg.ENTITY_TYPE_FEE and x.mod_id is null
                                              then (
                                                    select
                                                           xmlelement("value_fee"
                                                             , xmlelement("fee_rate_calc",  f.fee_rate_calc)
                                                             , xmlelement("fee_base_calc",  f.fee_base_calc)
                                                             , xmlelement("currency",       f.currency)
                                                             , (
                                                                select
                                                                       xmlagg(
                                                                           xmlelement("tier"
                                                                                            , xmlelement("fixed_rate",            ft.fixed_rate)
                                                                                            , xmlelement("percent_rate",          ft.percent_rate)
                                                                                            , xmlelement("min_value",             ft.min_value)
                                                                                            , xmlelement("max_value",             ft.max_value)
                                                                                            , decode(ft.length_type,null,null,xmlelement("length_type",           ft.length_type))
                                                                                            , xmlelement("sum_threshold",         ft.sum_threshold)
                                                                                            , xmlelement("count_threshold",       ft.count_threshold)
                                                                                            , decode(ft.length_type_algorithm,null,null,xmlelement("length_type_algorithm", ft.length_type_algorithm))
                                                                                     )
                                                                             )
                                                                  from fcl_fee_tier ft
                                                                 where ft.fee_id = f.id
                                                               )
                                                             , case
                                                                   when f.limit_id is not null
                                                                   then generate_limit_block(
                                                                                             i_limit_id => f.limit_id
                                                                                            )
                                                                   else null
                                                               end
                                                             , case
                                                                   when f.cycle_id is not null
                                                                   then generate_cycle_block(
                                                                                             i_cycle_id => f.cycle_id
                                                                                            )
                                                                   else null
                                                               end
                                                                     )
                                                      from fcl_fee f
                                                     where f.id = to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT)
                                                   )
                                              else null
                                          end
                                        , case when x.mod_id is not null
                                               then xmlelement("modifier_flag", 1)
                                               else xmlelement("modifier_flag", 0)
                                          end
                                        , xmlelement("definition_level", x.definition_level)
                                        , xmlelement("entity_type",      x.entity_type)
                                        , xmlelement("object_id",        x.object_id)
                                        , xmlelement("object_number"
                                          , case x.entity_type
                                                when prd_api_const_pkg.ENTITY_TYPE_PRODUCT then
                                                     (
                                                      select o.product_number
                                                        from prd_product o
                                                       where o.id = x.object_id
                                                     )
                                                when prd_api_const_pkg.ENTITY_TYPE_SERVICE then
                                                    (
                                                     select o.service_number
                                                       from prd_service o
                                                      where o.id = x.object_id
                                                    )
                                                when com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                                                    (
                                                     select o.customer_number
                                                       from prd_customer o
                                                      where o.id = x.object_id
                                                    )
                                                when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                                                     (
                                                      select o.account_number
                                                        from acc_account o
                                                       where o.id = x.object_id
                                                     )
                                                when iss_api_const_pkg.ENTITY_TYPE_CARD then
                                                    (
                                                     select iss_api_token_pkg.decode_card_number(i_card_number => o.card_number)
                                                       from iss_card_number o
                                                      where o.card_id = x.object_id
                                                    )
                                                when acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                                                    (
                                                     select o.merchant_number
                                                       from acq_merchant o
                                                      where o.id = x.object_id
                                                    )
                                                when acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                                                   (
                                                    select o.terminal_number
                                                      from acq_terminal o
                                                     where o.id = x.object_id
                                                   )
                                            end
                                          )
                            )
                 )
      into  l_attr_val_block
      from (
            select distinct a.attr_name                             attr_name
                 , decode(v.mod_id, null, a.data_type, null)        data_type
                 , a.definition_level                               definition_level
                 , a.entity_type                                    attr_entity_type
                 , decode(v.mod_id, null, null, 1)                  mod_id
                 , v.start_date                                     start_date
                 , v.end_date                                       end_date
                 , decode(v.mod_id, null, v.attr_value, null)       attr_value
                 , v.entity_type                                    entity_type
                 , v.object_id                                      object_id
                 , count (mod_id) over (partition by attr_name)     is_mod
              from (
                    select connect_by_root  p2.id  product_id
                         , level   level_priority
                         , p2.id   parent_id
                         , case when p2.parent_id is null then 1 else 0 end top_flag
                      from prd_product p2
                      connect by prior p2.parent_id = p2.id
                      start with              p2.id = i_product_id
                   ) p
                 , prd_attribute_value v
                 , prd_attribute a
                 , prd_service s
                 , rul_mod m
                 , prd_product_service ps
             where ps.id     = i_product_service_id
               and ps.product_id     = p.product_id
               and ps.service_id     = s.id
               and v.service_id      = s.id
               and a.service_type_id = s.service_type_id
               and l_eff_date       <= nvl(v.end_date, l_eff_date + 1)
               and v.object_id       = case
                                           when v.entity_type in (prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                                                , prd_api_const_pkg.ENTITY_TYPE_SERVICE)
                                           then decode(a.definition_level
                                                     , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE
                                                     , s.id
                                                     , p.parent_id
                                                )
                                           else v.object_id
                                       end
               and v.entity_type     = case
                                           when v.entity_type in (prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                                                , prd_api_const_pkg.ENTITY_TYPE_SERVICE)
                                           then decode (a.definition_level
                                                           , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE,
                                                                 decode (p.top_flag
                                                                       , 1
                                                                       , prd_api_const_pkg.ENTITY_TYPE_SERVICE
                                                                       , DEFAULT_CHAR
                                                                        )
                                                           , prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                                                       )
                                           else v.entity_type
                                       end
               and v.attr_id         = a.id
               and v.mod_id          = m.id(+)
               and p.parent_id    in (
                                      case
                                          when v.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                                              (
                                                  select pc.product_id
                                                    from prd_customer o, prd_contract pc
                                                   where o.id  = v.object_id
                                                     and pc.id = o.contract_id
                                              )
                                          when v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                                              (
                                                  select pc.product_id
                                                    from acc_account o, prd_contract pc
                                                   where o.id  = v.object_id
                                                     and pc.id = o.contract_id
                                              )
                                          when v.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                                              (
                                                  select pc.product_id
                                                    from iss_card o, prd_contract pc
                                                   where o.id  = v.object_id
                                                     and pc.id = o.contract_id
                                              )
                                          when v.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                                              (
                                                  select pc.product_id
                                                    from acq_merchant o, prd_contract pc
                                                   where o.id  = v.object_id
                                                     and pc.id = o.contract_id
                                              )
                                          when v.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                                              (
                                                  select pc.product_id
                                                    from acq_terminal o, prd_contract pc
                                                   where o.id  = v.object_id
                                                     and pc.id = o.contract_id
                                              )
                                          else
                                              p.parent_id
                                      end
                                     )
           ) x
     where x.is_mod = 0 or x.mod_id is not null;
    return  l_attr_val_block;
end generate_attribute_block;

function execute_product_query_2_0(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_omni_iss_version  in     com_api_type_pkg.t_name
  , o_xml                  out clob
  , i_session_file_id   in     com_api_type_pkg.t_long_id default null
) return number is
    C_CRLF       constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    l_estimated_count      com_api_type_pkg.t_long_id;
begin
    select
        count(p.id) cnt
      , com_api_const_pkg.XML_HEADER || C_CRLF ||
            xmlelement(
            "products"
          , xmlattributes('http://bpc.ru/SVXP/omnichannels/product' as "xmlns")
          , xmlelement("file_type", itf_api_const_pkg.FILE_TYPE_PRODUCT   ) --file_type
          , xmlelement("inst_id"  , to_char(i_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT)) --inst_id
          , xmlelement("file_id"  , to_char(i_session_file_id, com_api_const_pkg.XML_NUMBER_FORMAT)) -- file_id
          , xmlagg(
                xmlelement("product" -- product
                  , xmlelement("product_type", product_type)      -- product_type
                  , xmlelement("contract_type", contract_type)    --  contract_type
                  , xmlelement("customer_types"            -- customer_types
                     , (select xmlagg(
                                   xmlelement("customer_type", customer_entity_type) -- customer_type
                               )
                          from prd_contract_type ct
                         where ct.contract_type = p.contract_type
                           and ct.product_type  = p.product_type
                       )
                    )
                  , xmlelement("product_number", product_number ) -- product_number
                  , (select
                         xmlagg(
                             xmlelement("product_name"-- product_name
                               , xmlattributes(l.lang as "language")
                               , xmlelement("name", get_text(i_table_name  => 'prd_product'
                                                           , i_column_name => 'label'
                                                           , i_object_id   => p.id
                                                           , i_lang        => l.lang
                                                    )
                                           )
                               , xmlelement("description", get_text(i_table_name  => 'prd_product'
                                                                  , i_column_name => 'description'
                                                                  , i_object_id   => p.id
                                                                  , i_lang        => l.lang
                                                            )
                                 )
                             )
                         )
                       from com_language_vw l
                      where (l.lang = i_lang or i_lang is null)
                    )
                  , xmlelement("product_status", p.status)  -- product_status
                  , (select
                         xmlagg(
                             itf_omn_product_pkg.generate_service_block(
                                 i_product_service_id => ps1.id
                               , i_lang               => i_lang
                             )
                         )
                       from prd_product_service ps1
                      where ps1.product_id = p.id
                    )
                  , (select xmlagg(
                                xmlelement("product_accounts"    -- product_accounts
                                  , xmlelement("account_type"  , pat.account_type)
                                  , xmlelement("currency"      , pat.currency)
                                  , xmlelement("service_number", s.service_number)
                                )
                            )
                       from acc_product_account_type pat
                          , prd_service s
                      where pat.product_id = p.id
                        and s.id = pat.service_id
                    )
                  , (select xmlagg(
                                xmlelement("product_cards" -- product_cards
                                  , xmlelement("card_type_id",   pct.card_type_id)
                                  , xmlelement("service_number", s.service_number)
                                )
                             )
                       from iss_product_card_type pct
                          , prd_service s
                      where pct.product_id = p.id
                        and s.id           = pct.service_id
                    )
                  )
               )
            ).getclobval() as product_data
          into l_estimated_count
             , o_xml
          from prd_product p
         where p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS --'PRDT0100'
           and (p.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
    return l_estimated_count;

exception
    when others then
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end;

function execute_product_query_3_0(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , o_xml                  out clob
  , i_session_file_id   in     com_api_type_pkg.t_long_id default null
) return number is
    C_CRLF       constant  com_api_type_pkg.t_name := chr(13)||chr(10);
    l_estimated_count      com_api_type_pkg.t_long_id;
begin
    select
           count(p.id) cnt
         , com_api_const_pkg.XML_HEADER || C_CRLF ||
               xmlelement(
               "products"
             , xmlattributes('http://bpc.ru/SVXP/omnichannels/product' as "xmlns")
                 , xmlelement("file_type", itf_api_const_pkg.FILE_TYPE_PRODUCT   )
                 , xmlelement("inst_id"  , to_char(i_inst_id, com_api_const_pkg.XML_NUMBER_FORMAT))
                 , xmlelement("file_id"  , to_char(i_session_file_id, com_api_const_pkg.XML_NUMBER_FORMAT))
                 , xmlagg(
                       xmlelement("product"
                         , xmlelement("product_type", product_type)
                         , xmlelement("contract_type", contract_type)
                         , xmlelement("customer_types"
                                        , (select xmlagg(xmlelement("customer_type", customer_entity_type))
                                             from prd_contract_type ct
                                            where ct.contract_type = p.contract_type
                                              and ct.product_type  = p.product_type
                                          )
                                     )
                         , xmlelement("product_number", product_number)
                         , xmlelement("product_name"
                                    , xmlattributes(lng.lang as "language")
                                    , xmlelement("name",        get_text(i_table_name  => 'prd_product'
                                                                        , i_column_name => 'label'
                                                                        , i_object_id   => p.id
                                                                        , i_lang        => lng.lang
                                                                        )
                                                )
                                    , xmlelement("description", get_text(i_table_name  => 'prd_product'
                                                                        , i_column_name => 'description'
                                                                        , i_object_id   => p.id
                                                                        , i_lang        => lng.lang
                                                                        )
                                                )
                                     )
                         , xmlelement("product_status", p.status)
                         , (select
                                   xmlagg(
                                           generate_service_block
                                           (
                                                     i_product_service_id => ps1.id
                                                   , i_lang               => i_lang
                                                   , i_omni_iss_version   =>'3.0'
                                           )
                                       )
                           from prd_product_service ps1
                          where ps1.product_id = p.id
                         )
                         , (select xmlagg(
                                        xmlelement("product_accounts"
                                           , xmlelement("account_type"  , pat.account_type)
                                           , xmlelement("account_type_name",(select get_text (
                                                                                               i_table_name  => 'com_dictionary'
                                                                                             , i_column_name => 'name'
                                                                                             , i_object_id   => dict.id
                                                                                             , i_lang        => lng.lang
                                                                                             )
                                                                               from com_dictionary dict
                                                                               where dict.dict || dict.code = pat.account_type
                                                                            )
                                                       )

                                           , xmlelement("currency"      , pat.currency)
                                           , xmlelement("service_number", s.service_number)

                                                  )
                                       )
                            from acc_product_account_type pat
                               , prd_service s
                           where pat.product_id = p.id
                             and s.id = pat.service_id
                         )
                         , (select xmlagg(
                                           xmlelement("product_cards"
                                             , xmlelement("card_type_id",   pct.card_type_id)
                                             , xmlelement("card_type_name",get_text (
                                                                                     i_table_name  => 'net_card_type'
                                                                                   , i_column_name => 'name'
                                                                                   , i_object_id   => pct.card_type_id
                                                                                   , i_lang        => lng.lang
                                                                                    )
                                                         )
                                             , xmlelement("service_number", s.service_number)
                                                     )
                                         )
                             from iss_product_card_type pct
                                , prd_service s
                            where pct.product_id = p.id
                              and s.id           = pct.service_id
                           )
                                 )
                         )
                         ).getclobval() as product_data
          into l_estimated_count
             , o_xml
          from prd_product p left join com_language_vw lng on lng.lang = nvl(i_lang, 'LANGENG')
         where p.product_type = prd_api_const_pkg.PRODUCT_TYPE_ISS
           and (p.inst_id = i_inst_id or i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST);
    return l_estimated_count;

exception
    when others then
        if  com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE
            or
            com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE
        then
            raise;
        else
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

end;

function execute_product_query(
    i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
  , i_omni_iss_version  in     com_api_type_pkg.t_name
  , o_xml                  out clob
  , i_session_file_id   in     com_api_type_pkg.t_long_id default null
) return number is
begin
    if i_omni_iss_version between '2.0' and '2.0' then
        return execute_product_query_2_0(
                   i_inst_id          => i_inst_id
                 , i_lang             => i_lang
                 , i_omni_iss_version => i_omni_iss_version
                 , o_xml              => o_xml
                 , i_session_file_id  => i_session_file_id
               );
    elsif i_omni_iss_version = '3.0' then
        return execute_product_query_3_0(
                   i_inst_id          => i_inst_id
                 , i_lang             => i_lang
                 , o_xml              => o_xml
                 , i_session_file_id  => i_session_file_id
               );
    else
        com_api_error_pkg.raise_fatal_error(
            i_error       => 'VERSION_IS_NOT_SUPPORTED'
          , i_env_param1  => i_omni_iss_version
        );
    end if;

end;

end itf_omn_product_pkg;
/
