insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000001, 'PRS_PRC_PERSO_PKG.GENERATE', 0, 9999, 0, 0)
/
insert into prc_process (id, procedure_name, is_parallel, inst_id, is_external, is_container) values (10000033, 'PRS_PRC_PERSO_PKG.GENERATE_WITHOUT_BATCH', 0, 9999, 0, 0)
/
update prc_process set procedure_name = 'PRS_PRC_PERSO_PKG.GENERATE_WITH_BATCH' where id = 10000001
/
