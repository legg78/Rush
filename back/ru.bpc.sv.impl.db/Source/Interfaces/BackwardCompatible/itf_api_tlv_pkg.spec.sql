create or replace package itf_api_tlv_pkg as
type tag_value_rec is record
(   
    tag varchar2(10)
    , value varchar2(2000) 
    , parent_id integer
    , applique integer
);
type tag_value_tab is table of tag_value_rec index by binary_integer; 

function get_tag_from_line(
      i_line                in varchar2
)
return  com_api_type_pkg.t_attr_name;

function get_length_from_line(
      i_line                in varchar2
)
return com_api_type_pkg.t_attr_name;


function get_dec_from_ber_tlv_length(
     i_ber_tlv_length       in varchar2
)
return com_api_type_pkg.t_short_id;

procedure get_tlv_tab(
    i_string        in      varchar2
    , o_tags_tab    out     itf_api_type_pkg.tag_value_tab
); 

end itf_api_tlv_pkg;
/