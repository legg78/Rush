create or replace package body opr_cst_message_pkg is

    function get_message_source return com_api_type_pkg.t_text is
        l_result                  com_api_type_pkg.t_text;
    begin
        --l_result := ' union select ...';
        return l_result;
    end;
  
end;
/
