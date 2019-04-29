insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000001, 10000022, 'HOST_DATE_FROM', 'OPER_ID is not null or HOST_DATE_TILL-nvl(HOST_DATE_FROM,sysdate)<60', 10005574)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000002, 10000022, 'HOST_DATE_TILL', null, null)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000003, 10000022, 'CARD_MASK', 'length(CARD_MASK)>=4', 10005326)
/
update acm_priv_limit_field set condition = 'OPER_ID is not null or (nvl(HOST_DATE_TILL,sysdate)-nvl(HOST_DATE_FROM,sysdate)<60)' where id = 10000001
/
update acm_priv_limit_field set condition = 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''_'',-1),instr(CARD_MASK,''%'',-1))+1))>=4)' where id = 10000003
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000004, 10000041, 'HOST_DATE_FROM', 'OPER_ID is not null or (nvl(HOST_DATE_TILL,sysdate)-nvl(HOST_DATE_FROM,sysdate)<60)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000005, 10000041, 'HOST_DATE_TILL', NULL, NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000006, 10000041, 'CARD_MASK', 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''''_'''',-1),instr(CARD_MASK,''''%'''',-1))+1))>=4)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000007, 10000042, 'HOST_DATE_FROM', 'OPER_ID is not null or (nvl(HOST_DATE_TILL,sysdate)-nvl(HOST_DATE_FROM,sysdate)<60)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000008, 10000042, 'HOST_DATE_TILL', NULL, NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000009, 10000042, 'CARD_MASK', 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''''_'''',-1),instr(CARD_MASK,''''%'''',-1))+1))>=4)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000010, 10000043, 'HOST_DATE_FROM', 'OPER_ID is not null or (nvl(HOST_DATE_TILL,sysdate)-nvl(HOST_DATE_FROM,sysdate)<60)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000011, 10000043, 'HOST_DATE_TILL', NULL, NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000012, 10000043, 'CARD_MASK', 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''''_'''',-1),instr(CARD_MASK,''''%'''',-1))+1))>=4)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000013, 10000044, 'HOST_DATE_FROM', 'OPER_ID is not null or (nvl(HOST_DATE_TILL,sysdate)-nvl(HOST_DATE_FROM,sysdate)<60)', NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000014, 10000044, 'HOST_DATE_TILL', NULL, NULL)
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000015, 10000044, 'CARD_MASK', 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''''_'''',-1),instr(CARD_MASK,''''%'''',-1))+1))>=4)', NULL)
/
update acm_priv_limit_field set label_id = 10005574 where id in (10000004, 10000007, 10000010, 10000013)
/
update acm_priv_limit_field set label_id = 10005326 where id in (10000006, 10000009, 10000012, 10000015)
/
update acm_priv_limit_field set condition = 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''_'',-1),instr(CARD_MASK,''%'',-1))+1))>=4' where id in (10000006, 10000009, 10000012, 10000015)
/
update acm_priv_limit_field set condition = 'length(substr(CARD_MASK,greatest(instr(CARD_MASK,''_'',-1),instr(CARD_MASK,''%'',-1))+1))>=4' where id in (10000003)
/
