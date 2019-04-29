create or replace package body trc_dbms_output_pkg as

-- pakage comments

procedure log(
    i_trace_conf        in      trc_config_pkg.trace_conf
  , i_timestamp         in      timestamp
  , i_level             in      com_api_type_pkg.t_dict_value
  , i_section           in      com_api_type_pkg.t_full_desc
  , i_user              in      com_api_type_pkg.t_oracle_name
  , i_text              in      com_api_type_pkg.t_text
) is
    l_pt          number;
    l_hdr         varchar2(4000);
    l_hdr_len     pls_integer;
    l_line_len    pls_integer;
    l_wrap        number := i_trace_conf.dbms_output_wrap;   --length to wrap long text.
begin
    if i_trace_conf.use_dbms_output = com_api_const_pkg.TRUE then

        sys.dbms_output.enable(buffer_size => null);

        l_hdr := to_char(i_timestamp, 'hh24:mi:ss.ff') || '-' || i_level || '-' || i_section;

        l_hdr_len := length(l_hdr);
        l_line_len := l_wrap - l_hdr_len;

        sys.dbms_output.put(l_hdr);
        l_pt := 1;

        while l_pt <= length(i_text) loop
            if l_pt = 1 then
                sys.dbms_output.put_line(substr(i_text, l_pt, l_line_len));
            else
                sys.dbms_output.put_line(lpad(' ',l_hdr_len)||substr(i_text, l_pt, l_line_len));
            end if;
            l_pt := l_pt + l_line_len;
        end loop;
    end if;
end;

end;
/
