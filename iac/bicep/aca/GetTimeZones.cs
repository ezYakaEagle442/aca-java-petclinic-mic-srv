using System;
using System.Globalization;
using System.IO;
using System.Collections.ObjectModel;

// https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/default-time-zones?view=windows-11
// Run in CMD: tzutil /l

// https://docs.microsoft.com/en-us/dotnet/api/system.timezoneinfo.getsystemtimezones?view=net-6.0
// https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?tabs=bicep
// https://stackoverflow.com/questions/68518905/how-can-i-find-and-use-the-latest-version-of-csc-exe-when-using-visual-studio-co
// https://docs.microsoft.com/en-us/dotnet/csharp/language-reference/compiler-options/
// usage: in VSCode press Ctrl+F5 to the Run

// on Windows:
// C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\Roslyn\csc.exe
// \.vscode\extensions\ms-dotnettools.csharp-1.23.13\.omnisharp\1.37.12\.msbuild\Current\Bin\Roslyn
// C:\Users\%USERNAME%\.vscode\extensions\ms-dotnettools.csharp-1.25.0-win32-x64\.omnisharp\1.39.0-net6.0\OmniSharp.exe
// C:\Program Files (x86)\Microsoft SDKs\UWPNuGetPackages\microsoft.net.native.compiler\2.2.10-rel-29722-00\tools\csc
// c:\windows\Microsoft.NET\Framework\v3.5\bin\csc.exe /t:exe /out:GetTimeZones.exe GetTimeZones.cs
// C:\ProgramData\chocolatey\lib\dotnet-6.0-runtime\tools
// C:\Windows\Microsoft.NET\Framework\v4.0.30319 

// On Mac:
// csc GetTimeZones.cs
// mono GetTimeZones.exe

public class GetTimeZones
{
   public static void Main()
   {
      const string OUTPUTFILENAME = @".\TimeZoneInfo.txt";
   
      DateTimeFormatInfo dateFormats = CultureInfo.CurrentCulture.DateTimeFormat;
      ReadOnlyCollection<TimeZoneInfo> timeZones = TimeZoneInfo.GetSystemTimeZones(); 
      StreamWriter sw = new StreamWriter(OUTPUTFILENAME, false);
   
      foreach (TimeZoneInfo timeZone in timeZones)
      {
         bool hasDST = timeZone.SupportsDaylightSavingTime;
         TimeSpan offsetFromUtc = timeZone.BaseUtcOffset;
         TimeZoneInfo.AdjustmentRule[] adjustRules;
         string offsetString;
      
         sw.WriteLine("ID: {0}", timeZone.Id);
         sw.WriteLine("   Display Name: {0, 40}", timeZone.DisplayName);
         sw.WriteLine("   Standard Name: {0, 39}", timeZone.StandardName);
         sw.Write("   Daylight Name: {0, 39}", timeZone.DaylightName);
         sw.Write(hasDST ? "   ***Has " : "   ***Does Not Have ");
         sw.WriteLine("Daylight Saving Time***");
         offsetString = String.Format("{0} hours, {1} minutes", offsetFromUtc.Hours, offsetFromUtc.Minutes);
         sw.WriteLine("   Offset from UTC: {0, 40}", offsetString);
         adjustRules = timeZone.GetAdjustmentRules();
         sw.WriteLine("   Number of adjustment rules: {0, 26}", adjustRules.Length);  
         if (adjustRules.Length > 0)
         {
            sw.WriteLine("   Adjustment Rules:");
            foreach (TimeZoneInfo.AdjustmentRule rule in adjustRules)
            {
               TimeZoneInfo.TransitionTime transTimeStart = rule.DaylightTransitionStart;
               TimeZoneInfo.TransitionTime transTimeEnd = rule.DaylightTransitionEnd; 
            
               sw.WriteLine("      From {0} to {1}", rule.DateStart, rule.DateEnd);
               sw.WriteLine("      Delta: {0}", rule.DaylightDelta);
               if (! transTimeStart.IsFixedDateRule)
               {
                  sw.WriteLine("      Begins at {0:t} on {1} of week {2} of {3}", transTimeStart.TimeOfDay, 
                                                                                transTimeStart.DayOfWeek,                                                                                 
                                                                                transTimeStart.Week, 
                                                                                dateFormats.MonthNames[transTimeStart.Month - 1]);
                  sw.WriteLine("      Ends at {0:t} on {1} of week {2} of {3}", transTimeEnd.TimeOfDay,
                                                                                transTimeEnd.DayOfWeek, 
                                                                                transTimeEnd.Week,
                                                                                dateFormats.MonthNames[transTimeEnd.Month - 1]);
               }
               else
               {
                  sw.WriteLine("      Begins at {0:t} on {1} {2}", transTimeStart.TimeOfDay, 
                                                                 transTimeStart.Day, 
                                                                 dateFormats.MonthNames[transTimeStart.Month - 1]);
                  sw.WriteLine("      Ends at {0:t} on {1} {2}", transTimeEnd.TimeOfDay, 
                                                               transTimeEnd.Day, 
                                                               dateFormats.MonthNames[transTimeEnd.Month - 1]);
               }
            }
         }            
      }
      sw.Close();
   }
}