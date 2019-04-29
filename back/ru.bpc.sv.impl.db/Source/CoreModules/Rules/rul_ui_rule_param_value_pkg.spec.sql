create or replace package rul_ui_rule_param_value_pkg is
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
);

procedure set_value_char (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      varchar2
);

procedure set_value_num (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      number
);

procedure set_value_date (
    io_id            in out  com_api_type_pkg.t_short_id
  , io_seqnum        in out  com_api_type_pkg.t_seqnum
  , i_rule_id        in      com_api_type_pkg.t_short_id
  , i_proc_param_id  in      com_api_type_pkg.t_short_id
  , i_param_value    in      date
);

procedure remove (
    i_id             in      com_api_type_pkg.t_short_id
  , i_seqnum         in      com_api_type_pkg.t_seqnum
);

end;
/
