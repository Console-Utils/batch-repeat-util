@echo off
setlocal

call :init

set "option=%~1"

set /a "is_help=%false%"
if "%option%" == "-h" set /a "is_help=%true%"
if "%option%" == "--help" set /a "is_help=%true%"

if "%is_help%" == "%true%" (
    call :help
    exit /b %ec_success%
)

set /a "is_version=%false%"
if "%option%" == "-v" set /a "is_version=%true%"
if "%option%" == "--version" set /a "is_version=%true%"

if "%is_version%" == "%true%" (
    call :version
    exit /b %ec_success%
)

set /a "is_interactive=%false%"
if "%option%" == "-i" set /a "is_interactive=%true%"
if "%option%" == "--interactive" set /a "is_interactive=%true%"

if "%is_interactive%" == "%true%" (
    call :interactive
    exit /b %ec_success%
)

if "%option%" == "--" shift

set "string=%~1"
set "delimiter=%~2"
set "count=%~3"
set "next_argument=%~4"

if defined next_argument (
    echo %em_too_many_arguments%
    exit /b %ec_too_many_arguments%
)

call :repeat_string_syntax_check "%string%" "%delimiter%" "%count%"
set /a "temp_errorlevel=%errorlevel%"
if %temp_errorlevel% gtr 0 exit /b %temp_errorlevel%

call :repeat_string string "%string%" "%count%"
echo.%string%
exit /b %ec_success%

:init
    set /a "ec_success=0"

    set /a "ec_too_many_arguments=10"

    set "em_too_many_arguments=Other options or string repetitions are not allowed after first string repetition construction."

    set /a "true=0"
    set /a "false=1"

    set "prompt=>>> "
    set "substitution_prompt=-^> Every !! replaced with "

    call :set_esc
exit /b %ec_success%

:help
    echo Prints string repetition.
    echo.
    echo Syntax:
    echo    repeat [options] string * count
    echo.
    echo Options:
    echo    -h^|--help - writes help and exits
    echo    -v^|--version - writes version and exits
    echo    -i^|--interactive - fall in interactive mode
    echo    -- - ends option list
    echo.
    echo If string is specified before some option then it is ignored.
    echo.
    echo Interactive mode commands:
    echo    q^|quit - exits
    echo    c^|clear - clears screen
    echo    h^|help - writes help
    echo    -- - makes possible to use interactive mode commands as strings to repeat
    echo.
    echo Error codes:
    echo    - 0 - Success
    echo    - 10 - Other options or string repetitions are not allowed after first string repetition construction.
    echo    - 20 - Asterisk delimiter is not specified after string to repeat.
    echo    - 21 - Repetition count is not specified after asterisk delimiter.
    echo.
    echo Examples:
    echo    - repeat --help
    echo    - repeat abc * 10
    echo    - repeat abc * 10 --help (--help option is ignored)
exit /b %ec_success%

:version
    echo 1.0 ^(c^) 2021 year
exit /b %ec_success%

:interactive
    set /a "i_last_errorlevel=0"

    :interactive_loop
        set /a "i_color_code=32"
        if not %i_last_errorlevel% == 0 set /a "i_color_code=31"
        set "i_command="
        set /p "i_command=%esc%[%i_color_code%m%i_last_errorlevel% %prompt%%esc%[0m"
        
        if not defined i_command goto interactive_loop
        
        set "i_command_before_substitution=%i_command%"
        call set "i_command=%%i_command:!!=%i_previous_command%%%"
        set /a "i_color_code=35"
        if not "%i_command_before_substitution%" == "%i_command%" echo %esc%[%i_color_code%m%substitution_prompt%"%i_previous_command%".%esc%[0m

        call :extract_argument i_end_option_list 0 %i_command%

        if "%i_end_option_list%" == "--" (
            call :i_if_i_end_option_list_equal_to_end_option_list
            call :i_repeat_string
        )

        set "i_string=%i_end_option_list%"

        set "i_comment_regex=^#.*$"
        echo %i_string%| findstr /r "%i_comment_regex%" 2> nul > nul && goto interactive_loop

        set /a "i_is_quit=%false%"
        if "%i_string%" == "q" set /a "i_is_quit=%true%"
        if "%i_string%" == "quit" set /a "i_is_quit=%true%"

        if "%i_is_quit%" == "%true%" exit /b %ec_success%
    
        set /a "i_is_clear=%false%"
        if "%i_string%" == "c" set /a "i_is_clear=%true%"
        if "%i_string%" == "clear" set /a "i_is_clear=%true%"

        if "%i_is_clear%" == "%true%" (
            cls
            goto interactive_loop
        )

        set /a "i_is_help=%false%"
        if "%i_string%" == "h" set /a "i_is_help=%true%"
        if "%i_string%" == "help" set /a "i_is_help=%true%"

        if "%i_is_help%" == "%true%" (
            call :help
            goto interactive_loop
        )

        call :extract_argument i_string 0 %i_command%
        call :extract_argument i_delimiter 1 %i_command%
        call :extract_argument i_count 2 %i_command%
        call :extract_argument i_next_argument 3 %i_command%

        call :i_repeat_string
exit /b %ec_success%

:i_if_i_end_option_list_equal_to_end_option_list
    call :extract_argument i_string 1 %i_command%
    call :extract_argument i_delimiter 2 %i_command%
    call :extract_argument i_count 3 %i_command%
    call :extract_argument i_next_argument 4 %i_command%
exit /b %ec_success%

:i_repeat_string
    set "i_previous_command=%i_command%"

    if not "%i_next_argument%" == "" (
        echo %em_too_many_arguments%
        set /a "i_last_errorlevel=%ec_too_many_arguments%"
        goto interactive_loop
    )
    
    call :repeat_string_syntax_check "%i_string%" "%i_delimiter%" "%i_count%"
    set /a "i_last_errorlevel=%errorlevel%"
    if %i_last_errorlevel% neq 0 goto interactive_loop

    call :repeat_string i_string "%i_string%" "%i_count%"
    echo.%i_string%
    goto interactive_loop
exit /b %ec_success%

:extract_argument
    set "ea_variable_name=%~1"
    set /a "ea_argument_index=%~2"

    shift
    shift

    set /a "ea_i=0"
    :ea_extract_argument_loop
        if %ea_i% lss %ea_argument_index% (
            set /a "ea_i+=1"
            shift
            goto ea_extract_argument_loop
        )
    
    set "%ea_variable_name%=%~1"
exit /b %ec_success%

:repeat_string_syntax_check
    set /a "rssc_ec_asterisk_expected=20"
    set /a "rssc_ec_count_number_expected=21"

    set "rssc_em_asterisk_expected=Asterisk delimiter is not specified after string to repeat."
    set "rssc_em_count_number_expected=Repetition count is not specified after asterisk delimiter."

    set "rssc_string=%~1"
    set "rssc_delimiter=%~2"
    set "rssc_count=%~3"

    if not "%rssc_delimiter%" == "*" (
        echo %rssc_em_asterisk_expected%
        exit /b %rssc_ec_asterisk_expected%
    )

    set "rssc_count_regex=^[0-9][0-9]*$"
    echo %rssc_count%| findstr /r "%rssc_count_regex%" 2> nul > nul
    if errorlevel 1 (
        echo %rssc_em_count_number_expected%
        exit /b %rssc_ec_count_number_expected%
    )
exit /b %ec_success%

:repeat_string
    set "rs_variable_name=%~1"
    set "rs_string=%~2"
    set "rs_count=%~3"

    set /a "rs_i=0"
    set "rs_string_result="

    :rs_repetition_loop
        if %rs_i% lss %rs_count% (
            set "rs_string_result=%rs_string_result%%rs_string%"
            set /a "rs_i+=1"
            goto rs_repetition_loop
        )

    set "%rs_variable_name%=%rs_string_result%"
exit /b %ec_success%

:set_esc
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
        set "esc=%%b"
        exit /b 0
    )
exit /b %ec_success%
