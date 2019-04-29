create or replace type stragg_tpr
   authid current_user
as object (
curr_str   varchar2 (32767),
member function get_separator return varchar2,

static function odciaggregateinitialize (
    sctx in out stragg_tpr
) return number,
member function odciaggregateiterate (
    self   in out   stragg_tpr
  , p1     in       varchar2
) return number,

member function odciaggregateterminate (
    self         in     stragg_tpr
  , returnvalue     out varchar2
  , flags        in     number
)
  return number,
member function odciaggregatemerge (
    self    in out   stragg_tpr
  , sctx2   in       stragg_tpr
)
  return number
);
/


create or replace type body stragg_tpr
is
member function get_separator return varchar2 is 
begin 
    return nvl(com_api_const_pkg.get_separator, ','); 
end;

static function odciaggregateinitialize (
    sctx in out stragg_tpr
) return number is
begin
  sctx := stragg_tpr (null);
  return odciconst.success;
end;

member function odciaggregateiterate (
    self   in out   stragg_tpr
  , p1     in       varchar2
) return number
is
begin
    if curr_str is not null then
        curr_str := curr_str || get_separator || p1;
    else
       curr_str := p1;
    end if;

    return odciconst.success;
end;

member function odciaggregateterminate (
    self         in       stragg_tpr
  , returnvalue     out      varchar2
  , flags        in       number
) return number is
begin
    returnvalue := curr_str;
    return odciconst.success;
end;

member function odciaggregatemerge (
    self    in out   stragg_tpr
  , sctx2   in       stragg_tpr
) return number
is
begin
    if (sctx2.curr_str is not null) then
        self.curr_str := self.curr_str || get_separator || sctx2.curr_str;
    end if;

    return odciconst.success;
end;

end;
/
