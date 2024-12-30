*"* use this source file for your ABAP unit test classes
class yf24gr05_Cl_Number_To_Vn definition deferred.
class zf24gr05_Cl_Number_To_Vietnam definition local friends yf24gr05_Cl_Number_To_Vn.

class yf24gr05_Cl_Number_To_Vn definition for testing
  duration short
  risk level harmless
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>yf24gr05_Cl_Number_To_Vn
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZF24GR05_CL_NUMBER_TO_VIETNAM
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
             number type p LENGTH 15 DECIMALS 0,
             text   type string,
           end of ty_test_case.

    types: ty_t_test_case type standard table of ty_test_case with empty key.

    data:
      f_Cut        type ref to z211_Cl_Number_To_Vietnamese,  "class under test
      lt_test_case type ty_t_test_case.

    class-methods: class_Setup.

    class-methods: class_Teardown.
    methods: setup.

    methods: teardown.

    methods: call_test
      importing
        iv_number      type p
        exp            type string
      returning
        value(rv_text) type string.

    methods: number_To_Vietnamese for testing.

endclass.       "yf24gr05_Cl_Number_To_Vn


class yf24gr05_Cl_Number_To_Vn implementation.

  method class_Setup.

  endmethod.

  method class_Teardown.

  endmethod.

  method setup.
    " Create an instance of the class under test
    create object f_Cut.

    lt_test_case = value ty_t_test_case(
      (
        number = -0
        text = 'không'
      )
      (
        number = 101
        text = 'một trăm lẻ một'
      )
      (
        number = 105
        text = 'một trăm lẻ năm'
      )
      (
        number = 111
        text = 'một trăm mười một'
      )
      (
        number = 115
        text = 'một trăm mười lăm'
      )
      (
        number = 121
        text = 'một trăm hai mươi mốt'
      )
      (
        number = 1001
        text = 'một nghìn không trăm lẻ một'
      )
      (
        number = 1005
        text = 'một nghìn không trăm lẻ năm'
      )
      (
        number = 1015
        text = 'một nghìn không trăm mười lăm'
      )
      (
        number = 1115
        text = 'một nghìn một trăm mười lăm'
      )
      (
        number = 11002
        text = 'mười một nghìn không trăm lẻ hai'
      )
      (
        number = 21005
        text = 'hai mươi mốt nghìn không trăm lẻ năm'
      )
      (
        number = 501005
        text = 'năm trăm lẻ một nghìn không trăm lẻ năm'
      )
      (
        number = 1010101
        text = 'một triệu không trăm mười nghìn một trăm lẻ một'
      )
      (
        number = 1000000000
        text = 'một tỷ'
      )
      (
        number = 1000000000000
        text = 'một nghìn tỷ'
      )
      (
        number = 100000000000000
        text = 'một trăm nghìn tỷ'
      )
      (
        number = 123456789012345
        text = 'một trăm hai mươi ba nghìn bốn trăm năm mươi sáu tỷ bảy trăm tám mươi chín triệu không trăm mười hai nghìn ba trăm bốn mươi lăm'
      )
    ).

  endmethod.

  method teardown.

  endmethod.

  method call_test.

    try.
        rv_text = f_Cut->number_To_Vietnamese( iv_Number ).

        cl_abap_unit_assert=>assert_equals(
          act = rv_Text
          exp = exp
          msg = |Testing conversion of { iv_number }|
          quit = if_aunit_constants=>quit-no
        ).

      catch cx_root.
    endtry.

  endmethod. " call_test

  method number_To_Vietnamese.
    " Test for complete conversion functionality with different types of inputs
    data rv_Text type string.

    loop at lt_test_case into data(wa).

      rv_text = me->call_test(
                      iv_number = wa-number
                      exp       = wa-text
                    ).

    endloop.

  endmethod.

endclass.
