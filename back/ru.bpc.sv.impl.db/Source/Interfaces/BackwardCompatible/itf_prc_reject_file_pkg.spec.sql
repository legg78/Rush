create or replace package itf_prc_reject_file_pkg is
/************************************************************
 * API for process reject files <br /> 
 * Created by Truschelev O.(truschelev@bpcbt.com)  at 28.10.2015 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-28 10:25:00 +0300#$ <br />
 * Revision: $LastChangedRevision: 61628 $ <br />
 * Module: itf_prc_reject_file_pkg <br />
 * @headcom
 ***********************************************************/

FILE_TYPE_REJECT_TURNOVER   constant com_api_type_pkg.t_dict_value := 'FLTPRTRA';
FILE_TYPE_REJECT_CARDS      constant com_api_type_pkg.t_dict_value := 'FLTPRCRD';
FILE_TYPE_REJECT_MERCHANTS  constant com_api_type_pkg.t_dict_value := 'FLTPRMRC';
FILE_TYPE_REJECT_TERMINALS  constant com_api_type_pkg.t_dict_value := 'FLTPRTRM';
FILE_TYPE_REJECT_PERSONS    constant com_api_type_pkg.t_dict_value := 'FLTPRPRS';

procedure process_rejected_turnover;

procedure process_rejected_cards;

procedure process_rejected_merchants;

procedure process_rejected_terminals;

procedure save_rejected_count(
    i_file_type    com_api_type_pkg.t_dict_value
);

procedure process_rejected_persons;

end itf_prc_reject_file_pkg;
/
