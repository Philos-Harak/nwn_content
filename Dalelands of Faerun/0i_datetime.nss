/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Name: 0i_datetime
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include script for handling date and time functions.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"
#include "0i_database"
void SaveServerCalendarToDatabase();
void GetServerCalendarFromDatabase();

// Gets the in game calendar year, month, and day and returns in minutes.
int GetCurrentDateTimeInMinutes();

// Returns Date & Time in a string.
// "137212223135" i.e. 1372 year 12 month 22 day 3 hour 1 minute 35 seconds.
string GetDateTimeToString();

// Gets the in game calendar year, month, and day and returns in minutes.
int GetCurrentDateTimeInMinutes()
{
    return GetCalendarYear()  * 12 * 28 * 24 * MINUTES_IN_ONE_GAME_HOUR
         + GetCalendarMonth()      * 28 * 24 * MINUTES_IN_ONE_GAME_HOUR
         + GetCalendarDay()             * 24 * MINUTES_IN_ONE_GAME_HOUR
         + GetTimeHour()                     * MINUTES_IN_ONE_GAME_HOUR
         + GetTimeMinute();
}

// Returns the difference in GetCurrentDateTimeInMinutes
// nDate1(Newest) - nDate2(Oldest).
// nReturnType is 0 = minutes, 1 = hours, 2 = days, 3 = months.
int DifferenceInCalendarDates(int nDate1, int nDate2, int nReturnType = 0)
{
    // If ndate1 is not valid or set then we return 999 time passed.
    if (nDate2 == 0) return 999;
    if (nReturnType == 0) return (nDate1 - nDate2);
    if (nReturnType == 1) return (nDate1 - nDate2) / (MINUTES_IN_ONE_GAME_HOUR);
    if (nReturnType == 2) return (nDate1 - nDate2) / (24 * MINUTES_IN_ONE_GAME_HOUR);
    if (nReturnType == 3) return (nDate1 - nDate2) / (28 * 24 * MINUTES_IN_ONE_GAME_HOUR);
    return 0;
}

void SaveServerCalendarToDatabase()
{
    int iYear, iMonth, iDay, iHour;
    string sYear, sMonth, sDay, sHour;
    object oModule = GetModule ();
    iYear = GetCalendarYear();
    sYear = IntToString (iYear);
    iMonth = GetCalendarMonth ();
    sMonth = IntToString (iMonth);
    iDay = GetCalendarDay ();
    sDay = IntToString (iDay);
    iHour = GetTimeHour ();
    sHour = IntToString (iHour);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "year", iYear);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "month", iMonth);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "day", iDay);
    SetServerDatabaseInt (oModule, SERVER_TABLE, "hour", iHour);
    SendMessages ("(SaveServerCalendar) Saving the current calendar [" + sYear + ":" + sMonth + ":" + sDay + ":" + sHour + "].", COLOR_GRAY, OBJECT_INVALID, FALSE, TRUE);
}

void GetServerCalendarFromDatabase ()
{
    int iYear, iMonth, iDay, iHour;
    string sYear, sMonth, sDay, sHour;
    object oModule = GetModule ();
    iYear = GetServerDatabaseInt (oModule, SERVER_TABLE, "year");
    iMonth = GetServerDatabaseInt (oModule, SERVER_TABLE, "month");
    iDay = GetServerDatabaseInt (oModule, SERVER_TABLE, "day");
    iHour = GetServerDatabaseInt (oModule, SERVER_TABLE, "hour");
    SetCalendar (iYear, iMonth, iDay);
    SetTime (iHour, 6, 0, 0);
    SendMessages ("Setting the current calendar [" + IntToString (iYear) + ":" + IntToString (iMonth) + ":" + IntToString (iDay) + ":" + IntToString (iHour) + "].", COLOR_GRAY, OBJECT_INVALID, FALSE);
}

// Returns Date & Time in a string.
// "137212223135" i.e. 1372 year 12 month 22 day 3 hour 1 minute 35 seconds.
string GetDateTimeToString ()
{
    return IntToString (GetCalendarYear ()) +
            IntToString (GetCalendarMonth ()) +
            IntToString (GetCalendarDay ()) +
            IntToString (GetTimeHour ()) +
            IntToString (GetTimeMinute ()) +
            IntToString (GetTimeSecond ());
}



