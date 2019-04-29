create or replace package body lty_api_lottery_tickets_pkg as
/*********************************************************
 *  Loyalty - Lottery tickets API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 07.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: lty_api_lottery_tickets_pkg <br />
 *  @headcom
 **********************************************************/
 
function get_service_type_id(
    i_entity_type  in com_api_type_pkg.t_dict_value
) return com_api_type_pkg.t_short_id is
begin
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        return lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID;
    elsif i_entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT then
        return lty_api_const_pkg.LOYALTY_SERVICE_MRCH_TYPE_ID;
    elsif i_entity_type = acc_api_const_pkg.ENTITY_TYPE_ACCOUNT then
        return lty_api_const_pkg.LOYALTY_SERVICE_ACC_TYPE_ID;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        return lty_api_const_pkg.LOYALTY_SERVICE_CUST_TYPE_ID;
    else
        com_api_error_pkg.raise_error(
            i_error       => 'UNKNOWN_ENTITY_TYPE'
          , i_env_param1  => i_entity_type
        );
    end if;
end;

procedure add_lottery_ticket(
    o_id                   out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_entity_type       in      com_api_type_pkg.t_dict_value
  , i_object_id         in      com_api_type_pkg.t_medium_id     
  , i_service_id        in      com_api_type_pkg.t_short_id      default null
  , i_ticket_number     in      com_api_type_pkg.t_name          default null
  , i_registration_date in      date                             default null
  , i_status            in      com_api_type_pkg.t_dict_value    default lty_api_const_pkg.LOTTERY_TICKET_ACTIVE
  , i_inst_id           in      com_api_type_pkg.t_inst_id       default null
) is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_ticket_number             com_api_type_pkg.t_name;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_card_id                   com_api_type_pkg.t_medium_id;
    l_registration_date         date;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_params                    com_api_type_pkg.t_param_tab;
begin
    l_registration_date := nvl(i_registration_date, com_api_sttl_day_pkg.get_sysdate);

    o_id := com_api_id_pkg.get_id(lty_lottery_ticket_seq.nextval, l_registration_date);
    o_seqnum := 1;
    
    if i_entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD then
        l_card_id := i_object_id;
        
        select c.customer_id
             , nvl(i_split_hash, c.split_hash)
             , nvl(i_inst_id, c.inst_id)
          into l_customer_id
             , l_split_hash
             , l_inst_id
          from iss_card c
         where id = i_object_id;
    elsif i_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        l_customer_id := i_object_id;
        l_card_id := null;

        select nvl(i_split_hash, c.split_hash)
             , nvl(i_inst_id, c.inst_id)
          into l_split_hash
             , l_inst_id
          from prd_customer c
         where id = i_object_id;
    else
        com_api_error_pkg.raise_error(
            i_error      => 'ENTITY_OBJECT_IS_NOT_DEFINED'
        );      
    end if;
    
    if i_service_id is null then
        l_service_id := prd_api_service_pkg.get_active_service_id(
            i_entity_type      => i_entity_type
          , i_object_id        => i_object_id
          , i_attr_name        => null
          , i_service_type_id  => get_service_type_id(
                                      i_entity_type  =>  i_entity_type
                                  )
          , i_eff_date         => l_registration_date
          , i_mask_error       => com_api_const_pkg.FALSE
          , i_inst_id          => l_inst_id 
        );
    else
        l_service_id := i_service_id;
    end if;

    if i_ticket_number is null then
        l_ticket_number := rul_api_name_pkg.get_name (
                i_inst_id             => l_inst_id
              , i_entity_type         => lty_api_const_pkg.ENTITY_TYPE_LOTTERY_TICKET
              , i_param_tab           => l_params
              , i_double_check_value  => null
            ); 
    else
        l_ticket_number := i_ticket_number;
    end if;

    insert into lty_lottery_ticket_vw(
        id
      , seqnum
      , split_hash
      , customer_id
      , card_id
      , service_id
      , ticket_number
      , registration_date
      , status
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , l_split_hash
      , l_customer_id
      , l_card_id
      , l_service_id
      , l_ticket_number
      , l_registration_date
      , nvl(i_status, lty_api_const_pkg.LOTTERY_TICKET_ACTIVE)
      , l_inst_id
    );
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'LOTTERY_TICKET_ALREADY_EXISTS'
        );      
end add_lottery_ticket;

end;
/
