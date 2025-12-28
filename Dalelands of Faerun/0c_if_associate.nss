/*//////////////////////////////////////////////////////////////////////////////
 Script: 0c_if_associate
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 Text Appears When script that checks to see if oPC has an associate.
 sParam = sAssociate
 1 = ASSOCIATE_TYPE_HENCHMAN & nIndex = #
 2 = ASSOCIATE_TYPE_ANIMALCOMPANION
 3 = ASSOCIATE_TYPE_FAMILIAR
 4 = ASSOCIATE_TYPE_SUMMONED
 5 = ASSOCIATE_TYPE_DOMINATED
 6 = ASSOCIATE_TYPE_NPC && nIndex = #
*///////////////////////////////////////////////////////////////////////////////
#include "0i_master"
int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nAssociate = StringToInt(GetScriptParam("sAssociate"));
    int nIndex = StringToInt(GetScriptParam("nIndex"));
    object oAssociate = GetAssociate(nAssociate, oPC, 1);
    if(nAssociate == ASSOCIATE_TYPE_HENCHMAN || nAssociate == ASSOCIATE_TYPE_NPC)
    {
        int nCount = 1;
        while(oAssociate != OBJECT_INVALID)
        {
            if(GetLocalInt(oAssociate, PC_ASSOCIATE_TYPE) == nAssociate &&
               nCount == nIndex) break;
            oAssociate = GetAssociate(nAssociate, oPC, ++nCount);
        }
    }
    if(oAssociate != OBJECT_INVALID) return TRUE;
    return FALSE;
}
