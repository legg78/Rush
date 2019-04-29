create or replace force view rcn_srvp_data_vw as
    select
        id
      , part_key
      , msg_id
      , purpose_id
      , param_id
      , param_value
    from rcn_srvp_data
/
