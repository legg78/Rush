create or replace package body itf_api_type_pkg as

    function pad_number (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        case 
            when nvl(lengthb(i_data), 0) < i_min_length then return lpad(nvl(i_data, '0'), i_min_length, '0');
            when nvl(lengthb(i_data), 0) > i_max_length then return substr(i_data, - i_max_length);
            else return i_data;
        end case;
    end;
          
    function pad_char (
        i_data              in varchar2
        , i_min_length      in integer
        , i_max_length      in integer
    ) return varchar2 is
    begin
        case 
            when nvl(lengthb(i_data), 0) < i_min_length then return rpad(nvl(i_data, ' '), i_min_length, ' ');
            when nvl(lengthb(i_data), 0) > i_max_length then return substr(i_data, 1, i_max_length);
            else return i_data;
        end case;
    end;
end;
/
