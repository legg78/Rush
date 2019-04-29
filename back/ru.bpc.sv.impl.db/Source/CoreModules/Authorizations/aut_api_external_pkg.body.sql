create or replace package body aut_api_external_pkg is

procedure get_auth_tag_values(
    i_oper_id           in     com_api_type_pkg.t_long_id
  , i_tag_reference     in     com_api_type_pkg.t_name       default null
  , i_seq_number        in     com_api_type_pkg.t_tiny_id    default null
  , o_ref_cursor           out com_api_type_pkg.t_ref_cur
) is
begin
    open o_ref_cursor for
        select vl.tag_id
             , tg.reference
             , vl.tag_value
          from aut_auth au
             , aup_tag_value vl
             , aup_tag tg
         where vl.auth_id            = au.id
           and au.id                 = i_oper_id
           and tg.tag                = vl.tag_id
           and tg.reference          = nvl(i_tag_reference, tg.reference)
           and nvl(vl.seq_number, 1) = nvl(i_seq_number, 1);
end get_auth_tag_values;

end;
/
