create index mcw_fpd_CLMS0040_ndx on mcw_fpd(decode(status, 'CLMS0040', network_id, null))
/
