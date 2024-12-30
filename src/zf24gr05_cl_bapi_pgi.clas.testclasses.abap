*"* use this source file for your ABAP unit test classes
class yf24gr05_Cl_Bapi_Pgi definition deferred.
class zf24gr05_Cl_Bapi_Pgi definition local friends yf24gr05_Cl_Bapi_Pgi.

class yf24gr05_Cl_Bapi_Pgi definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>yf24gr05_Cl_Bapi_Pgi
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZF24GR05_CL_BAPI_PGI
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
      f_Cut type ref to zf24gr05_Cl_Bapi_Pgi.  "class under test

    class-methods:
      class_Setup,
      class_Teardown.

    methods:
      setup,
      teardown.

    methods:
      handle_Multi_Messages for testing,
      handle_Single_Message for testing,
      post_Gi_Delivery      for testing,
      post_Multi_Gi         for testing,
      post_Single_Gi        for testing.

endclass.       "yf24gr05_Cl_Bapi_Pgi


class yf24gr05_Cl_Bapi_Pgi implementation.

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

    data: it_Prott   type zf24gr05_Cl_Bapi_Pgi=>ty_T_Prott,
          rt_Message type zf24gr05_Cl_Bapi_Root=>rty_T_Message.

    rt_Message = f_Cut->handle_Multi_Messages( it_Prott ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.


  method handle_Single_Message.

    data: iv_Prott   type prott,
          rs_Message type zf24gr05_Cl_Bapi_Root=>ty_Message.

    rs_Message = f_Cut->handle_Single_Message( iv_Prott ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rs_Message
      exp   = rs_Message          "<--- please adapt expected value
    " msg   = 'Testing value rs_Message'
*     level =
    ).

  endmethod.


  method post_Gi_Delivery.

    data: it_Delivery            type zf24gr05_Cl_Bapi_Root=>ty_T_Delivery,
          iv_Flg_Display_Message type abap_Bool,
          rt_Message             type zf24gr05_Cl_Bapi_Root=>rty_T_Message.

    rt_Message = f_Cut->post_Gi_Delivery(
        it_delivery = it_Delivery
*       IV_FLG_DISPLAY_MESSAGE = iv_Flg_Display_Message
    ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.


  method post_Multi_Gi.

    data: it_Delivery type zf24gr05_Cl_Bapi_Root=>ty_T_Delivery,
          rt_Message  type zf24gr05_Cl_Bapi_Root=>rty_T_Message.

    rt_Message = f_Cut->post_Multi_Gi( it_Delivery ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.


  method post_Single_Gi.

    data: iv_Delivery type zf24gr05_Cl_Bapi_Root=>ty_Delivery,
          rt_Message  type zf24gr05_Cl_Bapi_Root=>rty_T_Message.

    rt_Message = f_Cut->post_Single_Gi( iv_Delivery ).

    cl_Abap_Unit_Assert=>assert_Equals(
      act   = rt_Message
      exp   = rt_Message          "<--- please adapt expected value
    " msg   = 'Testing value rt_Message'
*     level =
    ).

  endmethod.




endclass.
