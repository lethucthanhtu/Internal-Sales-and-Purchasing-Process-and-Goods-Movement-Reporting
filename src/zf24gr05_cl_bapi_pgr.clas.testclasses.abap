*"* use this source file for your ABAP unit test classes
class yf24gr05_Cl_Bapi_Pgr definition deferred.
class zf24gr05_Cl_Bapi_Pgr definition local friends yf24gr05_Cl_Bapi_Pgr.

class yf24gr05_Cl_Bapi_Pgr definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>yf24gr05_Cl_Bapi_Pgr
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZF24GR05_CL_BAPI_PGR
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

    data:
      f_Cut type ref to zf24gr05_Cl_Bapi_Pgr.  "class under test

    class-methods:
      class_Setup,
      class_Teardown.

    methods:
      setup,
      teardown.

    methods:
      handle_Multi_Messages for testing,
      handle_Single_Message for testing,
      post_Gr_Delivery for testing,
      post_Multi_Gr for testing,
      post_Single_Gr for testing.

endclass.       "yf24gr05_Cl_Bapi_Pgr


class yf24gr05_Cl_Bapi_Pgr implementation.

  method class_Setup.



  endmethod.


  method class_Teardown.



  endmethod.


  method setup.


    create object f_Cut.

  endmethod.


  method teardown.



  endmethod.


  method handle_Multi_Messages.

    data: it_Bapiret2 type zf24gr05_Cl_Bapi_Pgr=>ty_T_Bapiret2,
          iv_Vbeln    type vbeln_Vl,
          rt_Messages type zf24gr05_Cl_Bapi_Root=>ty_T_Message.

    rt_Messages =
      f_Cut->handle_Multi_Messages(
        it_bapiret2 = it_Bapiret2
        iv_vbeln = iv_Vbeln
      ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Messages
      exp   = rt_Messages          "<--- please adapt expected value
    " msg   = 'Testing value rt_Messages'
*     level =
    ).

  endmethod.


  method handle_Single_Message.

    data: iv_Bapiret2 type bapiret2,
          iv_Vbeln    type zf24gr05_Cl_Bapi_Root=>ty_Delivery,
          rs_Message  type zf24gr05_Cl_Bapi_Root=>ty_Message.

    rs_Message =
      f_Cut->handle_Single_Message(
        iv_bapiret2 = iv_Bapiret2
        iv_vbeln = iv_Vbeln
      ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rs_Message
      exp   = rs_Message          "<--- please adapt expected value
    " msg   = 'Testing value rs_Message'
*     level =
    ).

  endmethod.


  method post_Gr_Delivery.

    data: it_Delivery type zf24gr05_Cl_Bapi_Root=>ty_T_Delivery,
          iv_Display  type abap_Bool,
          rt_Table    type zf24gr05_Cl_Bapi_Root=>ty_T_Message.

    rt_Table = f_Cut->post_Gr_Delivery(
        it_delivery = it_Delivery
*       IV_DISPLAY = iv_Display
    ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Table
      exp   = rt_Table          "<--- please adapt expected value
    " msg   = 'Testing value rt_Table'
*     level =
    ).

  endmethod.


  method post_Multi_Gr.

    data: it_Delivery type zf24gr05_Cl_Bapi_Root=>ty_T_Delivery,
          rt_Message  type zf24gr05_Cl_Bapi_Root=>ty_T_Message.

    rt_Message = f_Cut->post_Multi_Gr( it_Delivery ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.


  method post_Single_Gr.

    data: iv_Delivery type zf24gr05_Cl_Bapi_Root=>ty_Delivery,
          rt_Message  type zf24gr05_Cl_Bapi_Root=>ty_T_Message.

    rt_Message = f_Cut->post_Single_Gr( iv_Delivery ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.




endclass.
