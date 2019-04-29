create index acq_terminal_contract_ndx on acq_terminal (contract_id)
/

create index acq_terminal_number_ndx on acq_terminal (terminal_number)
/

create index acq_terminal_number_rvrs_ndx on acq_terminal (reverse(terminal_number))
/
create unique index acq_terminal_device_atm on acq_terminal (decode(terminal_type, 'TRMT0002', decode(status, 'TRMS0001', device_id)))
/
create unique index acq_terminal_number_uk on acq_terminal (decode(nvl(is_template, 0), 0, terminal_number), decode(nvl(is_template, 0), 0, inst_id))
/
drop index acq_terminal_number_uk
/
create unique index acq_terminal_number_uk on acq_terminal (decode(nvl(is_template, 0), 0, decode(status, 'TRMS0009', null, terminal_number)), decode(nvl(is_template, 0), 0, decode(status, 'TRMS0009', null, inst_id)))
/
