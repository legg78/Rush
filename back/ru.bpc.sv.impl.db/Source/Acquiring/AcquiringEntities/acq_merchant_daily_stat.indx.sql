create index acq_merchant_daily_stat_ndx on acq_merchant_daily_stat(customer_id, stat_date, currency_code)
/
create index acq_merchant_daily_stat_dt_ndx on acq_merchant_daily_stat(trunc(stat_date))
/
