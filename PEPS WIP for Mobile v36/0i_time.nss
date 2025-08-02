/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_time
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all time functions for the server.

 Lokey's functions:
int GetPosixTimestamp();
string GetCurrentDateTime();

*///////////////////////////////////////////////////////////////////////////////
// Returns a Timestamp in seconds since 1970-01-01.
int ai_GetCurrentTimeStamp();
// Returns a formated date, good for Dating logs and text.
string GetCurrentDateTime();
// Sends a server shutdown message 1800 seconds i.e 30 minutes before.
// nDuration is in seconds. i.e. one hours is 3600 defaults to 24 hours (86400).
// Should be put into the servers OnHeartBeat.
void CheckServerShutdownMessage(int nDuration = 86400);
/// Returns the current time formatted according to the provided sqlite date time format string.
/// Format string as used by sqlites STRFTIME().
/// Returns the current time in the requested format. Empty string on error.
string SQLite_GetFormattedSystemTime(string format);
/// Returns the number of milliseconds since midnight on January 1, 1970.
int SQLite_GetTimeMilliseconds();
/// Returns the date in the format (mm/dd/yyyy).
string SQLite_GetSystemDate();
/// Returns the current time in the format (24:mm:ss).
string SQLite_GetSystemTime();

int ai_GetCurrentTimeStamp()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "SELECT STRFTIME('%s', 'now')");
    SqlStep(query);
    return SqlGetInt(query, 0);
}
string GetCurrentDateTime()
{
    sqlquery sqlQuery = SqlPrepareQueryObject(GetModule(), "SELECT datetime('now', 'localtime')");
    SqlStep(sqlQuery);
    return SqlGetString(sqlQuery, 0);
}
struct SQLite_MillisecondTimeStamp
{
    int seconds; ///< Seconds since epoch
    int milliseconds; ///< Milliseconds
};
string SQLite_GetFormattedSystemTime(string format)
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "SELECT STRFTIME(@format, 'now', 'localtime')");
    SqlBindString(query, "@format", format);
    SqlStep(query); // sqlite returns NULL for invalid format in STRFTIME()
    return SqlGetString(query, 0);
}
int SQLite_GetTimeMillisecond()
{
    sqlquery query = SqlPrepareQueryObject(GetModule(), "select cast((julianday('now') - 2440587.5) * 86400 * 1000 as integer)");
    SqlStep(query);
    return SqlGetInt(query, 0);
}
string SQLite_GetSystemDate()
{
    return SQLite_GetFormattedSystemTime("%m/%d/%Y");
}
string SQLite_GetSystemTime()
{
    return SQLite_GetFormattedSystemTime("%H:%M:%S");
}

