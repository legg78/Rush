create or replace force view com_rate_pair_vw as
select id
     , seqnum
     , rate_type
     , inst_id
     , src_currency
     , dst_currency
     , base_rate_type
     , base_rate_mnemonic
     , base_rate_formula
     , req_regular_reg
     , input_mode
     , src_scale
     , dst_scale
     , inverted
     , rate_example
     , display_order
  from com_rate_pair
/