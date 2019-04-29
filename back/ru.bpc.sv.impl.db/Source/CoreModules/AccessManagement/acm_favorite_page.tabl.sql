create table acm_favorite_page (
    user_id     number(8)
  , section_id  number(4)
)
/

comment on table acm_favorite_page is 'User Favorite Pages'
/

comment on column acm_favorite_page.user_id is 'User ID ( link to ACM_USER)'
/

comment on column acm_favorite_page.section_id is 'Section ID ( link to ACM_SECTION)'
/

