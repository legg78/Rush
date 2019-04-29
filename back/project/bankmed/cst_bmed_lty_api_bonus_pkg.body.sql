create or replace package body cst_bmed_lty_api_bonus_pkg as

procedure get_lty_account_info(
    i_card_id          in     com_api_type_pkg.t_long_id
  , o_service_id          out com_api_type_pkg.t_short_id
) is
    l_split_hash          com_api_type_pkg.t_tiny_id;
begin
    l_split_hash := com_api_hash_pkg.get_split_hash(iss_api_const_pkg.ENTITY_TYPE_CARD, i_card_id);

    select min(service_id)
      into o_service_id
      from prd_service_object o
         , prd_service s
     where o.service_id      = s.id
       and s.service_type_id = lty_api_const_pkg.LOYALTY_SERVICE_TYPE_ID
       and o.entity_type     = iss_api_const_pkg.ENTITY_TYPE_CARD
       and o.object_id       = i_card_id
       and o.split_hash      = l_split_hash;
end get_lty_account_info;

function check_customer_has_lty_card(
    i_customer_id        in     com_api_type_pkg.t_medium_id
  , i_service_id         in     com_api_type_pkg.t_short_id   default null
  , i_card_id            in     com_api_type_pkg.t_long_id    default null
  , i_eff_date           in     date
) return com_api_type_pkg.t_boolean as
    l_product_id             com_api_type_pkg.t_short_id;
    l_service_id             com_api_type_pkg.t_short_id;
    l_card_service_id        com_api_type_pkg.t_short_id;
    l_account                acc_api_type_pkg.t_account_rec;
    l_inst_id                com_api_type_pkg.t_inst_id;
    l_welcome_gift           com_api_type_pkg.t_dict_value;
    l_count                  com_api_type_pkg.t_tiny_id;
begin
    if i_service_id is null and i_card_id is not null then
        select inst_id
          into l_inst_id
          from iss_card
         where id = i_card_id;
        
        lty_api_bonus_pkg.get_lty_account_info(
            i_entity_type  => iss_api_const_pkg.ENTITY_TYPE_CARD
          , i_object_id    => i_card_id
          , i_inst_id      => l_inst_id
          , i_eff_date     => null
          , i_mask_error   => com_api_const_pkg.TRUE
          , o_account      => l_account
          , o_service_id   => l_card_service_id
          , o_product_id   => l_product_id
        );
    else
        l_card_service_id := i_service_id;
    end if;

    l_welcome_gift := com_api_flexible_data_pkg.get_flexible_value (
                          i_field_name      => 'WELCOME_GIFT'
                        , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                        , i_object_id       => i_card_id
                      );
    
    l_product_id   := prd_api_product_pkg.get_product_id(
                          i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                        , i_object_id       => i_card_id
                      );
            
    for p in (
         select id as product_id
           from prd_product
        connect by prior id = parent_id
          start with id = (select id 
                             from prd_product 
                            where parent_id is null 
                          connect by prior parent_id = id 
                            start with id = l_product_id)
    ) loop
        select count(1)
          into l_count
          from iss_card c
             , prd_contract ct
             , evt_event_object o
             , evt_event e
             , iss_card_instance ci
         where c.customer_id    = i_customer_id
           and c.id            != i_card_id
           and c.contract_id    = ct.id
           and ct.product_id    = p.product_id
           and c.id             = ci.card_id
           and o.procedure_name = 'CST_BMED_LTY_PRC_BONUS_PKG.EXPORT_NEW_MEMBERS'
           and o.status        in (evt_api_const_pkg.EVENT_STATUS_READY, evt_api_const_pkg.EVENT_STATUS_PROCESSED)
           and o.eff_date       < i_eff_date
           and o.inst_id        = c.inst_id
           and o.entity_type    = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
           and o.object_id      = ci.id
           and ci.inst_id       = c.inst_id
           and ci.split_hash    = o.split_hash
           and e.id             = o.event_id
           and com_api_flexible_data_pkg.get_flexible_value (
                  i_field_name      => 'WELCOME_GIFT'
                , i_entity_type     => iss_api_const_pkg.ENTITY_TYPE_CARD
                , i_object_id       => ci.card_id
              ) is not null
           and rownum           < 2;
                   
        if l_count > 0 then
            return com_api_const_pkg.TRUE;
        end if;
    end loop;

    return com_api_const_pkg.FALSE;

end;

end;
/
