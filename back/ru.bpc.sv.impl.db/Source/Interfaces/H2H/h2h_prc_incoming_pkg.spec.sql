create or replace package h2h_prc_incoming_pkg as
/*********************************************************
 *  H2H incoming clearing <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 22.06.2018 <br />
 *  Module: H2H_API_INCOMING_PKG <br />
 *  @headcom
 **********************************************************/

/*
 * Loading (import) of an incoming H2H clearing file.
 * @param i_use_institution - it defines which institution code from the file (forw_inst_code or
 *     receiv_inst_code) is used to determine H2H message isntitution ID.
 *     For example, if the forwarding (originator) institution (A) hasn't own CMID (Visa), then its
 *     fin. messages should be created with institution (inst_id) associated with receiving institution (B)
 *     that have to have some CMID value. In this case the parameter should be set to "Receiving institution".
 *     Therefore, Visa will get Visa fin. messages (are created by H2H messages) with CMID of institution (B).
 *     Another situation is when institution (A) has own CMID. In this case it is required to create Visa
 *     fin. messages with CMID of forwarding/originator institution (A). So the parameter should be set to
 *     value "Forwarding/originator institution".
 */
procedure process(
    i_network_id        in      com_api_type_pkg.t_network_id
  , i_use_institution   in      com_api_type_pkg.t_dict_value
);

end;
/
