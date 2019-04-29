insert into acm_user_password (user_id, password_hash, is_active, expire_date) values (1, '{SHA-1}Mjzw2TV3fz7HrAUtilZ4aIcYStib1wM=', 1, null)
/
insert into acm_user_password (user_id, password_hash, is_active, expire_date) values (2, '{SHA-1}Xr6AzS2ATsGmBBe9QF/HsExiPzAfIkg=', 1, null)
/
insert into acm_user_password (user_id, password_hash, is_active, expire_date) values (10000011, '{SHA-1}P7sgKmhiVBcEC0tEJSSi0/UK5Puqlsw=', 1, null)
/
update acm_user_password set password_hash = '{SHA-1}NYLH5Wv0YK0tdbLbBSih3odIMf4=' where user_id = 1
/
update acm_user_password set password_hash = '{SHA-1}f/FD+pD9KPVvo5HqEyljmDnbJD0=' where user_id = 2
/
update acm_user_password set password_hash = '{SHA-1}urOB1lb73I3nBWsgOX7OM/r1GPw=' where user_id = 10000011
/
insert into acm_user_password (user_id, password_hash, is_active, expire_date) values (4, '0DPiKuNIrrVmD8IUCuw1hQxNqZc=', 1 , null)
/
update acm_user_password set password_hash = '{SHA-1}0DPiKuNIrrVmD8IUCuw1hQxNqZc=' where user_id = 1
/
