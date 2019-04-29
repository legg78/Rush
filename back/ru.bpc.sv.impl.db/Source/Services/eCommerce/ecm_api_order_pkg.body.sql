create or replace package body ecm_api_order_pkg as

procedure add_order (
      o_id                  out com_api_type_pkg.t_long_id
    , i_merchant_id         in  com_api_type_pkg.t_short_id
    , i_order_number        in  com_api_type_pkg.t_name
    , i_order_details       in  com_api_type_pkg.t_full_desc    
    , i_customer_identifier in  com_api_type_pkg.t_name
    , i_customer_name       in  com_api_type_pkg.t_name
    , i_order_uuid          in  com_api_type_pkg.t_name
    , i_success_url         in  com_api_type_pkg.t_name
    , i_fail_url            in  com_api_type_pkg.t_name
    , i_customer_number     in  com_api_type_pkg.t_name
    , i_entity_type         in  com_api_type_pkg.t_dict_value
    , i_object_id           in  com_api_type_pkg.t_long_id
    , i_purpose_id          in  com_api_type_pkg.t_short_id
    , i_template_id         in  com_api_type_pkg.t_tiny_id
    , i_amount              in  com_api_type_pkg.t_money
    , i_currency            in  com_api_type_pkg.t_curr_code
    , i_event_date          in  date    
    , i_status              in  com_api_type_pkg.t_dict_value
    , i_inst_id             in  com_api_type_pkg.t_inst_id
) is
    l_split_hash    com_api_type_pkg.t_tiny_id;
    l_customer_id   com_api_type_pkg.t_medium_id;
begin

    if i_customer_number is not null then
        begin
            select id
                 , split_hash
              into l_customer_id
                 , l_split_hash
              from prd_customer
             where customer_number = upper(i_customer_number)
               and inst_id         = i_inst_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error => 'CUSTOMER_NOT_FOUND'
                  , i_env_param1 => i_customer_number
                  , i_env_param2 => i_inst_id
                );
        end;
    else
        select split_hash
          into l_split_hash
          from acq_merchant
         where id = i_merchant_id;
    end if;    

    pmo_api_order_pkg.add_order (
          o_id                  => o_id                  
        , i_customer_id         => l_customer_id      
        , i_entity_type         => i_entity_type      
        , i_object_id           => i_object_id        
        , i_purpose_id          => i_purpose_id       
        , i_template_id         => i_template_id      
        , i_amount              => i_amount           
        , i_currency            => i_currency         
        , i_event_date          => i_event_date       
        , i_status              => i_status           
        , i_inst_id             => i_inst_id          
        , i_attempt_count       => null    
        , i_is_prepared_order   => com_api_const_pkg.FALSE
        , i_split_hash          => l_split_hash
    );
    
    insert into ecm_order (
        id              
        , merchant_id        
        , order_number       
        , order_details      
        , customer_identifier
        , customer_name     
        , split_hash 
        , order_uuid         
        , success_url
        , fail_url   
    ) values (
        o_id              
        , i_merchant_id        
        , i_order_number       
        , i_order_details      
        , i_customer_identifier
        , i_customer_name  
        , l_split_hash    
        , i_order_uuid
        , i_success_url
        , i_fail_url   
    );

end;

procedure modify_order (
      i_id                  in  com_api_type_pkg.t_long_id
    , i_purpose_id          in  com_api_type_pkg.t_short_id     default null
    , i_status              in  com_api_type_pkg.t_dict_value 
) is
begin
    pmo_api_order_pkg.set_order_status (
        i_order_id  =>  i_id
      , i_status    =>  i_status
    );
    
    if i_purpose_id is not null then
        pmo_api_order_pkg.set_order_purpose (
            i_order_id      =>  i_id
          , i_purpose_id    =>  i_purpose_id    
        );
    end if;
    
end;

procedure choose_host(
    i_purpose_id            in      com_api_type_pkg.t_short_id
  , i_network_id            in      com_api_type_pkg.t_tiny_id  default null
  , o_host_id                  out  com_api_type_pkg.t_tiny_id
) is
    l_host_next             com_api_type_pkg.t_boolean;
    l_response_code         com_api_type_pkg.t_dict_value;
    l_execution_type        com_api_type_pkg.t_dict_value := pmo_api_const_pkg.PAYMENT_ORD_EXC_TYPE_ECCM;
begin
    pmo_api_order_pkg.choose_host(
        i_purpose_id         => i_purpose_id
      , i_network_id         => i_network_id
      , i_choose_host_mode   => pmo_api_const_pkg.CHOOSE_HOST_MODE_ALG
      , io_execution_type    => l_execution_type
      , o_host_member_id     => o_host_id
      , o_host_next          => l_host_next
      , o_response_code      => l_response_code
    );
end;

end ecm_api_order_pkg;
/
