create or replace package body cst_woo_evt_rule_proc_pkg is
/*********************************************************
 *  API for event rule processing for Woori bank <br />
 *  Created by Man Do(m.do@bpcbt.com) at 18.10.2018 <br />
 *  Module: CST_WOO_EVT_RULE_PROC_PKG <br />
 *  @headcom
 **********************************************************/

procedure unload_card_info_by_customer is
    l_params                    com_api_type_pkg.t_param_tab;
    l_object_id                 com_api_type_pkg.t_long_id;  
    l_entity_type               com_api_type_pkg.t_dict_value;
    l_param_tab_evt             com_api_type_pkg.t_param_tab;
begin
    l_params        := evt_api_shared_data_pkg.g_params;
    l_object_id     := rul_api_param_pkg.get_param_num('OBJECT_ID', l_params);
    l_entity_type   := rul_api_param_pkg.get_param_char('ENTITY_TYPE', l_params);

    trc_log_pkg.debug(
        i_text => 'Register event:' || cst_woo_const_pkg.EVT_TYPE_UNLOADING_CARD_INFO
    );

    if l_entity_type = com_api_const_pkg.ENTITY_TYPE_CUSTOMER then
        for rec in(
            select i.card_id
                 , c.split_hash
                 , c.inst_id 
              from iss_card c
                 , iss_card_instance i
                 , net_card_type_feature f
             where c.id = i.card_id
               and c.card_type_id = f.card_type_id
               and f.card_feature = net_api_const_pkg.CARD_FEATURE_STATUS_CREDIT
               and i.state = iss_api_const_pkg.CARD_STATE_ACTIVE
               and c.customer_id = l_object_id
        )loop
            evt_api_event_pkg.register_event(
                i_event_type    => cst_woo_const_pkg.EVT_TYPE_UNLOADING_CARD_INFO
              , i_eff_date      => get_sysdate
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD
              , i_object_id     => rec.card_id
              , i_inst_id       => rec.inst_id
              , i_split_hash    => rec.split_hash
              , i_param_tab     => l_param_tab_evt
            );
        end loop;
    else 
        trc_log_pkg.debug(
            i_text          => 'l_entity_type [#1] is not an entity customer type' 
          , i_env_param1    => l_entity_type
    );
    end if;
    
end unload_card_info_by_customer;

end;
/
