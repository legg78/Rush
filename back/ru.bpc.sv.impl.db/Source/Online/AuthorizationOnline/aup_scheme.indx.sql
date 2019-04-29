update aup_scheme set system_name = 'SCHEME_' || id where system_name is null
/
create unique index aup_scheme_uk on aup_scheme (inst_id, upper(system_name))
/