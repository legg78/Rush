create or replace package emv_ui_block_pkg is
/************************************************************
 * User interface for EMV data blocks <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 20.09.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_ui_block_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add block
 * @param  o_id                  - Block identifier
 * @param  o_seqnum              - Block sequence number
 * @param  i_application_id      - Application indentifier
 * @param  i_code                - Unique data block code
 * @param  i_include_in_sda      - Block include in sda
 * @param  i_include_in_afl      - Block include in application file locator
 * @param  i_transport_key_id    - Transport key indentifier
 * @param  i_encryption_id       - Encryption indentifier
 * @param  i_block_order         - Order within block
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 */ 
    procedure add_block (
        o_id                        out com_api_type_pkg.t_short_id
        , o_seqnum                  out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_code                    in com_api_type_pkg.t_tag
        , i_include_in_sda          in com_api_type_pkg.t_boolean
        , i_include_in_afl          in com_api_type_pkg.t_boolean
        , i_transport_key_id        in com_api_type_pkg.t_short_id
        , i_encryption_id           in com_api_type_pkg.t_short_id
        , i_block_order             in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    );

/*
 * Modify block
 * @param  o_id                  - Block identifier
 * @param  io_seqnum             - Block sequence number
 * @param  i_application_id      - Application indentifier
 * @param  i_code                - Unique data block code
 * @param  i_include_in_sda      - Block include in sda
 * @param  i_include_in_afl      - Block include in application file locator
 * @param  i_transport_key_id    - Transport key indentifier
 * @param  i_encryption_id       - Encryption indentifier
 * @param  i_block_order         - Order within block
 * @param  i_profile             - Profile of EMV application (EPFL dictionary)
 */ 
    procedure modify_block (
        i_id                        in com_api_type_pkg.t_short_id
        , io_seqnum                 in out com_api_type_pkg.t_seqnum
        , i_application_id          in com_api_type_pkg.t_short_id
        , i_code                    in com_api_type_pkg.t_tag
        , i_include_in_sda          in com_api_type_pkg.t_boolean
        , i_include_in_afl          in com_api_type_pkg.t_boolean
        , i_transport_key_id        in com_api_type_pkg.t_short_id
        , i_encryption_id           in com_api_type_pkg.t_short_id
        , i_block_order             in com_api_type_pkg.t_tiny_id
        , i_profile                 in com_api_type_pkg.t_dict_value
    );

/*
 * Remove block
 * @param  i_id                  - Block identifier
 * @param  i_seqnum              - Block sequence number
 */ 
    procedure remove_block (
        i_id                        in com_api_type_pkg.t_short_id
        , i_seqnum                  in com_api_type_pkg.t_seqnum
    );

end;
/
