*"* use this source file for your ABAP unit test classes
class yf24gr05_Cl_Alv definition deferred.
class zf24gr05_Cl_Alv definition local friends yf24gr05_Cl_Alv.

class yf24gr05_Cl_Alv definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>yf24gr05_Cl_Alv
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZF24GR05_CL_ALV
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE>X
*?</GENERATE_CLASS_FIXTURE>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>

  private section.

    types: begin of ty_test_case,
             delivery    type zf24gr05_cl_bapi_root=>ty_delivery,
             exp_pgi_msg type string,
             exp_pgr_msg type string,
           end of ty_test_case.

    types: ty_t_test_case type standard table of ty_test_case with empty key.

    data: lt_test_case type ty_t_test_case.

    data: f_Cut      type ref to zf24gr05_Cl_Alv.  "class under test

    data: lt_message type zf24gr05_cl_bapi_root=>ty_t_message,
          ls_message like line of lt_message.

    data: lt_delivery type zf24gr05_cl_bapi_root=>ty_t_delivery.

    class-methods:
      class_Setup,
      class_Teardown.

    methods:
      setup,
      teardown.

    methods:
      call_pgi
        importing
          it_test_case type ty_t_test_case.

    methods:
      call_pgr
        importing
          it_test_case type ty_t_test_case.

    methods:
      fetch_Data for testing,
      get_T_Alv for testing,
      post_Gi for testing,
      post_Gr for testing,
      test_status_indicator for testing,
      test_status for testing,
      test_status_color for testing,
      test_picked_quant for testing
      .

endclass.       "yf24gr05_Cl_Alv


class yf24gr05_Cl_Alv implementation.

  method class_Setup.



  endmethod.


  method class_Teardown.



  endmethod.


  method setup.

    data: ir_Matnr type zf24gr05_cl_alv=>ty_R_Product,
          ir_Splnt type zf24gr05_cl_alv=>ty_R_Splant,
          ir_Rplnt type zf24gr05_cl_alv=>ty_R_Rplant,
          ir_Sloc  type zf24gr05_cl_alv=>ty_R_Sloc,
          ir_Ginr  type zf24gr05_cl_alv=>ty_R_Ginr,
          ir_Grnr  type zf24gr05_cl_alv=>ty_R_Grnr,
          ir_Ponr  type zf24gr05_cl_alv=>ty_R_Ponr,
          ir_Gidat type zf24gr05_cl_alv=>ty_R_Gidat,
          ir_Grdat type zf24gr05_cl_alv=>ty_R_Grdat.

    create object f_Cut
*     EXPORTING
*       IR_MATNR = ir_Matnr
*       IR_SPLNT = ir_Splnt
*       IR_RPLNT = ir_Rplnt
*       IR_SLOC = ir_Sloc
*       IR_GINR = ir_Ginr
*       IR_GRNR = ir_Grnr
*       IR_PONR = ir_Ponr
*       IR_GIDAT = ir_Gidat
*       IR_GRDAT = ir_Grdat
      .

    lt_test_case =
      value ty_t_test_case(
        (
          delivery = '0080000204'
          exp_pgi_msg = 'Goods issue has already been posted for delivery'
          exp_pgr_msg = 'Outbound delivery 80000204 has already posted Goods Receipt.'
        )
        (
          delivery = '0080000446'
          exp_pgi_msg = 'Goods issue has already been posted for delivery'
          exp_pgr_msg = 'Outbound delivery 80000204 has already posted Goods Receipt.'
        )
      ).

    lt_delivery = value #(
      for wa in lt_test_case (
         wa-delivery
      )
    ).


  endmethod.


  method teardown.



  endmethod.

  "
  method get_T_Alv.

    data rt_Table type zf24gr05_cl_alv=>rty_T_Alv.

    rt_Table = f_Cut->get_T_Alv(  ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Table
      exp   = rt_Table          "<--- please adapt expected value
    " msg   = 'Testing value rt_Table'
*     level =
    ).

  endmethod.

  " only check if data is empty
  method fetch_data.

    data(lo_alv) = new zf24gr05_cl_alv(
*      ir_matnr = value #( ( sign = 'I' option = 'EQ' low = 'MAT001' ) )
    ).

    try.

        data(lt_alv) = lo_alv->get_t_alv( ).
        cl_abap_unit_assert=>assert_not_initial( lt_alv ).

      catch cx_root into data(lx_error).

        cl_abap_unit_assert=>fail(
          lx_error->get_text( )
        ).

    endtry.

  endmethod. " fetch_data

  method call_pgr.

    endmethod. " call_pgr

  method call_pgi.

    data(lo_pgi) = new zf24gr05_cl_bapi_pgi( ).

    loop at lt_test_case into data(wa).

      data(lt_deli) =
       value zf24gr05_cl_bapi_root=>rty_t_delivery(
         ( wa-delivery )
       ).

      lt_message = lo_pgi->post_gi_delivery(
          it_delivery = lt_deli
      ).

      cl_abap_unit_assert=>assert_not_initial( lt_message ).

       cl_Abap_Unit_Assert=>assert_Equals(
         act   = lt_message[ 1 ]-msgtxt
         exp   = 'Goods issue has already been posted for delivery'          "<--- please adapt expected value
         msg   = '80000204 PGI'
*       level =
       ).

    endloop.

    clear: lt_message.

  endmethod. " call_pgi

  " only check if message is empty
  method post_gi.

    data(lo_pgi) = new zf24gr05_cl_bapi_pgi( ).

    try.

        lt_message = lo_pgi->post_gi_delivery(
          it_delivery = lt_delivery
        ).
        cl_abap_unit_assert=>assert_not_initial( lt_message ).

        cl_Abap_Unit_Assert=>assert_Equals(
             act   = lt_message[ 1 ]-msgtxt
             exp   = 'Goods issue has already been posted for delivery'          "<--- please adapt expected value
             msg   = '80000204 PGI'
*           level =
           ).

      catch cx_root into data(lx_error).

        cl_abap_unit_assert=>fail(
          lx_error->get_text( )
        ).

    endtry.

  endmethod. " post_gi

  " only check if message is empty
  method post_gr.

    data(idx) = 0.

    data(lo_pgr) = new zf24gr05_cl_bapi_pgr( ).

*    data(lt_delivery) =
*      value zf24gr05_cl_bapi_root=>rty_t_delivery(
*        ( '0080000204' )
*        ( '0080000446' )
*      ).

    try.

        lt_message = lo_pgr->post_gr_delivery(
          it_delivery = lt_delivery
        ).

        cl_abap_unit_assert=>assert_not_initial( lt_message ).

        idx = idx + 1.
        ls_message = lt_message[ idx ].
        cl_Abap_Unit_Assert=>assert_Equals(
             act   = ls_message-msgtxt
             exp   = 'Outbound delivery 80000204 has already posted Goods Receipt.'          "<--- please adapt expected value
             msg   = |{ ls_message-delivery } PGR|
*             level =
        ).

        idx = idx + 1.
        ls_message = lt_message[ idx ].
        cl_Abap_Unit_Assert=>assert_Equals(
             act   = ls_message-msgtxt
             exp   = 'Posting only possible in periods 2024/11 and 2024/10 in company code ZFS5'          "<--- please adapt expected value
             msg   = |{ ls_message-delivery } PGR|
*             level =
        ).




      catch cx_root into data(lx_error).

        cl_abap_unit_assert=>fail(
          lx_error->get_text( )
        ).

    endtry.

    clear: lt_delivery.

  endmethod. " post_gr

  method test_status_indicator.

    data(lo_alv) = new zf24gr05_cl_alv( ).

    data(lt_alv) = lo_alv->get_t_alv( ).

    loop at lt_alv into data(wa).

      data(lv_gi) = wa-goods_issue.
      data(lv_gi_cancelled) = wa-goods_issue_status.

      data(lv_gr) = wa-goods_receipt.
      data(lv_gr_cancelled) = wa-goods_receipt_status.

      if   lv_gi is initial
        or lv_gi_cancelled = abap_true.

        cl_abap_unit_assert=>assert_equals(
          act   = wa-status_icon
          exp   = icon_green_light         "<--- please adapt expected value
          msg   = 'test Icon'
        ).

      elseif lv_gr is initial
        or   lv_gr_cancelled = abap_true.

        cl_abap_unit_assert=>assert_equals(
            act   = wa-status_icon
            exp   = icon_yellow_light         "<--- please adapt expected value
            msg   = 'test Icon'
          ).

      else.

        cl_abap_unit_assert=>assert_equals(
          act   = wa-status_icon
          exp   = icon_red_light         "<--- please adapt expected value
          msg   = 'test Icon'
        ).

      endif.

    endloop.

  endmethod. " test_status_indicator

  method test_picked_quant.

    data(lo_alv) = new zf24gr05_cl_alv( ).

    data(lt_alv) = lo_alv->get_t_alv( ).

    loop at lt_alv into data(wa).

      data(lv_deli) = wa-delivery_quantity.
      data(lv_pick) = wa-picked_quantity.

      if lv_deli <> lv_pick.

        data(lt_color) = wa-cell_color.

        loop at lt_color into data(wa_color).

          if wa_color-fname = 'PICKED_QUANTITY'.

            cl_abap_unit_assert=>assert_equals(
                  act   = wa_color-color-int
                  exp   = 1         "<--- please adapt expected value
                  msg   = 'test Icon'
                ).

          endif.

        endloop.

      endif.

    endloop.

  endmethod. " test_picked_quant

  method test_status.

    data(lo_alv) = new zf24gr05_cl_alv( ).
    data(lt_alv) = lo_alv->get_t_alv( ).

    loop at lt_alv into data(wa).

      data(lv_gi) = wa-goods_issue.
      data(lv_gi_cancelled) = wa-goods_issue_status.

      data(lv_gr) = wa-goods_receipt.
      data(lv_gr_cancelled) = wa-goods_receipt_status.

      if   lv_gi is initial
        or lv_gi_cancelled = abap_true.

        cl_abap_unit_assert=>assert_equals(
          act   = wa-status
          exp   = 'OPEN'         "<--- please adapt expected value
          msg   = 'test Icon'
        ).

      elseif lv_gr is initial
        or   lv_gr_cancelled = abap_true.

        cl_abap_unit_assert=>assert_equals(
            act   = wa-status
            exp   = 'PARTIAL'         "<--- please adapt expected value
            msg   = 'test Icon'
          ).

      else.

        cl_abap_unit_assert=>assert_equals(
          act   = wa-status
          exp   = 'CLOSE'         "<--- please adapt expected value
          msg   = 'test Icon'
        ).

      endif.


    endloop.

  endmethod. " test_status

  method test_status_color.

    data(lo_alv) = new zf24gr05_cl_alv( ).
    data(lt_alv) = lo_alv->get_t_alv( ).

    loop at lt_alv into data(wa).

      data(lv_gi) = wa-goods_issue.
      data(lv_gi_cancelled) = wa-goods_issue_status.

      data(lv_gr) = wa-goods_receipt.
      data(lv_gr_cancelled) = wa-goods_receipt_status.

      data(lt_color) = wa-cell_color.

      loop at lt_color into data(wa_color).

        data(lv_color) = 0.

        if wa_color-fname = 'STATUS'.
          lv_color = wa_color-color-int.
        endif.

        if   lv_gi is initial
          or lv_gi_cancelled = abap_true.

          cl_abap_unit_assert=>assert_equals(
            act   = lv_color
            exp   = 5         "<--- please adapt expected value
            msg   = 'test open'
          ).

        elseif lv_gr is initial
          or   lv_gr_cancelled = abap_true.

          cl_abap_unit_assert=>assert_equals(
            act   = lv_color
            exp   = 7         "<--- please adapt expected value
            msg   = 'test partial'
          ).

        else.

          cl_abap_unit_assert=>assert_equals(
            act   = lv_color
            exp   = 4         "<--- please adapt expected value
            msg   = 'test close'
          ).

        endif.

      endloop.

    endloop.

  endmethod. " test_status_color

endclass.
