create or replace force view prc_api_client_info_vw as
select sid
     , serial#
     , username
     , status
     , substr(client_info, instr(client_info, '[', 1, 1) + 1, instr(client_info, ']', 1, 1) - instr(client_info, '[', 1, 1) - 1 ) as session_id
     , substr(client_info, instr(client_info, '[', 1, 2) + 1, instr(client_info, ']', 1, 2) - instr(client_info, '[', 1, 2) - 1 ) as thread_number
     , substr(client_info, instr(client_info, '[', 1, 3) + 1, instr(client_info, ']', 1, 3) - instr(client_info, '[', 1, 3) - 1 ) as container_id
     , substr(client_info, instr(client_info, '[', 1, 4) + 1, instr(client_info, ']', 1, 4) - instr(client_info, '[', 1, 4) - 1 ) as process_id
  from v$session
 where client_info like 'sv:sid[%'
/
