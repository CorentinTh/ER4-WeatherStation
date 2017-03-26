
/*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


var glbUpdatingMainScreen := 1;
var glbUpdateFrequenceToogleMainScreen := 5000;

// We periodic update the date till we are on the main screen
func updatingDate()
    getDateTimeI2C();

    if(1 == glbUpdatingMainScreen)
        sys_SetTimer(TIMER1,1000);
    endif
endfunc

// We update the temperature and the hygrometrie every 10 sec
func updatingTemp()
    getTempI2C();
    getHumidityI2C();

    // We change the background according to the temperature
    //  T°C < 8°C : Background cold
    //  8°C < T°C < 28°C : Background normal
    //  T°C > 28°C : Background warm

    if(glbTemperature < 80)
        glbBackgroundType := IMAGE_BG_COLD;
    else
        if(glbTemperature > 280)
            glbBackgroundType := IMAGE_BG_WARM;
        else
            glbBackgroundType := IMAGE_BG_NORMAL;
        endif
    endif

    sys_SetTimer(TIMER2,10000);
endfunc

// This function toogle the display between temperature and time
func updatingToogle()
    var private cpt := 0;
    var nbIteration := 100;

    // We draw the loading bar at the bottom of the screen
    gfx_Line(0, 239, cpt * 320/nbIteration, 239, WHITE);
    gfx_Line(0, 238, cpt * 320/nbIteration, 238, WHITE);

    if(cpt++ >= nbIteration)
        mainScreen.state := !mainScreen.state;
        cpt := 0;

        gfx_ClipWindow(0, 238, 320, 240);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        gfx_Clipping(OFF);
    endif

    if(1 == glbUpdatingMainScreen)
        sys_SetTimer(TIMER3,glbUpdateFrequenceToogleMainScreen/nbIteration);
    else
        cpt := 0;

        gfx_ClipWindow(0, 238, 320, 240);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType);
        gfx_Clipping(OFF);
    endif
endfunc

// This function managed the main screen
func mainScreen()

    var private state := 0;
    var oldState := -1;
    var xtouched, ytouched;

    sys_SetTimer(TIMER1,1);
    sys_SetTimer(TIMER3,1);

    glbUpdatingMainScreen := 1;

    img_Show(hndl, glbBackgroundType + 1);

    drawSettingButton();
    drawDate();

    while(1 == glbUpdatingMainScreen)

        // If the state changed we clean the middle of the screen and we display either the time or the temperature/humidity
        if(oldState != state)
            oldState := state;

            myClipWindow(50, 60, 220, 140);
            gfx_Clipping(ON);
            img_Show(hndl, glbBackgroundType + 1);
            gfx_Clipping(OFF);

            if(1 == state)
                drawClock(1);  // We display all the clock
            endif
        endif

        if(state == 1)
            drawClock(0); // We display only the things that have changed
        else
            drawTemp();
            drawHygro();
        endif

        // We check if an interaction occured
        if(getTouchStatus() == TOUCH_PRESSED)
            // We get the X and Y coordinates of the touched point
            xtouched := touch_Get(TOUCH_GETX);
            ytouched := touch_Get(TOUCH_GETY);

            if(isDotInBox(xtouched, ytouched,0,0,45,34))  // Setting button
                // We stop all timer and go out of the while loop and update the states graph
                glbUpdatingMainScreen := 0;
                glbStateDispaly := STATE_MENU_SCREEN;
            else
                if(isDotInBox(xtouched, ytouched,70,35,180,180))  // In the circle
                    // We manually toogle the display and reset the timer fot toogleing
                    state := !state;

                    updatingToogle.cpt := 0;

                else
                    // If the user touch the date and month at the top right corner we go directly in the setting to update the date & time
                    if(isDotInBox(xtouched, ytouched, 226, 0, 94, 50))
                        glbUpdatingMainScreen := 0;
                        glbStateDispaly := STATE_SETTING;
                        settingScreen.stateSetting := 1;
                    endif
                endif
            endif
        endif
    wend
endfunc
