create or replace package din_api_rule_proc_pkg is
/*********************************************************
*  Diners Club operation rules processing <br />
*  Created by Alalykin A.(alalykin@bpcbt.com) at 06.07.2016 <br />
*  Last changed by $Author: alalykin $ <br />
*  $LastChangedDate:: 2016-06-07 18:00:00 +0300#$ <br />
*  Revision: $LastChangedRevision: 1 $ <br />
*  Module: DIN_API_RULE_PROC_PKG <br />
*  @headcom
**********************************************************/

/*
 * Creation of Diners Club financial message during operation processing.
 */
procedure create_fin_message;

end;
/
