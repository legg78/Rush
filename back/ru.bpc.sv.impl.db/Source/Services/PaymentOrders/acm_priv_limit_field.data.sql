insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000016, 10000045, 'ORDER_DATE_FROM', 'trunc(nvl(ORDER_DATE_FROM, sysdate) - trunc(sysdate) <= 60', 10013494)
/
update acm_priv_limit_field set condition = 'trunc(nvl(ORDER_DATE_TO, sysdate)) - trunc(nvl(ORDER_DATE_FROM, sysdate)) <= 60' where id = 10000016
/
insert into acm_priv_limit_field (id, priv_limit_id, field, condition, label_id) values (10000017, 10000045, 'ORDER_DATE_TO', '1=1', 10005216)
/
