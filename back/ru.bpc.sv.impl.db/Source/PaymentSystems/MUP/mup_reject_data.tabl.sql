create table mup_reject_data 
(
  id                      number(16)
  , reject_id             number(16)
  , original_id           number(16)
  , reject_type           varchar2(8)
  , process_date          date
  , originator_network    number(16)
  , destination_network   number(16)
  , scheme                varchar2(50)
  , reject_code           varchar2(50)
  , operation_type        varchar2(8)
  , assigned              varchar2(50)
  , card_number           varchar2(50)
  , arn                   varchar2(50)
  , resolution_mode       varchar2(8)
  , resolution_date       date
  , status                varchar2(8)
  , updated_oper_id       number(16)
  , reversal_oper_id      number(16)
)
/

comment on table mup_reject_data is 'Information about why operation was rejected'
/
comment on column mup_reject_data.id is 'Unique identifier'
/
comment on column mup_reject_data.reject_id is 'FK (mcw_reject.ID)'
/
comment on column mup_reject_data.original_id is 'Original operation id (mcw_REJECTED.ORIGINAL_ID -> OPR_OPERATION.ID)'
/
comment on column mup_reject_data.reject_type is 'Reject type (RJTP0001 - primary validation, RJTP0002 - business validation, RJTP0003 - regulators schemes)'
/
comment on column mup_reject_data.process_date is 'Process date (date when the validations were performed by SmartVista)'
/
comment on column mup_reject_data.originator_network is 'Source Network (ServiRed, 4B, Visa, Master, Amex, Diners, JCB, CUP, CECA, TMA, TMT)'
/
comment on column mup_reject_data.destination_network is 'Destination Network (ServiRed, 4B, Visa, Master, Amex, Diners, JCB, CUP, CECA, TMA, TMT)'
/
comment on column mup_reject_data.scheme is 'Scheme (4b or Servired)'
/
comment on column mup_reject_data.reject_code is 'Reject codes (for REJECT_TYPE = RJTP0001 - primary validation codes, for RJTP0002 –  business primary validation codes, for RJTP0003 – provided by regulators)'
/
comment on column mup_reject_data.operation_type is 'Operation type (original transaction, request for copy, chargeback, 2-nd presentment, fee collection)'
/
comment on column mup_reject_data.assigned is 'User identifier (ID of department and person in charge of the resolution of the reject transaction)'
/
comment on column mup_reject_data.card_number is 'Card number (OPR_CARD.CARD_NUMBER)'
/
comment on column mup_reject_data.arn is 'Acquiring reference number (not defined in VISA TC44 and VISA Rejected Item File)'
/
comment on column mup_reject_data.resolution_mode is 'Resolution mode (RJMD001 - FORWARD, RJMD002 - CANCELED, RJMD003 - NO ACTIONS)'
/
comment on column mup_reject_data.resolution_date is 'Resolution date'
/
comment on column mup_reject_data.status is 'Reject status (RJST0001 - Opened, RJST0002 - Closed, RJST0003 - Resolved)'
/
comment on column mup_reject_data.updated_oper_id is 'New operation id generated when field of original operation was updated first time, original not changed (stays in status Rejected) (OPR_OPERATION.ID)'
/
comment on column mup_reject_data.reversal_oper_id is 'New operation id - reversal generated during loading of rejected operation for correct account balance in network (OPR_OPERATION.ID)'
/
comment on column mup_reject_data.reject_id is 'FK (mup_reject.ID)'
/
comment on column mup_reject_data.original_id is 'Original operation id (mup_REJECTED.ORIGINAL_ID -> OPR_OPERATION.ID)'
/
