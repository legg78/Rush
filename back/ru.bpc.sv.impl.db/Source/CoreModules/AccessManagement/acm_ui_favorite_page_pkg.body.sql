create or replace package body acm_ui_favorite_page_pkg as
/************************************************************
 * Provides an interface for managing user favorite pages. <br />
 * Created by Filimonov A.(filimonov@bpc.ru)  at 10.03.2011 <br />
 * Last changed by $Author: krukov $ <br />
 * $LastChangedDate:: 2011-02-22 16:41:58 +0300#$ <br />
 * Revision: $LastChangedRevision: 8217 $ <br />
 * Module: ACM_UI_FAVORITE_PAGE_PKG <br />
 * @headcom
 *************************************************************/
procedure add_favorite_page(
    i_user_id     in      com_api_type_pkg.t_short_id
  , i_section_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    insert into acm_favorite_page_vw(
        user_id
      , section_id
    ) values (
        i_user_id
      , i_section_id
    );
end;

procedure remove_favorite_page(
    i_user_id     in      com_api_type_pkg.t_short_id
  , i_section_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    delete acm_favorite_page_vw
     where user_id    = i_user_id 
       and section_id = i_section_id;
end;

end;
/
