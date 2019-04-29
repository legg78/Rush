insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1009, 1, 'LTY_PRC_BONUS_PKG.EXPORT_BONUS_FILE', 'CYTP1104', 1)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1115, 1, 'LTY_PRC_BONUS_PKG.EXPORT_BONUS_FILE', 'EVNT1103', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1116, 1, 'LTY_PRC_BONUS_PKG.EXPORT_BONUS_FILE', 'EVNT1104', 20)
/
delete from evt_subscriber where id = 1116
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1204, 1, 'LTY_PRC_LOTTERY_TICKETS_PKG.EXPORT_FILE', 'EVNT1109', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1297, 1, 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL', 'CYTP0420', 10)
/
insert into evt_subscriber (id, seqnum, procedure_name, event_type, priority) values (1298, 1, 'LTY_PRC_PROMO_PKG.CHECK_PROMOTION_LEVEL', 'CYTP0140', 10)
/
