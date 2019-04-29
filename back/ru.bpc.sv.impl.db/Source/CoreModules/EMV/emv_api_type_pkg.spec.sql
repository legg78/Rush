create or replace package emv_api_type_pkg is
/************************************************************
 * EMV types <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 15.06.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_type_pkg <br />
 * @headcom
 ************************************************************/

    type            t_emv_tag_rec is record (
        id                   com_api_type_pkg.t_tiny_id
        , tag                com_api_type_pkg.t_tag
        , min_length         com_api_type_pkg.t_tiny_id
        , max_length         com_api_type_pkg.t_tiny_id
        , data_type          com_api_type_pkg.t_dict_value
        , data_format        com_api_type_pkg.t_name
        , default_value      com_api_type_pkg.t_name
        , tag_type           com_api_type_pkg.t_dict_value
    );
    type            t_emv_tag_tab is table of t_emv_tag_rec index by com_api_type_pkg.t_tag;
    type            t_emv_tag2_tab is table of t_emv_tag_rec index by binary_integer;

    type            t_emv_tag_value_rec is record (
        id                   com_api_type_pkg.t_short_id
        , entity_type        com_api_type_pkg.t_dict_value
        , object_id          com_api_type_pkg.t_short_id
        , tag                com_api_type_pkg.t_tag
        , tag_value          com_api_type_pkg.t_name
        , profile            com_api_type_pkg.t_dict_value
    );
    type            t_emv_tag_value_tab is table of t_emv_tag_value_rec index by binary_integer;

    type            t_emv_element_rec is record (
        id                   com_api_type_pkg.t_short_id
        , seqnum             com_api_type_pkg.t_seqnum
        , parent_id          com_api_type_pkg.t_short_id
        , entity_type        com_api_type_pkg.t_dict_value
        , object_id          com_api_type_pkg.t_short_id
        , element_order      com_api_type_pkg.t_tiny_id
        , code               com_api_type_pkg.t_name
        , tag                com_api_type_pkg.t_tag
        , value              com_api_type_pkg.t_name
        , is_optional        com_api_type_pkg.t_boolean
        , add_length         com_api_type_pkg.t_boolean
        , start_position     com_api_type_pkg.t_tiny_id
        , length             com_api_type_pkg.t_tiny_id
        , is_leaf            com_api_type_pkg.t_boolean
        , profile            com_api_type_pkg.t_dict_value
    );
    type            t_emv_element_tab is table of t_emv_element_rec index by binary_integer;

    type            t_emv_block_rec is record (
        id                   com_api_type_pkg.t_short_id
        , seqnum             com_api_type_pkg.t_seqnum
        , application_id     com_api_type_pkg.t_short_id
        , code               com_api_type_pkg.t_tag
        , include_in_sda     com_api_type_pkg.t_boolean
        , include_in_afl     com_api_type_pkg.t_boolean
        , transport_key_id   com_api_type_pkg.t_short_id
        , encryption_id      com_api_type_pkg.t_short_id
        , block_order        com_api_type_pkg.t_tiny_id
        , profile            com_api_type_pkg.t_dict_value
    );
    type            t_emv_block_tab is table of t_emv_block_rec index by binary_integer;

    type            t_emv_variable_rec is record (
        id                   com_api_type_pkg.t_short_id
        , seqnum             com_api_type_pkg.t_seqnum
        , application_id     com_api_type_pkg.t_short_id
        , variable_type      com_api_type_pkg.t_dict_value
        , profile            com_api_type_pkg.t_dict_value
    );
    type            t_emv_variable_tab is table of t_emv_variable_rec index by binary_integer;

    type            t_emv_application_rec is record (
        id                   com_api_type_pkg.t_short_id
        , seqnum             com_api_type_pkg.t_seqnum
        , aid                com_api_type_pkg.t_name
        , id_owner           com_api_type_pkg.t_name
        , mod_id             com_api_type_pkg.t_tiny_id
        , appl_scheme_id     com_api_type_pkg.t_tiny_id
        , name               com_api_type_pkg.t_name
        , pix                com_api_type_pkg.t_name
    );
    type            t_emv_application_tab is table of t_emv_application_rec index by binary_integer;

    type            t_emv_appl_scheme_rec is record (
        id                   com_api_type_pkg.t_tiny_id
        , seqnum             com_api_type_pkg.t_seqnum
        , inst_id            com_api_type_pkg.t_tiny_id
        , type               com_api_type_pkg.t_dict_value
    );
    type            t_emv_appl_scheme_tab is table of t_emv_appl_scheme_rec index by binary_integer;

    type            t_appl_data_rec is record (
        aid                  com_api_type_pkg.t_name
        , pix                com_api_type_pkg.t_name
        , appl_name          com_api_type_pkg.t_name
        , metadata           com_api_type_pkg.t_lob_data
        , icc_data           com_api_type_pkg.t_lob_data
    );
    type            t_appl_data_tab is table of t_appl_data_rec index by binary_integer;

    type            t_transport_key_data_rec is record (
        id              com_api_type_pkg.t_raw_data
        , tk_type       com_api_type_pkg.t_curr_code
        , c_mode        com_api_type_pkg.t_raw_data
        , dgi_count     com_api_type_pkg.t_tiny_id
        , dgi_list      com_api_type_pkg.t_raw_data
    );
    type            t_transport_key_data_tab is table of t_transport_key_data_rec index by com_api_type_pkg.t_lob_data;

    type            t_emv_script_type_rec is record (
        id                   com_api_type_pkg.t_tiny_id
        , seqnum             com_api_type_pkg.t_seqnum
        , type               com_api_type_pkg.t_dict_value
        , priority           com_api_type_pkg.t_tiny_id
        , mac                com_api_type_pkg.t_boolean
        , tag_71             com_api_type_pkg.t_boolean
        , tag_72             com_api_type_pkg.t_boolean
        , condition          com_api_type_pkg.t_dict_value
        , retransmission     com_api_type_pkg.t_boolean
        , repeat_number      com_api_type_pkg.t_tiny_id
        , class_byte         com_api_type_pkg.t_byte_char
        , instruction_byte   com_api_type_pkg.t_byte_char
        , parameter1         com_api_type_pkg.t_byte_char
        , parameter2         com_api_type_pkg.t_byte_char
        , req_length_data    com_api_type_pkg.t_boolean
    );
    type            t_emv_script_type_tab is table of t_emv_script_type_rec index by binary_integer;

    type            t_emv_script_rec is record (
        id                   com_api_type_pkg.t_long_id
        , object_id          com_api_type_pkg.t_long_id
        , entity_type        com_api_type_pkg.t_dict_value
        , type               com_api_type_pkg.t_dict_value
        , mac                com_api_type_pkg.t_boolean
        , tag_71             com_api_type_pkg.t_boolean
        , tag_72             com_api_type_pkg.t_boolean
        , status             com_api_type_pkg.t_dict_value
        , req_length_data    com_api_type_pkg.t_boolean
        , class_byte         com_api_type_pkg.t_byte_char
        , instruction_byte   com_api_type_pkg.t_byte_char
        , parameter1         com_api_type_pkg.t_byte_char
        , parameter2         com_api_type_pkg.t_byte_char
        , length             com_api_type_pkg.t_tiny_id
        , data               com_api_type_pkg.t_name
    );
    type            t_emv_script_tab is table of t_emv_script_rec index by binary_integer;

    -- Type for storing a list of EMV tags with their data formats
    type            t_emv_tag_type_tab is table of com_name_pair_tpr;

end;
/
