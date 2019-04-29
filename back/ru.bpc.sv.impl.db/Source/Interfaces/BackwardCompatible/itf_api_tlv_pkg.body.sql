create or replace package body itf_api_tlv_pkg as

g_ber_tlv_min_length   com_api_type_pkg.t_tiny_id    default 127;
g_ber_tlv_add_length   com_api_type_pkg.t_short_id   default 32768; 


function get_tag_from_line(
      i_line                in varchar2
)
return   com_api_type_pkg.t_attr_name
is
    l_exit        com_api_type_pkg.t_postal_code            default null;
    l_delta       com_api_type_pkg.t_byte_char;
    l_line        varchar2(32767);
    l_my_message  com_api_type_pkg.t_name                   default 'It is impossibly determine name TAG for string - ';

begin
    l_line := i_line;
    loop
        l_delta := substr(l_line, 1, 2);
        l_exit  := l_exit || l_delta;
        if (l_delta is null) or (length(l_delta) <> 2) then
            com_api_error_pkg.raise_error('INVALIDATE_DATA');
        elsif to_number(l_delta, rpad('X', length(l_delta), 'X'))  <= g_ber_tlv_min_length then
              exit;
        else
              l_line := substr(l_line, 3);
        end if;
    end loop;

    return l_exit;
end;

function get_length_from_line(
      i_line                in varchar2
)
return com_api_type_pkg.t_attr_name
is
    l_line          varchar2(32767)   := i_line;
    l_length        com_api_type_pkg.t_mcc         default null;
    l_dec           com_api_type_pkg.t_long_id;
    l_my_message    com_api_type_pkg.t_name        default 'It is impossibly determine LENGTH TAG for string - ';
begin
    l_length    := substr(l_line,1,2);
    l_dec       := to_number(l_length, rpad('X', length(l_length), 'X'));
    if l_dec > g_ber_tlv_min_length then
      l_length := l_length || substr(l_line,3,2);
    end if;
    return l_length;

end;

function get_dec_from_ber_tlv_length(
     i_ber_tlv_length       in varchar2
)
return com_api_type_pkg.t_short_id
is
begin
    if SubStr(i_ber_tlv_length, 1, 1) in ('0', '1', '2', '3', '4', '5', '6', '7') then
        return to_number(i_ber_tlv_length, rpad('X', length(i_ber_tlv_length), 'X'));
    else
        return to_number(i_ber_tlv_length, rpad('X', length(i_ber_tlv_length), 'X'))- g_ber_tlv_add_length;
    end if;
end;

procedure get_tlv_tab(
    i_string        in      varchar2
    , o_tags_tab    out     itf_api_type_pkg.tag_value_tab
)is 
    l_len               com_api_type_pkg.t_short_id;            --length of the i_string            

    l_tag_name          com_api_type_pkg.t_postal_code;         --tag
    l_tag_name_size     com_api_type_pkg.t_tiny_id;             --length of the tag, exmpl FF8023 = 6 
    
    l_tag_len           com_api_type_pkg.t_dict_value;          --length for the value of the tag 
    l_tag_len_size      com_api_type_pkg.t_tiny_id;             --Length-length tag
    l_tag_len_dec       com_api_type_pkg.t_tiny_id;             --the length, the re-encoded to decimal = count symbol
    
    l_tag_value         varchar2(32767);                        --tag value  
    
    l_cur_string        varchar2(32767);    
    l_seq_tag           com_api_type_pkg.t_dict_value default 'DF805D';
    l_seq_tag_len       com_api_type_pkg.t_tiny_id;             --length of the l_seq_tag
    
    i                   com_api_type_pkg.t_tiny_id;      
    l_apq               com_api_type_pkg.t_tiny_id   default 0; --sign composite block
    l_last_parent       com_api_type_pkg.t_tiny_id;  
    
begin
 
    l_len := length(i_string);
    l_cur_string := i_string;
    i := 1;
    l_last_parent := 0;
    
    while l_len > 0 
    loop
        --get tag name
        l_tag_name := itf_api_tlv_pkg.get_tag_from_line(l_cur_string); 
        l_tag_name_size := length(l_tag_name);
        
        --delete tag 
        l_cur_string := substr(l_cur_string, l_tag_name_size + 1);
        l_len := length(l_cur_string);
        
        --length of the tag
        l_tag_len := itf_api_tlv_pkg.get_length_from_line(l_cur_string);
        l_tag_len_size := length(l_tag_len);
        
        --the length, the re-encoded to decimal
        l_tag_len_dec := itf_api_tlv_pkg.get_dec_from_ber_tlv_length(l_tag_len);
        
        --delete length
        l_cur_string := substr(l_cur_string, l_tag_len_size + 1);
        
        --value
        l_tag_value := substr(l_cur_string, 1, l_tag_len_dec);    
        
        --check the following tag to l_seq_tag
        if substr(l_cur_string, 1, length(l_seq_tag)) = l_seq_tag then
            l_apq := 1;
            --delete l_seq_tag
            l_cur_string := substr(l_cur_string, length(l_seq_tag) + 1);
            --length
            l_tag_len := itf_api_tlv_pkg.get_length_from_line(l_cur_string);
            l_tag_len_size := length(l_tag_len);
            l_cur_string := substr(l_cur_string, l_tag_len_size + itf_api_tlv_pkg.get_dec_from_ber_tlv_length(l_tag_len) + 1);
        else 
            --if a simple value, remove the value
            l_apq := 0;
            l_cur_string := substr(l_cur_string, length(l_tag_value) + 1);
        end if;
        l_len := length(l_cur_string);
            
        --save a couple: tag - value
        if o_tags_tab.count = 0 then
            --first element
            o_tags_tab(i).parent_id := null;
        else
            if l_apq = 1 then
                o_tags_tab(i).parent_id := 1;
                l_last_parent := i;
            else
                o_tags_tab(i).parent_id := l_last_parent;                    
            end if;
        end if;
        o_tags_tab(i).tag := l_tag_name;
        o_tags_tab(i).value := l_tag_value;
        o_tags_tab(i).applique := l_apq;
        
        i := i + 1;
        
    end loop;

end;

end itf_api_tlv_pkg;
/