insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1089, 1, 1038, 10, 'MbFreqUnholdOprDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1090, 1, 1038, 20, 'MbFreqUnholdOprRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1112, 1, 1048, 10, 'MbBalanceTransferFromPrepaidCardDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1113, 1, 1048, 20, 'MbBalanceTransferFromPrepaidCardRS')
/
update gui_wizard_step set step_source='MbUnholdOprRS' where id=1090
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1114, 1, 1049, 10, 'MbFreqBalanceCorrectionDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1115, 1, 1049, 20, 'MbBalanceCorrectionRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1118, 1, 1051, 10, 'MbFreqCardOperationDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1119, 1, 1051, 20, 'MbCardOperationRS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1137, 1, 1062, 2, 'MbDualFeeCollectionDS')
/
insert into gui_wizard_step (id, seqnum, wizard_id, step_order, step_source) values (1138, 1, 1062, 3, 'MbDualFeeCollectionRS')
/
