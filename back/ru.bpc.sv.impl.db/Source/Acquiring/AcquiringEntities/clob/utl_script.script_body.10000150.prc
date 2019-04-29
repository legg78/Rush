begin
    execute immediate 'drop index acq_terminal_number_rvrs_ndx';
    execute immediate 'drop index acq_terminal_number_uk';
    execute immediate 'drop index acq_terminal_device_atm';
end;
