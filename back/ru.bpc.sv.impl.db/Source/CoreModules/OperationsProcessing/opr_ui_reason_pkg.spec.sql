create or replace package opr_ui_reason_pkg is
/************************************************************
 * User interface for mapping of operation reason <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 09.08.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2013-08-09 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: opr_ui_reason_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Add mapping of operation reason
 * @param  o_id                  - Record identifier
 * @param  o_seqnum              - Sequential number of record version
 * @param  i_oper_type           - Operation type
 * @param  i_reason_dict         - Reason dictionary
 */
    procedure add_reason (
        o_id                    out com_api_type_pkg.t_tiny_id
        , o_seqnum              out com_api_type_pkg.t_seqnum
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_reason_dict         in com_api_type_pkg.t_dict_value
        );

/*
 * Modify mapping of operation reason
 * @param  o_id                  - Record identifier
 * @param  o_seqnum              - Sequential number of record version
 * @param  i_oper_type           - Operation type
 * @param  i_reason_dict         - Reason dictionary
 */
    procedure modify_reason (
        i_id                    in com_api_type_pkg.t_tiny_id
        , io_seqnum             in out com_api_type_pkg.t_seqnum
        , i_oper_type           in com_api_type_pkg.t_dict_value
        , i_reason_dict         in com_api_type_pkg.t_dict_value
    );

/*
 * Remove mapping of operation reason
 * @param  i_id                  - Record identifier
 * @param  i_seqnum              - Sequential number of record version
 */
    procedure remove_reason (
        i_id                    in com_api_type_pkg.t_tiny_id
        , i_seqnum              in com_api_type_pkg.t_seqnum
    );

end; 
/
