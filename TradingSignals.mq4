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

// User options
input bool ShowSignalAlerts = true; //Show alerts in Meta Trader
input bool SendSignalAlertsByEmail = false; //Get alerts in e-mails
input bool SendSignalAlertsByMobileNotifiaction = true; //Get alerts in your mobile phone
input string EmailSubject = "Alert From InvestAnswersSignals ExpertAdvisor"; //Set the email subject for the alerts

// SMA
//input int SMA_MAPeriod=20;
//input int SMA_MAShift=0;
//input int SMA_MAMethod=1; //MODE_EMA
//input int SMA_AppliedPrice=0; //PRICE_CLOSE
//input int SMA_Shift=0;
enum ENUM_RsiMACD
  {
   None = 0,// None
   RSI = 1,// RSI Only
   RSI_With_MACD = 2, // RSI + MACD
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input bool BB_Enable=true; // Enable Bolinder Bands alerts (BB)
input int BB_Period=100;//BB Period
input int BB_Deviators=2;//BB Deviators
input ENUM_APPLIED_PRICE BB_AppliedPrice=PRICE_CLOSE; //BB Applied price
// RSI
input ENUM_RsiMACD RSI_MACD=RSI_With_MACD; // RSI with MACD combination
//input bool RSI_Enable=true; // Enable Relative Strength Index alerts (RSI)
input int RSI_Period=10;//RSI Period
input int RSI_Shift=0;//RSI Shift
input ENUM_APPLIED_PRICE RSI_AppliedPrice=PRICE_CLOSE; //RSI Applied price
//input bool MACD_Enable=true; // Enable Moving Averages Convergence/Divergence alerts (MACD)
input int MACD_Fast_EMA_Period=8; // MACD Fast EMA averaging period.
input int MACD_Slow_EMA_Period=21; // MACD Slow EMA averaging period.
input int MACD_Signal_Period=5; // MACD Signal Period.
input ENUM_APPLIED_PRICE MACD_Applied_Price=PRICE_CLOSE; // MACD Applied price
//input int MACD_Signal_Mode=MODE_SIGNAL; // MACD Signal mode
input bool MACO_Enable=true; // Enable Moving Averages CrossOver alerts (MACO)
// MA crosses arrows or lines mtf+alerts
input string MACO_Name = "MA crosses arrows or lines mtf+alerts"; //MA crossover indicator name. Change the name if your indicator uses another one, names should match for the EA to work.
input int MACO_TimeFrame=0; // MACO TimeFrame
input int MACO_TimeFrameCustom=0;
input int MACO_FastMaPeriod=50; // MACO Fast MA Period
input int MACO_FastMaMethod=0;// MACO Fast MA Method
input ENUM_APPLIED_PRICE MACO_FastMaPrice=PRICE_CLOSE;// MACO Fast MA Applied price
input int MACO_SlowMaPeriod=200;// MACO Slow MA Period
input int MACO_SlowMaMethod=0;// MACO Slow MA Method
input ENUM_APPLIED_PRICE MACO_SlowMaPrice=PRICE_CLOSE;//MACO Slow MA Applied price

// Global variables
int CurrentPeriod = 0;
datetime LastTimeChecked = 0;
enum MACDLineAndSignal
  {
   MACDLineBelowSignal = -1,
   Undefined = 0,
   MACDLineAboveSignal = 1,
  };
MACDLineAndSignal MACDValuesRelation = Undefined;
enum RSI_MACD_Conditions
  {
   Default = 0,
   RSI_Confirmed = 1,
   MACD_CrossOver_Signal_Confirmed = 2,
  };
RSI_MACD_Conditions RSI_MACD_Current_Condition = Default;
enum RSI_Value
  {
   RSI_Below_30 = -1,
   RSI_Undefined = 0,
   RSI_Above_70 = 1,
  };
RSI_Value RSI_Current_Value = RSI_Undefined;
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
   CurrentPeriod = Period();
   ResetRSIWithMACDConditions();
  }

//+------------------------------------------------------------------+
//|     Get Current MA Cross Value                                   |
//+------------------------------------------------------------------+
MACrossSignal GetMACO()
  {
   double price0 = iCustom(NULL,0,MACO_Name,MACO_TimeFrame, MACO_TimeFrameCustom, MACO_FastMaPeriod, MACO_FastMaMethod, MACO_FastMaPrice, MACO_SlowMaPeriod, MACO_SlowMaMethod, MACO_SlowMaPrice, 0, 0);
   if(price0!=EMPTY_VALUE)
      return BullishCross;

   double price1 = iCustom(NULL,0,MACO_Name,MACO_TimeFrame, MACO_TimeFrameCustom, MACO_FastMaPeriod, MACO_FastMaMethod, MACO_FastMaPrice, MACO_SlowMaPeriod, MACO_SlowMaMethod, MACO_SlowMaPrice, 1, 0);
   if(price1!=EMPTY_VALUE)
      return BearishCross;

   double price2 = iCustom(NULL,0,MACO_Name,MACO_TimeFrame, MACO_TimeFrameCustom, MACO_FastMaPeriod, MACO_FastMaMethod, MACO_FastMaPrice, MACO_SlowMaPeriod, MACO_SlowMaMethod, MACO_SlowMaPrice, 2, 0);
   double price3 = iCustom(NULL,0,MACO_Name,MACO_TimeFrame, MACO_TimeFrameCustom, MACO_FastMaPeriod, MACO_FastMaMethod, MACO_FastMaPrice, MACO_SlowMaPeriod, MACO_SlowMaMethod, MACO_SlowMaPrice, 3, 0);

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
//|     Get Current MACD Line Value                                        |
//+------------------------------------------------------------------+
double GetMACDLine()
  {
   return iMACD(NULL,0,MACD_Fast_EMA_Period,MACD_Slow_EMA_Period,MACD_Signal_Period,MACD_Applied_Price,0,0);
  }

//+------------------------------------------------------------------+
//|     Get Current MACD Signal Value                                        |
//+------------------------------------------------------------------+
double GetMACDSignal()
  {
   return iMACD(NULL,0,MACD_Fast_EMA_Period,MACD_Slow_EMA_Period,MACD_Signal_Period,MACD_Applied_Price,1,0);
  }

//+------------------------------------------------------------------+
//|     Get Current Bolinder Bands Value                             |
//+------------------------------------------------------------------+
int GetBB()
  {
   double upperBands = iBands(NULL,0,BB_Period,BB_Deviators,0,BB_AppliedPrice,1,0);
   double lowerBands = iBands(NULL,0,BB_Period,BB_Deviators,0,BB_AppliedPrice,2,0);
   double currentClosePrice = iClose(NULL,0,0);
   //Print("upperBands "+upperBands+" lowerBands "+lowerBands);
   if(currentClosePrice > upperBands)
      return 1;
   if(currentClosePrice < lowerBands)
      return -1;
   return 0;
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
//double GetSMA()
//{
// return iMA(NULL,0,SMA_MAPeriod,SMA_MAShift,SMA_MAMethod,SMA_AppliedPrice,SMA_Shift);
//}

//+------------------------------------------------------------------+
//|     Get Current Alerts                                           |
//+------------------------------------------------------------------+
string GetIndicatorsAlertMessages()
  {
   string returnMessage = GetSymbolAndTimeframe();

   if(RSI_MACD == RSI)
      returnMessage += GetRSIAlertMessage();

   if(RSI_MACD == RSI_With_MACD)
      returnMessage += GetRSIWithMACDAlertMessages();

   if(MACO_Enable)
      returnMessage += GetMACrossAlertMessage();

   if(BB_Enable)
      returnMessage += GetBBAlertMessage();

   return returnMessage;
  }

//+------------------------------------------------------------------+
//|     Get Symbol And Timeframe                                     |
//+------------------------------------------------------------------+
string GetSymbolAndTimeframe()
  {
   return Symbol() + " - " + GetTimeFrame(Period()) + " - ";
  }

//+------------------------------------------------------------------+
//|     Get RSI Alert Message                                        |
//+------------------------------------------------------------------+
string GetRSIAlertMessage()
  {
   string returnMessage = "";
   double currentRSI = GetRSI();

   if(currentRSI>70)
      returnMessage = "RSI above 70, Sell signal. ";
   else
      if(currentRSI<30)
         returnMessage = "RSI below 30, Buy signal. ";

   return returnMessage;
  }

//+------------------------------------------------------------------+
//|     Reset RSI With MACD Conditions                               |
//+------------------------------------------------------------------+
void ResetRSIWithMACDConditions()
  {
   MACDValuesRelation = Undefined;
   RSI_MACD_Current_Condition = Default;
   RSI_Current_Value = RSI_Undefined;
  }
//+------------------------------------------------------------------+
//|     Get RSI With MACD Confirmation Alert Message                 |
//+------------------------------------------------------------------+
string GetRSIWithMACDAlertMessages()
  {
   string returnMessage = "";
   double MACDLineValue = GetMACDLine();
   double MACDSignalValue = GetMACDSignal();
//Print("MACDLineValue "+MACDLineValue+" MACDSignalValue "+MACDSignalValue);

   if(RSI_MACD_Current_Condition == Default)
     {
      bool RSIConfirmed = false;
      double currentRSI = GetRSI();

      if(currentRSI>70)
        {
         returnMessage += "1/3 RSI above 70, Sell signal. Waiting for MACD Confirmation. ";
         RSI_Current_Value = RSI_Above_70;
        }
      else
         if(currentRSI<30)
           {
            returnMessage += "1/3 RSI below 30, Buy signal. Waiting for MACD Confirmation. ";
            RSI_Current_Value = RSI_Below_30;
           }

      if(RSI_Current_Value != RSI_Undefined)
        {
         RSI_MACD_Current_Condition = RSI_Confirmed;

         if(MACDLineValue>MACDSignalValue)
            MACDValuesRelation = MACDLineAboveSignal;
         else
            MACDValuesRelation = MACDLineBelowSignal;
        }

      return returnMessage;
     }

   if(RSI_MACD_Current_Condition == RSI_Confirmed)
     {
      if((MACDLineValue>MACDSignalValue && MACDValuesRelation == MACDLineBelowSignal) || (MACDLineValue<MACDSignalValue && MACDValuesRelation == MACDLineAboveSignal))
        {
         returnMessage += "2/3 MACD Crossover Confirmed. Strong";
         if(RSI_Current_Value == RSI_Below_30)
            returnMessage +=  " Buy ";

         if(RSI_Current_Value == RSI_Above_70)
            returnMessage +=  " Sell ";

         returnMessage += "signal. ";
         RSI_MACD_Current_Condition = MACD_CrossOver_Signal_Confirmed;

         if(MACDLineValue>MACDSignalValue)
            MACDValuesRelation = MACDLineAboveSignal;
         else
            MACDValuesRelation = MACDLineBelowSignal;

         return returnMessage;
        }
     }

   if(RSI_MACD_Current_Condition == MACD_CrossOver_Signal_Confirmed)
     {
      if((MACDLineValue>MACDSignalValue && MACDValuesRelation == MACDLineBelowSignal) || (MACDLineValue<MACDSignalValue && MACDValuesRelation == MACDLineAboveSignal))
        {
         returnMessage += "3/3 MACD Crossover again. Close order signal. ";
         ResetRSIWithMACDConditions();
         return returnMessage;
        }
     }

   return returnMessage;
  }

//+------------------------------------------------------------------+
//|     Get MA Cross Alert Message                                        |
//+------------------------------------------------------------------+
string GetMACrossAlertMessage()
  {
   string returnMessage = "";

   MACrossSignal maCrossValue = GetMACO();
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
//|     Get BB Alert Message                                         |
//+------------------------------------------------------------------+
string GetBBAlertMessage()
  {
   string returnMessage = "";

   int currentBBValue = GetBB();
   if(currentBBValue == 1)
      returnMessage += "Close price is above the upper Bolinder Band zone, Sell Signal. ";
   if(currentBBValue == -1)
      returnMessage += "Close price is below the lower Bolinder Band zone, Buy Signal. ";

   return returnMessage;
  }

//+------------------------------------------------------------------+
//|     Check For Signals                                            |
//+------------------------------------------------------------------+
void CheckForSignals()
  {
   string currentSignalsMessage = GetIndicatorsAlertMessages();
   if(currentSignalsMessage != "" && currentSignalsMessage != GetSymbolAndTimeframe())
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

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case 1:
         return("M1");
      case 5:
         return("M5");
      case 15:
         return("M15");
      case 30:
         return("M30");
      case 60:
         return("H1");
      case 240:
         return("H4");
      case 1440:
         return("D1");
      case 10080:
         return("W1");
      case 43200:
         return("MN1");
     }
   return IntegerToString(lPeriod);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| OnTick function                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(CurrentPeriod != Period()) // Period changed, reseting conditions
     {
      CurrentPeriod = Period();
      ResetRSIWithMACDConditions();
     }

   datetime currentTime = iTime(NULL, 0,0);
   if(LastTimeChecked != currentTime)
     {
      LastTimeChecked = currentTime;
      CheckForSignals();
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+