*&---------------------------------------------------------------------*
*& Include          Z211_ALV_SCREEN
*&---------------------------------------------------------------------*
  data(lo_alv) = new zf24gr05_cl_alv(

    ir_matnr = value #(
      for lr_matnr in s_matnr (
        corresponding #( lr_matnr )
      )
    )

    ir_splnt = value #(
      for lr_splnt in s_splnt (
        corresponding #( lr_splnt )
      )
    )

    ir_rplnt = value #(
      for lr_rplnt in s_rplnt (
        corresponding #( lr_rplnt )
      )
    )

    ir_sloc  = value #(
      for lr_sloc in s_sloc (
        corresponding #( lr_sloc )
      )
    )

    ir_ginr  = value #(
      for lr_ginr in s_ginr (
        corresponding #( lr_ginr )
      )
    )

    ir_grnr  = value #(
      for lr_grnr in s_grnr (
        corresponding #( lr_grnr )
      )
    )

    ir_ponr  = value #(
      for lr_ponr in s_ponr (
        corresponding #( lr_ponr )
      )
    )

    ir_gidat = value #(
      for lr_gidat in s_gidat (
        corresponding #( lr_gidat )
      )
    )

    ir_grdat = value #(
      for lr_grdat in s_grdat (
        corresponding #( lr_grdat )
      )
    )

 ).

 lo_alv->display( ).
