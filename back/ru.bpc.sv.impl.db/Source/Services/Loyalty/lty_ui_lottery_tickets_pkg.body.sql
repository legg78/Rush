create or replace package body lty_ui_lottery_tickets_pkg as
/*********************************************************
 *  Loyalty - Lottery tickets UI <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 07.04.2017 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: lty_ui_lottery_tickets_pkg <br />
 *  @headcom
 **********************************************************/
 
procedure add_lottery_ticket(
    o_id                   out  com_api_type_pkg.t_long_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_split_hash        in      com_api_type_pkg.t_tiny_id       default null
  , i_customer_id       in      com_api_type_pkg.t_medium_id     default null
  , i_card_id           in      com_api_type_pkg.t_medium_id     default null
  , i_service_id        in      com_api_type_pkg.t_short_id      default null
  , i_ticket_number     in      com_api_type_pkg.t_name          default null
  , i_registration_date in      date                             default null
  , i_status            in      com_api_type_pkg.t_dict_value    default lty_api_const_pkg.LOTTERY_TICKET_ACTIVE
  , i_inst_id           in      com_api_type_pkg.t_inst_id       default null
) is
    l_split_hash                com_api_type_pkg.t_tiny_id;
    l_ticket_number             com_api_type_pkg.t_name;
    l_customer_id               com_api_type_pkg.t_medium_id;
    l_registration_date         date;
    l_service_id                com_api_type_pkg.t_short_id;
    l_inst_id                   com_api_type_pkg.t_inst_id;
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_object_id                 com_api_type_pkg.t_medium_id;
    l_params                    com_api_type_pkg.t_param_tab;
begin
    l_registration_date := nvl(i_registration_date, com_api_sttl_day_pkg.get_sysdate);

    o_id := com_api_id_pkg.get_id(lty_lottery_ticket_seq.nextval, l_registration_date);
    o_seqnum := 1;
    
    if i_card_id is not null then
        l_entity_type := iss_api_const_pkg.ENTITY_TYPE_CARD;
        l_object_id := i_card_id;
        
        select nvl(i_customer_id, c.customer_id)
             , nvl(i_split_hash, c.split_hash)
             , nvl(i_inst_id, c.inst_id)
          into l_customer_id
             , l_split_hash
             , l_inst_id
          from iss_card c
         where id = i_card_id;
    else
        l_entity_type := com_api_const_pkg.ENTITY_TYPE_CUSTOMER;
        l_object_id := i_customer_id;
        l_customer_id := i_customer_id;

        select nvl(i_split_hash, c.split_hash)
             , nvl(i_inst_id, c.inst_id)
          into l_split_hash
             , l_inst_id
          from prd_customer c
         where id = i_customer_id;
    end if;
    
    if i_service_id is null then
        l_service_id := prd_api_service_pkg.get_active_service_id(
            i_entity_type      => l_entity_type
          , i_object_id        => l_object_id
          , i_attr_name        => null
          , i_service_type_id  => lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
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
      , i_card_id
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

procedure modify_lottery_ticket(
    i_id                in      com_api_type_pkg.t_long_id
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_status            in      com_api_type_pkg.t_dict_value    default null
) is
begin
    update lty_lottery_ticket_vw
       set seqnum = io_seqnum
         , status = nvl(i_status, status)
     where id = i_id;
            
    io_seqnum := io_seqnum + 1; 
end modify_lottery_ticket;

procedure remove_lottery_ticket(
    i_id                in      com_api_type_pkg.t_long_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update lty_lottery_ticket_vw
       set seqnum = i_seqnum
     where id = i_id;
            
    delete from lty_lottery_ticket_vw
     where id = i_id;
end remove_lottery_ticket;

end;
/
