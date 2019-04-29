create or replace package body prd_prc_product_pkg as
/*********************************************************
*  Export&Import utility for product's migration <br />
*  Created by Filimonov A.(filimonov@bpc.ru) at 30.03.2010 <br />
*  Last changed by $Author: truschelev $ <br />
*  $LastChangedDate:: 2015-08-07 15:58:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 52893 $ <br />
*  Module: PRD_PRC_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

CRLF                     constant com_api_type_pkg.t_name := chr(13) || chr(10);

-- Event object id lists for next objects: product, customer, account, card, merchant, terminal.

g_event_customer_id_tab  num_tab_tpt;
g_event_account_id_tab   num_tab_tpt;
g_event_card_id_tab      num_tab_tpt;
g_event_merchant_id_tab  num_tab_tpt;
g_event_terminal_id_tab  num_tab_tpt;


type t_product_rec is record (
    command              com_api_type_pkg.t_dict_value
  , product_type         com_api_type_pkg.t_dict_value
  , contract_type        com_api_type_pkg.t_dict_value
  , product_number       com_api_type_pkg.t_name
  , product_status       com_api_type_pkg.t_dict_value
  , product_service      xmltype
  , product_name         xmltype
  , product              xmltype
  , product_account_type xmltype
  , product_card_type    xmltype
  , product_note         xmltype
  , product_scheme       xmltype
);

type t_product_tab is table of t_product_rec index by binary_integer;

procedure make_cycle_shift(
    i_cycle_id          in  com_api_type_pkg.t_short_id
  , i_xml               in  xmltype
) is
    l_cycle_shift_id        com_api_type_pkg.t_short_id;

begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_cycle_shift'
    );

    for shift in (
        select shift_length
             , shift_length_type
             , shift_priority
             , shift_sign
             , shift_type
        from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/shift'
                passing i_xml
                columns
                      shift_length          number          path 'shift_length'
                    , shift_length_type     varchar2(8)     path 'shift_length_type'
                    , shift_priority        number          path 'shift_priority'
                    , shift_sign            number          path 'shift_sign'
                    , shift_type            varchar2(8)     path 'shift_type'
               )
    ) loop
        fcl_ui_cycle_pkg.add_cycle_shift(
            i_cycle_id          => i_cycle_id
          , i_shift_type        => shift.shift_type
          , i_priority          => shift.shift_priority
          , i_shift_sign        => shift.shift_sign
          , i_length_type       => shift.shift_length_type
          , i_shift_length      => shift.shift_length
          , o_cycle_shift_id    => l_cycle_shift_id
        );

    end loop;

end;

function make_cycle(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_xml               in  xmltype
  , i_cycle_type        in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id is
    l_length_type       com_api_type_pkg.t_dict_value;
    l_cycle_length      com_api_type_pkg.t_tiny_id;
    l_trunc_type        com_api_type_pkg.t_dict_value;
    l_wd_only           com_api_type_pkg.t_boolean;
    l_shift             xmltype;

    l_cycle_id          com_api_type_pkg.t_short_id;
begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_cycle'
    );

    begin
        select cycle_length_type
             , cycle_length
             , cycle_trunc_type
             , workdays_only
             , shift
          into l_length_type
             , l_cycle_length
             , l_trunc_type
             , l_wd_only
             , l_shift
          from xmltable(
                    xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                  , '/value_cycle'
                    passing i_xml
                    columns
                        cycle_length_type   varchar2(8) path 'cycle_length_type'
                      , cycle_length        number      path 'cycle_length'
                      , cycle_trunc_type    varchar2(8) path 'cycle_trunc_type'
                      , workdays_only       number      path 'workdays_only'
                      , shift               xmltype     path 'shift'
                   );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ATTRIBUTE_VALUE_NOT_DEFINED'
            );

        when too_many_rows then
            trc_log_pkg.error(
                i_text          => 'Only one value expected'
            );

            com_api_error_pkg.raise_error(
                i_error         => 'WRONG_ATTRIBUTE_VALUE'
            );
    end;

    fcl_ui_cycle_pkg.add_cycle(
        i_cycle_type        => i_cycle_type
      , i_length_type       => l_length_type
      , i_cycle_length      => l_cycle_length
      , i_trunc_type        => l_trunc_type
      , i_inst_id           => i_inst_id
      , i_workdays_only     => l_wd_only
      , o_cycle_id          => l_cycle_id
    );

    if l_shift is not null then
        make_cycle_shift(
            i_cycle_id  => l_cycle_id
          , i_xml       => l_shift
        );
    end if;

    return l_cycle_id;

end;

function make_limit(
    i_inst_id           in  com_api_type_pkg.t_inst_id
  , i_xml               in  xmltype
  , i_limit_type        in  com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_long_id is
    l_limit_id              com_api_type_pkg.t_long_id;
    l_value_cycle           xmltype;
    l_limit_sum_value       com_api_type_pkg.t_money;
    l_limit_count_value     com_api_type_pkg.t_long_id;
    l_limit_check_type      com_api_type_pkg.t_dict_value;
    l_currency              com_api_type_pkg.t_curr_code;
    l_limit_base            com_api_type_pkg.t_dict_value;
    l_limit_rate            com_api_type_pkg.t_dict_value;
    l_cycle_type            com_api_type_pkg.t_dict_value;
    l_cycle_id              com_api_type_pkg.t_short_id;

begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_limit'
    );

    begin
        select cycle_type
          into l_cycle_type
          from fcl_limit_type
         where limit_type = i_limit_type;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_TYPE_NOT_EXIST'
            );

    end;

    begin
        select limit_sum_value
             , limit_count_value
             , limit_check_type
             , currency
             , limit_base
             , limit_rate
             , value_cycle
          into l_limit_sum_value
             , l_limit_count_value
             , l_limit_check_type
             , l_currency
             , l_limit_base
             , l_limit_rate
             , l_value_cycle
          from xmltable(
                    xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                  , '/value_limit'
                    passing i_xml
                    columns
                        limit_sum_value     varchar2(32)    path 'limit_sum_value'
                      , limit_count_value   number          path 'limit_count_value'
                      , limit_check_type    varchar2(8)     path 'limit_check_type'
                      , currency            varchar2(3)     path 'currency'
                      , limit_base          varchar2(8)     path 'limit_base'
                      , limit_rate          varchar2(8)     path 'limit_rate'
                      , value_cycle         xmltype         path 'value_cycle'
                   );
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ATTRIBUTE_VALUE_NOT_DEFINED'
            );

        when too_many_rows then
            trc_log_pkg.error(
                i_text          => 'Only one value expected'
            );

            com_api_error_pkg.raise_error(
                i_error         => 'WRONG_ATTRIBUTE_VALUE'
            );
    end;

    if l_cycle_type is null and l_value_cycle is not null then
        com_api_error_pkg.raise_error(
            i_error         => 'CYCLE_NOT_NEEDED_FOR_LIMIT'
          , i_env_param1    => i_limit_type
        );

    elsif l_cycle_type is not null then
        if l_value_cycle is null then
            com_api_error_pkg.raise_error(
                i_error         => 'CYCLE_MANDATORY_FOR_LIMIT'
              , i_env_param1    => i_limit_type
              , i_env_param2    => l_cycle_type
            );

        else
            l_cycle_id  := make_cycle(
                i_inst_id       => i_inst_id
              , i_xml           => l_value_cycle
              , i_cycle_type    => l_cycle_type
            );

        end if;

    end if;

    fcl_ui_limit_pkg.add_limit(
        i_limit_type        => i_limit_type
      , i_cycle_id          => l_cycle_id
      , i_count_limit       => l_limit_count_value
      , i_sum_limit         => to_number(l_limit_sum_value, com_api_const_pkg.XML_FLOAT_FORMAT)
      , i_check_type        => l_limit_check_type
      , i_currency          => l_currency
      , i_inst_id           => i_inst_id
      , i_limit_base        => l_limit_base
      , i_limit_rate        => l_limit_rate
      , o_limit_id          => l_limit_id
    );

    return l_limit_id;

end;

procedure make_fee_tiers(
    i_xml           in  xmltype
  , i_fee_id        in  com_api_type_pkg.t_short_id
) is
    l_tier_id       com_api_type_pkg.t_short_id;
    l_seqnum        com_api_type_pkg.t_seqnum;
begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_fee_tiers'
    );

    for tier in (
        select fixed_rate
             , percent_rate
             , min_value
             , max_value
             , length_type
             , sum_threshold
             , count_threshold
             , length_type_algorithm
        from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/tier'
                passing i_xml
                columns
                    fixed_rate              varchar2(32)    path 'fixed_rate'
                  , percent_rate            varchar2(32)    path 'percent_rate'
                  , min_value               varchar2(32)    path 'min_value'
                  , max_value               varchar2(32)    path 'max_value'
                  , length_type             varchar2(8)     path 'length_type'
                  , sum_threshold           varchar2(32)    path 'sum_threshold'
                  , count_threshold         number(16)      path 'count_threshold'
                  , length_type_algorithm   varchar2(8)     path 'length_type_algorithm'
               )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'fixed_rate [#1], length_type_algorithm [#2]'
          , i_env_param1    => to_number(tier.fixed_rate, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_env_param2    => tier.length_type_algorithm
        );

        fcl_ui_fee_pkg.add_fee_tier(
            i_fee_id                => i_fee_id
          , i_fixed_rate            => to_number(tier.fixed_rate, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_percent_rate          => to_number(tier.percent_rate, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_min_value             => to_number(tier.min_value, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_max_value             => to_number(tier.max_value, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_length_type           => tier.length_type
          , i_sum_threshold         => to_number(tier.sum_threshold, com_api_const_pkg.XML_FLOAT_FORMAT)
          , i_count_threshold       => to_number(tier.count_threshold, com_api_const_pkg.XML_NUMBER_FORMAT)
          , i_length_type_algorithm => tier.length_type_algorithm
          , o_fee_tier_id           => l_tier_id
          , o_seqnum                => l_seqnum
        );

    end loop;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_fee_tiers finished'
    );

end;

function make_fee(
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_xml           in  xmltype
  , i_fee_type      in  com_api_type_pkg.t_dict_value

) return com_api_type_pkg.t_short_id is
    l_seqnum            com_api_type_pkg.t_seqnum;
    l_fee_id            com_api_type_pkg.t_short_id;
    l_fee_rate_calc     com_api_type_pkg.t_dict_value;
    l_fee_base_calc     com_api_type_pkg.t_dict_value;
    l_currency          com_api_type_pkg.t_curr_code;
    l_value_cycle       xmltype;
    l_value_limit       xmltype;
    l_tiers             xmltype;

    l_cycle_type        com_api_type_pkg.t_dict_value;
    l_limit_type        com_api_type_pkg.t_dict_value;

    l_limit_id          com_api_type_pkg.t_long_id;
    l_cycle_id          com_api_type_pkg.t_short_id;

begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_fee [#1]'
      , i_env_param1    => i_fee_type
    );

    begin
        select cycle_type
             , limit_type
          into l_cycle_type
             , l_limit_type
          from fcl_fee_type
         where fee_type = i_fee_type;

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'FEE_TYPE_NOT_FOUND'
            );
    end;

    begin
        select fee_rate_calc
             , fee_base_calc
             , currency
             , value_cycle
             , value_limit
             , tier
          into l_fee_rate_calc
             , l_fee_base_calc
             , l_currency
             , l_value_cycle
             , l_value_limit
             , l_tiers
          from xmltable(
                    xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                  , '/value_fee'
                    passing i_xml
                    columns
                        fee_rate_calc   varchar2(8)     path    'fee_rate_calc'
                      , fee_base_calc   varchar2(8)     path    'fee_base_calc'
                      , currency        varchar2(3)     path    'currency'
                      , value_cycle     xmltype         path    'value_cycle'
                      , value_limit     xmltype         path    'value_limit'
                      , tier            xmltype         path    'tier'
                   );

    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ATTRIBUTE_VALUE_NOT_DEFINED'
            );

        when too_many_rows then
            trc_log_pkg.error(
                i_text          => 'Only one value expected'
            );

            com_api_error_pkg.raise_error(
                i_error         => 'WRONG_ATTRIBUTE_VALUE'
            );

    end;

    if l_cycle_type is null and l_value_cycle is not null then
        com_api_error_pkg.raise_error(
            i_error         => 'CYCLE_NOT_NEEDED_FOR_FEE'
          , i_env_param1    => i_fee_type
        );

    elsif l_cycle_type is not null then
        if l_value_cycle is null then
            com_api_error_pkg.raise_error(
                i_error         => 'CYCLE_MANDATORY_FOR_FEE'
              , i_env_param1    => i_fee_type
              , i_env_param2    => l_cycle_type
            );

        else
            l_cycle_id  := make_cycle(
                i_inst_id       => i_inst_id
              , i_xml           => l_value_cycle
              , i_cycle_type    => l_cycle_type
            );

        end if;

    end if;

    if l_limit_type is null and l_value_limit is not null then
        com_api_error_pkg.raise_error(
            i_error         => 'LIMIT_NOT_NEEDED_FOR_FEE'
          , i_env_param1    => i_fee_type
        );

    elsif l_limit_type is not null then
        if l_value_limit is null then
            com_api_error_pkg.raise_error(
                i_error         => 'LIMIT_MANDATORY_FOR_FEE'
              , i_env_param1    => i_fee_type
              , i_env_param2    => l_limit_type
            );

        else
            l_limit_id  := make_limit(
                i_inst_id       => i_inst_id
              , i_xml           => l_value_limit
              , i_limit_type    => l_limit_type
            );

        end if;

    end if;

    fcl_ui_fee_pkg.add_fee(
          i_fee_type        => i_fee_type
        , i_currency        => l_currency
        , i_fee_rate_calc   => l_fee_rate_calc
        , i_fee_base_calc   => l_fee_base_calc
        , i_limit_id        => l_limit_id
        , i_cycle_id        => l_cycle_id
        , i_inst_id         => i_inst_id
        , o_fee_id          => l_fee_id
        , o_seqnum          => l_seqnum
    );

    make_fee_tiers(
        i_xml       => l_tiers
      , i_fee_id    => l_fee_id
    );

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.make_fee [#1] finished'
      , i_env_param1    => l_fee_id
    );

    return l_fee_id;
end;

procedure process_attribute_value(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_service_id            in  com_api_type_pkg.t_short_id
  , i_attribute_xml         in  xmltype
) is
    l_attr_value_id         com_api_type_pkg.t_medium_id;
    l_entity_type           com_api_type_pkg.t_dict_value;
    l_object_id             com_api_type_pkg.t_long_id;
begin
    if i_attribute_xml is null then
        return;

    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_attribute_value'
    );

    for attr in (
            select av.attribute_name
                 , to_date(av.start_date, com_api_const_pkg.XML_DATETIME_FORMAT) start_date
                 , to_date(av.end_date, com_api_const_pkg.XML_DATETIME_FORMAT) end_date
                 , av.mod_id
                 , av.value_char
                 , av.value_num
                 , av.value_date
                 , av.definition_level xml_def_level
                 , av.value_cycle
                 , av.value_limit
                 , av.value_fee
                 , a.id attr_id
                 , a.definition_level attr_def_level
                 , a.entity_type
                 , a.object_type
                 , a.data_type
                 , case when av.value_char  is null then 0 else 1 end +
                   case when av.value_num   is null then 0 else 1 end +
                   case when av.value_date  is null then 0 else 1 end +
                   case when av.value_cycle is null then 0 else 1 end +
                   case when av.value_limit is null then 0 else 1 end +
                   case when av.value_fee   is null then 0 else 1 end
                   num_values
              from xmltable(
                    xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                  , '/attribute_value'
                    passing i_attribute_xml
                    columns
                        attribute_name              varchar2(200)   path 'attribute_name'
                      , start_date                  varchar2(20)    path 'start_date'
                      , end_date                    varchar2(20)    path 'end_date'
                      , mod_id                      number          path 'mod_id'
                      , value_char                  varchar2(200)   path 'value_char'
                      , value_num                   number          path 'value_num'
                      , value_date                  varchar2(20)    path 'value_date'
                      , definition_level            varchar2(8)     path 'definition_level'
                      , value_cycle                 xmltype         path 'value_cycle'
                      , value_limit                 xmltype         path 'value_limit'
                      , value_fee                   xmltype         path 'value_fee'
                   ) av
                 , prd_attribute a
             where av.attribute_name = a.attr_name(+)
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process attribute [#1]; mod_id [#2]; num_values [#3]'
          , i_env_param1    => attr.attribute_name
          , i_env_param2    => attr.mod_id
          , i_env_param3    => attr.num_values
        );

        if attr.num_values > 1 then
            trc_log_pkg.error(
                i_text          => 'Attribute [#1] have wrong number of values [#2]'
              , i_env_param1    => attr.attribute_name
              , i_env_param2    => attr.num_values
            );

            com_api_error_pkg.raise_error(
                i_error         => 'WRONG_ATTRIBUTE_VALUE'
            );
        end if;

        if attr.attr_id is null then
            trc_log_pkg.error(
                i_text          => 'Attribute [#1] not found by name'
              , i_env_param1    => attr.attribute_name
            );
            com_api_error_pkg.raise_error(
                i_error         => 'ATTRIBUTE_NOT_FOUND'
            );
        end if;

        if attr.xml_def_level is not null 
          and attr.attr_def_level != attr.xml_def_level then
            trc_log_pkg.error(
                i_text          => 'ATTR_WRONG_NUMBER_VALUES'
              , i_env_param1    => attr.attribute_name
              , i_env_param2    => attr.xml_def_level
              , i_env_param3    => attr.attr_def_level
            );
            com_api_error_pkg.raise_error(
                i_error         => 'ATTRIBUTE_NOT_FOUND'
            );
        
        else 
            if attr.attr_def_level = prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE then
            
                l_entity_type := prd_api_const_pkg.ENTITY_TYPE_SERVICE;
                l_object_id   := i_service_id;
            else
                l_entity_type := prd_api_const_pkg.ENTITY_TYPE_PRODUCT;
                l_object_id   := i_product_id;
            end if;             
        end if;
        
        trc_log_pkg.debug(
            i_text          => 'Definition_level [#1]; Entity type [#2]; attr.entity_type [#3]; attr.data_type [#4]; l_object_id [#5]'
          , i_env_param1    => attr.attr_def_level
          , i_env_param2    => l_entity_type
          , i_env_param3    => attr.entity_type
          , i_env_param4    => attr.data_type
          , i_env_param5    => l_object_id
        );

        l_attr_value_id     := null;

        case attr.entity_type
        when rul_api_const_pkg.ENTITY_TYPE_GROUP_ATTR then
            trc_log_pkg.error(
                i_text          => 'Group attribute [#1] does not supported'
              , i_env_param1    => attr.attribute_name
            );

            com_api_error_pkg.raise_error(
                i_error         => 'ENTITY_TYPE_NOT_SUPPORTED'
            );

        when fcl_api_const_pkg.ENTITY_TYPE_CYCLE then
            if attr.value_cycle is not null then
                prd_api_attribute_value_pkg.set_attr_value_cycle (
                    io_attr_value_id        => l_attr_value_id
                    , i_service_id          => i_service_id
                    , i_entity_type         => l_entity_type
                    , i_object_id           => l_object_id
                    , i_attr_name           => attr.attribute_name
                    , i_mod_id              => attr.mod_id
                    , i_start_date          => attr.start_date
                    , i_end_date            => attr.end_date
                    , i_cycle_id            => make_cycle(i_inst_id => i_inst_id, i_xml => attr.value_cycle, i_cycle_type => attr.object_type)
                    , i_check_start_date    => com_api_const_pkg.FALSE
                    , i_inst_id             => i_inst_id
                );

            else
                trc_log_pkg.debug(
                    i_text          => 'Empty cycle value of attribute [#1]; service_id [#2], product_id [#3]'
                  , i_env_param1    => attr.attribute_name
                  , i_env_param2    => i_service_id
                  , i_env_param3    => i_product_id
                );
            end if;

        when fcl_api_const_pkg.ENTITY_TYPE_LIMIT then
            if attr.value_limit is not null then
                prd_api_attribute_value_pkg.set_attr_value_limit (
                    io_attr_value_id        => l_attr_value_id
                    , i_service_id          => i_service_id
                    , i_entity_type         => l_entity_type
                    , i_object_id           => l_object_id
                    , i_attr_name           => attr.attribute_name
                    , i_mod_id              => attr.mod_id
                    , i_start_date          => attr.start_date
                    , i_end_date            => attr.end_date
                    , i_limit_id            => make_limit(i_inst_id => i_inst_id, i_xml => attr.value_limit, i_limit_type => attr.object_type)
                    , i_check_start_date    => com_api_const_pkg.FALSE
                    , i_inst_id             => i_inst_id
                );

            else
                trc_log_pkg.debug(
                    i_text          => 'Empty limit value of attribute [#1]; service_id [#2], product_id [#3]'
                  , i_env_param1    => attr.attribute_name
                  , i_env_param2    => i_service_id
                  , i_env_param3    => i_product_id
                );
            end if;

        when fcl_api_const_pkg.ENTITY_TYPE_FEE then
            if attr.value_fee is not null then
                prd_api_attribute_value_pkg.set_attr_value_fee (
                    io_attr_value_id        => l_attr_value_id
                    , i_service_id          => i_service_id
                    , i_entity_type         => l_entity_type
                    , i_object_id           => l_object_id
                    , i_attr_name           => attr.attribute_name
                    , i_mod_id              => attr.mod_id
                    , i_start_date          => attr.start_date
                    , i_end_date            => attr.end_date
                    , i_fee_id              => make_fee(i_inst_id => i_inst_id, i_xml => attr.value_fee, i_fee_type => attr.object_type)
                    , i_check_start_date    => com_api_const_pkg.FALSE
                    , i_inst_id             => i_inst_id
                );

            else
                trc_log_pkg.debug(
                    i_text          => 'Empty fee value of attribute [#1]; service_id [#2], product_id [#3]'
                  , i_env_param1    => attr.attribute_name
                  , i_env_param2    => i_service_id
                  , i_env_param3    => i_product_id
                );
            end if;

        else
            case attr.data_type
            when com_api_const_pkg.DATA_TYPE_NUMBER then
                if attr.value_num is not null then
                    prd_api_attribute_value_pkg.set_attr_value_num (
                          io_id                 => l_attr_value_id
                        , i_service_id          => i_service_id
                        , i_entity_type         => l_entity_type
                        , i_object_id           => l_object_id
                        , i_attr_name           => attr.attribute_name
                        , i_mod_id              => attr.mod_id
                        , i_start_date          => attr.start_date
                        , i_end_date            => attr.end_date
                        , i_value               => to_number(attr.value_num, com_api_const_pkg.XML_FLOAT_FORMAT)
                        , i_check_start_date    => com_api_const_pkg.FALSE
                        , i_inst_id             => i_inst_id
                    );

                else
                    trc_log_pkg.debug(
                        i_text          => 'Empty number value of attribute [#1]; service_id [#2], product_id [#3]'
                      , i_env_param1    => attr.attribute_name
                      , i_env_param2    => i_service_id
                      , i_env_param3    => i_product_id
                    );
                end if;

            when com_api_const_pkg.DATA_TYPE_CHAR then
                if attr.value_char is not null then
                    prd_api_attribute_value_pkg.set_attr_value_char (
                          io_id                 => l_attr_value_id
                        , i_service_id          => i_service_id
                        , i_entity_type         => l_entity_type
                        , i_object_id           => l_object_id
                        , i_attr_name           => attr.attribute_name
                        , i_mod_id              => attr.mod_id
                        , i_start_date          => attr.start_date
                        , i_end_date            => attr.end_date
                        , i_value               => attr.value_char
                        , i_check_start_date    => com_api_const_pkg.FALSE
                        , i_inst_id             => i_inst_id
                    );

                else
                    trc_log_pkg.debug(
                        i_text          => 'Empty char value of attribute [#1]; service_id [#2], product_id [#3]'
                      , i_env_param1    => attr.attribute_name
                      , i_env_param2    => i_service_id
                      , i_env_param3    => i_product_id
                    );
                end if;

            when com_api_const_pkg.DATA_TYPE_DATE then
                if attr.value_date is not null then
                    prd_api_attribute_value_pkg.set_attr_value_date (
                          io_id                 => l_attr_value_id
                        , i_service_id          => i_service_id
                        , i_entity_type         => l_entity_type
                        , i_object_id           => l_object_id
                        , i_attr_name           => attr.attribute_name
                        , i_mod_id              => attr.mod_id
                        , i_start_date          => attr.start_date
                        , i_end_date            => attr.end_date
                        , i_value               => to_date(attr.value_date, com_api_const_pkg.XML_DATETIME_FORMAT)
                        , i_check_start_date    => com_api_const_pkg.FALSE
                        , i_inst_id             => i_inst_id
                    );

                else
                    trc_log_pkg.debug(
                        i_text          => 'Empty date value of attribute [#1]; service_id [#2], product_id [#3]'
                      , i_env_param1    => attr.attribute_name
                      , i_env_param2    => i_service_id
                      , i_env_param3    => i_product_id
                    );
                end if;

            else
                trc_log_pkg.error(
                    i_text          => 'Attribute [#1] has unsupported data type [#2]'
                  , i_env_param1    => attr.attribute_name
                  , i_env_param2    => attr.data_type
                );
                com_api_error_pkg.raise_error(
                    i_error         => 'WRONG_ATTRIBUTE_DATA_TYPE'
                );

            end case;

        end case;

    end loop;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_attribute_value finished'
    );

end;

procedure process_services(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_parent_id             in  com_api_type_pkg.t_short_id 
  , i_service_xml           in  xmltype
) is
    l_id                    com_api_type_pkg.t_short_id;
    l_product_service_id    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_initial_id            com_api_type_pkg.t_short_id;
    l_command               com_api_type_pkg.t_dict_value;
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    if i_service_xml is null then
        return;

    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_services'
    );

    for service in (
        select command
             , service_number
             , initial_service_number
             , min_count
             , max_count
             , attribute_value
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_service'
                passing i_service_xml
                columns
                    command                     varchar2(8)     path 'command'
                  , service_number              varchar2(200)   path 'service_number'
                  , initial_service_number      varchar2(200)   path 'initial_service_number'
                  , min_count                   number          path 'min_count'
                  , max_count                   number          path 'max_count'
                  , attribute_value             xmltype         path 'attribute_value'
                )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process service [#1]'
          , i_env_param1    => service.service_number
        );
        
        begin
            select id
                 , seqnum
              into l_id
                 , l_seqnum
              from prd_service
             where service_number = service.service_number
               and inst_id = i_inst_id;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Service not found by number [#1]'
                  , i_env_param1    => service.service_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );

        end;
        
        -- if service not defined on parent product, then raise error
        if i_parent_id is not null then

            select count(1)
              into l_count
              from prd_product_service
             where product_id = i_parent_id
               and service_id = l_id;
            
            if l_count = 0 then
                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND_ON_PRODUCT'
                  , i_env_param1    => l_id
                  , i_env_param2    => i_parent_id
                );
            end if;                
                
        end if;   
        
        if i_parent_id is not null and (service.initial_service_number is not null 
                                                  or service.min_count is not null 
                                                  or service.max_count is not null) then
            com_api_error_pkg.raise_error(
                i_error         => 'ATTR_MUST_DEFINED_ON_PARENT_PRODUCT'
              , i_env_param1    => l_id
              , i_env_param2    => i_parent_id
            );        
        end if;
        
        if service.initial_service_number is not null then
            select id
              into l_initial_id
              from prd_service
             where service_number = service.initial_service_number
               and inst_id = i_inst_id;
        else
            l_initial_id := null;

        end if;

        begin
            select ps.id
              into l_product_service_id
              from prd_product_service ps
                 , prd_service s
             where ps.service_id = s.id
               and s.inst_id = i_inst_id
               and s.id = l_id
               and ps.product_id = i_product_id;

            trc_log_pkg.debug(
                i_text          => 'Service [#1] have been found on product [#2]; l_product_service_id [#3]'
              , i_env_param1    => l_id
              , i_env_param2    => i_product_id
              , i_env_param3    => l_product_service_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Service [#1] have not been found on product [#2]'
                  , i_env_param1    => l_id
                  , i_env_param2    => i_product_id
                );
                l_product_service_id := null;
        end;

        l_command   := nvl(service.command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );

        if l_product_service_id is null then
    
            l_seqnum    := 1;
    
            if l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
              , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                prd_ui_product_pkg.add_product_service (
                      o_id          => l_product_service_id
                    , o_seqnum      => l_seqnum
                    , i_parent_id   => l_initial_id
                    , i_service_id  => l_id
                    , i_product_id  => i_product_id
                    , i_min_count   => nvl(service.min_count, 0)
                    , i_max_count   => nvl(service.max_count, 999)
                );

                process_attribute_value(
                    i_inst_id           => i_inst_id
                  , i_product_id        => i_product_id
                  , i_service_id        => l_id
                  , i_attribute_xml     => service.attribute_value
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                process_attribute_value(
                    i_inst_id           => i_inst_id
                  , i_product_id        => i_product_id
                  , i_service_id        => l_id
                  , i_attribute_xml     => service.attribute_value
                );

            end if;

        else
            if l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_PRODUCT_SERVICE'
                  , i_env_param1    => l_id
                  , i_env_param2    => i_product_id
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                prd_ui_product_pkg.modify_product_service (
                    i_id            => l_product_service_id
                  , io_seqnum       => l_seqnum
                  , i_product_id    => i_product_id
                  , i_min_count     => service.min_count
                  , i_max_count     => service.max_count
                );

                process_attribute_value(
                    i_inst_id           => i_inst_id
                  , i_product_id        => i_product_id
                  , i_service_id        => l_id
                  , i_attribute_xml     => service.attribute_value
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                process_attribute_value(
                    i_inst_id           => i_inst_id
                  , i_product_id        => i_product_id
                  , i_service_id        => l_id
                  , i_attribute_xml     => service.attribute_value
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                prd_ui_product_pkg.remove_product_service(
                    i_id            => l_product_service_id
                  , i_seqnum        => 0
                  , i_product_id    => i_product_id
                );

            end if;

        end if;

    end loop;

end process_services;

procedure process_account_types(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_account_type_xml      in  xmltype
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_account_type_id   com_api_type_pkg.t_short_id;
    l_command                   com_api_type_pkg.t_dict_value;
begin
    if i_account_type_xml is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_account_types'
    );

    for account_types in (
        select command
             , account_type
             , currency
             , service_number
             , aval_algorithm
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_account_type'
                passing i_account_type_xml
                columns
                    command                     varchar2(8)     path 'command'
                  , account_type                varchar2(8)     path 'account_type'
                  , currency                    varchar2(3)     path 'currency'
                  , service_number              varchar2(200)   path 'service_number'
                  , aval_algorithm              varchar2(8)     path 'aval_algorithm'
                )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process account_type [#1], service_number [#2], currency [#3] for product_id [#4]'
          , i_env_param1    => account_types.account_type
          , i_env_param2    => account_types.service_number
          , i_env_param3    => account_types.currency
          , i_env_param4    => i_product_id
        );

        begin
            select s.id
              into l_service_id 
              from prd_service s, prd_product_service p, prd_service_type t 
             where s.service_number = account_types.service_number
               and s.id = p.service_id 
               and t.id = s.service_type_id
               and t.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and p.product_id = i_product_id
               and t.is_initial = com_api_type_pkg.TRUE
               and s.inst_id = i_inst_id
             connect by prior p.id = p.parent_id 
               start with p.parent_id is null;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Service not found by number [#1]'
                  , i_env_param1    => account_types.service_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );

        end;

        begin
            select pat.id
              into l_product_account_type_id
              from acc_product_account_type pat
             where pat.product_id = i_product_id
               and pat.account_type = account_types.account_type
               and pat.currency = account_types.currency
               and pat.service_id = l_service_id;

            trc_log_pkg.debug(
                i_text          => 'Account type [#1] for service [#2] and currency [#3] have been found on product [#4]; l_product_account_type_id [#5]'
              , i_env_param1    => account_types.account_type
              , i_env_param2    => l_service_id
              , i_env_param3    => account_types.currency
              , i_env_param4    => i_product_id
              , i_env_param5    => l_product_account_type_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Account type [#1] for service [#2] and currency [#3] have not been found on product [#4]'
                  , i_env_param1    => account_types.account_type
                  , i_env_param2    => l_service_id
                  , i_env_param3    => account_types.currency
                  , i_env_param4    => i_product_id
                );
                l_product_account_type_id := null;
        end;

        l_command   := nvl(account_types.command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );

        if l_product_account_type_id is null then
            if l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_TYPE_NOT_FOUND'
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
              , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                acc_ui_product_account_pkg.add_product_account_type (
                    o_id               => l_product_account_type_id
                    , i_product_id     => i_product_id
                    , i_account_type   => account_types.account_type
                    , i_scheme_id      => null
                    , i_currency       => account_types.currency
                    , i_service_id     => l_service_id
                    , i_aval_algorithm => account_types.aval_algorithm
                );
            end if;

        else
            if l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_TYPE_OF_PRODUCT_ALREADY_EXISTS'
                  , i_env_param1    => account_types.account_type
                  , i_env_param2    => i_product_id
                  , i_env_param3    => account_types.currency
                  , i_env_param4    => l_service_id
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                acc_ui_product_account_pkg.modify_product_account_type (
                    i_id               => l_product_account_type_id
                    , i_product_id     => i_product_id
                    , i_account_type   => account_types.account_type
                    , i_scheme_id      => null
                    , i_currency       => account_types.currency
                    , i_service_id     => l_service_id
                    , i_aval_algorithm => account_types.aval_algorithm
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                acc_ui_product_account_pkg.remove_product_account_type (
                    i_id               => l_product_account_type_id
                );
            end if;

        end if;

    end loop;

end process_account_types;

procedure process_card_types(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_card_type_xml         in  xmltype
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_card_type_id      com_api_type_pkg.t_short_id;
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_command                   com_api_type_pkg.t_dict_value;
    l_bin_id                    com_api_type_pkg.t_short_id;
    l_index_range_id            com_api_type_pkg.t_short_id;
    l_number_format_id          com_api_type_pkg.t_tiny_id;
    l_count                     com_api_type_pkg.t_short_id;
    l_perso_method_id           com_api_type_pkg.t_tiny_id;
begin
    if i_card_type_xml is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_card_types'
    );

    for card_types in (
        select command
             , card_type_id
             , seq_number_low
             , seq_number_high
             , bin
             , index_range_id
             , number_format_id
             , emv_appl_scheme_id
             , pin_request
             , pin_mailer_request
             , embossing_request
             , status
             , perso_priority
             , reiss_command
             , reiss_start_date_rule
             , reiss_expir_date_rule
             , reiss_card_type_id
             , reiss_contract_id
             , blank_type_id
             , state
             , perso_method_id
             , service_number
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_card_type'
                passing i_card_type_xml
                columns
                    command                     varchar2(8)     path 'command'
                  , card_type_id                number          path 'card_type_id'
                  , seq_number_low              number          path 'seq_number_low'
                  , seq_number_high             number          path 'seq_number_high'
                  , bin                         varchar2(6)     path 'bin'
                  , index_range_id              number          path 'index_range_id'
                  , number_format_id            number          path 'number_format_id'
                  , emv_appl_scheme_id          number          path 'emv_appl_scheme_id'
                  , pin_request                 varchar2(8)     path 'pin_request'
                  , pin_mailer_request          varchar2(8)     path 'pin_mailer_request'
                  , embossing_request           varchar2(8)     path 'embossing_request'
                  , status                      varchar2(8)     path 'status'
                  , perso_priority              varchar2(8)     path 'perso_priority'
                  , reiss_command               varchar2(8)     path 'reiss_command'
                  , reiss_start_date_rule       varchar2(8)     path 'reiss_start_date_rule'
                  , reiss_expir_date_rule       varchar2(8)     path 'reiss_expir_date_rule'
                  , reiss_card_type_id          number          path 'reiss_card_type_id'
                  , reiss_contract_id           number          path 'reiss_contract_id'
                  , blank_type_id               number          path 'blank_type_id'
                  , state                       varchar2(8)     path 'state'
                  , perso_method_id             number          path 'perso_method_id'
                  , service_number              varchar2(200)   path 'service_number'
                )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process card_type [#1], service_number [#2], bin [#3] for product_id [#4]'
          , i_env_param1    => card_types.card_type_id
          , i_env_param2    => card_types.service_number
          , i_env_param3    => card_types.bin
          , i_env_param4    => i_product_id
        );

        begin
            select s.id
              into l_service_id 
              from prd_service s, prd_product_service p, prd_service_type t 
             where s.service_number = card_types.service_number
               and s.id = p.service_id 
               and t.id = s.service_type_id
               and t.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and p.product_id = i_product_id
               and t.is_initial = com_api_type_pkg.TRUE
               and s.inst_id = i_inst_id
             connect by prior p.id = p.parent_id 
               start with p.parent_id is null;

        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Service not found by number [#1]'
                  , i_env_param1    => card_types.service_number
                );

                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );

        end;

        begin
            select id
              into l_bin_id
              from iss_bin
             where bin = card_types.bin
               and card_type_id = card_types.card_type_id
               and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'BIN not found [#1]'
                  , i_env_param1    => card_types.bin
                );
                com_api_error_pkg.raise_error (
                    i_error      => 'BIN_IS_NOT_FOUND'
                  , i_env_param1 => card_types.bin
                );
        end;
        
        begin
            select id
              into l_index_range_id
              from iss_bin_index_range
             where bin_id = l_bin_id
               and index_range_id = card_types.index_range_id;
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'BIN_INDEX_RANGE not found [#1]'
                  , i_env_param1    => card_types.index_range_id
                );
                com_api_error_pkg.raise_error (
                    i_error         => 'BIN_INDEX_RANGE_NOT_FOUND_BY_ID'
                    , i_env_param1  => card_types.index_range_id
                );
        end;
        
        begin
            select id
              into l_number_format_id
              from rul_name_format
             where id = card_types.number_format_id
               and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
               and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Number format not found [#1]'
                  , i_env_param1    => card_types.number_format_id
                );
                com_api_error_pkg.raise_error (
                    i_error         => 'RUL_NAME_INDEX_PARAM_NOT_FOUND'
                    , i_env_param1  => card_types.number_format_id
                );
        end;
        
        select count(*)
          into l_count
          from emv_appl_scheme
         where (id = card_types.emv_appl_scheme_id or card_types.emv_appl_scheme_id is null)
           and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        
        if l_count = 0 and card_types.emv_appl_scheme_id is not null then
            trc_log_pkg.error(
                i_text          => 'Scheme of EMV card not found [#1]'
              , i_env_param1    => card_types.emv_appl_scheme_id
            );
            com_api_error_pkg.raise_error (
                i_error         => 'EMV_APPL_SCHEME_NOT_FOUND'
                , i_env_param1  => card_types.emv_appl_scheme_id
            );
        end if; 
        
        select count(*)
          into l_count
          from prs_blank_type
         where (id = card_types.blank_type_id or card_types.blank_type_id is null)
           and card_type_id = card_types.card_type_id
           and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
           
        if l_count = 0 and card_types.blank_type_id is not null then
            trc_log_pkg.error(
                i_text          => 'Card blank type not found [#1]'
              , i_env_param1    => card_types.blank_type_id
            );
            com_api_error_pkg.raise_error (
                i_error         => 'BLANK_TYPE_NOT_FOUND'
                , i_env_param1  => card_types.blank_type_id
            );
        end if; 
        
        begin
            select id
              into l_perso_method_id
              from prs_method
             where id = card_types.perso_method_id
               and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Method of card personalization not found [#1]'
                  , i_env_param1    => card_types.perso_method_id
                );
                com_api_error_pkg.raise_error (
                    i_error         => 'CARD_PERSONALIZATION_METHOD_NOT_FOUND'
                    , i_env_param1  => card_types.perso_method_id
                );
        end;
        
        begin
            select p.id, p.seqnum
              into l_product_card_type_id, l_seqnum
              from (select pct.id, pct.seq_number_low, pct.seqnum
                      from iss_product_card_type pct
                     where pct.product_id = i_product_id
                       and pct.card_type_id = card_types.card_type_id
                       and pct.service_id = l_service_id
                       and pct.bin_id = l_bin_id
                       and pct.index_range_id = card_types.index_range_id
                       and pct.perso_method_id = card_types.perso_method_id
                       and pct.number_format_id = card_types.number_format_id
                       and (pct.blank_type_id = card_types.blank_type_id or card_types.blank_type_id is null)
                       and (pct.emv_appl_scheme_id = card_types.emv_appl_scheme_id or card_types.emv_appl_scheme_id is null)
                       and pct.seq_number_low = card_types.seq_number_low
                   order by pct.seq_number_high) p
             where rownum = 1;

            trc_log_pkg.debug(
                i_text          => 'Card type [#1] for service [#2] have been found on product [#3]; l_product_card_type_id [#4]'
              , i_env_param1    => card_types.card_type_id
              , i_env_param2    => l_service_id
              , i_env_param3    => i_product_id
              , i_env_param4    => l_product_card_type_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Card type [#1] for service [#2] have not been found on product [#4]'
                  , i_env_param1    => card_types.card_type_id
                  , i_env_param2    => l_service_id
                  , i_env_param4    => i_product_id
                );
                l_product_card_type_id := null;
        end;

        l_command   := nvl(card_types.command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );


        if l_product_card_type_id is null then
            l_seqnum    := 1;
            if l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'CARD_TYPE_NOT_FOUND'
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
              , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                iss_ui_product_card_type_pkg.add_product_card_type (
                    o_id                        => l_product_card_type_id
                    , o_seqnum                  => l_seqnum
                    , i_product_id              => i_product_id
                    , i_card_type_id            => card_types.card_type_id
                    , i_seq_number_low          => card_types.seq_number_low
                    , i_seq_number_high         => card_types.seq_number_high
                    , i_bin_id                  => l_bin_id
                    , i_index_range_id          => card_types.index_range_id
                    , i_number_format_id        => card_types.number_format_id
                    , i_emv_appl_scheme_id      => card_types.emv_appl_scheme_id
                    , i_pin_request             => card_types.pin_request
                    , i_pin_mailer_request      => card_types.pin_mailer_request
                    , i_embossing_request       => card_types.embossing_request
                    , i_status                  => card_types.status
                    , i_perso_priority          => card_types.perso_priority
                    , i_reiss_command           => card_types.reiss_command
                    , i_reiss_start_date_rule   => card_types.reiss_start_date_rule
                    , i_reiss_expir_date_rule   => card_types.reiss_expir_date_rule
                    , i_reiss_card_type_id      => card_types.reiss_card_type_id
                    , i_reiss_contract_id       => card_types.reiss_contract_id
                    , i_blank_type_id           => card_types.blank_type_id
                    , i_state                   => card_types.state
                    , i_perso_method_id         => card_types.perso_method_id
                    , i_service_id              => l_service_id
                );
                
            end if;

        else
            if l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'CARD_TYPE_FOR_PRODUCT_ALREADY_EXISTS'
                  , i_env_param1    => card_types.card_type_id
                  , i_env_param2    => i_product_id
                  , i_env_param3    => l_service_id
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                iss_ui_product_card_type_pkg.modify_product_card_type (
                    i_id                        => l_product_card_type_id
                    , io_seqnum                 => l_seqnum
                    , i_product_id              => i_product_id
                    , i_card_type_id            => card_types.card_type_id
                    , i_seq_number_low          => card_types.seq_number_low
                    , i_seq_number_high         => card_types.seq_number_high
                    , i_bin_id                  => l_bin_id
                    , i_index_range_id          => card_types.index_range_id
                    , i_number_format_id        => card_types.number_format_id
                    , i_emv_appl_scheme_id      => card_types.emv_appl_scheme_id
                    , i_pin_request             => card_types.pin_request
                    , i_pin_mailer_request      => card_types.pin_mailer_request
                    , i_embossing_request       => card_types.embossing_request
                    , i_status                  => card_types.status
                    , i_perso_priority          => card_types.perso_priority
                    , i_reiss_command           => card_types.reiss_command
                    , i_reiss_start_date_rule   => card_types.reiss_start_date_rule
                    , i_reiss_expir_date_rule   => card_types.reiss_expir_date_rule
                    , i_reiss_card_type_id      => card_types.reiss_card_type_id
                    , i_reiss_contract_id       => card_types.reiss_contract_id
                    , i_blank_type_id           => card_types.blank_type_id
                    , i_state                   => card_types.state
                    , i_perso_method_id         => card_types.perso_method_id
                    , i_service_id              => l_service_id
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                iss_ui_product_card_type_pkg.remove_product_card_type (
                    i_id                        => l_product_card_type_id
                    , i_seqnum                  => l_seqnum
                );
            end if;

        end if;

    end loop;

end process_card_types;

procedure process_notes(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_note_xml              in  xmltype
) is
    l_note_id                   com_api_type_pkg.t_long_id;
begin
    if i_note_xml is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_notes'
    );

    for notes in (
        select note_type
             , lang
             , note_header
             , note_text
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_note'
                passing i_note_xml
                columns
                    note_type                   varchar2(8)     path 'note_type'
                  , lang                        varchar2(8)     path 'lang'
                  , note_header                 varchar2(4000)  path 'note_header'
                  , note_text                   varchar2(4000)  path 'note_text'
                )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process note for note_type [#1] for product_id [#2]'
          , i_env_param1    => notes.note_type
          , i_env_param2    => i_product_id
        );
        
        ntb_ui_note_pkg.add (
            o_id                    => l_note_id
            , i_entity_type         => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
            , i_object_id           => i_product_id
            , i_note_type           => notes.note_type
            , i_lang                => notes.lang
            , i_header              => notes.note_header
            , i_text                => notes.note_text
        );

    end loop;

end process_notes;

procedure process_schemes(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_scheme_xml            in  xmltype
) is
    l_scheme_id                 com_api_type_pkg.t_tiny_id;
    l_scheme_object_id          com_api_type_pkg.t_long_id;
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_command                   com_api_type_pkg.t_dict_value;
begin
    if i_scheme_xml is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_schemes'
    );

    for schemes in (
        select command
             , scheme_id
             , to_date(start_date, com_api_const_pkg.XML_DATETIME_FORMAT) start_date
             , to_date(end_date, com_api_const_pkg.XML_DATETIME_FORMAT) end_date
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_scheme'
                passing i_scheme_xml
                columns
                    command                     varchar2(8)     path 'command'
                  , scheme_id                   number          path 'scheme_id'
                  , start_date                  varchar2(20)    path 'start_date'
                  , end_date                    varchar2(20)    path 'end_date'
                )
    ) loop
        trc_log_pkg.debug(
            i_text          => 'Process scheme [#1] for product_id [#2]'
          , i_env_param1    => schemes.scheme_id
          , i_env_param2    => i_product_id
        );
        
        begin
            select id
              into l_scheme_id
              from aup_scheme
             where id = schemes.scheme_id;
        exception
            when no_data_found then
                trc_log_pkg.error(
                    i_text          => 'Scheme not found [#1]'
                  , i_env_param1    => schemes.scheme_id
                );
                com_api_error_pkg.raise_error (
                    i_error         => 'AUTH_SCHEME_NOT_FOUND'
                );
        end;
        
        begin
            select id, seqnum
              into l_scheme_object_id, l_seqnum
              from aup_scheme_object
             where object_id = i_product_id
               and entity_type = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
               and scheme_id = schemes.scheme_id
               and start_date = schemes.start_date;

            trc_log_pkg.debug(
                i_text          => 'Scheme [#1] have been found on product [#2]; l_scheme_object_id [#3]'
              , i_env_param1    => schemes.scheme_id
              , i_env_param2    => i_product_id
              , i_env_param3    => l_scheme_object_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Scheme [#1] have not been found on product [#2]'
                  , i_env_param1    => schemes.scheme_id
                  , i_env_param2    => i_product_id
                );
                l_scheme_object_id := null;
        end;

        l_command   := nvl(schemes.command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );

        if l_scheme_object_id is null then
            l_seqnum := 1;
            if l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'AUTH_SCHEME_NOT_FOUND'
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
              , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
              , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
            ) then
                aup_ui_scheme_pkg.add_scheme_object(
                    o_scheme_object_id  => l_scheme_object_id
                  , o_seqnum            => l_seqnum
                  , i_scheme_id         => schemes.scheme_id
                  , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_object_id         => i_product_id
                  , i_start_date        => schemes.start_date
                  , i_end_date          => schemes.end_date
                );
            end if;

        else
            if l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
            ) then
                com_api_error_pkg.raise_error(
                    i_error         => 'SCHEME_IS_NOT_UNIQUE'
                  , i_env_param1    => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_env_param2    => i_product_id
                  , i_env_param3    => schemes.start_date
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
              , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
            ) then
                aup_ui_scheme_pkg.modify_scheme_object(
                    i_scheme_object_id  => l_scheme_object_id
                  , io_seqnum           => l_seqnum
                  , i_end_date          => schemes.end_date
                );
            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                aup_ui_scheme_pkg.remove_scheme_object(
                    i_scheme_object_id  => l_scheme_object_id
                  , i_seqnum            => l_seqnum
                );
            end if;

        end if;

    end loop;

end process_schemes;

procedure check_contract_type(
    i_product_id            in  com_api_type_pkg.t_short_id
  , i_old_contract_type     in  com_api_type_pkg.t_dict_value
  , i_new_contract_type     in  com_api_type_pkg.t_dict_value
) is
begin
    if i_old_contract_type is null
       or i_new_contract_type is null
       or i_old_contract_type != i_new_contract_type
    then
        com_api_error_pkg.raise_error(
            i_error         => 'WRONG_CONTRACT_TYPE_IN_FILE'
          , i_env_param1    => i_new_contract_type
          , i_env_param2    => i_product_id
          , i_env_param3    => i_old_contract_type
        );
    end if;
end;

procedure process_product(
    i_command               in  com_api_type_pkg.t_dict_value
  , i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_parent_id             in  com_api_type_pkg.t_short_id     default null
  , i_product_type          in  com_api_type_pkg.t_dict_value
  , i_contract_type         in  com_api_type_pkg.t_dict_value
  , i_product_number        in  com_api_type_pkg.t_name
  , i_product_status        in  com_api_type_pkg.t_dict_value
  , i_product_service       in  xmltype
  , i_product_name          in  xmltype
  , i_child_products        in  xmltype
  , i_product_account_type  in  xmltype
  , i_product_card_type     in  xmltype
  , i_product_note          in  xmltype
  , i_product_scheme        in  xmltype
) is
    l_id                    com_api_type_pkg.t_short_id;
    l_seqnum                com_api_type_pkg.t_seqnum;
    l_command_tab           com_api_type_pkg.t_dict_tab;
    l_lang_tab              com_api_type_pkg.t_dict_tab;
    l_label_tab             com_api_type_pkg.t_name_tab;
    l_description_tab       com_api_type_pkg.t_desc_tab;

    l_product_tab           t_product_tab;
    l_old_contract_type     com_api_type_pkg.t_dict_value;

    cursor name_cur is
        select pn.command
             , pn.lang
             , pn.label
             , pn.description
          from xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/product_name'
                passing i_product_name
                columns
                    command             varchar2(8)     path 'command'
                  , lang                varchar2(8)     path '@language'
                  , label               varchar2(200)   path 'label'
                  , description         varchar2(2000)  path 'description'
               ) pn;

    cursor product_cur is
        select x.command
             , x.product_type
             , x.contract_type
             , x.product_number
             , x.product_status
             , x.product_service
             , x.product_name
             , x.child_products
             , x.product_account_type
             , x.product_card_type
             , x.product_note
             , x.product_scheme
          from xmltable(
                    xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                  , '/product'
                    passing i_child_products
                    columns
                        command                   varchar2(8)     path 'command'
                      , product_type              varchar2(8)     path 'product_type'
                      , contract_type             varchar2(8)     path 'contract_type'
                      , product_number            varchar2(200)   path 'product_number'
                      , product_status            varchar2(8)     path 'product_status'
                      , product_service           xmltype         path 'product_service'
                      , product_name              xmltype         path 'product_name'
                      , child_products            xmltype         path 'product'
                      , product_account_type      xmltype         path 'product_account_type'
                      , product_card_type         xmltype         path 'product_card_type'
                      , product_note              xmltype         path 'product_note'
                      , product_scheme            xmltype         path 'product_scheme'
                 ) x;
begin
    trc_log_pkg.debug(
        i_text          => 'prd_prc_product_pkg.process_product [#1] [#2]; inst_id [#3]'
      , i_env_param1    => i_command
      , i_env_param2    => i_product_number
      , i_env_param3    => i_inst_id
    );

    begin
        select id
             , seqnum
             , contract_type
          into l_id
             , l_seqnum
             , l_old_contract_type
          from prd_product
         where product_number = i_product_number
           and inst_id = i_inst_id;

        trc_log_pkg.debug(
            i_text          => 'product found by number [#1]; id [#2]'
          , i_env_param1    => i_product_number
          , i_env_param2    => l_id
        );

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'product not found by number [#1]'
              , i_env_param1    => i_product_number
            );
    end;

    if l_id is null then
        if i_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'PRODUCT_NOT_FOUND'
              , i_env_param1    => i_product_number
            );

        elsif i_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
          , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        ) then
            open name_cur;
            fetch name_cur bulk collect
            into l_command_tab
               , l_lang_tab
               , l_label_tab
               , l_description_tab;
            close name_cur;

            if l_label_tab.count = 0 then
                com_api_error_pkg.raise_error(
                    i_error         => 'PRODUCT_NAME_NOT_DEFINED'
                  , i_env_param1    => i_product_number
                );

            end if;

            prd_ui_product_pkg.add_product (
                o_id                => l_id
              , o_seqnum            => l_seqnum
              , i_product_type      => i_product_type
              , i_contract_type     => i_contract_type
              , i_parent_id         => i_parent_id
              , i_inst_id           => i_inst_id
              , i_lang              => l_lang_tab(1)
              , i_label             => l_label_tab(1)
              , i_description       => l_description_tab(1)
              , i_status            => i_product_status
              , i_product_number    => i_product_number
            );

            for i in 2 .. l_label_tab.count loop
                l_seqnum    := 1;
                prd_ui_product_pkg.modify_product (
                    i_id            => l_id
                  , io_seqnum       => l_seqnum
                  , i_lang          => l_lang_tab(i)
                  , i_label         => l_label_tab(i)
                  , i_description   => l_description_tab(i)
                  , i_status        => i_product_status
                  , i_product_number=> i_product_number
                );

            end loop;

            process_services(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_parent_id         => i_parent_id 
             , i_service_xml       => i_product_service
            );

            process_account_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_account_type_xml  => i_product_account_type
            );

            process_card_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_card_type_xml     => i_product_card_type
            );

            process_notes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_note_xml          => i_product_note
            );

            process_schemes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_scheme_xml        => i_product_scheme
            );

            if i_child_products is not null then
                open product_cur;
                fetch product_cur bulk collect into l_product_tab;
                close product_cur;

                for i in 1 .. l_product_tab.count loop
                    process_product(
                        i_command                 => l_product_tab(i).command
                      , i_inst_id                 => i_inst_id
                      , i_parent_id               => l_id
                      , i_product_type            => l_product_tab(i).product_type
                      , i_contract_type           => l_product_tab(i).contract_type
                      , i_product_number          => l_product_tab(i).product_number
                      , i_product_status          => l_product_tab(i).product_status
                      , i_product_service         => l_product_tab(i).product_service
                      , i_product_name            => l_product_tab(i).product_name
                      , i_child_products          => l_product_tab(i).product
                      , i_product_account_type    => l_product_tab(i).product_account_type
                      , i_product_card_type       => l_product_tab(i).product_card_type
                      , i_product_note            => l_product_tab(i).product_note
                      , i_product_scheme          => l_product_tab(i).product_scheme
                    );

                end loop;

            end if;

        else
            trc_log_pkg.info(
                i_text          => 'Ignore product [#1]'
              , i_env_param1    => i_product_number
            );

        end if;

    else
        --product exists
        if i_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
        ) then
            com_api_error_pkg.raise_error(
                i_error         => 'PRODUCT_ALREADY_EXIST'
              , i_env_param1    => i_product_number
            );

        elsif i_command in (
            app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
          , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
        ) then
            prd_ui_product_pkg.remove_product(
                i_id            => l_id
              , i_seqnum        => l_seqnum--1
            );

        elsif i_command in (
            app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
          , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
        ) then
            check_contract_type(
                i_product_id        => l_id
              , i_old_contract_type => l_old_contract_type
              , i_new_contract_type => i_contract_type
            );

            open name_cur;
            fetch name_cur bulk collect
            into l_command_tab
               , l_lang_tab
               , l_label_tab
               , l_description_tab;
            close name_cur;

            for i in 1 .. l_label_tab.count loop
                --l_seqnum    := 1;
                prd_ui_product_pkg.modify_product (
                    i_id            => l_id
                  , io_seqnum       => l_seqnum
                  , i_lang          => l_lang_tab(i)
                  , i_label         => l_label_tab(i)
                  , i_description   => l_description_tab(i)
                  , i_status        => i_product_status
                  , i_product_number=> i_product_number
                );

            end loop;

            process_services(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_parent_id         => i_parent_id 
             , i_service_xml       => i_product_service
            );

            process_account_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_account_type_xml  => i_product_account_type
            );

            process_card_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_card_type_xml     => i_product_card_type
            );

            process_notes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_note_xml          => i_product_note
            );

            process_schemes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_scheme_xml        => i_product_scheme
            );

            if i_child_products is not null then
                open product_cur;
                fetch product_cur bulk collect into l_product_tab;
                close product_cur;

                for i in 1 .. l_product_tab.count loop
                    process_product(
                        i_command                 => l_product_tab(i).command
                      , i_inst_id                 => i_inst_id
                      , i_parent_id               => l_id
                      , i_product_type            => nvl(l_product_tab(i).product_type, i_product_type)
                      , i_contract_type           => nvl(l_product_tab(i).contract_type, i_contract_type)
                      , i_product_number          => l_product_tab(i).product_number
                      , i_product_status          => l_product_tab(i).product_status
                      , i_product_service         => l_product_tab(i).product_service
                      , i_product_name            => l_product_tab(i).product_name
                      , i_child_products          => l_product_tab(i).product
                      , i_product_account_type    => l_product_tab(i).product_account_type
                      , i_product_card_type       => l_product_tab(i).product_card_type
                      , i_product_note            => l_product_tab(i).product_note
                      , i_product_scheme          => l_product_tab(i).product_scheme
                    );

                end loop;

            end if;

        elsif i_command in (
            app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
          , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
        ) then
            check_contract_type(
                i_product_id        => l_id
              , i_old_contract_type => l_old_contract_type
              , i_new_contract_type => i_contract_type
            );

            process_services(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_parent_id         => i_parent_id 
             , i_service_xml       => i_product_service
            );

            process_account_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_account_type_xml  => i_product_account_type
            );

            process_card_types(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_card_type_xml     => i_product_card_type
            );

            process_notes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_note_xml          => i_product_note
            );

            process_schemes(
               i_inst_id           => i_inst_id
             , i_product_id        => l_id
             , i_scheme_xml        => i_product_scheme
            );

            if i_child_products is not null then
                open product_cur;
                fetch product_cur bulk collect into l_product_tab;
                close product_cur;

                for i in 1 .. l_product_tab.count loop
                    process_product(
                        i_command                 => l_product_tab(i).command
                      , i_inst_id                 => i_inst_id
                      , i_parent_id               => l_id
                      , i_product_type            => l_product_tab(i).product_type
                      , i_contract_type           => l_product_tab(i).contract_type
                      , i_product_number          => l_product_tab(i).product_number
                      , i_product_status          => l_product_tab(i).product_status
                      , i_product_service         => l_product_tab(i).product_service
                      , i_product_name            => l_product_tab(i).product_name
                      , i_child_products          => l_product_tab(i).product
                      , i_product_account_type    => l_product_tab(i).product_account_type
                      , i_product_card_type       => l_product_tab(i).product_card_type
                      , i_product_note            => l_product_tab(i).product_note
                      , i_product_scheme          => l_product_tab(i).product_scheme
                    );

                end loop;

            end if;

        else
            trc_log_pkg.info(
                i_text          => 'Ignore product [#1]'
              , i_env_param1    => i_product_number
            );

        end if;

    end if;

end process_product;

procedure import_products
is
    l_estimated_count       com_api_type_pkg.t_long_id := 0;
    l_processed_count       com_api_type_pkg.t_long_id := 0;
    l_excepted_count        com_api_type_pkg.t_long_id := 0;

begin
    savepoint read_products_start;

    trc_log_pkg.info(
        i_text          => 'prd_prc_product_pkg.import_products'
    );
    trc_log_pkg.debug(
        i_text          => 'container_id = ' || prc_api_session_pkg.get_container_id
    );

    prc_api_stat_pkg.log_start;

    select nvl(sum(product_count), 0)
      into l_estimated_count
      from prc_session_file s
         , prc_file_attribute a
         , prc_file f
         , xmltable(
                xmlnamespaces(default 'http://bpc.ru/SVXP/product')
              , '/products'
                passing s.file_xml_contents
                columns
                      product_count         number        path 'fn:count(product)'
              ) x
         where s.session_id = get_session_id
         and s.file_attr_id = a.id
           and f.id = a.file_id
           and f.file_type = prd_api_const_pkg.FILE_TYPE_PRODUCTS;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count  => l_estimated_count
      , i_measure          => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
    );

    if l_estimated_count > 0 then
        for prd in (
            select z.inst_id
                 , x.command
                 , x.product_type
                 , x.contract_type
                 , x.product_number
                 , x.product_status
                 , x.product_service
                 , x.product_name
                 , x.child_products
                 , x.product_account_type
                 , x.product_card_type
                 , x.product_note
                 , x.product_scheme
              from prc_session_file s
                 , prc_file_attribute a
                 , prc_file f
                 , xmltable(
                        xmlnamespaces('http://bpc.ru/SVXP/product' as "svxp")
                      , '/svxp:products'
                         passing  s.file_xml_contents
                         columns
                            inst_id               number        path 'svxp:inst_id'
                         ) z

                 , xmltable(
                        xmlnamespaces(default 'http://bpc.ru/SVXP/product')
                      , '/products/product'
                        passing s.file_xml_contents
                        columns
                            command               varchar2(8)     path 'command'
                          , product_type          varchar2(8)     path 'product_type'
                          , contract_type         varchar2(8)     path 'contract_type'
                          , product_number        varchar2(200)   path 'product_number'
                          , product_status        varchar2(8)     path 'product_status'
                          , product_service       xmltype         path 'product_service'
                          , product_name          xmltype         path 'product_name'
                          , child_products        xmltype         path 'product'
                          , product_account_type  xmltype         path 'product_account_type'
                          , product_card_type     xmltype         path 'product_card_type'
                          , product_note          xmltype         path 'product_note'
                          , product_scheme        xmltype         path 'product_scheme'
                     ) x
             where s.session_id = get_session_id
               and s.file_attr_id = a.id
               and f.id = a.file_id
               and f.file_type = prd_api_const_pkg.FILE_TYPE_PRODUCTS
        ) loop
            savepoint register_product_start;
            begin
                process_product(
                    i_command                => prd.command
                  , i_inst_id                => prd.inst_id
                  , i_product_type           => prd.product_type
                  , i_contract_type          => prd.contract_type
                  , i_product_number         => prd.product_number
                  , i_product_status         => prd.product_status
                  , i_product_service        => prd.product_service
                  , i_product_name           => prd.product_name
                  , i_child_products         => prd.child_products
                  , i_product_account_type   => prd.product_account_type
                  , i_product_card_type      => prd.product_card_type
                  , i_product_note           => prd.product_note
                  , i_product_scheme         => prd.product_scheme
                );

                l_processed_count := l_processed_count + 1;

            exception
                when others then
                    rollback to savepoint register_product_start;
                    if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                        l_excepted_count := l_excepted_count + 1;

                    else
                        raise;

                    end if;
            end;

            if mod(l_processed_count, 100) = 0 then
                prc_api_stat_pkg.log_current (
                    i_current_count     => l_processed_count
                  , i_excepted_count    => l_excepted_count
                );
            end if;

        end loop;

    else
        trc_log_pkg.info(
            i_text          => 'Nothing to import'
        );

    end if;

    prc_api_stat_pkg.log_end (
        i_excepted_total     => l_excepted_count
        , i_processed_total  => l_processed_count
        , i_result_code      => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    trc_log_pkg.info(
        i_text          => 'Import products finished'
    );

exception
    when others then
        rollback to savepoint read_products_start;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );

        end if;

        raise;
end;

/*
 * Generate XML block for cycle and his components.
 * @param i_cycle_id    - it's cycle id.
 */
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
             , xmlelement("cycle_trunc_type",  fc.trunc_type)
             , xmlelement("workdays_only",     fc.workdays_only)
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

/*
 * Generate XML block for limit and his components.
 * @param i_limit_id    - it's limit id.
 */
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
                    , xmlelement("limit_count_value",  fl.count_limit)
                    , xmlelement("limit_check_type",   fl.check_type)
                    , xmlelement("currency",           fl.currency)
                    , xmlelement("limit_base",         fl.limit_base)
                    , xmlelement("limit_rate",         fl.limit_rate)
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

/*
 * Generate XML block for service and his components.
 * @param i_product_id           - it is product id.
 * @param i_product_service_id   - it is product's service id.
 * @param i_service_id           - it is service id.
 * @param i_full_export          - full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 */
function generate_service_block(
    i_product_id          in     com_api_type_pkg.t_short_id
  , i_product_service_id  in     com_api_type_pkg.t_short_id
  , i_service_id          in     com_api_type_pkg.t_short_id
  , i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return xmltype
is
    DEFAULT_CHAR          constant com_api_type_pkg.t_name := '-';
    l_service_header      xmltype;
    l_service_block       xmltype;
begin

    if i_product_service_id is null then
        return null;
    end if;

    select
        xmlconcat(
            xmlelement("command",                  'CMMDCREX')
          , xmlelement("service_number",           s1.service_number)
          , (
                select xmlelement("initial_service_number", s2.service_number)
                  from prd_product_service  ps2
                     , prd_service          s2
                 where ps2.id = ps1.parent_id
                   and s2.id  = ps2.service_id
            )
          , xmlelement("min_count",                ps1.min_count)
          , xmlelement("max_count",                ps1.max_count)
        )  service_header
      , (  -- The attribute_value block is based on source code of the view prd_ui_product_attr_value_vw.
           select
               xmlagg(
                   xmlelement("attribute_value"
                     , xmlelement("attribute_name",     x.attr_name)
                     , xmlelement("start_date",    to_char(x.start_date, com_api_const_pkg.XML_DATETIME_FORMAT))
                     , case
                           when x.end_date is not null
                           then xmlelement("end_date"
                                         , to_char(x.end_date, com_api_const_pkg.XML_DATETIME_FORMAT)
                                )
                           else null
                       end
                     , case when x.data_type = com_api_const_pkg.DATA_TYPE_CHAR and x.attr_entity_type is null
                           then xmlelement("value_char", x.attr_value)
                           else null
                       end
                     , case when x.data_type = com_api_const_pkg.DATA_TYPE_NUMBER and x.attr_entity_type is null
                           then xmlelement("value_num"
                                         , to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT)
                                )
                           else null
                       end
                     , case when x.data_type = com_api_const_pkg.DATA_TYPE_DATE and x.attr_entity_type is null
                           then xmlelement("value_date"
                                         , to_char(to_date(x.attr_value, com_api_const_pkg.DATE_FORMAT), com_api_const_pkg.XML_DATETIME_FORMAT)
                                )
                           else null
                       end
                     , case x.attr_entity_type
                           when 'ENTTCYCL' 
                           then generate_cycle_block(
                                    i_cycle_id => to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT)
                                )
                           else null
                       end
                     , case x.attr_entity_type
                           when 'ENTTLIMT'
                           then generate_limit_block(
                                    i_limit_id => to_number(x.attr_value, com_api_const_pkg.NUMBER_FORMAT)
                                )
                           else null
                       end
                     , case x.attr_entity_type
                           when 'ENTTFEES'
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
                                                     , xmlelement("sum_threshold",         ft.sum_threshold)
                                                     , xmlelement("count_threshold",       ft.count_threshold)
                                                     , xmlelement("length_type",           ft.length_type)
                                                     , xmlelement("length_type_algorithm", ft.length_type_algorithm)
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
                     , case
                           when x.mod_id is not null
                           then xmlelement("mod_id", x.mod_id)
                           else null
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
                                              select 
                                                  case i_export_clear_pan
                                                      when com_api_const_pkg.FALSE
                                                      then o.card_number
                                                      else iss_api_token_pkg.decode_card_number(i_card_number => o.card_number) 
                                                  end
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
            from (
                select a.attr_name
                     , a.data_type
                     , a.definition_level
                     , a.entity_type  attr_entity_type
                     , v.mod_id
                     , v.start_date
                     , v.end_date
                     , v.attr_value
                     , v.entity_type
                     , v.object_id
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
               where ps.service_id     = i_service_id
                 and ps.product_id     = p.product_id
                 and ps.service_id     = s.id
                 and v.service_id      = s.id
                 and a.service_type_id = s.service_type_id
                 and i_eff_date       <= nvl(v.end_date, i_eff_date + 1)
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
                                             then decode(a.definition_level
                                                       , prd_api_const_pkg.ATTRIBUTE_DEFIN_LVL_SERVICE,
                                                         decode(p.top_flag
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
                 and p.parent_id      in (
                         case
                             when v.entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
                                 (
                                     select pc.product_id
                                       from prd_customer o, prd_contract pc
                                      where o.id  = v.object_id
                                        and pc.id = o.contract_id
                                        and (
                                                i_full_export = com_api_type_pkg.TRUE
                                                or exists (
                                                       select column_value
                                                         from table(cast(g_event_customer_id_tab as num_tab_tpt))
                                                        where column_value = o.id
                                                   )
                                        )
                                 )
                             when v.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
                                 (
                                     select pc.product_id
                                       from acc_account o, prd_contract pc
                                      where o.id  = v.object_id
                                        and pc.id = o.contract_id
                                        and (
                                                i_full_export = com_api_type_pkg.TRUE
                                                or exists (
                                                       select column_value
                                                         from table(cast(g_event_account_id_tab as num_tab_tpt))
                                                        where column_value = o.id
                                                   )
                                        )
                                 )
                             when v.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
                                 (
                                     select pc.product_id
                                       from iss_card o, prd_contract pc
                                      where o.id  = v.object_id
                                        and pc.id = o.contract_id
                                        and (
                                                i_full_export = com_api_type_pkg.TRUE
                                                or exists (
                                                       select column_value
                                                         from table(cast(g_event_card_id_tab as num_tab_tpt))
                                                        where column_value = o.id
                                                   )
                                        )
                                 )
                             when v.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
                                 (
                                     select pc.product_id
                                       from acq_merchant o, prd_contract pc
                                      where o.id  = v.object_id
                                        and pc.id = o.contract_id
                                        and (
                                                i_full_export = com_api_type_pkg.TRUE
                                                or exists (
                                                       select column_value
                                                         from table(cast(g_event_merchant_id_tab as num_tab_tpt))
                                                        where column_value = o.id
                                                   )
                                        )
                                 )
                             when v.entity_type = acq_api_const_pkg.ENTITY_TYPE_TERMINAL then
                                 (
                                     select pc.product_id
                                       from acq_terminal o, prd_contract pc
                                      where o.id  = v.object_id
                                        and pc.id = o.contract_id
                                        and (
                                                i_full_export = com_api_type_pkg.TRUE
                                                or exists (
                                                       select column_value
                                                         from table(cast(g_event_terminal_id_tab as num_tab_tpt))
                                                        where column_value = o.id
                                                   )
                                        )
                                 )
                             else
                                 p.parent_id
                         end
                    )
                ) x
        )  service_block
    into l_service_header
       , l_service_block
    from prd_product_service  ps1
       , prd_service          s1
   where ps1.id = i_product_service_id
     and s1.id  = ps1.service_id;


    -- If attributes block is empty and export mode is incremental then we don't output service block into XML file.
    if l_service_block is null and i_full_export = com_api_type_pkg.FALSE then
        l_service_block := null;
    else
        select xmlelement("product_service"
                 , l_service_header
                 , l_service_block
               )
          into l_service_block
          from dual;
    end if;

    return l_service_block;

exception
    when others then
        trc_log_pkg.error('Error when generate service block on service_id = ' || i_product_service_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_service_block;

/*
 * Generate XML block for product and his components.
 * @param i_full_export          – full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_inst_id              - export for this institution id.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 * @param i_product_id           – it's product id.
 */
function generate_product_block(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
  , i_product_id          in     com_api_type_pkg.t_short_id
) return xmltype
is
    l_product_block     xmltype;
begin

    if i_product_id is null then
        return null;
    end if;

    select xmlelement("product"
             , xmlelement("command",         'CMMDCREX')
             , xmlelement("product_type",    pp.product_type)
             , xmlelement("contract_type",   pp.contract_type)
             , xmlelement("product_number",  pp.product_number)
             , (select
                    xmlagg(
                        xmlelement("product_name"
                          , xmlattributes(l.lang as "language")
                          , xmlelement("command", 'CMMDCREX')
                          , xmlelement("label"
                                     , get_text(
                                           i_table_name  => 'prd_product'
                                         , i_column_name => 'label'
                                         , i_object_id   => pp.id
                                         , i_lang        => l.lang
                                      )
                            )
                          , xmlelement("description"
                                     , get_text(
                                           i_table_name  => 'prd_product'
                                         , i_column_name => 'description'
                                         , i_object_id   => pp.id
                                         , i_lang        => l.lang
                                      )
                            )
                        )
                    )
                 from com_language_vw l
               )
             , xmlelement("product_status",  pp.status)
             , (select
                    xmlagg(
                        generate_service_block(
                            i_product_id         => pp.id
                          , i_product_service_id => ps1.id
                          , i_service_id         => ps1.service_id
                          , i_full_export        => i_full_export
                          , i_eff_date           => i_eff_date
                          , i_export_clear_pan   => i_export_clear_pan
                        )
                    )
                  from prd_product_service ps1
                 where ps1.product_id = pp.id
               )
             , (select
                    xmlagg(
                        generate_product_block(
                             i_full_export        => i_full_export
                           , i_eff_date           => i_eff_date
                           , i_inst_id            => i_inst_id
                           , i_export_clear_pan   => i_export_clear_pan
                           , i_product_id         => pl.id
                         )
                    )
                  from prd_product pl
                 where pl.parent_id = pp.id
               )
           )  xml_block
      into l_product_block
      from prd_product pp
     where pp.id  = i_product_id
       and i_inst_id in (pp.inst_id, ost_api_const_pkg.DEFAULT_INST)
       and rownum = 1;

    return l_product_block;

exception
    when others then
        trc_log_pkg.error('Error when generate product block on product_id = ' || i_product_id);
        trc_log_pkg.error(sqlerrm);
        return null;
end generate_product_block;

/*
 * Get event id lists for next objects: product, customer, account, card, merchant, terminal.
 * @param i_inst_id             - export for this institution id.
 * @param i_export_date         - it's begin date of the export operation.
 * @param io_result_product_tab - it's the product id list which is generated by events.
 * @param io_result_event_tab   - it's the processed event id list.
 */
procedure get_event_list(
    i_inst_id              in       com_api_type_pkg.t_inst_id
  , i_export_date          in       date
  , io_result_product_tab  in out   nocopy num_tab_tpt
  , io_result_event_tab    in out   nocopy num_tab_tpt
)
is
    l_event_product_id_tab num_tab_tpt;
    l_product_id_tab       num_tab_tpt;

    -- Event id lists for next objects: product, customer, account, card, merchant, terminal.

    l_product_event_tab    num_tab_tpt;
    l_customer_event_tab   num_tab_tpt;
    l_account_event_tab    num_tab_tpt;
    l_card_event_tab       num_tab_tpt;
    l_merchant_event_tab   num_tab_tpt;
    l_terminal_event_tab   num_tab_tpt;

    -- Event product lists for next objects: customer, account, card, merchant, terminal.

    l_customer_product_tab num_tab_tpt;
    l_account_product_tab  num_tab_tpt;
    l_card_product_tab     num_tab_tpt;
    l_merchant_product_tab num_tab_tpt;
    l_terminal_product_tab num_tab_tpt;
begin

    -- Get product info.
    select eo.id
         , a.id
      bulk collect into l_product_event_tab
                      , l_event_product_id_tab
      from evt_event_object eo
         , prd_product a
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = prd_api_const_pkg.ENTITY_TYPE_PRODUCT
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

     -- Add parent and child products into product list.
     select p2.id
       bulk collect into l_product_id_tab
       from prd_product p2
       connect by prior p2.parent_id = p2.id
       start with             p2.id in (
                                           select column_value
                                             from table(cast(l_event_product_id_tab as num_tab_tpt))
                                       )
     union
     select p2.id
       from prd_product p2
       connect by prior p2.id = p2.parent_id
       start with      p2.id in (
                                    select column_value
                                      from table(cast(l_event_product_id_tab as num_tab_tpt))
                                );

    trc_log_pkg.debug(
        i_text          => 'incremental export products [#1]'
      , i_env_param1    => l_product_id_tab.count
    );

    -- Get customer info.
    select eo.id
         , a.id
         , c.product_id
      bulk collect into l_customer_event_tab
                      , g_event_customer_id_tab
                      , l_customer_product_tab
      from evt_event_object eo
         , prd_customer a
         , prd_contract c
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = com_api_const_pkg.ENTITY_TYPE_CUSTOMER
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and a.contract_id      = c.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text          => 'incremental export customers [#1]'
      , i_env_param1    => g_event_customer_id_tab.count
    );

    -- Get account info.
    select eo.id
         , a.id
         , c.product_id
      bulk collect into l_account_event_tab
                      , g_event_account_id_tab
                      , l_account_product_tab
      from evt_event_object eo
         , acc_account a
         , prd_contract c
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and a.contract_id      = c.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text          => 'incremental export accounts [#1]'
      , i_env_param1    => g_event_account_id_tab.count
    );

    -- Get card info.
    select eo.id
         , a.id
         , c.product_id
      bulk collect into l_card_event_tab
                      , g_event_card_id_tab
                      , l_card_product_tab
      from evt_event_object eo
         , iss_card a
         , prd_contract c
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD 
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and a.contract_id      = c.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text          => 'incremental export cards [#1]'
      , i_env_param1    => g_event_card_id_tab.count
    );

    -- Get merchant info.
    select eo.id
         , a.id
         , c.product_id
      bulk collect into l_merchant_event_tab
                      , g_event_merchant_id_tab
                      , l_merchant_product_tab
      from evt_event_object eo
         , acq_merchant a
         , prd_contract c
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = acq_api_const_pkg.ENTITY_TYPE_MERCHANT 
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and a.contract_id      = c.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text          => 'incremental export merchants [#1]'
      , i_env_param1    => g_event_merchant_id_tab.count
    );

    -- Get terminal info.
    select eo.id
         , a.id
         , c.product_id
      bulk collect into l_terminal_event_tab
                      , g_event_terminal_id_tab
                      , l_terminal_product_tab
      from evt_event_object eo
         , acq_terminal a
         , prd_contract c
     where decode(eo.status, 'EVST0001', eo.procedure_name, null) = 'PRD_PRC_PRODUCT_PKG.EXPORT_PRODUCTS'
       and eo.entity_type     = acq_api_const_pkg.ENTITY_TYPE_TERMINAL 
       and eo.eff_date       <= i_export_date
       and eo.object_id       = a.id
       and a.contract_id      = c.id
       and i_inst_id         in (eo.inst_id, ost_api_const_pkg.DEFAULT_INST);

    trc_log_pkg.debug(
        i_text          => 'incremental export terminals [#1]'
      , i_env_param1    => g_event_terminal_id_tab.count
    );

    -- Get product list of all events.
    select column_value
      bulk collect into io_result_product_tab
      from table(cast(l_product_id_tab as num_tab_tpt)) r, prd_product p
     where p.id = r.column_value
       and p.parent_id is null
    union
    select column_value
      from table(cast(l_customer_product_tab as num_tab_tpt))
    union
    select column_value
      from table(cast(l_account_product_tab as num_tab_tpt))
    union
    select column_value
      from table(cast(l_card_product_tab as num_tab_tpt))
    union
    select column_value
      from table(cast(l_merchant_product_tab as num_tab_tpt))
    union
    select column_value
      from table(cast(l_terminal_product_tab as num_tab_tpt));

    trc_log_pkg.debug(
        i_text          => 'incremental export result products [#1]'
      , i_env_param1    => io_result_product_tab.count
    );

    -- Get event list of all events.
    select column_value
      bulk collect into io_result_event_tab
      from table(cast(l_product_event_tab as num_tab_tpt))
    union all
    select column_value
      from table(cast(l_customer_event_tab as num_tab_tpt))
    union all
    select column_value
      from table(cast(l_account_event_tab as num_tab_tpt))
    union all
    select column_value
      from table(cast(l_card_event_tab as num_tab_tpt))
    union all
    select column_value
      from table(cast(l_merchant_event_tab as num_tab_tpt))
    union all
    select column_value
      from table(cast(l_terminal_event_tab as num_tab_tpt));

    trc_log_pkg.debug(
        i_text          => 'incremental export result events [#1]'
      , i_env_param1    => io_result_event_tab.count
    );

end get_event_list;

/*
 * Export product and his components into XML file.
 * Limitations: The complex tags <product_account_type> and <product_card_type> is not supported now.
 * @param i_full_export          – full export mode when com_api_const_pkg.TRUE,
 *                                 incremental export mode when com_api_const_pkg.FALSE.
 * @param i_eff_date             - effective date.
 * @param i_inst_id              - export for this institution id.
 * @param i_export_clear_pan     - if it is FALSE then process unloads undecoded PANs (tokens)
 *                                 for the case when Message Bus is capable to handle them.
 */
procedure export_products(
    i_full_export         in     com_api_type_pkg.t_boolean    default null
  , i_eff_date            in     date
  , i_inst_id             in     com_api_type_pkg.t_inst_id
  , i_export_clear_pan    in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
)
is
    LOG_PREFIX             constant com_api_type_pkg.t_name       := 'export_products';
    FILE_TYPE_PRODUCT      constant com_api_type_pkg.t_dict_value := 'FLTPPROD';
    DATETIME_FORMAT        constant com_api_type_pkg.t_name       := 'dd.mm.yyyy hh24:mi:ss';

    l_estimated_count      com_api_type_pkg.t_long_id             := 0;
    l_processed_count      com_api_type_pkg.t_long_id             := 0;
    l_sysdate              date;
    l_eff_date             date;
    l_sess_file_id         com_api_type_pkg.t_long_id;
    l_file                 clob;
    l_full_export          com_api_type_pkg.t_boolean;
    l_export_clear_pan     com_api_type_pkg.t_boolean;
    l_inst_id              com_api_type_pkg.t_inst_id;

    -- Result id lists for products and events.

    l_result_product_tab   num_tab_tpt;
    l_result_event_tab     num_tab_tpt;
begin
    savepoint sp_export_products;

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || ': Start'
    );

    prc_api_stat_pkg.log_start;

    l_sysdate             := com_api_sttl_day_pkg.get_sysdate;
    l_eff_date            := nvl(i_eff_date, l_sysdate);
    l_full_export         := nvl(i_full_export,      com_api_type_pkg.FALSE);
    l_inst_id             := nvl(i_inst_id,          ost_api_const_pkg.DEFAULT_INST);
    l_export_clear_pan    := nvl(i_export_clear_pan, com_api_const_pkg.TRUE);

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || ': l_sysdate [#1], l_full_export [#2], l_eff_date [#3] l_inst_id [#4] l_export_clear_pan [#5]'
      , i_env_param1    => to_char(l_sysdate,  DATETIME_FORMAT)
      , i_env_param2    => l_full_export
      , i_env_param3    => to_char(l_eff_date, DATETIME_FORMAT)
      , i_env_param4    => l_inst_id
      , i_env_param5    => l_export_clear_pan
    );

    if l_full_export = com_api_type_pkg.TRUE then
        -- Get all available products.
        select pp.id
          bulk collect into l_result_product_tab
          from prd_product pp
         where l_inst_id in (pp.inst_id, ost_api_const_pkg.DEFAULT_INST)
           and pp.parent_id is null;

        trc_log_pkg.debug(
            i_text          => 'full export products'
        );
    else
        -- Get all available products by object events.
        get_event_list(
            i_inst_id             => l_inst_id
          , i_export_date         => l_sysdate
          , io_result_product_tab => l_result_product_tab
          , io_result_event_tab   => l_result_event_tab
        );

        trc_log_pkg.debug(
            i_text          => 'incremental export products'
        );
    end if;

    l_estimated_count := l_result_product_tab.count;

    prc_api_stat_pkg.log_estimation (
        i_estimated_count  => l_estimated_count
      , i_measure          => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
    );

    trc_log_pkg.debug(
        i_text          => 'estimated root products [#1]'
      , i_env_param1    => l_estimated_count
    );

    -- Generate XML file.
    select '<?xml version="1.0" encoding="utf-8"?>'
        || CRLF
        || xmlelement("products"
             , xmlattributes('http://bpc.ru/sv/SVXP/product' as "xmlns")
             , xmlelement("file_type", FILE_TYPE_PRODUCT)
             , xmlelement("inst_id",   l_inst_id)
             , xmlagg(
                   generate_product_block(
                       i_full_export        => l_full_export
                     , i_eff_date           => l_eff_date
                     , i_inst_id            => l_inst_id
                     , i_export_clear_pan   => l_export_clear_pan
                     , i_product_id         => pp.id
                   )
               )
           ).getclobval()  xml_file
         , count(1)        cnt
      into l_file
         , l_processed_count
      from prd_product pp
     where pp.id in (
                        select column_value
                          from table(cast(l_result_product_tab as num_tab_tpt))
                    )
       and l_inst_id in (pp.inst_id, ost_api_const_pkg.DEFAULT_INST);


    -- Update statistic.

    trc_log_pkg.debug(
        i_text          => 'file length [#1], products exported [#2]'
      , i_env_param1    => length(l_file)
      , i_env_param2    => l_processed_count 
    );

    prc_api_stat_pkg.log_current(
        i_current_count   => l_processed_count
      , i_excepted_count  => 0
    );

    -- Save XML file if it exists.

    trc_log_pkg.debug(
        i_text          => 'before open file'
    );

    prc_api_file_pkg.open_file(
        o_sess_file_id => l_sess_file_id
      , i_file_type    => FILE_TYPE_PRODUCT
    );

    trc_log_pkg.debug(
        i_text          => 'l_sess_file_id [#1]'
      , i_env_param1    => l_sess_file_id  
    );

    prc_api_file_pkg.put_file(
        i_sess_file_id  => l_sess_file_id
      , i_clob_content  => l_file
    );
    prc_api_file_pkg.close_file(
        i_sess_file_id  => l_sess_file_id
      , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
      , i_record_count  => l_estimated_count
    );
    prc_api_stat_pkg.log_end(
        i_result_code   => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

    -- Mark events as processed.
    if l_full_export = com_api_type_pkg.FALSE then
        trc_log_pkg.debug(
            i_text          => 'events processed [#1]'
          , i_env_param1    => l_result_event_tab.count
        );

        -- In case of full export mode all elements of collection <l_event_tab> are null
        evt_api_event_pkg.process_event_object(
            i_event_object_id_tab => l_result_event_tab
        );
    end if;

    trc_log_pkg.debug(
        i_text          => LOG_PREFIX || ': Products exporting finished'
    );

exception
    when others then
        rollback to sp_export_products;

        prc_api_stat_pkg.log_end (
            i_result_code  => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );
        
        if l_sess_file_id is not null then
            prc_api_file_pkg.close_file (
                i_sess_file_id  => l_sess_file_id
              , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
            );
        end if;
        
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error         => 'UNHANDLED_EXCEPTION'
              , i_env_param1    => sqlerrm
            );
        end if;
        raise;

end export_products;

end prd_prc_product_pkg;
/
