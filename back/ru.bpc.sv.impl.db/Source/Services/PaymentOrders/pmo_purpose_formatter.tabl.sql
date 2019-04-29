create table pmo_purpose_formatter (
    id                  number(8)
  , seqnum              number(4)
  , purpose_id          number(8)
  , standard_id         number(4)
  , version_id          number(4)
  , paym_aggr_msg_type  varchar2(8)
  , formatter           clob
)
/

comment on table pmo_purpose_formatter is 'Purpose formatters to build request to payment host'
/

comment on column pmo_purpose_formatter.id is 'Primary key'
/

comment on column pmo_purpose_formatter.seqnum is 'Data version sequence number'
/

comment on column pmo_purpose_formatter.purpose_id is 'Reference to purpose of payment'
/

comment on column pmo_purpose_formatter.standard_id is 'Communication standard of payment host'
/

comment on column pmo_purpose_formatter.version_id is 'Version of communication standard'
/

comment on column pmo_purpose_formatter.paym_aggr_msg_type is 'Payment aggregator message type (check, request, status)'
/

comment on column pmo_purpose_formatter.formatter is 'XML template of message to/from payment host'
/

