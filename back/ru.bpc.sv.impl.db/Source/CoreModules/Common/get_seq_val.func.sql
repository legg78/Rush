create or replace function get_seq_val (
    i_sequence_name       in com_api_type_pkg.t_name
    , i_val_type          in com_api_type_pkg.t_name default 'nextval'
) return com_api_type_pkg.t_long_id is
    l_result              com_api_type_pkg.t_long_id;
begin
    execute immediate 'select ' || i_sequence_name || '.' || i_val_type || ' from dual' into l_result;
    return l_result;
exception
    when others then
        trc_log_pkg.error (
            i_text          => 'Error executing ' || i_sequence_name || '.' || i_val_type || ':' || sqlerrm
        );
        raise;
end get_seq_val;
/
