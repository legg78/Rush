create or replace package utl_api_deperso_pkg is
/**********************************************************
 * API for depersonalization of personal data <br />
 * Created by Kopachev D.(kopachev@bpcbt.com)  at 17.01.2017 <br />
 * Last changed by $Author: fomichev $ <br />
 * $LastChangedDate:: 2017-07-28 17:36:45 +0400$ <br />
 * Revision: $LastChangedRevision: 7636 $ <br />
 * Module: utl_api_deperso_pkg <br />
 * @headcom
 **********************************************************/
 
procedure create_indexes;
-- RUN SENSIBLE!
    
procedure before_deperso (
    i_start_date   in       date default null
  , i_end_date     in       date default null
);
    
procedure run_deperso_card (
    i_start_date   in       date default null
  , i_end_date     in       date default null
);
    
procedure run_deperso_data;
    
procedure after_deperso;

end utl_api_deperso_pkg;
/
