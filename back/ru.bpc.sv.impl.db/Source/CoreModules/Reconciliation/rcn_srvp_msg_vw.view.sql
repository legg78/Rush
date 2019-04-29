create or replace force view rcn_srvp_msg_vw as
    select
        id
      , part_key
      , recon_type
      , msg_source
      , recon_status
      , msg_date
      , recon_date
      , inst_id
      , split_hash
      , order_id
      , recon_msg_id
      , payment_order_number
      , order_date
      , order_amount
      , order_currency
      , customer_id
      , customer_number
      , purpose_id
      , purpose_number
      , provider_id
      , provider_number
      , order_status
    from rcn_srvp_msg
/
