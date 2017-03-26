
 /*
      - Weather station project -
    ER4 - IUT Annecy-Le-vieux - 2017

       • Anne LENSING
       • Helena STICKELBROECK
       • Cyrille DUPONT
       • Corentin THOMASSET
*/


// This functions permits to check if a plot (x, y) is in a rectangle (x, y, width, height)
func isInBox(var x, var y, var bx, var by, var bw, var bh)
    return ((x > bx) && (x < bx + bw) && (y > by) && (y < by + bh));
endfunc

// This function print the required error message or do nothing if error number is zero
func report(var n)
    #IF EXISTS DEBUG_ON
        var e;
        if ( e := file_Error() )
            print( "[",n,"] Error ", e, "=", [STR] FileErrors[e - 1], "\n" );
        endif
    #ELSE
        return;
    #ENDIF
endfunc

// To initialize the environnement
func setUp()
    // To be sure that the display is in landscape mode
    gfx_ScreenMode(LANDSCAPE_R);
    //gfx_Clipping(OFF);

    putstr("Mounting...\n");
    // We try to mount the µSD card
    if (!(file_Mount()))
        gfx_Cls();
        putstr("Drive not mounted.\nPlease plug the uSD card.\n");

        // We wait till the card gets plug
        while(!(file_Mount()))
            pause(200);
        wend
    endif

    gfx_Cls();


    var dat[20], gci[20];
    to(dat); print(FILE_IMAGES, ".Dat");
    to(gci); print(FILE_IMAGES, ".Gci");

    // Load the file containing all the pictures, and checking if it has been succefully loaded
    hndl := file_LoadImageControl(str_Ptr(dat), str_Ptr(gci), 1);
    if (!hndl)
         print("Error can't get the image file : ", FILE_IMAGES, "\n");

         repeat forever
    endif

    // We register our function that need a timer
    sys_SetTimerEvent(TIMER1, updatingDate);
    sys_SetTimerEvent(TIMER2, updatingTemp);
    sys_SetTimerEvent(TIMER3, updatingToogle);
    sys_SetTimerEvent(TIMER4, autoSaveData);
    sys_SetTimerEvent(TIMER7, modeEco);

    // Activate the transparency
    gfx_TransparentColour(TRANSPARENT_COLOR);
    gfx_Transparency(ON);

    // To enable the touchability of the display
    touch_Set(TOUCH_ENABLE);

    // Initializing the I2C
    I2C_Open(I2C_SLOW);
    pause(100);

    // To turn on the clock of the RTC
    setUpRTC();

    // We call those functions in order to initialize our global variables with the good value
    getTempI2C();
    getHumidityI2C();
    getDateTimeI2C();

    // We display the loading picture
    img_Show(hndl, glbBackgroundType);
    img_Show(hndl, IMAGE_LOADING);

    // We launch our timer that need to be launch
    sys_SetTimer(TIMER2,1);
    sys_SetTimer(TIMER4,6000);
    sys_SetTimer(TIMER7,6000);
endfunc

 // To set down the environnement
func setDown()

    //Shutting down the I2C
    I2C_Close();

    // We free the memory researved for the image handler
    mem_Free(hndl);

    // Unmouting the µSD
    file_Unmount();
endfunc

// A function to write in our data file in the µSD card
func writeOnSD(var datas)
    var dataFile;

    #IF EXISTS DEBUG_ON
        print("Openning the file for writing\n");
    #ENDIF
    // We try to open our file. If the file has already been created we open it in "append" mode ("a"), if not, in "write" mode
    if(dataFile := file_Open(FILE_DATA, (file_Exists(FILE_DATA)) ? 'a' : 'w'))

        #IF EXISTS DEBUG_ON
            print("Writing data\n");
        #ENDIF
        file_Write(datas, str_Length(datas), dataFile);
        report(2);

        #IF EXISTS DEBUG_ON
            print("Closing the file\n");
        #ENDIF
        file_Close(dataFile);
        report(3);
    else
        report(1);
        #IF EXISTS DEBUG_ON
            print("Can't open the file\n");
        #ENDIF
    endif

endfunc

// A function to read our data file in the µSD card
func readAllOnSD()
    var dataFile;
    var buffer;
    buffer := mem_Alloc(1000);


    #IF EXISTS DEBUG_ON
        print("Openning the file for reading\n");
    #ENDIF
    if(file_Exists(FILE_DATA))
        // We try to open our file in "read" mode
        if(dataFile := file_Open(FILE_DATA, 'r'))

            #IF EXISTS DEBUG_ON
                print("Reading data\n");
            #ENDIF
            file_Read(buffer,1000,dataFile);
            //report(5); Show "ERROR 10 : Reached the end of file" till the size of the file is greater than the size of the buffer

            #IF EXISTS DEBUG_ON
                print("Closing the file\n");
            #ENDIF
            file_Close(dataFile);
            //report(6); Show "ERROR 10 : Reached the end of file" till the size of the file is greater than the size of the buffer

            return buffer;
        else
            report(4);
            #IF EXISTS DEBUG_ON
                print("Can't open the file\n");
            #ENDIF
            return -1;
        endif
    else
        #IF EXISTS DEBUG_ON
            print("Trying to open a file that doesn't exists\n");
        #ENDIF
        return -1;
    endif
endfunc

// A function to read our data file in the µSD card
func readOnSD(var offset, var qqt)
    var nbCharByData := 16;

    var dataFile;
    var buffer;
    buffer := mem_Alloc(nbCharByData * qqt + 2);


    #IF EXISTS DEBUG_ON
        print("Openning the file for reading\n");
    #ENDIF
    if(file_Exists(FILE_DATA))

        // We try to open our file in "read" mode
        if(dataFile := file_Open(FILE_DATA, 'r'))

            // We choose from where to read
            #IF EXISTS DEBUG_ON
                print("Setting the index.\n");
            #ENDIF
            if(file_Index(dataFile, 0, nbCharByData,offset))

                // We read the amount of data we want
                #IF EXISTS DEBUG_ON
                    print("Reading data\n");
                #ENDIF
                if(file_GetS(buffer, (nbCharByData * qqt)+1, dataFile))

                    // We close the file
                    #IF EXISTS DEBUG_ON
                        print("Closing the file\n");
                    #ENDIF
                    if(file_Close(dataFile))
                        return buffer;
                    else
                        #IF EXISTS DEBUG_ON
                            print("Can't close the file\n") ;
                        #ENDIF
                        report(5); // Show "ERROR 10 : Reached the end of file" till the size of the file is greater than the size of the buffer
                    endif

                else
                    #IF EXISTS DEBUG_ON
                        print("Can't read the file\n") ;
                    #ENDIF
                    report(4); // Show "ERROR 10 : Reached the end of file" till the size of the file is greater than the size of the buffer
                endif

            else
                #IF EXISTS DEBUG_ON
                    print("Can't set the index.\n");
                #ENDIF
                report(3);
            endif
        else
            #IF EXISTS DEBUG_ON
                print("Can't open the file\n");
            #ENDIF
            report(2);
        endif
    else
        #IF EXISTS DEBUG_ON
            print("Trying to open a file that doesn't exists\n");
        #ENDIF
        report(1);
    endif

    return 0;
endfunc

// A function for debug, it stop the execution with an infinite loop
func STOP()
    repeat forever
endfunc

// A recursive function to calcul a number x to the power of n (a classy way instead of using a basic for loop)
func myPow(var x, var n)
    var m;

    if (n == 0)
        return 1;
    endif

    if (n % 2 == 0)
        m := myPow(x, n / 2);
        return m * m;
    else
        return x * myPow(x, n - 1);
    endif
endfunc

// This function looks for the temperature in the µSD card
func getTempInSD(var offset, var qqt)
    var buffer;
    var vars[30];
    var private ret[30];
    var n := 0;
    var ptr;
    var iBcl := 0;

    for(iBcl := 0; iBcl < qqt; ++iBcl)

        buffer := readOnSD(iBcl + offset, 1);
        ptr := str_Ptr(buffer);

        n := 0;
        while(str_GetC(&ptr, &vars[n++]) != 0);

        ret[iBcl] := ((vars[11]-'0')*100 + (vars[12]-'0')*10 + (vars[13]-'0'))*((vars[10]=='0') ? 1 : -1);

    next

    return ret;
endfunc

// This function returns the minimal value of an array
func getMin(var array,var length)
    var min := 0;
    var iBcl := 0;

    min := array[0];


    for(iBcl := 0; iBcl < length; ++iBcl)
        if(array[iBcl] < min)
            min := array[iBcl];
        endif
    next

    return min;
endfunc

// This function returns the maximal value of an array
func getMax(var array,var length)

    var max;
    var iBcl := 0;

    max := array[0];

    for(iBcl := 0; iBcl < length; ++iBcl)
        if(array[iBcl]>max)
            max := array[iBcl];
        endif
    next

    return max;
endfunc

// This function will look for the temperature on the sensor and store it into the global variable : glbTemperature
func getTempI2C()

    var temp := 0;
    var ret := 0;

    // Getting data
    I2C_Start();
    I2C_Write(I2C_ADDRESS_CPT_TEMP + 1);

    // We don't need the 2 first bytes (humidity)
    I2C_Read();
    I2C_Ack();
    I2C_Read();
    I2C_Ack();

    temp := I2C_Read()<<6;
    I2C_Ack();
    temp |= I2C_Read()>>2;
    I2C_Nack();


    // Calcul of the temperature

    var val32[2];
    var p;

    // Index 0 : LSB
    umul_1616(val32, temp, 1650);

    ret := (val32[1] << 2) | (val32[0] >> 14);
    ret -= 400;

    glbTemperature := ret;

endfunc

// This function will look for the humidity on the sensor and store it into the global variable : glbHumidity
func getHumidityI2C()
    var temp := 0;
    var ret := 0;

    // Getting data

    I2C_Start();
    I2C_Write(I2C_ADDRESS_CPT_TEMP + 1);



    temp := (I2C_Read() & 63) << 8;
    I2C_Ack();
    temp |= I2C_Read();
    I2C_Ack();

    // We don't need the 2 last bytes (temperature)
    I2C_Read();
    I2C_Ack();
    I2C_Read();
    I2C_Nack();

    // Calcul of the temperature

    var val32[2];
    var p;

    // Index 0 : LSB
    umul_1616(val32, temp, 100);

    ret := (val32[1] << 2) | (val32[0] >> 14);

    glbHumidity := ret;
endfunc

// This function will look for time and date information in the RTC and store it into the global array : glbDateTime
func getDateTimeI2C()

    var lect := 0;

    // Secondes
    lect := RTCRead(0);
    glbDateTime[U_SECONDES] := (lect & 15);
    glbDateTime[D_SECONDES] := (lect & 112) >> 4;

    // Minutes
    lect := RTCRead(0x01);
    glbDateTime[U_MINUTES] := (lect & 15);
    glbDateTime[D_MINUTES] := (lect & 112) >> 4;

    // Hour
    lect := RTCRead(0x02);
    glbDateTime[U_HOUR] := (lect & 15);
    glbDateTime[D_HOUR] := (lect & 48) >> 4;


    // Day
    lect := RTCRead(0x04);
    glbDateTime[U_DAY] := (lect & 15);
    glbDateTime[D_DAY] := (lect & 48) >> 4;


    // Month
    lect := RTCRead(0x05);
    glbDateTime[U_MONTH] := (lect & 15);
    glbDateTime[D_MONTH] := (lect & 16) >> 4;

    return;
endfunc

// This function permits to setup the RTC module.
func setUpRTC()
    var reg;

    // We switch on the bit that allow the couting
    reg := RTCRead(0);
    RTCWrite(0x, reg | 0x80);


    //We switch on the bit that allow the RTC to memorize the time & date thanks to the 3V batterie
    reg := RTCRead(0x03);
    RTCWrite(0x03, reg | 0x08);
endfunc

// This function is used for debug, it permits to print value in big
func bigprint(var text)
    txt_Set(TEXT_WIDTH, 5);
    txt_Set(TEXT_HEIGHT, 5);
    print(text);
    txt_Set(TEXT_WIDTH, 1);
    txt_Set(TEXT_HEIGHT, 1);
endfunc

// To make a clip window by width and heith
func myClipWindow(var x,var y,var w,var h)
     gfx_ClipWindow(x,y, x+w, y+h);
endfunc

// This function permits to know either a point is in a box or not
func isDotInBox(var x, var y, var bx, var by, var bw, var bh)
    return ((x > bx) && (x < bx + bw) && (y > by) && (y < by + bh));
endfunc

// This function returns 1 if a you touch in the specified box
// it works only one time in a loop (because when we get the touch status, it is reset)
func boxTouched(var xbox, var ybox, var wbox, var hbox)
    var state;
    var xtouched, ytouched;
    state := getTouchStatus();

    if(state == TOUCH_PRESSED)
        xtouched := touch_Get(TOUCH_GETX);
        ytouched := touch_Get(TOUCH_GETY);
        return isDotInBox(xtouched, ytouched, xbox, ybox, wbox, hbox);
    endif

    return 0;
endfunc

// This function gives the number of figures in a number (minus sign count for 1)
func nbDigit(var nombre)

    var ret := 0;

    if(nombre < 0)
       nombre *= -1;
       ++ret;
    endif

    while(nombre > 0)
        nombre /= 10;
        ++ret;
    wend

    return ret;
endfunc

// This function uses the values stored in glbDateTime to save them in the RTC
func setDateTimeI2C()
    var lect := 0;

    lect := RTCRead(0x1);
    RTCWrite(0x1, writeInReg(lect, (glbDateTime[U_MINUTES] | (glbDateTime[D_MINUTES] << 4)), 0, 7));

    lect := RTCRead(0x2);
    RTCWrite(0x2, writeInReg(lect, (glbDateTime[U_HOUR] | (glbDateTime[D_HOUR] << 4)), 0, 6));

    lect := RTCRead(0x4);
    RTCWrite(0x4, writeInReg(lect, (glbDateTime[U_DAY] | (glbDateTime[D_DAY] << 4)), 0, 6));

    lect := RTCRead(0x5);
    RTCWrite(0x5, writeInReg(lect, (glbDateTime[U_MONTH] | (glbDateTime[D_MONTH] << 4)), 0, 5));

endfunc

// This function write "value" in "reg" at the "offset"
func writeInReg(var reg, var value, var offset, var lenght)
    /*
          - Example -

       Reg :    11111111
       Value :  00000100
       Offset : 2
       Lenght : 3

       Return : 11110011
    */

    var mask := 0;
    var iBcl := 0;

    // First we create our mask
    // If we want to update from the bit 2 to the bit 4 our mask will be : mask = 00011100
    for(iBcl := offset; iBcl < offset + lenght; ++iBcl)
        mask += myPow(2,iBcl);
    next

    // Then, with the mask, we put our bits at 0 in the byte
    // Here we will obtain : reg = XXX000XX
    reg &= ~mask;

    // Then we put those bits to the desired value
    reg |= value << offset;
    return reg;
endfunc

// To read a specifeid register in the RTC
func RTCRead(var reg)
    var ret;

    I2C_Start();
    I2C_Write(I2C_ADDRESS_RTC);
    I2C_Write(reg);
    I2C_Restart();
    I2C_Write(I2C_ADDRESS_RTC + 1);
    ret := I2C_Read();
    I2C_Nack();
    I2C_Stop();

    return ret;
endfunc

// To write a value in a specified register in the RTC
func RTCWrite(var reg, var value)
    var ret;

    I2C_Start();
    I2C_Write(I2C_ADDRESS_RTC);
    I2C_Write(reg);
    I2C_Write(value);
    I2C_Ack();
    I2C_Stop();

endfunc

// A function that manages the eco mode
func modeEco()
    var secRemaining := 0;

    if(1 == glbModeSleepOn)
        secRemaining := sys_Sleep(65535);   // Sleeps for

        if(secRemaining == 0)
            sys_SetTimer(TIMER7,1);
        else
            sys_SetTimer(TIMER7,15000);
        endif

        sys_EventsResume();
    endif
 endfunc

// When called, this function save the date / time / temperature / humidity in the µSD card
func saveDataInSD()

    //1502171240004012  -> 15/02/17 12h40 04,0°C 12%

    var datas[20];
    var p;

    p:= str_Ptr(datas);

    // We actualise the time / humidity & date /time
    getTempI2C();
    getHumidityI2C();
    getDateTimeI2C();

    // We create our string containning all the data
    str_PutByte(p+0, '0' + glbDateTime[D_DAY]);
    str_PutByte(p+1, '0' + glbDateTime[U_DAY]);
    str_PutByte(p+2, '0' + glbDateTime[D_MONTH]);
    str_PutByte(p+3, '0' + glbDateTime[U_MONTH]);
    str_PutByte(p+4, '0' + glbDateTime[D_YEAR]);
    str_PutByte(p+5, '0' + glbDateTime[U_YEAR]);
    str_PutByte(p+6, '0' + glbDateTime[D_HOUR]);
    str_PutByte(p+7, '0' + glbDateTime[U_HOUR]);
    str_PutByte(p+8, '0' + glbDateTime[D_MINUTES]);
    str_PutByte(p+9, '0' + glbDateTime[U_MINUTES]);
    str_PutByte(p+10, (glbTemperature < 0) ? '1' : '0');
    str_PutByte(p+11, '0' + (glbTemperature/100));
    str_PutByte(p+12, '0' + ((glbTemperature/10)%10));
    str_PutByte(p+13, '0' + (glbTemperature%10));
    str_PutByte(p+14, '0' + (glbHumidity/10));
    str_PutByte(p+15, '0' + (glbHumidity%10));

    writeOnSD(p);

endfunc

// A function that manage the auto save in the SD card
func autoSaveData()
        var private iCpt := 0;
        iCpt++;

        // We don't save our data if the user is in the setting menu
        if(iCpt == glbFrequenceSaveData && glbStateDispaly != STATE_SETTING)
            iCpt := 0;

            saveDataInSD();
        endif

   sys_SetTimer(TIMER2,60000);
endfunc

// This returns the state of the touch register and postone the falling asleep of display if in eco mode and a touch event occured
func getTouchStatus()
    var status;
    status := touch_Get(TOUCH_STATUS);

    // If their is a touch event, we postone the enter in sleep mode
    if((status == TOUCH_PRESSED || status == TOUCH_MOVING) && 1 == glbModeSleepOn)
        sys_SetTimer(TIMER7,15000);
    endif

    return status;
endfunc


