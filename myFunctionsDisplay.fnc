
/*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


// This functions permit to draw digits using the pictures
func drawDigit(var x, var y, var digit, var image_size)

    // Some security checks
    if(image_size != IMAGE_DIGIT_BIG && image_size != IMAGE_DIGIT_SMALL && image_size != IMAGE_DIGIT_XSMALL)
        #IF EXISTS DEBUG_ON
            print("Error function drawDigit : Wrong size of digit\n");
        #ENDIF
        return;
    endif

    if(digit < 0 || digit > DIGIT_MAX)
        #IF EXISTS DEBUG_ON
            print("Error function drawDigit : Digit out of range : ", digit ,"\n");
        #ENDIF
        return;
    endif

    // We chose the index of the tiled picture
    img_SetWord(hndl, image_size, IMAGE_INDEX, digit);
    // We chose is coordinates
    img_SetPosition(hndl, image_size, x,y);
    // And we display it
    img_Show(hndl, image_size);
endfunc

// This function draw the month and the day on the top right corner
func drawDate()
    var month;

    month := glbDateTime[U_MONTH] + glbDateTime[D_MONTH]*10 - 1;

    if(month < 0)
        month := 0;
        print("Error: month == 0") ;
    endif

    // We chose the index of our tiled picture of months
    img_SetWord(hndl, IMAGE_MONTH, IMAGE_INDEX, month);
    // We chose its coordinates
    img_SetPosition(hndl, IMAGE_MONTH, 226,0);
    // And we display it
    img_Show(hndl, IMAGE_MONTH);

    // We display the day and we suppress the first digit if it's equal to zero (to have "5" instead of "05")
    if(glbDateTime[7] > 0)
        drawDigit(272,31,glbDateTime[U_DAY], IMAGE_DIGIT_SMALL);
        drawDigit(259,31,glbDateTime[D_DAY], IMAGE_DIGIT_SMALL);
    else
        drawDigit(267,31,glbDateTime[U_DAY], IMAGE_DIGIT_SMALL);
    endif
endfunc

// This functions permit to draw the clock in the middle of the screen
func drawClock(var updateAll)

    // This function will draw our digits only if needed in order
    // to prevent the clock from blinking unless we put "1" in argument


    var x0 := 160;
    var y0 := 120;
    y0-=20;

    var offsetClip := 3;

    var usec;
    usec := glbDateTime[U_SECONDES];
    var dsec;
    dsec := glbDateTime[D_SECONDES];
    var umin;
    umin := glbDateTime[U_MINUTES];
    var dmin;
    dmin := glbDateTime[D_MINUTES];
    var uhour;
    uhour := glbDateTime[U_HOUR];
    var dhour;
    dhour := glbDateTime[D_HOUR];

    var private oldusec := -1;
    var private olddsec := -1;
    var private oldumin := -1;
    var private olddmin := -1;
    var private olduhour := -1;
    var private olddhour := -1;

    // We display all our digit if "1" has been passed in argument
    if(1 == updateAll)
        drawDigit(x0-77, y0, dhour, IMAGE_DIGIT_BIG);
        drawDigit(x0-47, y0, uhour, IMAGE_DIGIT_BIG);
        drawDigit(x0+7, y0, dmin, IMAGE_DIGIT_BIG);
        drawDigit(x0+37, y0, umin, IMAGE_DIGIT_BIG);
        drawDigit(x0-12, y0+60, dsec, IMAGE_DIGIT_SMALL);
        drawDigit(x0+3, y0+60, usec, IMAGE_DIGIT_SMALL);
        return;
    endif

    // Hour tens
    if(olddhour != dhour)
        olddhour := dhour;

        myClipWindow(x0 - 77 + offsetClip, y0, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0-77, y0, dhour, IMAGE_DIGIT_BIG);
        gfx_Clipping(OFF);
    endif

    // Hour units
    if(olduhour != uhour)
        olduhour := uhour;

        myClipWindow(x0 - 47 + offsetClip, y0+offsetClip, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0-47, y0, uhour, IMAGE_DIGIT_BIG);
        gfx_Clipping(OFF);
    endif

    // The two dots
    drawDigit(x0-20, y0, DIGIT_TWO_DOTS, IMAGE_DIGIT_BIG);

    // Minutes tens
    if(olddmin != dmin)
        olddmin := dmin;

        myClipWindow(x0 +7 + offsetClip, y0, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0+7, y0, dmin, IMAGE_DIGIT_BIG);
        gfx_Clipping(OFF);
    endif

    // Minutes units
    if(oldumin != umin)
        oldumin := umin;

        myClipWindow(x0 +37 + offsetClip, y0, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0+37, y0, umin, IMAGE_DIGIT_BIG);
        gfx_Clipping(OFF);
    endif

    // Secondes tens
    if(olddsec != dsec)
        olddsec := dsec;

        myClipWindow(x0-12, y0+60, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0-12, y0+60, dsec, IMAGE_DIGIT_SMALL);
        gfx_Clipping(OFF);
    endif

    // Secondes units
    if(oldusec != usec)
        oldusec := usec;

        myClipWindow(x0+3, y0+60, 40-offsetClip, 40-offsetClip);
        gfx_Clipping(ON);
        img_Show(hndl, glbBackgroundType + 1);
        drawDigit(x0+3, y0+60, usec, IMAGE_DIGIT_SMALL);
        gfx_Clipping(OFF);
    endif
endfunc

// A custom function to draw rectangles
func myRectangle(var x, var y, var w, var h, var color)
    gfx_OutlineColour(WHITE) ;
    gfx_LinePattern(LPFINE) ;
    gfx_RectangleFilled(x, y, x+w, y+h, color) ;
    gfx_OutlineColour(BLACK) ;
    gfx_LinePattern(LPSOLID) ;
endfunc

// This function draw the list for the historic
func drawList(var offset)
    var linePerScreen := 5;
    var charPerLine := 16;

    var digitOffset := 0;
    var deltaX := 11;
    var deltaY := 17;
    var x := 15;
    var y := 147;

    var datas;
    var iBclLine, iBclChar;
    var ptr;
    var vars[80];
    var n := 0;

    datas := readOnSD(offset, linePerScreen);

    ptr := str_Ptr(datas);

    while(str_GetC(&ptr, &vars[n++]) != 0);

    for(iBclLine := 0; iBclLine < linePerScreen; ++iBclLine)
        digitOffset := 0;

        for(iBclChar := 0; iBclChar < 25; ++iBclChar)

            if((iBclChar == 2) || (iBclChar == 5) || (iBclChar == 11) || (iBclChar == 15) || (iBclChar == 18) || (iBclChar == 20) || (iBclChar == 24) || (iBclChar == 8) || (iBclChar == 14) || (iBclChar == 21))

                switch(iBclChar)
                    case 2 :
                    case 5 :
                        drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine,DIGIT_SLASH,IMAGE_DIGIT_SMALL);
                        break;
                    case 11 :
                        x -= 2;
                        drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine,DIGIT_TWO_DOTS,IMAGE_DIGIT_SMALL);
                        x -= 2;
                        break;
                    case 15 :
                        if(vars[charPerLine*iBclLine + iBclChar-digitOffset] == '1')
                            drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine,DIGIT_MINUS,IMAGE_DIGIT_SMALL);
                        endif

                        --digitOffset;

                        break;
                    case 18 :
                        x -= 2;
                        drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine, DIGIT_COMA, IMAGE_DIGIT_SMALL);
                        x -= 2;
                        break;
                    case 20 :
                        var digitTemp;
                        digitTemp := (glbIsCelcius == 1) ? DIGIT_CELCIUS : DIGIT_FAHRENHEIT;

                        drawDigit(x+iBclChar*deltaX,y+ deltaY*iBclLine,digitTemp , IMAGE_DIGIT_SMALL);
                        break;
                    case 24 :
                        drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine, DIGIT_PERCENT, IMAGE_DIGIT_SMALL);
                        break;
                    endswitch
                   ++digitOffset;
            else
                    drawDigit(x+iBclChar*deltaX,y+deltaY*iBclLine,vars[charPerLine * iBclLine + iBclChar-digitOffset]-'0',IMAGE_DIGIT_SMALL);
            endif

        next
        x+=8;
    next

endfunc

// This function draw the graph for the historic
func drawGraph(var offset)

    // Customize the graph
    var x0 := 40;                // Bottom left coordinates
    var y0 := 130;               // Bottom left coordinates
    var H := 85;                 // Height
    var W := 240;                // Width
    var nbGradYaxis := 5;        // Number of graduation on the y axis
    var numberOfPoints := 5;     // The number of point to be displayed
    // ... end of customization

    var points;
    var max, min;
    var stepGrad;
    var grad;
    var prevGrad := -1000;
    var sign;
    var iBcl := 0;
    var y,x;
    var yStep;
    var yline := -5;

    // We get our temperature values
    points := getTempInSD(offset, numberOfPoints);

    // We look for the greater and the lower one
    max := getMax(points,numberOfPoints);
    min := getMin(points,numberOfPoints);

    // We get our y scall
    yStep := (H-10)*10/(max-min);

    // We draw the axis
    if(min < 0 && max > 0)
       yline := (yStep * (0 - min))/10;
    endif

    gfx_Line(x0, y0+5, x0, y0-H-5, WHITE);
    gfx_TriangleFilled(x0-3, y0-H-5, x0+3, y0-H-5, x0, y0-H-11, WHITE);

    gfx_Line(x0-5, y0 - 5 - yline, x0+W+5, y0 - 5 - yline, WHITE);
    gfx_TriangleFilled(x0+W+5, y0 - 8 - yline, x0+W+5, y0 - 2 - yline, x0+W+11, y0 - 5 - yline, WHITE);

    // We display the curve

    gfx_MoveTo(x0+5+W/(numberOfPoints*2),y0-5);

    gfx_Set(PEN_SIZE, SOLID);

    for(iBcl := 0; iBcl < numberOfPoints; ++iBcl)

        x := x0+5+W/(numberOfPoints*2)+(W*iBcl)/numberOfPoints;

        y := (yStep * (points[iBcl] - min))/10;

        if(iBcl == 0)
            gfx_MoveTo(x,y0-5-y);
        else
            gfx_LineTo(x,y0-5-y);
        endif

        gfx_Bullet(2);
    next

    // We display the graduations

    stepGrad := (max-min)*10/nbGradYaxis;

    for(iBcl := 0; iBcl <= nbGradYaxis; iBcl ++)
        sign := 0;

        y := y0 - 5 - (yStep * (iBcl*stepGrad))/100;

        grad := (min+(iBcl*stepGrad)/10);

        if(grad != prevGrad)

            gfx_Line(x0-2,y,x0+2,y, WHITE);


            if(grad < 0)
                grad *= -1;
                sign := 1;
            endif

            drawDigit(x0-15,y-5,grad % 10,IMAGE_DIGIT_XSMALL);
            drawDigit(x0-21,y-5,DIGIT_COMA,IMAGE_DIGIT_XSMALL);
            drawDigit(x0-26,y-5,(grad/10)%10,IMAGE_DIGIT_XSMALL);

            if(grad/100 > 0)
                drawDigit(x0-31,y-5,(grad/100)%10,IMAGE_DIGIT_XSMALL);

                if(1 == sign)
                    drawDigit(x0-36,y-5,DIGIT_MINUS,IMAGE_DIGIT_XSMALL);
                endif
            else
                if(1 == sign)
                    drawDigit(x0-31,y-5,DIGIT_MINUS,IMAGE_DIGIT_XSMALL);
                endif
            endif
        endif
        prevGrad := grad;
    next
    gfx_Set(PEN_SIZE, OUTLINE);

endfunc

// This function permits to draw the temperature in the middle of the screen
func drawTemp()
    var temp;
    temp := glbTemperature;

    var digitTemp;
    var x;

    // We get the temperature and convert it if farenheit mode is set
    // (to convert to farenheit : T(°F) = T(°C) x 9/5 + 32)
    if(1 == glbIsCelcius)
        digitTemp := DIGIT_CELCIUS;
    else
        temp := ((temp*9)/5 +320);
        digitTemp := DIGIT_FAHRENHEIT;
    endif

    x := 160 - nbDigit(temp)*15 - 28;  // '- 28' because of the offset of the coma and the minus digit

    if(temp < 0)
        temp *= -1;
        drawDigit(x, 100, DIGIT_MINUS, IMAGE_DIGIT_BIG);
        x += 24;
    endif

    if(temp > 100)
        drawDigit(x, 100, temp / 100, IMAGE_DIGIT_BIG);
        x += 30;
    endif

    drawDigit(x, 100, (temp / 10) % 10, IMAGE_DIGIT_BIG);
    x += 20;

    drawDigit(x, 100, DIGIT_COMA, IMAGE_DIGIT_BIG);
    x += 20;

    drawDigit(x, 100, temp % 10, IMAGE_DIGIT_BIG);
    x += 30;

    drawDigit(x, 100, digitTemp, IMAGE_DIGIT_BIG);

endfunc

// This function permits to draw the hygrometrie
func drawHygro()
    var hygro;

    hygro := glbHumidity;

    // If supress the 0 in the left of our value if it's below 10 (in order to have "5" instead of "05")
    if(hygro > 9)
         drawDigit(140, 160, hygro / 10, IMAGE_DIGIT_SMALL);
         drawDigit(151, 160, hygro % 10, IMAGE_DIGIT_SMALL);
         drawDigit(166, 160, DIGIT_PERCENT, IMAGE_DIGIT_SMALL);
    else
         drawDigit(145, 160, hygro % 10, IMAGE_DIGIT_SMALL);
         drawDigit(160, 160, DIGIT_PERCENT, IMAGE_DIGIT_SMALL);
    endif
endfunc

// This function draw the historic (graph + list)
func drawHistoric(var graphType, var dataOffset)

    if((graphType != 0) & (graphType != 1))
        #IF EXISTS DEBUG_ON
            print("drawHistoric : Wrong type of graph ", graphType ,"\n  1 : Temp\n  0 : Hygro\n");
        #ENDIF
        return;
    endif

    drawList(dataOffset);
    drawGraph(dataOffset);

endfunc

// This function draw the hamburger button that permit to go to the menu panel
func drawSettingButton()
    var x0 := 10;
    var y0 := 10;
    var w := 25;
    var deltaY := 7;

    gfx_RectangleFilled(x0, y0, x0+w, y0+1, WHITE);
    gfx_RectangleFilled(x0, y0+deltaY, x0+w, y0+deltaY+1, WHITE);
    gfx_RectangleFilled(x0, y0+deltaY*2, x0+w, y0+deltaY*2+1, WHITE);
endfunc

