create table prs_batch (
    id               number(8) not null
    , seqnum         number(4)
    , inst_id        number(4)
    , agent_id       number(8)
    , product_id     number(8)
    , card_type_id   number(4)
    , blank_type_id  number(4)
    , card_count     number(8)
    , hsm_device_id  number(4)
    , status         varchar2(8)
    , status_date    timestamp
    , sort_id        number(4)
    , perso_priority varchar2(8)
)
/
comment on table prs_batch is 'Batch for personalisation purpose'
/
comment on column prs_batch.id is 'Batch identifier'
/
comment on column prs_batch.seqnum is 'Sequential number of record version'
/
comment on column prs_batch.inst_id is 'Owner institution identifier'
/
comment on column prs_batch.agent_id is 'Agent identifier'
/
comment on column prs_batch.product_id is 'Issuing product identifier'
/
comment on column prs_batch.card_type_id is 'Card type identifier'
/
comment on column prs_batch.blank_type_id is 'Identifier of blank for card embossing'
/
comment on column prs_batch.card_count is 'Card count for embossing'
/
comment on column prs_batch.hsm_device_id is 'HSM device identifier'
/
comment on column prs_batch.status is 'Batch status (BTST dictionary)'
/
comment on column prs_batch.status_date is 'Batch processed time'
/
comment on column prs_batch.sort_id is 'Sort identifier'
/
comment on column prs_batch.perso_priority is 'Personalization priority'
/

alter table prs_batch add batch_name varchar2(200)
/
comment on column prs_batch.batch_name is 'Batch name'
/
alter table prs_batch add reissue_reason varchar2(8)
/
comment on column prs_batch.reissue_reason is 'Reason of reissuing defines reissue command and reissuing flags (EVNT dictionary)'
/