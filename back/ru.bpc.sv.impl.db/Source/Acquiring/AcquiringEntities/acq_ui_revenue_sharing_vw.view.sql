create or replace force view acq_ui_revenue_sharing_vw as
select a.id
     , a.seqnum
     , a.terminal_id
     , a.customer_id
     , a.account_id
     , a.provider_id
     , a.mod_id
     , a.fee_type
     , a.fee_id
     , a.inst_id
     , com_ui_object_pkg.get_object_desc('ENTTCUST', a.customer_id) customer_name
     , t.terminal_number
     , c.account_number
     , m.customer_number
     , fcl_ui_fee_pkg.get_fee_desc(a.fee_id) fee_desc
     , com_ui_object_pkg.get_object_desc('ENTTCUST', prc.id) provider_name
     , com_api_i18n_pkg.get_text(
            i_table_name    => 'RUL_MOD'
          , i_column_name   => 'NAME'
          , i_object_id     => a.mod_id
          , i_lang          => get_user_lang
        ) mod_name
     , rm.condition
     , a.service_id
     , a.purpose_id   
     , com_api_i18n_pkg.get_text(
            i_table_name  => 'PMO_SERVICE'
          , i_column_name => 'LABEL'
          , i_object_id   => a.service_id
          , i_lang        => get_user_lang
        ) service_name
  from acq_revenue_sharing a
     , acq_terminal t
     , acc_account c
     , prd_customer m
     , pmo_provider pr
     , prd_customer prc
     , rul_mod rm
 where a.account_id  = c.id(+)
   and a.terminal_id = t.id(+)
   and a.customer_id = m.id(+)
   and a.provider_id = pr.id(+)
   and pr.id = prc.ext_object_id(+)
   and prc.ext_entity_type(+) = 'ENTTSRVP'
   and a.mod_id = rm.id(+)
   and a.inst_id in (select inst_id from acm_cu_inst_vw)
/
