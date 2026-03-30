//+------------------------------------------------------------------+
//|                                        RelayExecutor_Helpers.mqh |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
bool ShouldMoveToBe(string action,double moveToBePrice,double bid, double ask)
  {
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
      Print("No valid JSON lines found");
      return "";
     }

   return lastJson;
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
