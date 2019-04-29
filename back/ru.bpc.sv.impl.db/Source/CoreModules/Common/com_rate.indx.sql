create index com_rate_scan_ndx on com_rate (
    inst_id
    , src_currency
    , dst_currency
    , rate_type
    , status
    , eff_date
    , reg_date
    , exp_date
    , eff_rate
)
/
