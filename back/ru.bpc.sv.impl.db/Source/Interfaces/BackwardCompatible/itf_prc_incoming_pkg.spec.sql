create or replace package itf_prc_incoming_pkg is
/************************************************************
 * Interface for loading files <br />
 * Created by Kondratyev A.(kondratyev@bpc.ru)  at 03.06.2013 <br />
 * Last changed by $Author: Kondratyev A. $ <br />
 * $LastChangedDate:: 2013-06-03 13:30:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: itf_prc_incomming_pkg <br />
 * @headcom
 ************************************************************/

    procedure process;

    procedure load_operation_account;
    
    procedure process_account_event(
        i_event_type               in  com_api_type_pkg.t_dict_value
      , i_entity_type              in  com_api_type_pkg.t_dict_value   default null
      , i_account_number_column    in  com_api_type_pkg.t_name         default null
      , i_separate_char            in  com_api_type_pkg.t_byte_char    default null
    );
    
end;
/
