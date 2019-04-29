create or replace package body iss_api_virtual_card_pkg is

    function issue_virtual_card (
        i_id                        in com_api_type_pkg.t_long_id default null
        , i_source_card_instance_id in com_api_type_pkg.t_medium_id
        , i_card_type_id            in com_api_type_pkg.t_tiny_id
        , io_expir_date             in out date
        , i_limit_type              in com_api_type_pkg.t_dict_value default null
        , i_usage_limit_count       in com_api_type_pkg.t_long_id
        , i_usage_limit_amount      in com_api_type_pkg.t_money
        , i_usage_limit_currency    in com_api_type_pkg.t_curr_code
        , i_account_id              in com_api_type_pkg.t_account_id
        , o_card_number             out com_api_type_pkg.t_card_number
        , o_card_id                 out com_api_type_pkg.t_medium_id
        , o_card_instance_id        out com_api_type_pkg.t_medium_id
        , o_pin_verify_method       out com_api_type_pkg.t_dict_value
        , o_cvv_required            out com_api_type_pkg.t_boolean
        , o_icvv_required           out com_api_type_pkg.t_boolean
        , o_pvk_index               out com_api_type_pkg.t_tiny_id
        , o_service_code            out com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_dict_value is
        l_source_card_id            com_api_type_pkg.t_medium_id;
        l_inst_id                   com_api_type_pkg.t_inst_id;
        l_card_number               com_api_type_pkg.t_card_number;
        l_card_instance_id          com_api_type_pkg.t_medium_id;
        l_limit_type                com_api_type_pkg.t_dict_value := i_limit_type;
        l_limit_id                  com_api_type_pkg.t_long_id;
        l_value_id                  com_api_type_pkg.t_long_id;
        l_split_hash                com_api_type_pkg.t_tiny_id;
        l_account_object_id         com_api_type_pkg.t_long_id;
        l_card_type                 iss_api_type_pkg.t_product_card_type_rec;
        l_params                    com_api_type_pkg.t_param_tab;
    begin
        if i_id is not null then
            trc_log_pkg.set_object(
                 i_entity_type  => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                 , i_object_id  => i_id
            );
        end if;

        trc_log_pkg.debug(
            i_text       => 'Request for issuing virtual card: io_expir_date [#1], i_limit_type [#2], '
                         || 'i_usage_limit_count [' || i_usage_limit_count || '], '
                         || 'i_usage_limit_amount [' || i_usage_limit_amount || '], '
                         || 'i_usage_limit_currency [' || i_usage_limit_currency || '], '
                         || 'i_account_id [' || i_account_id || '], '
                         || 'i_source_card_instance_id [' || i_source_card_instance_id || '], '
                         || 'i_card_type_id [' || i_card_type_id || ']'
          , i_env_param1 => io_expir_date
          , i_env_param2 => i_limit_type
        );

        for rec in (
            select
                c.id as card_id
                , c.inst_id
                , c.contract_id
                , c.cardholder_id
                , c.customer_id
                , i.cardholder_name
                , i.company_name
                , i.agent_id
                , c.split_hash
            from
                iss_card_instance i
                , iss_card c
            where
                i.id = i_source_card_instance_id
                and i.card_id = c.id
        ) loop
            -- Checking for existing a link between rec.card_id and i_account_id
            if i_account_id is not null and
                acc_api_account_pkg.account_object_exists(
                    i_account_id  => i_account_id
                  , i_entity_type => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_object_id   => rec.card_id
                ) = com_api_type_pkg.FALSE
            then
                com_api_error_pkg.raise_error(
                    i_error      => 'ACCOUNT_IS_NOT_LINKED_WITH_OBJECT'
                  , i_env_param1 => i_account_id
                  , i_env_param2 => iss_api_const_pkg.ENTITY_TYPE_CARD
                  , i_env_param3 => rec.card_id
                );                
            end if;

            l_card_type := iss_api_product_pkg.get_product_card_type (
                i_contract_id       => rec.contract_id
                , i_card_type_id    => i_card_type_id
            );
            trc_log_pkg.debug('Product''s service_id [' || l_card_type.service_id || '] for contract_id [' || rec.contract_id || ']');
            
            iss_api_card_pkg.issue (
                o_id                    => o_card_id
                , io_card_number        => l_card_number
                , o_card_instance_id    => l_card_instance_id
                , i_inst_id             => rec.inst_id
                , i_agent_id            => rec.agent_id
                , i_contract_id         => rec.contract_id
                , i_cardholder_id       => rec.cardholder_id
                , i_card_type_id        => i_card_type_id
                , i_customer_id         => rec.customer_id
                , i_category            => iss_api_const_pkg.CARD_CATEGORY_VIRTUAL
                , io_expir_date         => io_expir_date
                , i_cardholder_name     => rec.cardholder_name
                , i_company_name        => rec.company_name
                , i_service_id          => l_card_type.service_id
            );
            
            prd_ui_service_pkg.set_service_object (
                i_service_id     => l_card_type.service_id
                , i_contract_id  => rec.contract_id
                , i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
                , i_object_id    => o_card_id
                , i_start_date   => get_sysdate
                , i_end_date     => null
                , i_inst_id      => rec.inst_id
                , i_params       => l_params
            );

            l_source_card_id := rec.card_id;
            l_inst_id := rec.inst_id;
            o_card_number := l_card_number;
            o_card_instance_id := l_card_instance_id;
            l_split_hash := rec.split_hash;

            select
                m.pin_verify_method
                , m.cvv_required
                , m.icvv_required
                , m.pvk_index
                , m.service_code
            into
                o_pin_verify_method
                , o_cvv_required
                , o_icvv_required
                , o_pvk_index
                , o_service_code
            from
                iss_card_instance i
                , prs_method m
            where
                i.id = o_card_instance_id
                and i.perso_method_id = m.id;
        end loop;

        if o_card_id is not null then
            if i_account_id is null then
                acc_api_account_pkg.copy_account_object(
                    i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_source_object_id    => l_source_card_id
                    , i_object_id           => o_card_id
                    , i_split_hash          => l_split_hash
                );
            else
                acc_api_account_pkg.add_account_object (
                    i_account_id           => i_account_id
                    , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_object_id          => o_card_id
                    , o_account_object_id  => l_account_object_id
                );
            end if;
            
            -- set default limit type
            if l_limit_type is null then
                l_limit_type := iss_api_const_pkg.LIMIT_CARD_USAGE;
                trc_log_pkg.debug(
                    i_text       => 'Incoming limit type is NULL; default value [#1] will be used'
                  , i_env_param1 => l_limit_type
                );
            end if;

            fcl_ui_limit_pkg.add_limit(
                i_limit_type        => l_limit_type
              , i_cycle_id          => null
              , i_count_limit       => i_usage_limit_count
              , i_sum_limit         => i_usage_limit_amount
              , i_currency          => i_usage_limit_currency
              , i_posting_method    => acc_api_const_pkg.POSTING_METHOD_IMMEDIATE
              , i_inst_id           => l_inst_id
              , i_is_custom         => com_api_type_pkg.FALSE
              , i_limit_base        => null
              , i_limit_rate        => null
              , o_limit_id          => l_limit_id
            );

            prd_ui_attribute_value_pkg.set_attr_value_limit (
                io_attr_value_id    => l_value_id
                , i_service_id      => null
                , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                , i_object_id       => o_card_id
                , i_attr_name       => 'ISS_CARD_USAGE_LIMIT'
                , i_mod_id          => null
                , i_start_date      => null
                , i_end_date        => null
                , i_limit_id        => l_limit_id
            );
        end if;
        
        if i_id is not null then
            trc_log_pkg.clear_object;
        end if;
        
        return
            case when o_card_id is null then aup_api_const_pkg.RESP_CODE_ERROR 
                                        else aup_api_const_pkg.RESP_CODE_OK 
            end;
    end issue_virtual_card;

    function get_virtual_card_types (
        i_source_card_id            in com_api_type_pkg.t_medium_id
        , i_lang                    in com_api_type_pkg.t_dict_value
        , o_card_types              out com_api_type_pkg.t_card_type_tab
    )  return com_api_type_pkg.t_dict_value is
    begin
        select distinct
            ctp.id
            , ctp.name
        bulk collect into
            o_card_types
        from
            iss_card crd
            , prd_contract cnt
            , iss_product_card_type prd
            , net_ui_card_type_vw ctp
            , net_card_type_feature_vw ctf
        where
            crd.id = i_source_card_id
            and crd.contract_id = cnt.id
            and cnt.product_id = prd.product_id
            and prd.card_type_id = ctp.id
            and ctf.card_type_id = prd.card_type_id
            and ctf.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_VIRTUAL
            and ctp.lang = nvl(i_lang, com_api_const_pkg.DEFAULT_LANGUAGE);

        trc_log_pkg.debug (
            i_text              => 'Returning [#1] types of available virtual cards using language [#2]'
            , i_env_param1      => o_card_types.count
            , i_env_param2      => i_lang
        );

        if o_card_types.count > 0 then
            return aup_api_const_pkg.RESP_CODE_OK;
        else
            return aup_api_const_pkg.RESP_CODE_SERVICE_NOT_ALLOWED;
        end if;
    end get_virtual_card_types;
    
    procedure get_connected_virtual_cards (
        i_card_number       in  com_api_type_pkg.t_card_number
        , i_card_status     in  com_api_type_pkg.t_dict_value   default null
        , o_card_numbers    out com_api_type_pkg.t_card_number_tab
    ) is
        l_card_hash             com_api_type_pkg.t_long_id;
    begin
        l_card_hash := com_api_hash_pkg.get_card_hash(i_card_number);
        
        select distinct
            iss_api_token_pkg.decode_card_number(i_card_number => cn.card_number)
        bulk collect into
            o_card_numbers
        from
            iss_card c
            , iss_card_number cn
            , iss_card_instance i
            , acc_account_object o
            , net_card_type_feature f
        where
            o.object_id = c.id
            and o.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
            and cn.card_id = c.id
            and i.card_id = c.id
            and (i.status = i_card_status or i_card_status is null)
            and f.card_type_id = c.card_type_id
            and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_VIRTUAL
            and o.account_id in (
                select
                    o2.account_id
                from
                    iss_card c2
                    , iss_card_number cn2
                    , acc_account_object o2
                    , net_card_type_feature f2
                where
                    c2.card_hash = l_card_hash
                    and cn2.card_id = c2.id
                    and reverse(cn2.card_number) = reverse(iss_api_token_pkg.encode_card_number(i_card_number => i_card_number))
                    and o2.object_id = c2.id
                    and o2.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                    and f2.card_type_id(+) = c2.card_type_id
                    and f2.card_feature(+) != net_api_const_pkg.CARD_FEATURE_STATUS_VIRTUAL
            );
    end get_connected_virtual_cards;

    procedure add_limit_virtual_card(
        i_card_id                   in      com_api_type_pkg.t_long_id
      , i_service_id                in      com_api_type_pkg.t_medium_id
      , i_split_hash                in      com_api_type_pkg.t_tiny_id
      , i_inst_id                   in      com_api_type_pkg.t_tiny_id    
      , i_attr_name                 in      com_api_type_pkg.t_name         default null
      , i_limit_type                in      com_api_type_pkg.t_dict_value   default null
      , i_usage_limit_count         in      com_api_type_pkg.t_long_id      default null
      , i_usage_limit_amount        in      com_api_type_pkg.t_money        
      , i_usage_limit_currency      in      com_api_type_pkg.t_curr_code    default null
    ) is
        l_currency                  com_api_type_pkg.t_curr_code;
        l_limit_type                com_api_type_pkg.t_dict_value;
        l_limit_id                  com_api_type_pkg.t_long_id;
        l_value_id                  com_api_type_pkg.t_long_id;
        l_attr_name                 com_api_type_pkg.t_name;
    begin
        trc_log_pkg.debug(
            i_text       => 'add_limit_virtual_card start: '
                         || 'i_card_id [' || i_card_id || '], '
                         || 'i_service_id [' || i_service_id || '], '
                         || 'i_split_hash [' || i_split_hash || '], '
                         || 'i_inst_id [' || i_inst_id || '], '
                         || 'i_attr_name [' || i_attr_name || '], '
                         || 'i_limit_type [' || i_limit_type || '], '
                         || 'i_usage_limit_count [' || i_usage_limit_count || '], '
                         || 'i_usage_limit_amount [' || i_usage_limit_amount || '], '
                         || 'i_usage_limit_currency [' || i_usage_limit_currency || '], '
        );
    
        if nvl(i_usage_limit_amount, 0) > 0 then
            if i_usage_limit_currency is null then
                select currency
                  into l_currency
                  from acc_account_object a
                     , acc_account b
                 where a.object_id = i_card_id
                   and a.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                   and a.account_id = b.id
                   and rownum = 1;
            end if;
                
            -- set default limit type
            l_limit_type := i_limit_type; 
            if l_limit_type is null then
                l_limit_type := iss_api_const_pkg.LIMIT_CARD_USAGE;
                l_attr_name := 'ISS_CARD_USAGE_LIMIT';
                trc_log_pkg.debug(
                    i_text       => 'Incoming limit type is NULL; default value [#1] will be used'
                  , i_env_param1 => l_limit_type
                );
            else
                select attr_name
                  into l_attr_name
                  from prd_attribute
                 where entity_type = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
                   and object_type = l_limit_type;
            end if;

            fcl_ui_limit_pkg.add_limit(
                i_limit_type        => l_limit_type
              , i_cycle_id          => null
              , i_count_limit       => nvl(i_usage_limit_count, -1)
              , i_sum_limit         => i_usage_limit_amount
              , i_currency          => nvl(i_usage_limit_currency, l_currency)
              , i_posting_method    => acc_api_const_pkg.POSTING_METHOD_IMMEDIATE
              , i_inst_id           => i_inst_id
              , i_is_custom         => com_api_const_pkg.FALSE
              , i_limit_base        => null
              , i_limit_rate        => null
              , o_limit_id          => l_limit_id
            );

            prd_ui_attribute_value_pkg.set_attr_value_limit (
                io_attr_value_id    => l_value_id
                , i_service_id      => i_service_id
                , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                , i_object_id       => i_card_id
                , i_attr_name       => l_attr_name
                , i_mod_id          => null
                , i_start_date      => null
                , i_end_date        => null
                , i_limit_id        => l_limit_id
            );
        end if;
        trc_log_pkg.debug(
            i_text       => 'add_limit_virtual_card end'
        );
    end;
    
    procedure issue_virtual_card (
        i_card_instance_id          in      com_api_type_pkg.t_medium_id
      , i_card_type_id              in      com_api_type_pkg.t_tiny_id      default null
      , i_expir_date                in      date                            default null
      , i_limit_type                in      com_api_type_pkg.t_dict_value   default null
      , i_usage_limit_count         in      com_api_type_pkg.t_long_id      default null
      , i_usage_limit_amount        in      com_api_type_pkg.t_money        
      , i_usage_limit_currency      in      com_api_type_pkg.t_curr_code    default null
      , i_card_number               in      com_api_type_pkg.t_card_number  default null
      , i_account_id                in      com_api_type_pkg.t_medium_id    default null
    ) is
        l_card_id                   com_api_type_pkg.t_medium_id;
        l_card_number               com_api_type_pkg.t_card_number  := i_card_number;
        l_expir_date                date                            := i_expir_date;
        l_card_instance_id          com_api_type_pkg.t_medium_id;
        l_limit_type                com_api_type_pkg.t_dict_value   := i_limit_type;
        l_limit_id                  com_api_type_pkg.t_long_id;
        l_value_id                  com_api_type_pkg.t_long_id;
        l_card_type                 iss_api_type_pkg.t_product_card_type_rec;
        l_params                    com_api_type_pkg.t_param_tab;
        l_attr_name                 com_api_type_pkg.t_name;
        l_customer_id               com_api_type_pkg.t_medium_id;
        l_currency                  com_api_type_pkg.t_curr_code;
        l_card_type_id              com_api_type_pkg.t_tiny_id;
        l_account_object_id         com_api_type_pkg.t_medium_id;
    begin
        trc_log_pkg.debug(
            i_text       => 'Request for issuing virtual card: '
                         || 'i_expir_date [' || i_expir_date || '], '
                         || 'i_limit_type [' || i_limit_type || '], '
                         || 'i_usage_limit_count [' || i_usage_limit_count || '], '
                         || 'i_usage_limit_amount [' || i_usage_limit_amount || '], '
                         || 'i_usage_limit_currency [' || i_usage_limit_currency || '], '
                         || 'i_account_id [' || i_account_id || '], '
                         || 'i_card_instance_id [' || i_card_instance_id || '], '
                         || 'i_card_type_id [' || i_card_type_id || ']'
        );

        for r in (
            select c.id as card_id
                 , c.inst_id
                 , c.contract_id
                 , c.cardholder_id
                 , c.customer_id
                 , i.cardholder_name
                 , i.company_name
                 , i.agent_id
                 , c.split_hash
                 , t.product_id
              from iss_card_instance i
                 , iss_card c
                 , prd_contract t
             where i.id      = i_card_instance_id
               and i.card_id = c.id
               and c.contract_id = t.id
        ) loop
            -- Checking for existing a link between customer and account
            if i_account_id is not null then
                begin
                    select customer_id
                      into l_customer_id
                      from acc_account
                     where id = i_account_id;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error(
                            i_error      => 'ACCOUNT_NOT_FOUND'
                          , i_env_param1 => i_account_id
                        ); 
                end;     
                          
                if l_customer_id != r.customer_id then
                    com_api_error_pkg.raise_error(
                        i_error      => 'ACCOUNT_IS_NOT_LINKED_WITH_OBJECT'
                      , i_env_param1 => i_account_id
                      , i_env_param2 => prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
                      , i_env_param3 => r.customer_id
                    );                
                end if;
            end if;
            
            if i_card_type_id is null then
                begin
                    select a.card_type_id
                      into l_card_type_id
                      from iss_product_card_type a
                         , net_card_type_feature b
                     where r.product_id = a.product_id
                       and a.card_type_id = b.card_type_id
                       and b.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_VIRTUAL
                       and rownum = 1;
                exception
                    when no_data_found then
                        com_api_error_pkg.raise_error (
                            i_error             => 'UNDEFINED_CARD_TYPE_FOR_PRODUCT'
                            , i_env_param1      => r.product_id
                            , i_env_param2      => null
                            , i_env_param3      => null
                        );
                end;
            else
                l_card_type_id := i_card_type_id;
            end if;
            
            l_card_type := 
                iss_api_product_pkg.get_product_card_type (
                    i_contract_id       => r.contract_id
                  , i_card_type_id      => l_card_type_id
                );
            trc_log_pkg.debug('Product''s service_id [' || l_card_type.service_id || '] for contract_id [' || r.contract_id || ']');
            
            iss_api_card_pkg.issue (
                o_id                    => l_card_id
              , io_card_number          => l_card_number
              , o_card_instance_id      => l_card_instance_id
              , i_inst_id               => r.inst_id
              , i_agent_id              => r.agent_id
              , i_contract_id           => r.contract_id
              , i_cardholder_id         => r.cardholder_id
              , i_card_type_id          => l_card_type_id
              , i_customer_id           => r.customer_id
              , i_category              => iss_api_const_pkg.CARD_CATEGORY_VIRTUAL
              , io_expir_date           => l_expir_date
              , i_cardholder_name       => r.cardholder_name
              , i_company_name          => r.company_name
              , i_service_id            => l_card_type.service_id
            );
            
            prd_ui_service_pkg.set_service_object (
                i_service_id    => l_card_type.service_id
              , i_contract_id   => r.contract_id
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => l_card_id
              , i_start_date    => get_sysdate
              , i_end_date      => null
              , i_inst_id       => r.inst_id
              , i_params        => l_params
            );

            if i_account_id is null then
                acc_api_account_pkg.copy_account_object(
                    i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_source_object_id    => r.card_id
                    , i_object_id           => l_card_id
                    , i_split_hash          => r.split_hash
                );
            else
                acc_api_account_pkg.add_account_object (
                    i_account_id           => i_account_id
                    , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_object_id          => l_card_id
                    , o_account_object_id  => l_account_object_id
                );
            end if;
            
            if nvl(i_usage_limit_amount, 0) > 0 then
            
                add_limit_virtual_card(
                    i_card_id                   => l_card_id
                  , i_service_id                => l_card_type.service_id
                  , i_split_hash                => r.split_hash
                  , i_inst_id                   => r.inst_id    
                  , i_attr_name                 => l_attr_name
                  , i_limit_type                => i_limit_type
                  , i_usage_limit_count         => i_usage_limit_count
                  , i_usage_limit_amount        => i_usage_limit_amount       
                  , i_usage_limit_currency      => i_usage_limit_currency
                );                    
            end if;
        end loop;
        
    end;

    procedure reconnect_virtual_card (
        i_card_id                   in      com_api_type_pkg.t_long_id
      , i_parent_card_id            in      com_api_type_pkg.t_medium_id
      , i_customer_id               in      com_api_type_pkg.t_medium_id
      , i_contract_id               in      com_api_type_pkg.t_long_id
      , i_cardholder_id             in      com_api_type_pkg.t_long_id
      , i_expir_date                in      date                            default null
      , i_split_hash                in      com_api_type_pkg.t_tiny_id
      , i_card_type_id              in      com_api_type_pkg.t_tiny_id
      , i_inst_id                   in      com_api_type_pkg.t_tiny_id
      , i_limit_type                in      com_api_type_pkg.t_dict_value   default null
      , i_usage_limit_count         in      com_api_type_pkg.t_long_id      default null
      , i_usage_limit_amount        in      com_api_type_pkg.t_money        
      , i_usage_limit_currency      in      com_api_type_pkg.t_curr_code    default null
      , i_card_number               in      com_api_type_pkg.t_card_number  default null
      , i_account_id                in      com_api_type_pkg.t_medium_id    default null
    ) is
        l_card_type                       iss_api_type_pkg.t_product_card_type_rec;
        l_params                          com_api_type_pkg.t_param_tab;   
        l_account_object_id               com_api_type_pkg.t_medium_id;
        l_account_status                  com_api_type_pkg.t_dict_value;
        l_card_status                     com_api_type_pkg.t_dict_value;
        l_card_instance_id                com_api_type_pkg.t_medium_id;
    begin
        trc_log_pkg.debug(
            i_text       => 'Request for reconnect virtual card: '
                         || 'i_card_id [' || i_card_id || '], '
                         || 'i_parent_card_id [' || i_parent_card_id || '], '
                         || 'i_customer_id [' || i_customer_id || '], '
                         || 'i_contract_id [' || i_contract_id || '], '
                         || 'i_cardholder_id [' || i_cardholder_id || '], '
                         || 'i_split_hash [' || i_split_hash || '], '
                         || 'i_card_type_id [' || i_card_type_id || '], '
                         || 'i_limit_type [' || i_limit_type || '], '
                         || 'i_usage_limit_count [' || i_usage_limit_count || '], '
                         || 'i_usage_limit_amount [' || i_usage_limit_amount || '], '
                         || 'i_usage_limit_currency [' || i_usage_limit_currency || '], '
                         || 'i_account_id [' || i_account_id || '], '
                         || 'i_expir_date [' || i_expir_date || '], '
        );
        
        iss_api_card_pkg.reconnect_card(
            i_card_id                    => i_card_id
          , i_customer_id                => i_customer_id
          , i_contract_id                => i_contract_id
          , i_cardholder_id              => i_cardholder_id
          , i_cardholder_photo_file_name => null
          , i_cardholder_sign_file_name  => null
          , i_expir_date                 => i_expir_date
        );
        
        l_card_type := 
            iss_api_product_pkg.get_product_card_type (
                i_contract_id       => i_contract_id
              , i_card_type_id      => i_card_type_id
            );
        trc_log_pkg.debug('Product''s service_id [' || l_card_type.service_id || '] for contract_id [' || i_contract_id || ']');
        
        prd_ui_service_pkg.set_service_object (
            i_service_id    => l_card_type.service_id
          , i_contract_id   => i_contract_id
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id     => i_card_id
          , i_start_date    => get_sysdate
          , i_end_date      => null
          , i_inst_id       => i_inst_id
          , i_params        => l_params
        );

        if i_account_id is null then
            acc_api_account_pkg.copy_account_object(
                i_entity_type           => iss_api_const_pkg.ENTITY_TYPE_CARD
                , i_source_object_id    => i_parent_card_id
                , i_object_id           => i_card_id
                , i_split_hash          => i_split_hash
            );
        else
            if acc_api_account_pkg.account_object_exists(
                   i_account_id        => i_account_id
                 , i_entity_type       => iss_api_const_pkg.ENTITY_TYPE_CARD
                 , i_object_id         => i_card_id
               ) = com_api_const_pkg.TRUE then
                -- customer pool account reconnect 
                acc_api_account_pkg.reconnect_account(
                    i_account_id  => i_account_id
                  , i_customer_id => i_customer_id
                  , i_contract_id => i_contract_id
                );
                
                l_account_status := acc_api_const_pkg.ACCOUNT_STATUS_ACTIVE;
                evt_api_status_pkg.change_status(
                    i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
                  , i_entity_type    => acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
                  , i_object_id      => i_account_id
                  , i_new_status     => l_account_status
                  , i_reason         => null
                  , o_status         => l_account_status
                  , i_eff_date       => null
                  , i_raise_error    => com_api_const_pkg.TRUE
                  , i_register_event => com_api_const_pkg.TRUE
                  , i_params         => l_params
                );
            else
                for r in (
                    select id
                      from acc_account_object
                     where object_id   = i_card_id
                       and entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                ) 
                loop
                    acc_api_account_pkg.remove_account_object(i_account_object_id => r.id);
                end loop;
                
                acc_api_account_pkg.add_account_object(
                      i_account_id         => i_account_id
                    , i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
                    , i_object_id          => i_card_id
                    , o_account_object_id  => l_account_object_id
                );
                
                trc_log_pkg.debug(
                    i_text       => 'l_account_object_id = ' || l_account_object_id
                );
            end if;
        end if;
        
        l_card_instance_id := iss_api_card_instance_pkg.get_card_instance_id(i_card_id => i_card_id);
        
        l_card_status := 
            iss_api_card_instance_pkg.get_instance(
                i_id          => l_card_instance_id
              , i_raise_error => com_api_const_pkg.TRUE
            ).status;
        
        if l_card_status = iss_api_const_pkg.CARD_STATUS_ACTIVTION_REQIRED then
            evt_api_status_pkg.change_status(
                i_initiator      => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type    => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id      => l_card_instance_id
              , i_new_status     => iss_api_const_pkg.CARD_STATUS_VALID_CARD
              , i_inst_id        => i_inst_id
              , i_reason         => null
              , o_status         => l_card_status
              , i_raise_error    => com_api_const_pkg.TRUE
              , i_params         => l_params
            );     
        end if;
        
        if nvl(i_usage_limit_amount, 0) > 0 then
            add_limit_virtual_card(
                i_card_id                   => i_card_id
              , i_service_id                => l_card_type.service_id
              , i_split_hash                => i_split_hash
              , i_inst_id                   => i_inst_id    
              , i_attr_name                 => null
              , i_limit_type                => i_limit_type
              , i_usage_limit_count         => i_usage_limit_count
              , i_usage_limit_amount        => i_usage_limit_amount       
              , i_usage_limit_currency      => i_usage_limit_currency
            );        
        end if;
    end;

end;
/
