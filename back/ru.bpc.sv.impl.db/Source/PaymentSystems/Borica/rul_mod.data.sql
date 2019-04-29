insert into rul_mod (id, scale_id, condition, priority, seqnum) values (1038, 1014, ':IS_REVERSAL = 0 AND :STTL_TYPE = ''STTT5005'' AND :MSG_TYPE != ''MSGTPRES''', 100, 1)
/
delete from rul_mod where id = 1038
/
 