create or replace package acm_ui_favorite_page_pkg as
/************************************************************
 * Provides an interface for managing menu section. <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 12.10.2010 <br />
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-02-22 16:41:58 +0300#$ <br />
 * Revision: $LastChangedRevision: 8217 $ <br />
 * Module: ACM_UI_SECTION_PKG <br />
 * @headcom
 *************************************************************/
procedure add_favorite_page(
    i_user_id     in      com_api_type_pkg.t_short_id
  , i_section_id  in      com_api_type_pkg.t_tiny_id

);


procedure remove_favorite_page(
    i_user_id     in      com_api_type_pkg.t_short_id
  , i_section_id  in      com_api_type_pkg.t_tiny_id
);

end acm_ui_favorite_page_pkg;
/
