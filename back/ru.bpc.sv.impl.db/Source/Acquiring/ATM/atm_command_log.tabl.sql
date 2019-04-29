create table atm_command_log(
    terminal_id         number(8)
  , user_id             number(8)
  , command_date        date
  , command             varchar2(8)
  , command_result      varchar2(8)
)
/

comment on table atm_command_log is 'History of commands sent to the ATM'
/

comment on column atm_command_log.terminal_id is 'Reference to terminal'
/

comment on column atm_command_log.user_id is 'User sent the command'
/

comment on column atm_command_log.command_date is 'Date of command'
/

comment on column atm_command_log.command is 'Command type'
/

comment on column atm_command_log.command_result is 'Result of command execution'
/