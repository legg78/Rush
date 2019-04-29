create or replace package body rul_ui_rule_param_value_pkg is
/*********************************************************
*  User interface for Rules procedures <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 21.01.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rul_ui_rule_param_value_pkg <br />
*  @headcom
**********************************************************/ 
procedure set_value (
    io_id           in out  com_api_type_pkg.t_short_id
  , io_seqnum       in out  com_api_type_pkg.t_seqnum
  , i_rule_id       in      com_api_type_pkg.t_short_id
  , i_proc_param_id in      com_api_type_pkg.t_short_id
  , i_value_v       in      varchar2 default null
  , i_value_d       in      date     default null
  , i_value_n       in      number   default null
) is
    l_value         com_api_type_pkg.t_name;
begin
    l_value  := case
                when i_value_v is not null then i_value_v
                when i_value_d is not null then to_char(i_value_d, com_api_const_pkg.DATE_FORMAT)
                when i_value_n is not null then to_char(i_value_n, com_api_const_pkg.NUMBER_FORMAT)
                end;
    if io_id is null then
        select rul_rule_param_value_seq.nextval
          into io_id
          from dual;
            
        io_seqnum := 1;
            
        insert into rul_rule_param_value_vw (
            id
          , seqnum
          , rule_id
          , proc_param_id
          , param_value
        ) values (
            io_id
          , io_seqnum
          , i_rule_id
          , i_proc_param_id
          , l_value
        );        
    else
        update rul_rule_param_value_vw
           set rule_id       = i_rule_id
             , proc_param_id = i_proc_param_id
             , param_value   = l_value
             , seqnum        = io_seqnum
         where id            = io_id;
                
        io_seqnum := io_seqnum + 1;
    end if;
end;

procedure set_value_char (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      varchar2
) is
begin
    set_value (
        io_id            => io_id
      , io_seqnum        => io_seqnum
      , i_rule_id        => i_rule_id
      , i_proc_param_id  => i_proc_param_id
      , i_value_v        => i_param_value
    );
end;

procedure set_value_num (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      number
) is
begin
    set_value (
        io_id            => io_id
      , io_seqnum        => io_seqnum
      , i_rule_id        => i_rule_id
      , i_proc_param_id  => i_proc_param_id
      , i_value_n        => i_param_value
    );
end;

procedure set_value_date (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      date
)is
begin
    set_value (
        io_id            => io_id
      , io_seqnum        => io_seqnum
      , i_rule_id        => i_rule_id
      , i_proc_param_id  => i_proc_param_id
      , i_value_d        => i_param_value
    );

end;

procedure remove (
    i_id        in     com_api_type_pkg.t_short_id
  , i_seqnum    in     com_api_type_pkg.t_seqnum
) is
begin
    if i_id is not null then
        update rul_rule_param_value_vw
           set seqnum = i_seqnum
         where id     = i_id;
        
        delete from rul_rule_param_value_vw
         where id     = i_id;
    end if;        
end;

end;
/
