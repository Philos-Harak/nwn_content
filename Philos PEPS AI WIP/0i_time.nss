/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_time
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all time functions for the server.

 Lokey's functions:
int GetPosixTimestamp();
string GetCurrentDateTime();

*///////////////////////////////////////////////////////////////////////////////
const string SERVER_SHUTDOWN_TIME = "SERVER_SHUTDOWN_TIME";
const string SERVER_MESSAGE_COUNT = "SERVER_MESSAGE_COUNT";
const string SERVER_SHUTDOWN_MESSAGE_1 = "The server will restart in half an hour! Please log off!";
const string SERVER_SHUTDOWN_MESSAGE_2 = "The server will restart in 15 minutes! Please log off!";
const string SERVER_SHUTDOWN_MESSAGE_3 = "The server will restart in 5 minutes! Please log off!";
// RETURNS a Timestamp in seconds since 1970-01-01.
int GetCurrentTimeInSeconds();
// RETURNS a formated date, good for timestamping logs and text.
string GetCurrentDateTime();
// Sends a server shutdown message 1800 seconds i.e 30 minutes before.
// nDuration is in seconds. i.e. one hours is 3600 defaults to 24 hours (86400).
// Should be put into the servers OnHeartBeat.
void CheckServerShutdownMessage(int nDuration = 86400);

int GetCurrentTimeInSeconds()
{
    string stmt = "SELECT strftime('%s','now');";
    sqlquery sqlQuery = SqlPrepareQueryObject(GetModule(), stmt);
    SqlStep(sqlQuery);
    return SqlGetInt(sqlQuery, 0);
}
string GetCurrentDateTime()
{
    string stmt = "SELECT datetime('now', 'localtime')";
    sqlquery sqlQuery = SqlPrepareQueryObject(GetModule(), stmt);
    SqlStep(sqlQuery);
    return SqlGetString(sqlQuery, 0);
}
void CheckServerShutdownMessage(int nDuration = 86400)
{
    object oModule = GetModule();
    int nServerShutDownTime = GetLocalInt(oModule, SERVER_SHUTDOWN_TIME);
    int nCurrentTime = GetCurrentTimeInSeconds();
    if(nServerShutDownTime > nCurrentTime) return;
    // The server has just started, so lets save the time.
    if(nServerShutDownTime == 0)
    {
        SetLocalInt(oModule, SERVER_SHUTDOWN_TIME, nCurrentTime + nDuration - 1800); // Removes half an hour
        return;
    }
    // Check our message count and then send the next one.
    int nMessageCount = GetLocalInt(oModule, SERVER_MESSAGE_COUNT);
    if(nMessageCount == 0)
    {
        SetLocalInt(oModule, SERVER_MESSAGE_COUNT, ++nMessageCount);
        SetLocalInt(oModule, SERVER_SHUTDOWN_TIME, nCurrentTime + 900); // Adds 15 minutes.
        SpeakString(SERVER_SHUTDOWN_MESSAGE_1, TALKVOLUME_SHOUT);
    }
    else if(nMessageCount == 1)
    {
        SetLocalInt(oModule, SERVER_MESSAGE_COUNT, ++nMessageCount);
        SetLocalInt(oModule, SERVER_SHUTDOWN_TIME, nCurrentTime + 600); // Adds 10 minutes.
        SpeakString(SERVER_SHUTDOWN_MESSAGE_2, TALKVOLUME_SHOUT);
    }
    else if(nMessageCount == 2)
    {
        SetLocalInt(oModule, SERVER_MESSAGE_COUNT, ++nMessageCount);
        SpeakString(SERVER_SHUTDOWN_MESSAGE_3, TALKVOLUME_SHOUT);
    }
}
/// @addtogroup time Time
/// @brief Provides various time related functions.
/// @brief Returns the current time formatted according to the provided sqlite date time format string.
/// @param format Format string as used by sqlites STRFTIME().
/// @return The current time in the requested format. Empty string on error.
string SQLite_GetFormattedSystemTime(string format);
/// @return Returns the number of seconds since midnight on January 1, 1970.
int SQLite_GetTimeStamp();
/// @return Returns the number of milliseconds since midnight on January 1, 1970.
int SQLite_GetTimeMilliseconds();
/// @brief A millisecond timestamp
struct SQLite_MillisecondTimeStamp
{
    int seconds; ///< Seconds since epoch
    int milliseconds; ///< Milliseconds
};
/// @remark For mircosecond timestamps use NWNX_Utility_GetHighResTimeStamp().
/// @return Returns the number of milliseconds since midnight on January 1, 1970.
struct SQLite_MillisecondTimeStamp SQLite_GetMillisecondTimeStamp();
/// @brief Returns the current date.
/// @return The date in the format (mm/dd/yyyy).
string SQLite_GetSystemDate();
/// @brief Returns current time.
/// @return The current time in the format (24:mm:ss).
string SQLite_GetSystemTime();
/// @}
string SQLite_GetFormattedSystemTime(string format)
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "SELECT STRFTIME(@format, 'now', 'localtime')");
    SqlBindString(query, "@format", format);
    SqlStep(query); // sqlite returns NULL for invalid format in STRFTIME()
    return SqlGetString(query, 0);
}
int SQLite_GetTimeStamp()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "SELECT STRFTIME('%s', 'now')");
    SqlStep(query);
    return SqlGetInt(query, 0);
}
int SQLite_GetTimeMillisecond()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "select cast((julianday('now') - 2440587.5) * 86400 * 1000 as integer)");
    SqlStep(query);
    return SqlGetInt(query, 0);
}
struct SQLite_MillisecondTimeStamp SQLite_GetMillisecondTimeStamp()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "SELECT STRFTIME('%s', 'now'), SUBSTR(STRFTIME('%f', 'now'), 4)");
    SqlStep(query);
    struct SQLite_MillisecondTimeStamp t;
    t.seconds = SqlGetInt(query, 0);
    t.milliseconds = SqlGetInt(query, 1);
    return t;
}
string SQLite_GetSystemDate()
{
    return SQLite_GetFormattedSystemTime("%m/%d/%Y");
}
string SQLite_GetSystemTime()
{
    return SQLite_GetFormattedSystemTime("%H:%M:%S");
}
