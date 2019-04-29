create or replace force view rcn_ui_srvp_msg_vw as
    select
        msg.id
      , msg.part_key
      , msg.recon_type
      , msg.msg_source
      , msg.recon_status
      , msg.msg_date
      , msg.recon_date
      , msg.inst_id                 as recon_inst_id
      , ins.name                    as inst_name
      , msg.split_hash
      , msg.order_id
      , msg.recon_msg_id
      , msg.payment_order_number
      , msg.order_date
      , msg.order_amount
      , msg.order_currency
      , msg.customer_id
      , msg.customer_number
      , msg.purpose_id
      , p.label                      as purpose_name
      , msg.purpose_number
      , msg.provider_id
      , get_text(
            i_table_name  => 'pmo_provider'
          , i_column_name => 'label'
          , i_object_id   => msg.provider_id
          , i_lang        => l.lang
        )                           as provider_name
      , msg.provider_number
      , msg.order_status
      , l.lang
    from rcn_srvp_msg               msg
       , ost_ui_institution_sys_vw  ins
       , pmo_ui_purpose_vw          p
       , com_language_vw            l
   where msg.inst_id = ins.id(+)
     and msg.purpose_id = p.id(+)
     and l.lang = ins.lang
/
