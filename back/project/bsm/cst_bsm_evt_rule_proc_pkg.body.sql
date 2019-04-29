create or replace package body cst_bsm_evt_rule_proc_pkg is

-- Checking of application properties and MIS table data by some criteria.
procedure priority_evaluation is
    LOG_PREFIX    constant     com_api_type_pkg.t_name    := lower($$PLSQL_UNIT) || '.priority_evaluation: ';
    l_entity_type              com_api_type_pkg.t_dict_value;
    l_event_type               com_api_type_pkg.t_dict_value;
    l_application_id           com_api_type_pkg.t_long_id;
    l_successfull_checks_count com_api_type_pkg.t_tiny_id := 0;
    l_customer_number          com_api_type_pkg.t_name;
    l_total_customer_balance   com_api_type_pkg.t_money;
    l_seqnum                   com_api_type_pkg.t_tiny_id;
    l_prod_count               com_api_type_pkg.t_tiny_id;
    l_flag_count               com_api_type_pkg.t_tiny_id;
    l_status                   com_api_type_pkg.t_dict_value;
    l_reissue_command          com_api_type_pkg.t_dict_value;
    l_card_count               com_api_type_pkg.t_tiny_id;
    l_priority_appl_count      com_api_type_pkg.t_tiny_id;
    l_appl_type                com_api_type_pkg.t_dict_value;
    l_evaluation_amount        com_api_type_pkg.t_money;
    l_product_quantity         com_api_type_pkg.t_tiny_id;

    procedure priority_save is
    begin
        insert into cst_bsm_priority_criteria (
            application_id
          , seqnum
          , total_customer_balance
          , priority_flag
          , product_count
          , reissue_command
          , card_count
          , priority_appl_count
        ) values (
            l_application_id
          , 1
          , l_total_customer_balance
          , l_flag_count
          , l_prod_count
          , l_reissue_command
          , l_card_count
          , l_priority_appl_count
        );
    exception
        when dup_val_on_index then
            update cst_bsm_priority_criteria
               set seqnum                 = seqnum + 1
                 , total_customer_balance = l_total_customer_balance
                 , priority_flag          = l_flag_count
                 , product_count          = l_prod_count
                 , reissue_command        = l_reissue_command
                 , card_count             = l_card_count
                 , priority_appl_count    = l_priority_appl_count
             where application_id = l_application_id;
    end priority_save;

begin
    trc_log_pkg.debug( i_text => LOG_PREFIX || ' started' );
    l_entity_type       := evt_api_shared_data_pkg.get_param_char(i_name => 'ENTITY_TYPE');
    l_event_type        := evt_api_shared_data_pkg.get_param_char(i_name => 'EVENT_TYPE');
    l_evaluation_amount := nvl(evt_api_shared_data_pkg.get_param_num(i_name => 'AMOUNT'), 0);
    l_product_quantity  := nvl(evt_api_shared_data_pkg.get_param_num(i_name => 'PRODUCT_QUANTITY'), 2);
        
    if l_entity_type != app_api_const_pkg.ENTITY_TYPE_APPLICATION 
    then
        trc_log_pkg.debug( 
            i_text => LOG_PREFIX || ' do nothing, event_type [#1], entity_type [#2], l_evaluation_amount [#3], l_product_quantity [#4]'
          , i_env_param1 => l_event_type
          , i_env_param2 => l_entity_type
          , i_env_param3 => l_evaluation_amount
          , i_env_param4 => l_product_quantity
        );
        return;
    end if;

    if nvl(app_api_application_pkg.get_prioritized_flag, com_api_const_pkg.FALSE) = com_api_const_pkg.TRUE 
    then
        l_application_id := evt_api_shared_data_pkg.get_param_num(i_name => 'OBJECT_ID' );

        select seqnum
             , appl_type
          into l_seqnum
             , l_appl_type
          from app_application
         where id = l_application_id;

        select min(d.element_value)
          into l_customer_number
          from app_data d
             , app_element e
         where d.appl_id    = l_application_id
           and d.element_id = e.id
           and e.name       = 'CUSTOMER_NUMBER';

        trc_log_pkg.debug( 
            i_text => LOG_PREFIX || ' application_id [#1], seqnum [#2], customer_number [#3]'
          , i_env_param1 => l_application_id
          , i_env_param2 => l_seqnum
          , i_env_param3 => l_customer_number
        );
    -- 1.    Total customer Balance (SummarySaldoCIF_Lcy) > 500.000.000. 
    --       This amount should be configurable in SVBO by Bank. (From MIS table)
    --       Implemented the latest customer balance
        select max(d.customer_balance) keep (dense_rank first order by d.id desc) customer_balance
          into l_total_customer_balance
          from cst_bsm_priority_acc_details d
         where customer_number = l_customer_number;

         if nvl(l_total_customer_balance, 0) > l_evaluation_amount then
             l_successfull_checks_count := l_successfull_checks_count + 1;
         end if;
        
    -- 2.    Priority Flag (priority flag) = ‘Y’ (From MIS table)
        select sum(case when d.priority_flag = 'Y' then 1 else 0 end) 
          into l_flag_count
          from cst_bsm_priority_acc_details d
         where customer_number = l_customer_number;
       
         if nvl(l_flag_count, 0) > 0 then
             l_successfull_checks_count := l_successfull_checks_count + 1;
         end if;
    -- 3.    Have Equal or More than product_quantity different Products (product_code). 
    --       If have product_quantity Accounts for same product, Count as 1 product. 
    --       (Product codes from MIS table) This number of products must be configurable.
    --       Implemented count of different products on the same customer
        select count(*)
          into l_flag_count
          from cst_bsm_priority_acc_details d
         where customer_number = l_customer_number
           and exists (select null
                         from com_array_element e
                        where e.array_id      = cst_bsm_const_pkg.EXCLUDE_PROD_NUMBERS_ARRAY_ID
                          and e.element_value = d.product_number);

        if l_flag_count = 0 then
            select count(distinct product_number)
              into l_prod_count
              from cst_bsm_priority_acc_details
             where customer_number = l_customer_number;
        else
            l_prod_count := 0;
        end if;

        if l_prod_count >= l_product_quantity then
             l_successfull_checks_count := l_successfull_checks_count + 1;
        end if;
    -- 4.    Exclude product code 6001 and 6003 Product codes to be excluded should be configurable in SV. 
    --       (From MIS table; List of product can be taken from priority product details table. 
    --       It should be configurable to exclude certain products)

        select nvl(min(d.element_value), 'RCMDNEWN')
          into l_reissue_command
          from app_data d
             , app_element e
         where d.appl_id    = l_application_id
           and d.element_id = e.id
           and e.name       = 'REISSUE_COMMAND';

    --       Implemented all cards not in priority criteria
        select count(*)
          into l_card_count
          from prd_customer       s
             , iss_card           c
             , iss_card_instance  i
             , prd_contract       t
             , prd_product        p
         where s.customer_number     = l_customer_number
           and s.id                  = c.customer_id
           and c.id                  = i.card_id
           and i.state              in (iss_api_const_pkg.CARD_STATE_PERSONALIZATION, iss_api_const_pkg.CARD_STATE_ACTIVE)
           and c.contract_id         = t.id
           and t.product_id          = p.id
           and p.product_number not in (select e.element_value
                                         from com_array_element e
                                        where e.array_id       = cst_bsm_const_pkg.EXCLUDE_PROD_NUMBERS_ARRAY_ID)
           and not exists (select null
                             from cst_bsm_priority_prod_details  b
                            where b.product_number = p.product_number);
           
        select count(i.id)
          into l_priority_appl_count 
          from iss_card c
             , iss_card_instance i
             , prd_customer cu
             , app_object o
             , app_application a
         where c.id                       = i.card_id
           and c.customer_id              = cu.id
           and c.id                       = o.object_id
           and o.entity_type              = iss_api_const_pkg.ENTITY_TYPE_CARD
           and o.appl_id                  = a.id
           and nvl(a.appl_prioritized, 0) = com_api_const_pkg.true
           and i.state                    in (iss_api_const_pkg.CARD_STATE_PERSONALIZATION, iss_api_const_pkg.CARD_STATE_ACTIVE)
           and cu.customer_number         = l_customer_number;

    -- 5.    For New Application, should check No Active Priority Card attached to this CIF (Customer number)
        if (l_reissue_command in ('RCMDNEWN', 'RCMDOLDN') or l_reissue_command is null) and l_card_count = 0 then
            l_successfull_checks_count := l_successfull_checks_count + 1; 
        end if;

    -- 6.    For Renewal, should check at least 1 Active Priority Card available for the CIF (Customer number)
        if l_reissue_command = 'RCMDRENW' and l_priority_appl_count > 0 then
            l_successfull_checks_count := l_successfull_checks_count + 1; 
        end if;

        priority_save;
    -- A result will be a new application status “Successful priority evaluation” or “Failed priority card evaluation”.
        if l_successfull_checks_count >= 4 then
            l_status := app_api_const_pkg.APPL_STATUS_PRIORITY_OK;
        else
            l_status := app_api_const_pkg.APPL_STATUS_PRIORITY_FAILED;
        end if;
        
        app_ui_application_pkg.modify_application(
            i_appl_id     => l_application_id
          , io_seqnum     => l_seqnum
          , i_appl_status => l_status
        );

        update app_application 
           set seqnum = seqnum -1
         where id     = l_application_id;

    end if;

    trc_log_pkg.debug( 
        i_text       => LOG_PREFIX || ' finished, l_successfull_checks_count [#1]'
      , i_env_param1 => l_successfull_checks_count
    );
     
exception
    when others then
        prc_api_stat_pkg.log_end(
            i_result_code       => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        else
            trc_log_pkg.debug(
                i_text       => LOG_PREFIX || 'FAILED: [#1]'
              , i_env_param1 => sqlerrm
            );
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;
end priority_evaluation;

end cst_bsm_evt_rule_proc_pkg;
/
