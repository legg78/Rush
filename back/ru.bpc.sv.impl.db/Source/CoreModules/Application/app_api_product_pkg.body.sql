create or replace package body app_api_product_pkg as
/*********************************************************
*  Application API product <br />
*  Created by Krukov E.(krukov@bpcsv.com)  at 12.02.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: APP_API_PRODUCT_PKG <br />
*  @headcom
**********************************************************/

procedure process_product(
    i_service_id    in  com_api_type_pkg.t_long_id
  , i_object_id     in  com_api_type_pkg.t_long_id
  , i_entity_type   in  com_api_type_pkg.t_dict_value
  , i_inst_id       in  com_api_type_pkg.t_inst_id
) is
begin

    for rec in (
        select pa.object_type as cycle_type
        from   prd_service_type   pst
             , prd_service        ps
             , prd_attribute      pa
        where  pa.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_CYCLE
        and    pst.entity_type    = i_entity_type
        and    ps.service_type_id = pst.id
        and    pa.service_type_id = pst.id
        and    ps.id              = i_service_id
        union all
        select c.cycle_type
        from   prd_service_type   pst
             , prd_service        ps
             , prd_attribute      pa
             , fcl_fee_type_vw    c
        where  ps.service_type_id = pst.id
        and    pa.service_type_id = pst.id
        and    ps.id              = i_service_id
        and    pst.entity_type    = i_entity_type
        and    c.fee_type         = pa.object_type
        and    c.cycle_type is not null
        and    pa.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
        and    i_entity_type      = nvl(c.entity_type, i_entity_type)
        union all
        select d.cycle_type
        from   prd_service_type   pst
             , prd_service        ps
             , prd_attribute      pa
             , fcl_limit_type_vw  d
        where  ps.service_type_id = pst.id
        and    pa.service_type_id = pst.id
        and    ps.id              = i_service_id
        and    pst.entity_type    = i_entity_type
        and    d.cycle_type       = pa.object_type
        and    d.cycle_type is not null
        and    pa.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
        and    i_entity_type      = nvl(d.entity_type, i_entity_type)
    ) loop
        fcl_api_cycle_pkg.add_cycle_counter(
            i_cycle_type        => rec.cycle_type
          , i_entity_type       => i_entity_type
          , i_object_id         => i_object_id
          , i_inst_id           => i_inst_id
        );
    end loop;

    for rec in (
        select pa.object_type as limit_type
        from   prd_service_type   pst
             , prd_service        ps
             , prd_attribute      pa
        where  ps.service_type_id = pst.id
        and    pa.service_type_id = pst.id
        and    ps.id              = i_service_id
        and    pst.entity_type    = i_entity_type
        and    pa.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_LIMIT
        union
        select c.limit_type
        from   prd_service_type   pst
             , prd_service        ps
             , prd_attribute      pa
             , fcl_fee_type_vw c
        where  ps.service_type_id = pst.id
        and    pa.service_type_id = pst.id
        and    ps.id              = i_service_id
        and    pst.entity_type    = i_entity_type
        and    pa.entity_type     = fcl_api_const_pkg.ENTITY_TYPE_FEE
        and   c.fee_type          = pa.object_type
        and   c.limit_type is not null
    ) loop
        fcl_api_limit_pkg.add_limit_counter(
            i_limit_type   =>  rec.limit_type
          , i_entity_type  =>  i_entity_type
          , i_object_id    =>  i_object_id
          , i_inst_id      =>  i_inst_id
        );
    end loop;
end process_product;

procedure attach_product_to_application(
    i_product_id    in            com_api_type_pkg.t_short_id
) is
    l_count                       com_api_type_pkg.t_count := 0;
begin
    if i_product_id is null then
        return;
    end if;

    select count(appl_id)
      into l_count
      from app_object
     where object_id    = i_product_id
       and appl_id      = app_api_application_pkg.get_appl_id
       and entity_type  = prd_api_const_pkg.ENTITY_TYPE_PRODUCT;

    trc_log_pkg.debug(
        i_text        => 'Attach product to the application: number of products [#1], product_id [#2], application_id [#3]'
      , i_env_param1  => l_count
      , i_env_param2  => i_product_id
      , i_env_param3  => app_api_application_pkg.get_appl_id
    );

    if l_count = 0 then
        app_api_appl_object_pkg.add_object(
            i_appl_id           => app_api_application_pkg.get_appl_id
          , i_entity_type       => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
          , i_object_id         => i_product_id
          , i_seqnum            => 1
        );
    end if;
end attach_product_to_application;

procedure process_attribute(
    i_object_id            in            com_api_type_pkg.t_long_id
  , i_inst_id              in            com_api_type_pkg.t_inst_id
  , i_entity_type          in            com_api_type_pkg.t_dict_value
  , i_service_id           in            com_api_type_pkg.t_short_id
  , i_product_id           in            com_api_type_pkg.t_short_id
  , i_appl_data_id         in            com_api_type_pkg.t_long_id
  , i_params               in            com_api_type_pkg.t_param_tab
) is
    l_id_tab                    com_api_type_pkg.t_number_tab;
begin
    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'ATTRIBUTE_VALUE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_service_pkg.process_attribute(
            i_object_id     => i_object_id
          , i_inst_id       => i_inst_id
          , i_entity_type   => i_entity_type
          , i_service_id    => i_service_id
          , i_product_id    => i_product_id
          , i_appl_data_id  => l_id_tab(i)
          , i_params        => i_params
        );
    end loop;
end process_attribute;

procedure process_services(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_parent_id             in  com_api_type_pkg.t_short_id 
  , i_appl_data_id          in  com_api_type_pkg.t_long_id
) is
    l_id                        com_api_type_pkg.t_short_id;
    l_product_service_id        com_api_type_pkg.t_short_id;
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_initial_id                com_api_type_pkg.t_short_id;
    l_command                   com_api_type_pkg.t_dict_value;
    l_count                     com_api_type_pkg.t_tiny_id;

    l_id_tab                    com_api_type_pkg.t_number_tab;
    l_service_number            com_api_type_pkg.t_name;
    l_initial_service_number    com_api_type_pkg.t_name;
    l_min_count                 com_api_type_pkg.t_tiny_id;
    l_max_count                 com_api_type_pkg.t_tiny_id;
    l_conditional_group         com_api_type_pkg.t_dict_value;
    l_params                    com_api_type_pkg.t_param_tab;
begin
    if i_appl_data_id is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'app_api_product_pkg.process_services - start'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PRODUCT_SERVICE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'COMMAND'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_command
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SERVICE_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_service_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'INITIAL_SERVICE_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_initial_service_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'MIN_COUNT'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_min_count
        );
        
        app_api_application_pkg.get_element_value(
            i_element_name   => 'MAX_COUNT'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_max_count
        );
        
        app_api_application_pkg.get_element_value(
            i_element_name   => 'CONDITIONAL_GROUP'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_conditional_group
        );

        -- attribute_value             xmltype         path 'attribute_value'

        begin
            select id
                 , seqnum
              into l_id
                 , l_seqnum
              from prd_service
             where service_number   = l_service_number
               and inst_id          = i_inst_id;
        exception
            when no_data_found then
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
        
        if  i_parent_id is not null
        and (l_initial_service_number is not null 
          or l_min_count is not null 
          or l_max_count is not null
            )
        then
            com_api_error_pkg.raise_error(
                i_error         => 'ATTR_MUST_DEFINED_ON_PARENT_PRODUCT'
              , i_env_param1    => l_id
              , i_env_param2    => i_parent_id
            );        
        end if;
        
        if l_initial_service_number is not null then
            select id
              into l_initial_id
              from prd_service
             where service_number   = l_initial_service_number
               and inst_id          = i_inst_id;
        else
            l_initial_id := null;
        end if;

        begin
            select ps.id
              into l_product_service_id
              from prd_product_service  ps
                 , prd_service          s
             where ps.service_id    = s.id
               and s.inst_id        = i_inst_id
               and s.id             = l_id
               and ps.product_id    = i_product_id;

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

        l_command   := nvl(l_command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );

        if l_product_service_id is null then
    
            l_seqnum := 1;
    
            if l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                            )
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                               , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                               , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE 
                               )
            then
                prd_ui_product_pkg.add_product_service(
                    o_id                => l_product_service_id
                  , o_seqnum            => l_seqnum
                  , i_parent_id         => l_initial_id
                  , i_service_id        => l_id
                  , i_product_id        => i_product_id
                  , i_min_count         => nvl(l_min_count, 0)
                  , i_max_count         => nvl(l_max_count, 999)
                  , i_conditional_group => l_conditional_group 
                );

                process_attribute(
                    i_object_id     => i_product_id
                  , i_inst_id       => i_inst_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_service_id    => l_id
                  , i_product_id    => i_product_id
                  , i_appl_data_id  => l_id_tab(i)
                  , i_params        => l_params
                );

            elsif l_command in (app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE)
            then
                process_attribute(
                    i_object_id     => i_product_id
                  , i_inst_id       => i_inst_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_service_id    => l_id
                  , i_product_id    => i_product_id
                  , i_appl_data_id  => l_id_tab(i)
                  , i_params        => l_params
                );

            end if;

        else
            if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'DUPLICATE_PRODUCT_SERVICE'
                  , i_env_param1    => l_id
                  , i_env_param2    => i_product_id
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                               , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                               )
            then
                prd_ui_product_pkg.modify_product_service(
                    i_id                => l_product_service_id
                  , io_seqnum           => l_seqnum
                  , i_product_id        => i_product_id
                  , i_min_count         => l_min_count
                  , i_max_count         => l_max_count
                  , i_conditional_group => l_conditional_group 
                );

                process_attribute(
                    i_object_id     => i_product_id
                  , i_inst_id       => i_inst_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_service_id    => l_id
                  , i_product_id    => i_product_id
                  , i_appl_data_id  => l_id_tab(i)
                  , i_params        => l_params
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                               , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                               )
            then
                process_attribute(
                    i_object_id     => i_product_id
                  , i_inst_id       => i_inst_id
                  , i_entity_type   => prd_api_const_pkg.ENTITY_TYPE_PRODUCT
                  , i_service_id    => l_id
                  , i_product_id    => i_product_id
                  , i_appl_data_id  => l_id_tab(i)
                  , i_params        => l_params
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                               , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                               )
            then
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
  , i_appl_data_id          in  com_api_type_pkg.t_long_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_account_type_id   com_api_type_pkg.t_short_id;
    l_command                   com_api_type_pkg.t_dict_value;
    l_account_type              com_api_type_pkg.t_dict_value;
    l_currency                  com_api_type_pkg.t_curr_code;
    l_service_number            com_api_type_pkg.t_name;
    l_aval_algorithm            com_api_type_pkg.t_dict_value;
    l_id_tab                    com_api_type_pkg.t_number_tab;
begin
    if i_appl_data_id is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'app_api_product_pkg.process_account_types - start'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PRODUCT_ACCOUNT_TYPE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'COMMAND'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_command
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'ACCOUNT_TYPE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_account_type
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CURRENCY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_currency
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SERVICE_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_service_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'AVAL_ALGORITHM'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_aval_algorithm
        );

        trc_log_pkg.debug(
            i_text          => 'Process account_type [#1], service_number [#2], currency [#3] for product_id [#4]'
          , i_env_param1    => l_account_type
          , i_env_param2    => l_service_number
          , i_env_param3    => l_currency
          , i_env_param4    => i_product_id
        );

        begin
            select s.id
              into l_service_id 
              from prd_service          s
                 , prd_product_service  p
                 , prd_service_type     t 
             where s.service_number = l_service_number
               and s.id             = p.service_id 
               and t.id             = s.service_type_id
               and t.entity_type    = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
               and p.product_id     = i_product_id
               and t.is_initial     = com_api_type_pkg.TRUE
               and s.inst_id        = i_inst_id
             connect by prior p.id  = p.parent_id 
               start with p.parent_id is null;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );
        end;

        begin
            select pat.id
              into l_product_account_type_id
              from acc_product_account_type pat
             where pat.product_id   = i_product_id
               and pat.account_type = l_account_type
               and pat.currency     = l_currency
               and pat.service_id   = l_service_id;

            trc_log_pkg.debug(
                i_text          => 'Account type [#1] for service [#2] and currency [#3] have been found on product [#4]; l_product_account_type_id [#5]'
              , i_env_param1    => l_account_type
              , i_env_param2    => l_service_id
              , i_env_param3    => l_currency
              , i_env_param4    => i_product_id
              , i_env_param5    => l_product_account_type_id
            );
        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Account type [#1] for service [#2] and currency [#3] have not been found on product [#4]'
                  , i_env_param1    => l_account_type
                  , i_env_param2    => l_service_id
                  , i_env_param3    => l_currency
                  , i_env_param4    => i_product_id
                );
                l_product_account_type_id := null;
        end;

        l_command := nvl(l_command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );

        if l_product_account_type_id is null then
            if l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                            )
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_TYPE_NOT_FOUND'
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                               , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                               , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                               )
            then
                acc_ui_product_account_pkg.add_product_account_type(
                    o_id             => l_product_account_type_id
                  , i_product_id     => i_product_id
                  , i_account_type   => l_account_type
                  , i_scheme_id      => null
                  , i_currency       => l_currency
                  , i_service_id     => l_service_id
                  , i_aval_algorithm => l_aval_algorithm
                );
            end if;

        else
            if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'ACCOUNT_TYPE_OF_PRODUCT_ALREADY_EXISTS'
                  , i_env_param1    => l_account_type
                  , i_env_param2    => i_product_id
                  , i_env_param3    => l_currency
                  , i_env_param4    => l_service_id
                );
            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                               , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                               )
            then
                acc_ui_product_account_pkg.modify_product_account_type(
                    i_id             => l_product_account_type_id
                  , i_product_id     => i_product_id
                  , i_account_type   => l_account_type
                  , i_scheme_id      => null
                  , i_currency       => l_currency
                  , i_service_id     => l_service_id
                  , i_aval_algorithm => l_aval_algorithm
                );
            elsif l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                               , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                               )
            then
                acc_ui_product_account_pkg.remove_product_account_type(
                    i_id => l_product_account_type_id
                );
            end if;
        end if;
    end loop;

end process_account_types;

procedure process_card_types(
    i_inst_id               in  com_api_type_pkg.t_inst_id
  , i_product_id            in  com_api_type_pkg.t_short_id
  , i_appl_data_id          in  com_api_type_pkg.t_long_id
) is
    l_service_id                com_api_type_pkg.t_short_id;
    l_product_card_type_id      com_api_type_pkg.t_short_id;
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_command                   com_api_type_pkg.t_dict_value;
    l_id_tab                    com_api_type_pkg.t_number_tab;
    l_index_range_id            com_api_type_pkg.t_short_id;
    l_number_format_id          com_api_type_pkg.t_tiny_id;
    l_count                     com_api_type_pkg.t_short_id;
    l_product_card_type         iss_api_type_pkg.t_product_card_type_rec;
    l_bin_id                    com_api_type_pkg.t_short_id;
    l_service_number            com_api_type_pkg.t_name;
    l_reissue_product_id        com_api_type_pkg.t_short_id;
    l_reissue_product_number    com_api_type_pkg.t_name;
    l_reissue_bin_id            com_api_type_pkg.t_short_id;
    l_reissue_bin               com_api_type_pkg.t_bin;

begin
    if i_appl_data_id is null then
        return;
    end if;

    trc_log_pkg.debug(
        i_text          => 'app_api_product_pkg.process_card_types'
    );

    app_api_application_pkg.get_appl_data_id(
        i_element_name  => 'PRODUCT_CARD_TYPE'
      , i_parent_id     => i_appl_data_id
      , o_appl_data_id  => l_id_tab
    );

    for i in 1..nvl(l_id_tab.count, 0) loop
        app_api_application_pkg.get_element_value(
            i_element_name   => 'COMMAND'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_command
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CARD_TYPE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.card_type_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SEQ_NUMBER_LOW'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.seq_number_low
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SEQ_NUMBER_HIGH'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.seq_number_high
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'BIN'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_bin_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'INDEX_RANGE_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.index_range_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'NUMBER_FORMAT_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.number_format_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'EMV_APPL_SCHEME_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.emv_appl_scheme_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PIN_REQUEST'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.pin_request
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PIN_MAILER_REQUEST'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.pin_mailer_request
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'EMBOSSING_REQUEST'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.embossing_request
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CARD_STATUS'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.status
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PERSO_PRIORITY'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.perso_priority
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_COMMAND'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.reiss_command
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_START_DATE_RULE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.reiss_start_date_rule
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_EXPIR_DATE_RULE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.reiss_expir_date_rule
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_CARD_TYPE_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.reiss_card_type_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_PRODUCT_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_reissue_product_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_PRODUCT_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_reissue_product_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_BIN_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_reissue_bin_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'REISSUE_BIN'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_reissue_bin
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'BLANK_TYPE_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.blank_type_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'CARD_STATE'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.state
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'PERSO_METHOD_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.perso_method_id
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'SERVICE_NUMBER'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_service_number
        );

        app_api_application_pkg.get_element_value(
            i_element_name   => 'UID_FORMAT_ID'
          , i_parent_id      => l_id_tab(i)
          , o_element_value  => l_product_card_type.uid_format_id
        );

        trc_log_pkg.debug(
            i_text          => 'Process card_type [#1], service_number [#2], bin_id [#3] for product_id [#4]'
          , i_env_param1    => l_product_card_type.card_type_id
          , i_env_param2    => l_service_number
          , i_env_param3    => l_bin_id
          , i_env_param4    => i_product_id
        );

        begin
            select s.id
              into l_service_id 
              from prd_service          s
                 , prd_product_service  p
                 , prd_service_type     t 
             where s.service_number = l_service_number
               and s.id             = p.service_id 
               and t.id             = s.service_type_id
               and t.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD
               and p.product_id     = i_product_id
               and t.is_initial     = com_api_type_pkg.TRUE
               and s.inst_id        = i_inst_id
             connect by prior p.id  = p.parent_id 
               start with p.parent_id is null;

        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error         => 'SERVICE_NOT_FOUND'
                );
        end;

        if l_bin_id is null then
            com_api_error_pkg.raise_error(
                i_error         => 'BIN_NOT_FOUND_BY_ID'
              , i_env_param1    => l_bin_id
            );
        else
            l_product_card_type.bin_id := l_bin_id;
        end if;
        
        begin
            select id
              into l_index_range_id
              from iss_bin_index_range
             where bin_id           = l_product_card_type.bin_id
               and index_range_id   = l_product_card_type.index_range_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'BIN_INDEX_RANGE_NOT_FOUND_BY_ID'
                  , i_env_param1  => l_product_card_type.index_range_id
                );
        end;
        
        begin
            select id
              into l_number_format_id
              from rul_name_format
             where id           = l_product_card_type.number_format_id
               and entity_type  = iss_api_const_pkg.ENTITY_TYPE_CARD
               and inst_id     in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'RUL_NAME_INDEX_PARAM_NOT_FOUND'
                  , i_env_param1  => l_product_card_type.number_format_id
                );
        end;
        
        select count(*)
          into l_count
          from emv_appl_scheme
         where ( id = l_product_card_type.emv_appl_scheme_id
              or l_product_card_type.emv_appl_scheme_id is null
               )
           and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        
        if l_count = 0
            and l_product_card_type.emv_appl_scheme_id is not null
        then
            com_api_error_pkg.raise_error(
                i_error       => 'EMV_APPL_SCHEME_NOT_FOUND'
              , i_env_param1  => l_product_card_type.emv_appl_scheme_id
            );
        end if; 
        
        select count(*)
          into l_count
          from prs_blank_type
         where ( id = l_product_card_type.blank_type_id
              or l_product_card_type.blank_type_id is null
               )
           and card_type_id = l_product_card_type.card_type_id
           and inst_id     in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
           
        if l_count = 0
            and l_product_card_type.blank_type_id is not null
        then
            com_api_error_pkg.raise_error(
                i_error       => 'BLANK_TYPE_NOT_FOUND'
              , i_env_param1  => l_product_card_type.blank_type_id
            );
        end if; 
        
        begin
            select id
              into l_product_card_type.perso_method_id
              from prs_method
             where id = l_product_card_type.perso_method_id
               and inst_id in (i_inst_id, ost_api_const_pkg.DEFAULT_INST);
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'CARD_PERSONALIZATION_METHOD_NOT_FOUND'
                  , i_env_param1  => l_product_card_type.perso_method_id
                );
        end;
        
        begin
            select p.id
                 , p.seqnum
              into l_product_card_type_id
                 , l_seqnum
              from (select pct.id
                         , pct.seq_number_low
                         , pct.seqnum
                      from iss_product_card_type pct
                     where pct.product_id           = i_product_id
                       and pct.card_type_id         = l_product_card_type.card_type_id
                       and pct.service_id           = l_service_id
                       and pct.bin_id               = l_product_card_type.bin_id
                       and pct.index_range_id       = l_product_card_type.index_range_id
                       and pct.perso_method_id      = l_product_card_type.perso_method_id
                       and pct.number_format_id     = l_product_card_type.number_format_id
                       and ( pct.blank_type_id      = l_product_card_type.blank_type_id
                          or l_product_card_type.blank_type_id is null
                           )
                       and ( pct.emv_appl_scheme_id = l_product_card_type.emv_appl_scheme_id
                          or l_product_card_type.emv_appl_scheme_id is null
                           )
                       and pct.seq_number_low = l_product_card_type.seq_number_low
                   order by pct.seq_number_high) p
             where rownum = 1;

            trc_log_pkg.debug(
                i_text          => 'Card type [#1] for service [#2] have been found on product [#3]; l_product_card_type_id [#4]'
              , i_env_param1    => l_product_card_type.card_type_id
              , i_env_param2    => l_service_id
              , i_env_param3    => i_product_id
              , i_env_param4    => l_product_card_type_id
            );

        exception
            when no_data_found then
                trc_log_pkg.debug(
                    i_text          => 'Card type [#1] for service [#2] have not been found on product [#4]'
                  , i_env_param1    => l_product_card_type.card_type_id
                  , i_env_param2    => l_service_id
                  , i_env_param4    => i_product_id
                );
                l_product_card_type_id := null;
        end;

        l_command := nvl(l_command, app_api_const_pkg.COMMAND_CREATE_OR_UPDATE);

        trc_log_pkg.debug(
            i_text          => 'Command [#1]'
          , i_env_param1    => l_command
        );


        if l_product_card_type_id is null then

            l_seqnum := 1;

            if l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                            , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                            )
            then
                com_api_error_pkg.raise_error(
                    i_error => 'CARD_TYPE_NOT_FOUND'
                );

            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                               , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                               , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                               )
            then
                iss_ui_product_card_type_pkg.add_product_card_type(
                    o_id                      => l_product_card_type_id
                  , o_seqnum                  => l_seqnum
                  , i_product_id              => i_product_id
                  , i_card_type_id            => l_product_card_type.card_type_id
                  , i_seq_number_low          => l_product_card_type.seq_number_low
                  , i_seq_number_high         => l_product_card_type.seq_number_high
                  , i_bin_id                  => l_product_card_type.bin_id
                  , i_index_range_id          => l_product_card_type.index_range_id
                  , i_number_format_id        => l_product_card_type.number_format_id
                  , i_emv_appl_scheme_id      => l_product_card_type.emv_appl_scheme_id
                  , i_pin_request             => l_product_card_type.pin_request
                  , i_pin_mailer_request      => l_product_card_type.pin_mailer_request
                  , i_embossing_request       => l_product_card_type.embossing_request
                  , i_status                  => l_product_card_type.status
                  , i_perso_priority          => l_product_card_type.perso_priority
                  , i_reiss_command           => l_product_card_type.reiss_command
                  , i_reiss_start_date_rule   => l_product_card_type.reiss_start_date_rule
                  , i_reiss_expir_date_rule   => l_product_card_type.reiss_expir_date_rule
                  , i_reiss_card_type_id      => l_product_card_type.reiss_card_type_id
                  , i_reiss_contract_id       => l_product_card_type.reiss_contract_id
                  , i_blank_type_id           => l_product_card_type.blank_type_id
                  , i_state                   => l_product_card_type.state
                  , i_perso_method_id         => l_product_card_type.perso_method_id
                  , i_service_id              => l_service_id
                  , i_reiss_product_id        => l_reissue_product_id
                  , i_reiss_bin_id            => l_reissue_bin_id
                  , i_uid_format_id           => l_product_card_type.uid_format_id
                );
            end if;

        else
            if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
            then
                com_api_error_pkg.raise_error(
                    i_error         => 'CARD_TYPE_FOR_PRODUCT_ALREADY_EXISTS'
                  , i_env_param1    => l_product_card_type.card_type_id
                  , i_env_param2    => i_product_id
                  , i_env_param3    => l_service_id
                );
            elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                               , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                               )
            then
                iss_ui_product_card_type_pkg.modify_product_card_type(
                    i_id                      => l_product_card_type_id
                  , io_seqnum                 => l_seqnum
                  , i_product_id              => i_product_id
                  , i_card_type_id            => l_product_card_type.card_type_id
                  , i_seq_number_low          => l_product_card_type.seq_number_low
                  , i_seq_number_high         => l_product_card_type.seq_number_high
                  , i_bin_id                  => l_product_card_type.bin_id
                  , i_index_range_id          => l_product_card_type.index_range_id
                  , i_number_format_id        => l_product_card_type.number_format_id
                  , i_emv_appl_scheme_id      => l_product_card_type.emv_appl_scheme_id
                  , i_pin_request             => l_product_card_type.pin_request
                  , i_pin_mailer_request      => l_product_card_type.pin_mailer_request
                  , i_embossing_request       => l_product_card_type.embossing_request
                  , i_status                  => l_product_card_type.status
                  , i_perso_priority          => l_product_card_type.perso_priority
                  , i_reiss_command           => l_product_card_type.reiss_command
                  , i_reiss_start_date_rule   => l_product_card_type.reiss_start_date_rule
                  , i_reiss_expir_date_rule   => l_product_card_type.reiss_expir_date_rule
                  , i_reiss_card_type_id      => l_product_card_type.reiss_card_type_id
                  , i_reiss_contract_id       => l_product_card_type.reiss_contract_id
                  , i_blank_type_id           => l_product_card_type.blank_type_id
                  , i_state                   => l_product_card_type.state
                  , i_perso_method_id         => l_product_card_type.perso_method_id
                  , i_service_id              => l_service_id
                  , i_reiss_product_id        => l_reissue_product_id
                  , i_reiss_bin_id            => l_reissue_bin_id
                  , i_uid_format_id           => l_product_card_type.uid_format_id
                );

            elsif l_command in (
                app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
              , app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
            ) then
                iss_ui_product_card_type_pkg.remove_product_card_type(
                    i_id                      => l_product_card_type_id
                  , i_seqnum                  => l_seqnum
                );
            end if;
        end if;
    end loop;

end process_card_types;

procedure process_product(
    i_appl_data_id  in          com_api_type_pkg.t_long_id
  , i_inst_id       in          com_api_type_pkg.t_inst_id
  , o_product_id   out nocopy   com_api_type_pkg.t_short_id
) is
    LOG_PREFIX      constant    com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.process_product: ';
    l_command                   com_api_type_pkg.t_dict_value;
    l_product                   prd_api_type_pkg.t_product;
    
    l_id                        com_api_type_pkg.t_short_id;
    l_seqnum                    com_api_type_pkg.t_seqnum;
    l_old_contract_type         com_api_type_pkg.t_dict_value;
    l_lang                      com_api_type_pkg.t_dict_value;

    l_id_tab_child              com_api_type_pkg.t_number_tab;
    l_lang_tab                  com_api_type_pkg.t_dict_tab;
    l_name_command              com_api_type_pkg.t_dict_value;
    l_label                     com_api_type_pkg.t_name;
    l_description               com_api_type_pkg.t_text;
begin
    trc_log_pkg.debug(LOG_PREFIX || 'START with i_appl_data_id [' || i_appl_data_id || '], i_inst_id [' || i_inst_id || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'COMMAND'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_command
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRODUCT_NUMBER'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product.product_number
    );

    trc_log_pkg.debug('l_command [' || l_command || '], product_number [' || l_product.product_number || ']');

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRODUCT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product.product_type
    );
    
    app_api_application_pkg.get_element_value(
        i_element_name   => 'CONTRACT_TYPE'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product.contract_type
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PARENT_PRODUCT_ID'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product.parent_id
    );

    app_api_application_pkg.get_element_value(
        i_element_name   => 'PRODUCT_STATUS'
      , i_parent_id      => i_appl_data_id
      , o_element_value  => l_product.status
    );

    begin
        select id
             , seqnum
             , contract_type
          into l_id
             , l_seqnum
             , l_old_contract_type
          from prd_product
         where product_number   = l_product.product_number
           and inst_id          = i_inst_id;

        l_product.id := l_id;

        trc_log_pkg.debug(
            i_text          => 'product found by number [#1]; id [#2]'
          , i_env_param1    => l_product.product_number
          , i_env_param2    => l_id
        );

    exception
        when no_data_found then
            trc_log_pkg.debug(
                i_text          => 'product not found by number [#1]'
              , i_env_param1    => l_product.product_number
            );
    end;

    if l_id is null then
        if l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                        , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                        , app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                        ) 
        then
            com_api_error_pkg.raise_error(
                i_error         => 'PRODUCT_NOT_FOUND'
              , i_env_param1    => l_product.product_number
            );
        elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT
                           , app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                           , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                           )
        then
            app_api_application_pkg.get_appl_data_id(
                i_element_name   => 'PRODUCT_NAME'
              , i_parent_id      => i_appl_data_id
              , o_appl_data_id   => l_id_tab_child
              , o_appl_data_lang => l_lang_tab
            );
    
            for j in 1..nvl(l_id_tab_child.count, 0) loop
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'COMMAND'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_name_command
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'LABEL'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_label
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'DESCRIPTION'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_description
                );
            
                l_lang := l_lang_tab(j);
            end loop;

            if l_label is null then
                com_api_error_pkg.raise_error(
                    i_error         => 'PRODUCT_NAME_NOT_DEFINED'
                  , i_env_param1    => l_product.product_number
                );
            end if;

            prd_ui_product_pkg.add_product(
                o_id                => l_id
              , o_seqnum            => l_seqnum
              , i_product_type      => l_product.product_type
              , i_contract_type     => l_product.contract_type
              , i_parent_id         => l_product.parent_id
              , i_inst_id           => i_inst_id
              , i_lang              => l_lang
              , i_label             => l_label
              , i_description       => l_description
              , i_status            => l_product.status
              , i_product_number    => l_product.product_number
            );

            l_product.id := l_id;

            process_services(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_parent_id     => l_product.parent_id 
              , i_appl_data_id  => i_appl_data_id
            );

            process_account_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            );

            process_card_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            ) ;
        else
            trc_log_pkg.info(
                i_text          => 'Ignore product [#1]'
              , i_env_param1    => l_product.product_number
            );
        end if;
    else
        --product exists
        if l_command in (app_api_const_pkg.COMMAND_CREATE_OR_EXCEPT)
        then
            com_api_error_pkg.raise_error(
                i_error         => 'PRODUCT_ALREADY_EXIST'
              , i_env_param1    => l_product.product_number
            );
        elsif l_command in ( app_api_const_pkg.COMMAND_PROCEED_OR_REMOVE
                           , app_api_const_pkg.COMMAND_EXCEPT_OR_REMOVE
                           )
        then
            prd_ui_product_pkg.remove_product(
                i_id            => l_id
              , i_seqnum        => l_seqnum
            );
        elsif l_command in ( app_api_const_pkg.COMMAND_EXCEPT_OR_UPDATE
                           , app_api_const_pkg.COMMAND_CREATE_OR_UPDATE
                           )
        then
            prd_prc_product_pkg.check_contract_type(
                i_product_id        => l_id
              , i_old_contract_type => l_old_contract_type
              , i_new_contract_type => l_product.contract_type
            );

            app_api_application_pkg.get_appl_data_id(
                i_element_name   => 'PRODUCT_NAME'
              , i_parent_id      => i_appl_data_id
              , o_appl_data_id   => l_id_tab_child
              , o_appl_data_lang => l_lang_tab
            );
    
            for j in 1..nvl(l_id_tab_child.count, 0) loop
                app_api_application_pkg.get_element_value(
                    i_element_name   => 'COMMAND'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_name_command
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'LABEL'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_label
                );

                app_api_application_pkg.get_element_value(
                    i_element_name   => 'DESCRIPTION'
                  , i_parent_id      => l_id_tab_child(j)
                  , o_element_value  => l_description
                );
            
                l_lang := l_lang_tab(j);
            end loop;

            prd_ui_product_pkg.modify_product(
                i_id            => l_id
              , io_seqnum       => l_seqnum
              , i_lang          => l_lang
              , i_label         => l_label
              , i_description   => l_description
              , i_status        => l_product.status
              , i_product_number=> l_product.product_number
            );

            process_services(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_parent_id     => l_product.parent_id 
              , i_appl_data_id  => i_appl_data_id
            );

            process_account_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            );

            process_card_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            ) ;

        elsif l_command in ( app_api_const_pkg.COMMAND_CREATE_OR_PROCEED
                           , app_api_const_pkg.COMMAND_EXCEPT_OR_PROCEED
                           )
        then
            prd_prc_product_pkg.check_contract_type(
                i_product_id        => l_id
              , i_old_contract_type => l_old_contract_type
              , i_new_contract_type => l_product.contract_type
            );

            process_services(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_parent_id     => l_product.parent_id 
              , i_appl_data_id  => i_appl_data_id
            );

            process_account_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            );

            process_card_types(
                i_inst_id       => i_inst_id
              , i_product_id    => l_id
              , i_appl_data_id  => i_appl_data_id
            ) ;

        else
            trc_log_pkg.info(
                i_text          => 'Ignore product [#1]'
              , i_env_param1    => l_product.product_number
            );
        end if;
    end if;

    attach_product_to_application(i_product_id => l_id);

end;

end app_api_product_pkg;
/
