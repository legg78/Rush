create table vis_fin_addendum
(
  id          number(16),
  fin_msg_id  number(16),
  tcr         varchar2(1),
  raw_data    varchar2(4000)
)
/

comment on table vis_fin_addendum is 'VISA financial message additional data (for dispute investigation).'
/

comment on column vis_fin_addendum.id is 'Primary key.'
/

comment on column vis_fin_addendum.fin_msg_id is 'Financial message identifier.'
/

comment on column vis_fin_addendum.tcr is 'Transaction component sequence number.'
/

comment on column vis_fin_addendum.raw_data is 'Raw data from VISA incoming file.'
/
 