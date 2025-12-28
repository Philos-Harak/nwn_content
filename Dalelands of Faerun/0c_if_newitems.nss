/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_if_newitems
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if enough time has passed to
 generate new items in a store.

/*//////////////////////////////////////////////////////////////////////////////
#include "0i_character"
int StartingConditional()
{
    if(GetIsDungeonMaster(GetPCSpeaker())) return FALSE;
    int nHours;
    int nCurrentDate = GetCurrentDateTimeInMinutes();
    object oMerchant = OBJECT_SELF;
    int nStoreDate = GetLocalInt(oMerchant, "0_Date_Generated");
    if(nStoreDate == 0)
    {
        nHours = NEW_SHIPMENT_DELAY;
        SetLocalInt(oMerchant, "0_Date_Generated", nCurrentDate);
    }
    else
    {
        nHours = DifferenceInCalendarDates(nCurrentDate, nStoreDate, 1);
        nHours = NEW_SHIPMENT_DELAY - nHours;
    }
    if(nHours > 0)
    {
        // set the custom token.
        SetCustomToken(1000, IntToString(nHours));
        return TRUE;
    }
    return FALSE;
}
