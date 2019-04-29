create table rpt_tag (
    id      number(4) not null
  , seqnum  number(4) not null
  , inst_id number(4)
)
/ 

comment on table rpt_tag is 'Tags to mark reports by it destination'
/

comment on column rpt_tag.id is 'Primary key'
/
comment on column rpt_tag.seqnum is 'Data version sequential number.'
/
comment on column rpt_tag.inst_id is 'Institution identifier'
/
