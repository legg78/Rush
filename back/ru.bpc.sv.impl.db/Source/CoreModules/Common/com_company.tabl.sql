create table com_company (
    id            number(8)
  , seqnum        number(4)
  , embossed_name varchar2(200)
  , incorp_form   varchar2(8)
  , inst_id       number(4)
)
/
comment on table com_company is 'Company''s information.'
/
comment on column com_company.id is 'Primary key.'
/
comment on column com_company.seqnum is 'Sequence number. Describe data version.'
/
comment on column com_company.embossed_name is 'Company''s embossed name.'
/
comment on column com_company.incorp_form is 'Incorporation form'
/
comment on column com_company.inst_id is 'Owner institution identifier.'
/