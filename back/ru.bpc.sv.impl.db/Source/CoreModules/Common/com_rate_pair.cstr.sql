alter table com_rate_pair add constraint com_rate_pair_pk primary key (
    id
)
/

create unique index com_rate_pair_uk on com_rate_pair (
    rate_type
    , inst_id
    , src_currency
    , dst_currency
)
/