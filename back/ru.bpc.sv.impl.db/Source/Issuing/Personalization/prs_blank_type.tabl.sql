create table prs_blank_type (
    id              number(4) not null
    , card_type_id  number(4)
    , inst_id       number(4)
    , seqnum        number(4)
    , is_active     number(1)
)
/
comment on table prs_blank_type is 'Blank for card embossing'
/
comment on column prs_blank_type.id is 'Batch type identifier'
/
comment on column prs_blank_type.card_type_id is 'Card type identifier'
/
comment on column prs_blank_type.inst_id is 'Owner institution identifier'
/
comment on column prs_blank_type.seqnum is 'Sequential number of record version'
/
comment on column prs_blank_type.is_active is 'Active if blank type was used in personalization'
/
alter table prs_blank_type add is_contactless number(1)
/
comment on column prs_blank_type.is_contactless is 'Flag that blank type is contactless'
/
