//+------------------------------------------------------------------+
//|                                        RelayExecutor_Helpers.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
bool ShouldMoveToBe(string action,double moveToBePrice,double bid, double ask)
  {
   if(moveToBePrice == 0 || beIsTriggered)
     {
      //Print("No price set for BE conditions");
      return false;
     }
   if(action == "BUY")
     {
      if(bid >= moveToBePrice)
         return true;
     }
   else
      if(action == "SELL")
        {
         if(ask <= moveToBePrice)
            return true;
        }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTPToN(string symbol, double tp, int positionsToApply)
  {
   int total = PositionsTotal();

   if(positionsToApply <= 0)
     {
      Print("Invalid positionsToApply: ", positionsToApply);
      return;
     }

   int applied = 0;

   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);

      if(!PositionSelectByTicket(ticket))
         continue;

      if(PositionGetString(POSITION_SYMBOL) != symbol)
         continue;

      double sl = PositionGetDouble(POSITION_SL);

      if(trade.PositionModify(ticket, sl, tp))
        {
         applied++;
         Print("TP applied | Ticket=", ticket, " TP=", tp);
        }
      else
        {
         Print("TP apply failed | ", trade.ResultRetcodeDescription());
        }

      // Stop if we've applied enough
      if(applied >= positionsToApply)
         return;
     }

   Print("Applied TP to ", applied, " positions (requested ", positionsToApply, ")");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyTP()
  {
   if(HasOpenPosition(pendingSymbol) && pendingFirstCandleTpInvalid)
     {
      candlesSinceEntry++;

      Print("New candle → candlesSinceEntry=", candlesSinceEntry);

      if(pendingFirstCandleTpInvalid && !tpActivated)
        {
         if(candlesSinceEntry >= 1)
           {
            Print("Second candle → activating TP");
            //Aply to the first position
            ApplyTPToN(pendingSymbol, pendingTakeProfit, 1);
            tpActivated = true;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HasOpenPosition(string symbol)
  {
   int total = PositionsTotal();

   for(int i = 0; i < total; i++)
     {
      ulong ticket = PositionGetTicket(i);
      if(PositionSelectByTicket(ticket))
        {
         if(PositionGetString(POSITION_SYMBOL) == symbol)
            return true;
        }
     }

   return false;
  }
//+------------------------------------------------------------------+
void SplitVolume(double totalVolume, double step, int parts, double &result[])
  {
   int totalSteps = (int)MathRound(totalVolume / step);

   int baseSteps = totalSteps / parts;
   int remainder = totalSteps % parts;

   ArrayResize(result, parts);

   for(int i = 0; i < parts; i++)
     {
      int steps = baseSteps;

      if(i >= parts - remainder)
         steps += 1;

      result[i] = NormalizeDouble(steps * step, 2);
     }
  }
//+------------------------------------------------------------------+
string ReadFile(string fileName)
  {
   int handle = FileOpen(
                   fileName,
                   FILE_READ | FILE_TXT | FILE_COMMON | FILE_ANSI
                );

   if(handle == INVALID_HANDLE)
     {
      Print("Failed to open ", fileName);
      return "";
     }

   string lastJson = ReadLastJsonLine(handle);
   FileClose(handle);

   if(lastJson == "")
     {
      //Print("No valid JSON lines found");
      return "";
     }

   return lastJson;
  }
//+------------------------------------------------------------------+
