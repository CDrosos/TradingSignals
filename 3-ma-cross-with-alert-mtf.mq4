//+--------------------------------------------------------------------------+
//|                                                3 MA Cross with alert.mq4 |
//|                                                                   mladen |
//+--------------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1 Aqua
#property indicator_color2 Orange
#property indicator_color3 DodgerBlue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 FireBrick
#property indicator_color7 Blue
#property indicator_color8 LimeGreen
#property indicator_color9 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 2
#property indicator_width9 2


//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern int    FasterMA         = 10;//5;
extern int    FasterShift      = 0;
extern ENUM_MA_METHOD     FasterMode  = 1;
extern ENUM_APPLIED_PRICE FasterPrice = PRICE_CLOSE;
extern int    MediumMA         = 20;
extern int    MediumShift      = 0;
extern ENUM_MA_METHOD     MediumMode  = 1;
extern ENUM_APPLIED_PRICE MediumPrice = PRICE_CLOSE;
extern int    SlowerMA         = 40;//34;
extern int    SlowerShift      = 0;
extern ENUM_MA_METHOD     SlowerMode  = 1;
extern ENUM_APPLIED_PRICE SlowerPrice = PRICE_CLOSE;
extern bool   showMAs          = true;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsOnFastCrossMiddle = true;
extern bool   alertsOnFastCrossSlow   = true;
extern bool   alertsOnMiddleCrossSlow = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsNotify     = false;
extern bool   alertsEmail      = false;
extern bool   showarrows_ms    = false;//true;
extern bool   showarrows_fs    = true;
extern bool   showarrows_fm    = true;
extern int    arrowUpCode_ms    = 159;
extern int    arrowDownCode_ms  = 159;
extern int    arrowUpCode_fs    = 233;
extern int    arrowDownCode_fs  = 234;
extern int    arrowUpCode_fm    = 116;
extern int    arrowDownCode_fm  = 116;
extern bool   Interpolate      = true;



extern bool   ArrowsOnFirstBar = false;
extern double arrowsFMGap      = 0.50;
extern double arrowsFSGap      = 0.75;
extern double arrowsMSGap      = 1.00;

//
//
//
//
//

double CrossfmUp[];
double CrossfmDn[];
double CrossfsUp[];
double CrossfsDn[];
double CrossmsUp[];
double CrossmsDn[];
double ma1[];
double ma2[];
double ma3[];
double trendfm[];
double trendfs[];
double trendms[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(12);
   //SetIndexBuffer(0,CrossmsUp);                    SetIndexStyle(0, DRAW_ARROW); SetIndexArrow(0,arrowUpCode)  ;
   SetIndexBuffer(0,CrossmsUp);   if (showarrows_ms) { SetIndexStyle(0, DRAW_ARROW); SetIndexArrow(0,arrowUpCode_ms)  ; } else SetIndexStyle(0,DRAW_NONE);
   //SetIndexBuffer(1,CrossmsDn);                    SetIndexStyle(1, DRAW_ARROW); SetIndexArrow(1,arrowDownCode);
   SetIndexBuffer(1,CrossmsDn);   if (showarrows_ms) { SetIndexStyle(1, DRAW_ARROW); SetIndexArrow(1,arrowDownCode_ms); } else SetIndexStyle(1,DRAW_NONE);
   //SetIndexBuffer(2,CrossfsUp);                    SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2,arrowUpCode)  ;
   SetIndexBuffer(2,CrossfsUp);   if (showarrows_fs) { SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2,arrowUpCode_fs)  ; } else SetIndexStyle(2,DRAW_NONE);
   //SetIndexBuffer(3,CrossfsDn);                    SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3,arrowDownCode);
   SetIndexBuffer(3,CrossfsDn);   if (showarrows_fs) { SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3,arrowDownCode_fs); } else SetIndexStyle(3,DRAW_NONE);
   //SetIndexBuffer(4,CrossfmUp);                    SetIndexStyle(4, DRAW_ARROW); SetIndexArrow(4,arrowUpCode)  ;
   SetIndexBuffer(4,CrossfmUp);   if (showarrows_fm) { SetIndexStyle(4, DRAW_ARROW); SetIndexArrow(4,arrowUpCode_fm)  ; } else SetIndexStyle(4,DRAW_NONE);
   //SetIndexBuffer(5,CrossfmDn);                    SetIndexStyle(5, DRAW_ARROW); SetIndexArrow(5,arrowDownCode);
   SetIndexBuffer(5,CrossfmDn);   if (showarrows_fm) { SetIndexStyle(5, DRAW_ARROW); SetIndexArrow(5,arrowDownCode_fm); } else SetIndexStyle(5,DRAW_NONE);
   
   SetIndexBuffer(6,ma1); 
   SetIndexBuffer(7,ma2); 
   SetIndexBuffer(8,ma3); 
   SetIndexBuffer(9 ,trendfm); 
   SetIndexBuffer(10,trendfs); 
   SetIndexBuffer(11,trendms); 
   if (showMAs)
   {
      SetIndexStyle(6,DRAW_LINE);
      SetIndexStyle(7,DRAW_LINE);
      SetIndexStyle(8,DRAW_LINE);
   }      
   else
   {
      SetIndexStyle(6,DRAW_NONE);
      SetIndexStyle(7,DRAW_NONE);
      SetIndexStyle(8,DRAW_NONE);
   } 
   
   //
   //
   //
   //
   //
   
   indicatorFileName = WindowExpertName();
   returnBars        = TimeFrame == "returnBars";     if (returnBars)     return(0);
   timeFrame         = stringToTimeFrame(TimeFrame);
   
      SetIndexShift(6,FasterShift*timeFrame/Period());
      SetIndexShift(7,MediumShift*timeFrame/Period());
      SetIndexShift(8,SlowerShift*timeFrame/Period());
   
   IndicatorShortName(timeFrameToString(timeFrame)+" 3 ma cross ");     
   return(0);
}
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{ 
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           if (FasterShift < 0) limit = MathMax(limit,-FasterShift);
           if (MediumShift < 0) limit = MathMax(limit,-MediumShift);
           if (SlowerShift < 0) limit = MathMax(limit,-SlowerShift);
           if (returnBars) { CrossmsUp[0] = limit+1; return(0); }
   
            if (timeFrame!=Period())
            {
               int shift = -1; if (ArrowsOnFirstBar) shift=1;
               limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,timeFrame,Time[i]);   
                  int x = iBarShift(NULL,timeFrame,Time[i+shift]);            
                     ma1[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FasterMA,0,FasterMode,FasterPrice,MediumMA,0,MediumMode,MediumPrice,SlowerMA,0,SlowerMode,SlowerPrice,showMAs,alertsOn,alertsOnCurrent,alertsOnFastCrossMiddle,alertsOnFastCrossSlow,alertsOnMiddleCrossSlow,alertsMessage,alertsSound,alertsNotify,alertsEmail,showarrows_ms,showarrows_fs,showarrows_fm,6,y);
                     ma2[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FasterMA,0,FasterMode,FasterPrice,MediumMA,0,MediumMode,MediumPrice,SlowerMA,0,SlowerMode,SlowerPrice,showMAs,alertsOn,alertsOnCurrent,alertsOnFastCrossMiddle,alertsOnFastCrossSlow,alertsOnMiddleCrossSlow,alertsMessage,alertsSound,alertsNotify,alertsEmail,showarrows_ms,showarrows_fs,showarrows_fm,7,y);
                     ma3[i]       = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FasterMA,0,FasterMode,FasterPrice,MediumMA,0,MediumMode,MediumPrice,SlowerMA,0,SlowerMode,SlowerPrice,showMAs,alertsOn,alertsOnCurrent,alertsOnFastCrossMiddle,alertsOnFastCrossSlow,alertsOnMiddleCrossSlow,alertsMessage,alertsSound,alertsNotify,alertsEmail,showarrows_ms,showarrows_fs,showarrows_fm,8,y);
                     CrossfmUp[i] = EMPTY_VALUE;
                     CrossfmDn[i] = EMPTY_VALUE;
                     CrossfsUp[i] = EMPTY_VALUE;
                     CrossfsDn[i] = EMPTY_VALUE;
                     CrossmsUp[i] = EMPTY_VALUE;
                     CrossmsDn[i] = EMPTY_VALUE;
                     trendfm[i]   = trendfm[i+1];
                     trendfs[i]   = trendfs[i+1];
                     trendms[i]   = trendms[i+1];
                     if (x!=y)
                     {
                        if (ma1[i]>ma2[i]) trendfm[i] =  1;
                        if (ma1[i]<ma2[i]) trendfm[i] = -1;
                        if (ma1[i]>ma3[i]) trendfs[i] =  1;
                        if (ma1[i]<ma3[i]) trendfs[i] = -1;
                        if (ma2[i]>ma3[i]) trendms[i] =  1;
                        if (ma2[i]<ma3[i]) trendms[i] = -1;
                        double range = iATR(NULL,0,15,i);         
                        if (alertsOnFastCrossMiddle && trendfm[i]!=trendfm[i+1]) 
                           if (trendfm[i] == 1)
                                 CrossfmUp[i] = MathMin(ma1[i],ma2[i])-range*arrowsFMGap;
                           else  CrossfmDn[i] = MathMax(ma1[i],ma2[i])+range*arrowsFMGap;
                        if (alertsOnFastCrossSlow && trendfs[i]!=trendfs[i+1]) 
                           if (trendfs[i] == 1)
                                 CrossfsUp[i] = MathMin(ma1[i],ma3[i])-range*arrowsFSGap;
                           else  CrossfsDn[i] = MathMax(ma1[i],ma3[i])+range*arrowsFSGap;
                        if (alertsOnMiddleCrossSlow && trendms[i]!=trendms[i+1]) 
                           if (trendms[i] == 1)
                                 CrossmsUp[i] = MathMin(ma2[i],ma3[i])-range*arrowsMSGap;
                           else  CrossmsDn[i] = MathMax(ma2[i],ma3[i])+range*arrowsMSGap;
                     }
                  
                      //
                      //
                      //
                      //
                      //
            
                      if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

                      //
                      //
                      //
                      //
                      //

                      datetime time = iTime(NULL,timeFrame,y);
                        for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
                        for(int k = 1; k < n; k++) 
                        {
                           ma1[i+k] = ma1[i] + (ma1[i+n] - ma1[i]) * k/n;
                           ma2[i+k] = ma2[i] + (ma2[i+n] - ma2[i]) * k/n;     
                           ma3[i+k] = ma3[i] + (ma3[i+n] - ma3[i]) * k/n;                                  
                        }       
               }
               return(0);
     }
     
     //
     //
     //
     //
     //
     
     for(i = limit; i >=0; i--)
     {    
         CrossfmUp[i] = EMPTY_VALUE;
         CrossfmDn[i] = EMPTY_VALUE;
         CrossfsUp[i] = EMPTY_VALUE;
         CrossfsDn[i] = EMPTY_VALUE;
         CrossmsUp[i] = EMPTY_VALUE;
         CrossmsDn[i] = EMPTY_VALUE;
         ma1[i]       = iMA(NULL, 0, FasterMA, FasterShift, FasterMode, FasterPrice, i);
         ma2[i]       = iMA(NULL, 0, MediumMA, MediumShift, MediumMode, MediumPrice, i);
         ma3[i]       = iMA(NULL, 0, SlowerMA, SlowerShift, SlowerMode, SlowerPrice, i);
         trendfm[i]   = trendfm[i+1];
         trendfs[i]   = trendfs[i+1];
         trendms[i]   = trendms[i+1];
               if (ma1[i]>ma2[i]) trendfm[i] =  1;
               if (ma1[i]<ma2[i]) trendfm[i] = -1;
               if (ma1[i]>ma3[i]) trendfs[i] =  1;
               if (ma1[i]<ma3[i]) trendfs[i] = -1;
               if (ma2[i]>ma3[i]) trendms[i] =  1;
               if (ma2[i]<ma3[i]) trendms[i] = -1;
         
      //
      //
      //
      //
      //
         
      range = iATR(NULL,0,15,i);         
         if (alertsOnFastCrossMiddle && trendfm[i]!=trendfm[i+1]) 
            if (trendfm[i] == 1)
                  CrossfmUp[i] = MathMin(ma1[i],ma2[i])-range*arrowsFMGap;
            else  CrossfmDn[i] = MathMax(ma1[i],ma2[i])+range*arrowsFMGap;
         if (alertsOnFastCrossSlow && trendfs[i]!=trendfs[i+1]) 
            if (trendfs[i] == 1)
                  CrossfsUp[i] = MathMin(ma1[i],ma3[i])-range*arrowsFSGap;
            else  CrossfsDn[i] = MathMax(ma1[i],ma3[i])+range*arrowsFSGap;
         if (alertsOnMiddleCrossSlow && trendms[i]!=trendms[i+1]) 
            if (trendms[i] == 1)
                  CrossmsUp[i] = MathMin(ma2[i],ma3[i])-range*arrowsMSGap;
            else  CrossmsDn[i] = MathMax(ma2[i],ma3[i])+range*arrowsMSGap;
   }   
   manageAlerts();
   return(0);
 }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar=1; if (alertsOnCurrent) whichBar = 0;
   
      //
      //
      //
      //
      //
         
         static string   mess1 = "";
         static datetime time1 = 0;
            if (alertsOnFastCrossMiddle && trendfm[whichBar]!=trendfm[whichBar+1]) 
            if (trendfm[whichBar] == 1)
                  doAlert(mess1,time1,"Fast MA crossed Medium MA UP");
            else  doAlert(mess1,time1,"Fast MA crossed Medium MA DOWN");
         static string   mess2 = "";
         static datetime time2 = 0;
            if (alertsOnFastCrossSlow && trendfs[whichBar]!=trendfs[whichBar+1]) 
            if (trendfs[whichBar] == 1)
                  doAlert(mess2,time2,"Fast MA crossed Slow MA UP");
            else  doAlert(mess2,time2,"Fast MA crossed Slow MA DOWN");
         static string   mess3 = "";
         static datetime time3 = 0;
            if (alertsOnMiddleCrossSlow && trendms[whichBar]!=trendms[whichBar+1]) 
            if (trendms[whichBar] == 1)
                  doAlert(mess3,time3,"Medium MA crossed Slow MA UP");
            else  doAlert(mess3,time3,"Medium MA crossed Slow MA DOWN");
   }               
}
 
//
//
//
//
//
//
 
void doAlert(string& previousAlert, datetime& previousTime, string doWhat)
{
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

           message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," 3 MA line crossing ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"3 MA line crossing"),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}

//
//
//
//
//

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

