*&---------------------------------------------------------------------*
*& Include          Z211_SELECTION_SCREEN
*&---------------------------------------------------------------------*
start-of-selection.

  select-options: s_matnr for gs_alv-product ,                    " Material Number
                  s_rplnt for gs_alv-receiving_plant,             " Receiving Plant
                  s_splnt for gs_alv-supplying_plant,             " Supplying Plant
*                  s_sloc  for gs_alv-sloc,                        " Storage Location
                  s_sloc  for ls_lgort,                           " Storage Location
                  s_ginr  for gs_alv-goods_issue,                 " GI number
                  s_grnr  for gs_alv-goods_receipt,               " GR number
                  s_ponr  for gs_alv-po_number,                   " PO number
                  s_gidat for gs_alv-planned_goods_movement_date, " GI date
                  s_grdat for gs_alv-picking_date                 " GR date
                  .

end-of-selection.
