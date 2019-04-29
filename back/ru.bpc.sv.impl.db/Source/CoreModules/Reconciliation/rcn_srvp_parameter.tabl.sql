create table rcn_srvp_parameter(
    id              number(8, 0) not null
  , inst_id         number(4, 0)
  , seqnum          number(4, 0)
  , provider_id     number(8, 0)
  , purpose_id      number(8, 0)
  , param_id        number(8, 0)
)
/

comment on table rcn_srvp_parameter is 'Additional parameters for reconciliation'
/
comment on column rcn_srvp_parameter.id is 'Record identifier'
/
comment on column rcn_srvp_parameter.inst_id is 'Institution identifier'
/
comment on column rcn_srvp_parameter.seqnum is 'Sequence number'
/
comment on column rcn_srvp_parameter.provider_id is 'Service provider identifier'
/
comment on column rcn_srvp_parameter.purpose_id is 'ID of payment order purpose'
/
comment on column rcn_srvp_parameter.param_id is 'Reference to payment parameter from pmo_parameter'
/
