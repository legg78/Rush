create index mup_fpd_CLMS0040_ndx on mup_fpd(decode(status, 'CLMS0040', network_id, null))
/
