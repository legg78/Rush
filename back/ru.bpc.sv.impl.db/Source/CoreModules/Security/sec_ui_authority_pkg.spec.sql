create or replace package sec_ui_authority_pkg is
/************************************************************
 * User interface for certificate authority centers <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 12.05.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: sec_ui_authority_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Register new certificate authority center
 * @param o_id                  Authority identificator
 * @param o_seqnum              Sequence number
 * @param i_type                Authority type
 * @param i_rid                 Registered application provider identifier
 * @param i_lang                Descriptions language
 * @param i_name                Authority name
 */
    procedure add_authority (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_rid                 in sec_api_type_pkg.t_subject_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
    );

/*
 * Modify certificate authority center
 * @param i_id                  Authority identificator
 * @param io_seqnum             Sequence number
 * @param i_type                Authority type
 * @param i_rid                 Registered application provider identifier
 * @param i_lang                Descriptions language
 * @param i_name                Authority name
 */
    procedure modify_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_type                in com_api_type_pkg.t_dict_value
        , i_rid                 in sec_api_type_pkg.t_subject_id
        , i_lang                in com_api_type_pkg.t_dict_value
        , i_name                in com_api_type_pkg.t_name
    );

/*
 * Remove certificate authority center
 * @param i_id                  Authority identificator
 * @param i_seqnum              Sequence number
 */
    procedure remove_authority (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end;
/
