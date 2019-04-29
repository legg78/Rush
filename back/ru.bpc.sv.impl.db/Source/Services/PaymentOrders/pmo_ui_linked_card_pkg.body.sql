create or replace package body pmo_ui_linked_card_pkg as

procedure get_linked_cards(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_account_number        in      com_api_type_pkg.t_account_number
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value       default null
  , o_linked_card_ref          out  com_api_type_pkg.t_ref_cur
) is
    l_account_id            com_api_type_pkg.t_medium_id;
    l_customer_id           com_api_type_pkg.t_medium_id;
begin
    begin
        select id
          into l_customer_id
          from prd_customer
         where customer_number = upper(i_customer_number)
           and inst_id = i_inst_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CUSTOMER_NOT_FOUND'
              , i_env_param1    => i_customer_number
              , i_env_param2    => i_inst_id
            );  
    end;  
    
    begin
        select id
          into l_account_id
          from acc_account
         where customer_id = l_customer_id
           and account_number = i_account_number;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'ACCOUNT_NOT_FOUND'
              , i_env_param1    => i_account_number
            );  
    end; 
        
    open o_linked_card_ref for
        select l.external_customer_id linked_card_id
             , l.card_mask
             , l.card_network_id
             , l.cardholder_name
             , to_char(l.expiration_date, 'mm/yy') expiration_date
             , l.status
             , l.link_date
             , l.unlink_date
          from pmo_linked_card l
         where l.customer_id = l_customer_id
           and l.entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
           and l.object_id = l_account_id
           and (i_status is null or i_status = l.status);
end;

procedure get_linked_card_data(
    i_linked_card_id        in      com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_account_id               out  com_api_type_pkg.t_medium_id
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_card_network_id          out  com_api_type_pkg.t_tiny_id            
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id            
  , o_iss_network_id           out  com_api_type_pkg.t_tiny_id            
  , o_iss_inst_id              out  com_api_type_pkg.t_inst_id            
) is
begin

    select l.customer_id
         , l.object_id
         , l.card_network_id
         , l.card_inst_id   
         , l.iss_network_id 
         , l.iss_inst_id
         , a.account_number  
      into o_customer_id
         , o_account_id 
         , o_card_network_id
         , o_card_inst_id   
         , o_iss_network_id 
         , o_iss_inst_id  
         , o_account_number
      from pmo_linked_card l
         , acc_account a
     where l.external_customer_id = i_linked_card_id
       and l.status  = pmo_api_const_pkg.LINKED_CARD_STATUS_CONFIRMED
       and l.object_id = a.id(+);
exception
    when no_data_found then       
        com_api_error_pkg.raise_error(
            i_error             => 'CARD_LINK_NOT_FOUND'
          , i_env_param1        => i_linked_card_id
        );
end;


procedure link_card(
    i_customer_id           in      com_api_type_pkg.t_medium_id
  , i_account_id            in      com_api_type_pkg.t_medium_id
  , i_external_customer_id  in      com_api_type_pkg.t_name
  , i_card_mask             in      com_api_type_pkg.t_card_number
  , i_cardholder_name       in      com_api_type_pkg.t_name
  , i_expiration_date       in      date
  , i_card_network_id       in      com_api_type_pkg.t_tiny_id
  , i_card_inst_id          in      com_api_type_pkg.t_inst_id
  , i_iss_network_id        in      com_api_type_pkg.t_tiny_id
  , i_iss_inst_id           in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value
) is
begin
    insert into pmo_linked_card (
        id
      , customer_id
      , entity_type
      , object_id
      , external_customer_id
      , card_mask
      , cardholder_name
      , expiration_date
      , card_network_id
      , card_inst_id
      , iss_network_id
      , iss_inst_id
      , status
      , link_date
      , unlink_date
    ) values (
        pmo_linked_card_seq.nextval
      , i_customer_id
      , acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
      , i_account_id
      , i_external_customer_id
      , i_card_mask
      , upper(i_cardholder_name)
      , i_expiration_date
      , i_card_network_id
      , i_card_inst_id
      , i_iss_network_id
      , i_iss_inst_id
      , i_status
      , get_sysdate
      , null
    );
    
end;

procedure unlink_card(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_linked_card_id        in      com_api_type_pkg.t_name
)is
    l_customer_id           com_api_type_pkg.t_medium_id;
begin
    begin
        select id
          into l_customer_id
          from prd_customer
         where customer_number = upper(i_customer_number)
           and inst_id = i_inst_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error         => 'CUSTOMER_NOT_FOUND'
              , i_env_param1    => i_customer_number
              , i_env_param2    => i_inst_id
            );  
    end;  
    
    update pmo_linked_card
       set status               = pmo_api_const_pkg.LINKED_CARD_STATUS_NOT_VALID
         , unlink_date          = com_api_sttl_day_pkg.get_sysdate
     where external_customer_id = i_linked_card_id
       and customer_id          = l_customer_id
       and status               = pmo_api_const_pkg.LINKED_CARD_STATUS_CONFIRMED;

    if sql%rowcount = 0 then
        com_api_error_pkg.raise_error(
            i_error             => 'CARD_LINK_NOT_FOUND'
          , i_env_param1        => i_linked_card_id
        );
    end if;
end;

end;
/
