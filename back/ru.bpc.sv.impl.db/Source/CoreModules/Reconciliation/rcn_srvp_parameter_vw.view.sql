create or replace force view rcn_srvp_parameter_vw as
    select
        id
      , inst_id
      , seqnum
      , provider_id
      , purpose_id
      , param_id
    from rcn_srvp_parameter
/
