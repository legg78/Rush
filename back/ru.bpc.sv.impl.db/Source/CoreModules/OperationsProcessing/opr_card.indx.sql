create index opr_card_card_number_ndx on opr_card (reverse(card_number))
/
create index opr_card_fast_card_number_ndx on opr_card (card_number_postfix, reverse(card_number))
/
