alter table cmn_tcp_ip add (constraint cmn_tcp_ip_pk primary key(id))
/

alter table cmn_tcp_ip add (constraint cmn_tcp_ip_uk unique (remote_address, remote_port, local_port))
/