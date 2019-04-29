create table acq_merchant_type_tree
(
    id                    number(4)     not null,
    seqnum                number(3),
    merchant_type         varchar2(8)   not null,
    parent_merchant_type  varchar2(8),
    inst_id               number(4)
)
/

comment on table acq_merchant_type_tree is 'Merchant structure defined by bank-acquirer.'
/

comment on column acq_merchant_type_tree.id is 'Primary key.'
/

comment on column acq_merchant_type_tree.merchant_type is 'Merchant type. Describe level of acquiring hierarchy.'
/

comment on column acq_merchant_type_tree.parent_merchant_type is 'Parent merchant type.'
/

comment on column acq_merchant_type_tree.inst_id is 'Institution identifier.'
/

comment on column acq_merchant_type_tree.seqnum is 'Sequence number. Describe data version.'
/
