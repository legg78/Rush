insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (1, 'E-mail', 200, 'E-mail')
/
insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (2, 'Hard copy', 200, 'Hard copy')
/
insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (3, '\d{10,11}', 140, 'NTF_API_NOTIFICATION_PKG.GET_MOBILE_NUMBER')
/
insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (4, 'Off-line SMS', 200, 'Off-line SMS')
/
update ntf_channel set address_source = 'NTF_API_NOTIFICATION_PKG.GET_EMAIL_ADDRESS' where id = 1
/
insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (5, 'GUI Notification', 200, 'NTF_API_NOTIFICATION_PKG.GET_USER_NAME')
/
insert into ntf_channel (id, address_pattern, mess_max_length, address_source) values (6, 'Push', 200, 'NTF_API_NOTIFICATION_PKG.GET_CUSTOMER_PUSH_NUMBER')
/
update ntf_channel set address_source = 'NTF_API_NOTIFICATION_PKG.GET_POSTAL_ADDRESS' where id = 2
/
