create table pos_batch (
    id number(12 , 0) not null
    , status varchar2(8) not null
    , open_date date not null
    , open_auth_id number(16 , 0) not null
)
/

comment on column pos_batch.id is 'Primary key.'
/
comment on column pos_batch.open_auth_id is 'Substitute authorization ID to be considered as ID that less than all ID''s of transactions in batch.'
/
comment on column pos_batch.open_date is 'Date of batch opening.'
/
comment on column pos_batch.status is 'Batch status.'
/
comment on table pos_batch is 'POS terminal batches.'
/