*&---------------------------------------------------------------------*
*& Report ZF24GR05_SMARTFORM
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZF24GR05_SMARTFORM.

INCLUDE ZF24GR05_sf_T01.

INCLUDE ZF24GR05_sf_F01.


*&---------------------------------------------------------------------*
*& AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
  AT SELECTION-SCREEN.


*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  " Check the user input to ensure it's NOT BLANK
  "       and that the number is valid and EXISTS.
  PERFORM is_valid_parametter.

  "Assign the value of the selected radio button to the display variable.
  CASE gc_true.

    WHEN lv_pp.
      gv_display = gty_display-print_preview.

    WHEN lv_lp.
      gv_display = gty_display-print_locally.

  ENDCASE.


*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.

PERFORM define_decimal_format.

PERFORM querry_and_process_data.

PERFORM spell_amount.

PERFORM call_sf_by_function_module.


  " Depending on the value of the display variable,
  " call the corresponding function or subroutine.
  CASE gv_display.

    WHEN gty_display-print_preview.

      PERFORM call_sf_with_no_OTF.

    WHEN gty_display-print_locally.

      PERFORM call_smartforms_with_otf.

      PERFORM call_convert_otf.

      PERFORM naming_file.

      PERFORM call_gui_download.

  ENDCASE.
