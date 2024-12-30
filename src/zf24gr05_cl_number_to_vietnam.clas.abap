class zf24gr05_cl_number_to_vietnam definition
  public
  final
  create public .

  public section.

    methods:
      constructor.

    methods:
      number_to_vietnamese
        importing
          iv_number      type p
        returning
          value(rv_text) type string.

  protected section.

  private section.

    types: ty_t_string type standard table of string with empty key.

    " Internal data for units, tens, and scales in Vietnamese
    data: lt_units  type ty_t_string,
          lt_tens   type ty_t_string,
          lt_scales type ty_t_string.

    "
    methods:
      convert_hundreds
        importing
          iv_number type i
          iv_orgnum type p
        changing
          cv_text   type string.

    methods:
      convert_number
        importing
          iv_number type p
        changing
          cv_text   type string.

ENDCLASS.



CLASS ZF24GR05_CL_NUMBER_TO_VIETNAM IMPLEMENTATION.


  method constructor.

    " Populate lt_units
    me->lt_units = value ty_t_string(
      (                            " 0
        conv string( 'không' )     " Zero
      )
      (                            " 1
        conv string( 'một' )       " One
      )
      (                            " 2
        conv string( 'hai' )       " Two
      )
      (                            " 3
        conv string( 'ba' )        " Three
      )
      (                            " 4
        conv string( 'bốn' )       " Four
      )
      (                            " 5
        conv string( 'năm' )       " Five
      )
      (                            " 6
        conv string( 'sáu' )       " Six
      )
      (                            " 7
        conv string( 'bảy' )       " Seven
      )
      (                            " 8
        conv string( 'tám' )       " Eight
      )
      (                            " 9
        conv string( 'chín' )      " Nine
      )
    ).

    " Populate lt_tens
    lt_tens = value ty_t_string(
      (                            " 0
        conv string( '' )          "
      )
      (                            " 1
        conv string( '' )          "
      )
      (                            " 2
        conv string( 'hai mươi' )  " Twenty
      )
      (                            " 3
        conv string( 'ba mươi' )   " Thirty
      )
      (                            " 4
        conv string( 'bốn mươi' )  " Forty
      )
      (                            " 5
        conv string( 'năm mươi' )  " Fifty
      )
      (                            " 6
        conv string( 'sáu mươi' )  " Sixty
      )
      (                            " 7
        conv string( 'bảy mươi' )  " Seventy
      )
      (                            " 8
        conv string( 'tám mươi' )  " Eighty
      )
      (                            " 9
        conv string( 'chín mươi' ) " Ninety
      )
    ).

    " Populate lt_scales
    lt_scales = value ty_t_string(
      (
        conv string( '' )      " Units
      )
      (
        conv string( 'nghìn' ) " Thousands
      )
      (
        conv string( 'triệu' ) " Millions
      )
      (
        conv string( 'tỷ' )    " Billions
      )
    ).

  endmethod.


  method convert_hundreds.

    " Temporary variable for text
    data: lv_temp type string.

    " Handle case where the number is zero
    if iv_number = 0.
      cv_text = ''.
      return.
    endif.

    " Split number into hundreds, tens, and units
    data(lv_hundreds) = iv_number div 100.
    data(lv_tens) = ( iv_number mod 100 ) div 10.
    data(lv_units) = iv_number mod 10.

    " Add 'trăm' (hundred) if applicable
    if lv_hundreds <= 0 and
       iv_orgnum >= 1000.

      read table lt_units
        into lv_temp
        index 1.

      concatenate cv_text lv_temp 'trăm'
        into cv_text
        separated by space.

    elseif lv_hundreds > 0.

      read table lt_units
        into lv_temp
        index lv_hundreds + 1.

      concatenate cv_text lv_temp 'trăm'
        into cv_text
        separated by space.

    endif.

    " Handle tens and units cases
    if lv_tens = 1.

      concatenate cv_text 'mười'
        into cv_text
        separated by space.

      if lv_units = 1. " 11

        concatenate cv_text 'một'
          into cv_text
          separated by space.

      elseif lv_units = 5. " end with unit = 5

        " Special case for 5
        concatenate cv_text 'lăm'
          into cv_text
          separated by space.

      elseif lv_units > 0.

        read table lt_units
          into lv_temp
          index lv_units + 1.

        concatenate cv_text lv_temp
          into cv_text
          separated by space.

      endif.

    elseif lv_tens > 1.

      read table lt_tens
        into lv_temp
        index lv_tens + 1.

      concatenate cv_text
                  lv_temp
        into cv_text
        separated by space.

      if lv_units = 1. " 21, 31, 41, ...

        " Special case for 21, 31, ...
        concatenate cv_text 'mốt'
          into cv_text
          separated by space.

      elseif lv_units = 5.

        concatenate cv_text 'lăm'
          into cv_text
          separated by space.

      elseif lv_units > 0.

        read table lt_units
          into lv_temp
          index lv_units + 1.

        concatenate cv_text lv_temp
          into cv_text
          separated by space.

      endif.

    elseif lv_units > 0.

      if ( lv_hundreds > 0 ) or
         (
           lv_hundreds <= 0 and
           iv_orgnum >= 1000
         ).

        " Handle trailing units
        concatenate cv_text 'lẻ'
          into cv_text
          separated by space.

      endif.

      if lv_units = 5.

        concatenate cv_text 'năm'
          into cv_text
          separated by space.

      else.

        read table lt_units
          into lv_temp
          index lv_units + 1.

        concatenate cv_text
                    lv_temp
          into cv_text
          separated by space.

      endif.

    endif.

  endmethod.


  method convert_number.

    " Intermediate variables
    data(lv_number) = iv_number.

    data: lv_part    type i,         " Part of the number (thousands, ...)
          lv_scale   type i value 0, " Scale index (e.g., thousand, million)
          lv_text    type string,
          lv_segment type string.

    clear: cv_text.

    " Handle zero as input
    if lv_number = 0.
      cv_text = 'không'.
      return.
    endif.

    " Process each segment of the number
    while lv_number > 0.

      data(lv_remain) = lv_number.

      " Extract the last 3 digits
      lv_part = lv_number mod 1000.
      lv_number = lv_number div 1000.

      clear: lv_segment.

      " Convert the segment if it exists or if it's the first segment
      if lv_part > 0 or
         lv_scale = 1.

        call method me->convert_hundreds
          exporting
            iv_number = lv_part
            iv_orgnum = lv_remain
          changing
            cv_text   = lv_segment.

        " Add scale text if applicable
        if lv_scale > 0 and
           lv_segment is not initial.

          read table lt_scales
            into lv_text
            index lv_scale + 1.

          concatenate lv_segment
                      lv_text
            into lv_segment
            separated by space.

        endif.

        " Append segment to the final text
        if cv_text is initial.
          cv_text = lv_segment.
        else.
          concatenate lv_segment
                      cv_text
            into cv_text.
        endif.

      endif.

      lv_scale = lv_scale + 1.

      " Handle edge case 1 000 000 000 000
      if lv_scale = 4 and
         cv_text is initial.

        read table lt_scales
          into lv_text
          index lv_scale.

        cv_text = | { lv_text }|.

      endif.

      " Handle "tram/ngin ty" case
      " Reset scale index after billions
      if lv_scale > 3.
        lv_scale = 1.
      endif.

    endwhile.

    " Clean up leading and trailing spaces
    shift cv_text left deleting leading space.
    shift cv_text right deleting trailing space.

  endmethod.


  method number_to_vietnamese.

    " Variable for numeric input
    data: lv_number_p type p.

    " Validate input
    try.
        lv_number_p = iv_number.
      catch cx_root.
        " Return 'Not a Number' if invalid input
        rv_text = 'NaN'.
        return.
    endtry.

    " Convert the number to Vietnamese text
    call method me->convert_number
      exporting
        iv_number = lv_number_p
      changing
        cv_text   = rv_text.

  endmethod.
ENDCLASS.
