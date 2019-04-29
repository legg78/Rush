create or replace package body ecm_api_linked_card_pkg as

procedure add_linked_card (
      o_id                  out com_api_type_pkg.t_long_id
    , i_entity_type     in      com_api_type_pkg.t_dict_value
    , i_object_id       in      com_api_type_pkg.t_long_id
    , i_cardholder_name in      com_api_type_pkg.t_name
    , i_expiration_date in      date
    , i_card_network_id in      com_api_type_pkg.t_network_id
    , i_card_inst_id    in      com_api_type_pkg.t_inst_id
    , i_iss_network_id  in      com_api_type_pkg.t_network_id
    , i_iss_inst_id     in      com_api_type_pkg.t_inst_id
    , i_status          in      com_api_type_pkg.t_dict_value
    , i_card_number     in      com_api_type_pkg.t_card_number
    , i_cvv_cvc         in      com_api_type_pkg.t_tiny_id
    , i_auth_id         in      com_api_type_pkg.t_long_id
) is
    l_store_cvv         com_apI_type_pkg.t_boolean;
    l_card_inst_id      com_api_type_pkg.t_inst_id;
    l_iss_network_id    com_api_type_pkg.t_network_id;
    l_iss_inst_id       com_api_type_pkg.t_inst_id;
begin
    for oper in (select p.inst_id, p.network_id, p.card_inst_id from opr_participant p where oper_id = i_auth_id and p.participant_type = com_api_const_pkg.PARTICIPANT_ISSUER) loop
        l_card_inst_id := oper.card_inst_id;
        l_iss_network_id := oper.network_id;
        l_iss_inst_id := oper.inst_id;
    end loop;
    
    o_id := ecm_linked_card_seq.nextval;
    
    insert into ecm_linked_card (
          id
        , entity_type
        , object_id
        , card_mask
        , cardholder_name
        , expiration_date
        , card_network_id
        , card_inst_id
        , iss_network_id
        , iss_inst_id
        , status
        , link_date
    ) values (
          o_id                  
        , i_entity_type    
        , i_object_id 
        , iss_api_card_pkg.get_card_mask(i_card_number)     
        , i_cardholder_name
        , i_expiration_date
        , i_card_network_id
        , nvl(i_card_inst_id, l_card_inst_id)
        , nvl(i_iss_network_id, l_iss_network_id)
        , nvl(i_iss_inst_id, l_iss_inst_id)
        , i_status         
        , com_api_sttl_day_pkg.get_sysdate      
    );
    
    l_store_cvv := 
        set_ui_value_pkg.get_system_param_n(
            i_param_name        => 'STORE_CVV_CVC'
        );
    
end;

procedure remove_linked_card (
      i_id              in  com_api_type_pkg.t_long_id
) is
    l_unlink_date   date;
begin
    select unlink_date
      into l_unlink_date 
      from ecm_linked_card
     where id = i_id;    
     
    if l_unlink_date is not null then
        com_api_error_pkg.raise_error (
            i_error     =>  'CARD_ALREADY_UNLINKED'
        );
    end if;
    
    update ecm_linked_card
       set unlink_date = com_api_sttl_day_pkg.get_sysdate
         , status = pmo_api_const_pkg.LINKED_CARD_STATUS_NOT_VALID
     where id = i_id;
     
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error     =>  'CARD_NOT_LINKED'
        );           
end;

procedure get_hold_amount (
      io_currency       in  out com_api_type_pkg.t_curr_code
    , o_amount              out com_api_type_pkg.t_money  
) is
begin
    o_amount := 1000;
    io_currency := com_api_currency_pkg.RUBLE;
end;

procedure modify_card_status (
      i_id              in      com_api_type_pkg.t_long_id
    , i_status          in      com_api_type_pkg.t_dict_value  
) is
begin
    update ecm_linked_card
       set status = i_status
     where id = i_id;       
end;

procedure get_linked_cards(
    i_customer_number       in      com_api_type_pkg.t_name
  , i_inst_id               in      com_api_type_pkg.t_inst_id
  , i_status                in      com_api_type_pkg.t_dict_value       default null
  , o_linked_card_ref          out  com_api_type_pkg.t_ref_cur
) is
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
    
    open o_linked_card_ref for
        select l.id linked_card_id
             , l.card_mask
             , l.card_network_id
             , l.cardholder_name
             , to_char(l.expiration_date, 'mm/yy') expiration_date
             , l.status
             , l.link_date
             , l.unlink_date
          from ecm_linked_card l
         where l.object_id = l_customer_id
           and l.entity_type = prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
           and (i_status is null or i_status = l.status);
end;

procedure get_linked_card_data(
    i_linked_card_id        in      com_api_type_pkg.t_name
  , o_customer_id              out  com_api_type_pkg.t_medium_id
  , o_account_id               out  com_api_type_pkg.t_name
  , o_account_number           out  com_api_type_pkg.t_account_number
  , o_card_network_id          out  com_api_type_pkg.t_tiny_id            
  , o_card_inst_id             out  com_api_type_pkg.t_inst_id            
  , o_iss_network_id           out  com_api_type_pkg.t_tiny_id            
  , o_iss_inst_id              out  com_api_type_pkg.t_inst_id            
) is
begin

    select l.object_id
         , l.card_network_id
         , l.card_inst_id   
         , l.iss_network_id 
         , l.iss_inst_id
         , a.account_number  
      into o_customer_id
         , o_card_network_id
         , o_card_inst_id   
         , o_iss_network_id 
         , o_iss_inst_id  
         , o_account_number
      from ecm_linked_card l
         , acc_account a
     where l.id = i_linked_card_id
       and l.status  = pmo_api_const_pkg.LINKED_CARD_STATUS_CONFIRMED
       and l.object_id = a.id(+);
exception
    when no_data_found then       
        com_api_error_pkg.raise_error(
            i_error             => 'CARD_LINK_NOT_FOUND'
          , i_env_param1        => i_linked_card_id
        );
end;

end ecm_api_linked_card_pkg;
/
