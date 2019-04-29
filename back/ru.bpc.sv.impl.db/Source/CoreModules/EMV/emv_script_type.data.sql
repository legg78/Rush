insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (1, 1, 'SRTP0030', 1, 1, 1, 1, NULL, 0, 1, '84', '1E', '00', '00', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (2, 1, 'SRTP0040', 1, 1, 1, 1, NULL, 0, 1, '84', '18', '00', '00', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (3, 1, 'SRTP0010', 1, 1, 1, 1, NULL, 0, 1, '84', '16', '00', '00', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (4, 1, 'SRTP0060', 1, 0, 1, 1, NULL, 0, 1, '84', '24', '00', '02', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (5, 1, 'SRTP0050', 1, 0, 1, 1, NULL, 0, 1, '84', '24', '00', '00', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (6, 1, 'SRTP0070', 1, 1, 0, 1, NULL, 0, 1, '84', 'DA', '9F', '14', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (7, 1, 'SRTP0080', 1, 1, 0, 1, NULL, 0, 1, '84', 'DA', '9F', '23', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (8, 1, 'SRTP0090', 1, 1, 0, 1, NULL, 0, 1, '84', 'DA', '00', 'CA', 0)
/
insert into emv_script_type ( id, seqnum, type, priority, mac, tag_71, tag_72, condition, retransmission, repeat_count, class_byte, instruction_byte, parameter1, parameter2, req_length_data ) values (9, 1, 'SRTP0100', 1, 1, 0, 1, NULL, 0, 1, '84', 'DA', '00', 'CB', 0)
/
update emv_script_type set mac = 1 where id in (4, 5)
/
update emv_script_type set form_url = '/pages/emv/forms/formSTR0011.jspx' where id in (6,7,8, 9)
/