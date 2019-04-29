create or replace type rcn_srvp_msg_tpr as object(
    id                      number(16)
  , recon_type              varchar2(8)
  , msg_source              varchar2(8)
  , recon_status            varchar2(8)
  , msg_date                date
  , recon_date              date
  , inst_id                 number(4)
  , split_hash              number(4)
  , order_id                number(16)
  , recon_msg_id            number(16)
  , payment_order_number    varchar2(200)
  , order_date              date
  , order_amount            number(22)
  , order_currency          varchar2(3)
  , customer_id             number(12)
  , customer_number         varchar2(200)
  , purpose_id              number(8)
  , purpose_number          varchar2(200)
  , provider_id             number(8)
  , provider_number         varchar2(200)
  , order_status            varchar2(8)
  , params                  com_param_map_tpt
)
/
