/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_time
////////////////////////////////////////////////////////////////////////////////
 Include script for handling all time functions for the server.

 Lokey's functions:
int GetPosixTimestamp();
string GetCurrentDateTime();

*///////////////////////////////////////////////////////////////////////////////
// RETURNS a Timestamp in seconds from
int GetPosixTimestamp();



int GetPosixTimestamp()
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
void main()
{
    WriteTimestampedLogEntry(GetCurrentDateTime());
    WriteTimestampedLogEntry(IntToString(GetPosixTimestamp()));
}
