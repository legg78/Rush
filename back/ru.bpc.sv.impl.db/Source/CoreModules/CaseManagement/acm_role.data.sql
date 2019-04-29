insert into acm_role (id, name, notif_scheme_id, inst_id) values (1007, 'SETTLEMENT_TEAM', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1008, 'SETTLEMENT_SUPERVISOR', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1009, 'ATM_TEAM', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1010, 'ACQUIRING_TEAM', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1011, 'CHARGEBACK_TEAM', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1012, 'BRANCH_TEAM', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1013, 'UNIVERSAL_USER', NULL, 9999)
/
insert into acm_role (id, name, notif_scheme_id, inst_id) values (1014, 'DISPUTE_ADMIN', NULL, 9999)
/
update acm_role set notif_scheme_id = 1005 where id = 1010
/
update acm_role set notif_scheme_id = 1003 where id = 1011
/
update acm_role set notif_scheme_id = 1004 where id = 1007
/
update acm_role set notif_scheme_id = 1002 where id = 1012
/
