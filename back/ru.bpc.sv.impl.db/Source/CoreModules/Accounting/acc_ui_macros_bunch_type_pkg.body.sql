create or replace package body acc_ui_macros_bunch_type_pkg is

procedure add (
    o_id                    out  com_api_type_pkg.t_tiny_id
  , o_seqnum                out  com_api_type_pkg.t_seqnum
  , i_macros_type_id     in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
) is
begin
    select acc_macros_bunch_type_seq.nextval into o_id from dual;
    o_seqnum := 1;

    insert into acc_macros_bunch_type_vw (
        id
      , seqnum
      , bunch_type_id
      , inst_id      
    ) values (
        o_id
      , o_seqnum
      , i_bunch_type_id
      , i_inst_id
    );
end;

procedure modify (
    i_id                 in      com_api_type_pkg.t_tiny_id
  , io_seqnum            in out  com_api_type_pkg.t_seqnum
  , i_macros_type_id     in      com_api_type_pkg.t_tiny_id
  , i_bunch_type_id      in      com_api_type_pkg.t_tiny_id
  , i_inst_id            in      com_api_type_pkg.t_inst_id
) is
begin
    update acc_macros_bunch_type_vw t
       set t.seqnum         = io_seqnum
         , t.bunch_type_id  = i_bunch_type_id
         , t.inst_id        = i_inst_id
     where t.id             = i_id;

    io_seqnum := io_seqnum + 1;
end;

procedure remove (
    i_id             in     com_api_type_pkg.t_tiny_id
  , i_seqnum         in     com_api_type_pkg.t_seqnum
) is
begin
    update acc_macros_bunch_type_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acc_macros_bunch_type_vw
     where id     = i_id;
end;

end;
/
