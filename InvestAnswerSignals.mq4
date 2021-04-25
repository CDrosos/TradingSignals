//+------------------------------------------------------------------+
//|                                  InvestAnswerSignals.mq4         |
//|                        Copyright 2021, Shuqeir & Drosos power.   |
//|  Settings are taken by https://www.investanswers.us/             |
//|  https://www.patreon.com/InvestAnswers                           |
//|  https://www.youtube.com/channel/UClgJyzwGs-GyaNxUHcLZrkg        |
//|  Programmed by Christopher Drosos.                               |
//|                                    https://www.investanswers.us/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Created by Christopher drosos. Settings are taken by https://www.investanswers.us/."
#property link      "https://www.patreon.com/InvestAnswers"
#property description "Get notifications when Moving Average Cross happens, price touch the lowest Moving average on bullish trend or touch the highest Moving average on bearish trend and when Relative Strength Index goes above 70 or below 30"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

//User options
extern bool ShowSignalAlerts = true;
extern bool SendSignalAlertsByEmail = false;
extern bool SendSignalAlertsByMobileNotifiaction = true;
extern string EmailSubject = "Alert From InvestAnswersSignals ExpertAdvisor";

// SMA
input int SMA_MAPeriod=20;
input int SMA_MAShift=0;
input int SMA_MAMethod=1; //MODE_EMA
input int SMA_AppliedPrice=0; //PRICE_CLOSE
input int SMA_Shift=0;

// RSI
input int RSI_Period=10;
input int RSI_Shift=0;
input int RSI_AppliedPrice=0; //PRICE_CLOSE

// MA crosses arrows or lines mtf+alerts
extern string MACA_Name = "MA crosses arrows or lines mtf+alerts"; //Change the name if your indicator uses another one.
input int MACA_TimeFrame=0;
input int MACA_TimeFrameCustom=0;
input int MACA_FastMaPeriod=50;
input int MACA_FastMaMethod=0;
input int MACA_FastMaPrice=0;
input int MACA_SlowMaPeriod=200;
input int MACA_SlowMaMethod=0;
input int MACA_SlowMaPrice=0;

// Global variables
datetime LastTimeChecked = 0;
enum MACrossSignal
  {
   BullMarket_PriceTouchLowerMA = 2,
   BullishCross = 1,
   NoSignal = 0,
   BearishCross = -1,
   BearMarket_PriceTouchHigherMA = -2,
  };

//+------------------------------------------------------------------+
//|    OnInit()                                                      |
//+------------------------------------------------------------------+
void OnInit()
  {

  }

//+------------------------------------------------------------------+
//|     Get Current MA Cross Value                                   |
//+------------------------------------------------------------------+
MACrossSignal GetMACD()
  {
   double price0 = iCustom(NULL,0,MACA_Name,MACA_TimeFrame, MACA_TimeFrameCustom, MACA_FastMaPeriod, MACA_FastMaMethod, MACA_FastMaPrice, MACA_SlowMaPeriod, MACA_SlowMaMethod, MACA_SlowMaPrice, 0, 0);
   if(price0!=EMPTY_VALUE)
      return BullishCross;

   double price1 = iCustom(NULL,0,MACA_Name,MACA_TimeFrame, MACA_TimeFrameCustom, MACA_FastMaPeriod, MACA_FastMaMethod, MACA_FastMaPrice, MACA_SlowMaPeriod, MACA_SlowMaMethod, MACA_SlowMaPrice, 1, 0);
   if(price1!=EMPTY_VALUE)
      return BearishCross;

   double price2 = iCustom(NULL,0,MACA_Name,MACA_TimeFrame, MACA_TimeFrameCustom, MACA_FastMaPeriod, MACA_FastMaMethod, MACA_FastMaPrice, MACA_SlowMaPeriod, MACA_SlowMaMethod, MACA_SlowMaPrice, 2, 0);
   double price3 = iCustom(NULL,0,MACA_Name,MACA_TimeFrame, MACA_TimeFrameCustom, MACA_FastMaPeriod, MACA_FastMaMethod, MACA_FastMaPrice, MACA_SlowMaPeriod, MACA_SlowMaMethod, MACA_SlowMaPrice, 3, 0);

   if(price2 > price3)
     {
      double currentLowPrice = iLow(NULL,0,0);
      if(currentLowPrice <= price3)
         return BullMarket_PriceTouchLowerMA;
     }

   if(price2 < price3)
     {
      double currentHighPrice = iHigh(NULL,0,0);
      if(currentHighPrice >= price3)
         return BearMarket_PriceTouchHigherMA;
     }

   return NoSignal;
  }


//+------------------------------------------------------------------+
//|     Get Current RSI Value                                        |
//+------------------------------------------------------------------+
double GetRSI()
  {
   return iRSI(NULL,0,RSI_Period,RSI_AppliedPrice,RSI_Shift);
  }

//+------------------------------------------------------------------+
//|     Get Current SMA Value                                        |
//+------------------------------------------------------------------+
double GetSMA()
  {
   return iMA(NULL,0,SMA_MAPeriod,SMA_MAShift,SMA_MAMethod,SMA_AppliedPrice,SMA_Shift);
  }

//+------------------------------------------------------------------+
//|     Get Current Alerts                                           |
//+------------------------------------------------------------------+
string GetIndicatorsAlertMessages()
  {
   string returnMessage = "";

   double currentRSI = GetRSI();
   if(currentRSI>70)
      returnMessage += "RSI above 70, Sell signal. ";
   else
      if(currentRSI<30)
         returnMessage += "RSI below 30, Buy signal. ";

   MACrossSignal maCrossValue = GetMACD();
   switch(maCrossValue)
     {
      case BullMarket_PriceTouchLowerMA :
         returnMessage += "MAC Signal, price below the lower MA in a Bullish market. Strong Buy signal. ";
         break;
      case BullishCross :
         returnMessage += "MAC Crossover, strong Buy Signal. ";
         break;
      case BearishCross :
         returnMessage += "MAC Crossover, strong Sell Signal. ";;
         break;
      case BearMarket_PriceTouchHigherMA :
         returnMessage += "MAC Signal, price above the higher MA in a Bearish market. Sell signal. ";
         break;
     }

   return returnMessage;
  }

//+------------------------------------------------------------------+
//|     Check For Signals                                            |
//+------------------------------------------------------------------+
void CheckForSignals()
  {
   string currentSignalsMessage = GetIndicatorsAlertMessages();
   if(currentSignalsMessage != "")
      AlertUser(currentSignalsMessage);
  }

//+------------------------------------------------------------------+
//|     Alert User with the Signal ersults                           |
//+------------------------------------------------------------------+
void AlertUser(string message)
  {
   if(ShowSignalAlerts)
      Alert(message);
   if(SendSignalAlertsByEmail)
     {
      bool emailResult = SendMail(EmailSubject,message);
      if(!emailResult)
         Print("Error sending the email, make sure you have configure the email settings from Meta Trader 4 Client / Tools / Options / Email");
     }
   if(SendSignalAlertsByMobileNotifiaction)
     {
      bool notificationResult = SendNotification(message);
      if(!notificationResult)
         Print("Error sending the notification, make sure you have configure the notification settings from Meta Trader 4 Client / Tools / Options / Notifications");
     }

   Print(message);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   datetime currentHour = iTime(NULL, 0,0);
   if(LastTimeChecked != currentHour)
     {
      LastTimeChecked = currentHour;
      CheckForSignals();
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+