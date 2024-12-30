*&---------------------------------------------------------------------*
*& Include          Z211_GLOBAL_DEFINE
*&---------------------------------------------------------------------*
types: gty_alv type zf24gr05_cl_alv=>ty_s_alv.

data: gt_alv type standard table of gty_alv,
      gs_alv like line of gt_alv.

data: ls_lgort type lips-lgort,
      ls_MBLNR type mseg-mblnr,
      ls_ginr  type mseg-mblnr,
      ls_grnr  type mseg-mblnr
      .
