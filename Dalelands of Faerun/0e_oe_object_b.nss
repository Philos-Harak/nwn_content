/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_oe_object_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when an object is examined.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "nwnx_events"

void main()
{
    object oPC = OBJECT_SELF;
    if(GetIsCharacter(oPC))
    {
        object oObject = StringToObject(NWNX_Events_GetEventData("EXAMINEE_OBJECT_ID"));
        if(GetTag(oObject) == "0_quest_paper" && GetResRef(oObject) != "0_treasure_map")
        {
            object oPossessor = GetItemPossessor(oObject);
            if(GetIsCharacter(oPossessor))
            {
                string sQuestID = GetLocalString(oObject, "0_Q_ID");
                string sDescription = GetServerDatabaseString(oPossessor, QUEST_TABLE, "description", sQuestID);
                Debug("0e_oe_object_b", "23", "oPossessor: " + GetName(oPossessor) +
                      " Quest: " + GetName(oObject) + " sQuestID: " + sQuestID +
                      " sDescription: " + sDescription);
                if(sDescription != "") SetDescription(oObject, sDescription, TRUE);
            }
            return;
        }
        string sDescription = GetDescription(oObject, FALSE, TRUE);
        Debug("0e_oe_object_b", "31", "oPossessor: " + GetName(GetItemPossessor(oObject)) +
              " Quest: " + GetName(oObject) + " sDescription: " + sDescription);
        int iIndex = FindSubString(sDescription, "[");
        if(iIndex != -1)
        {
            SetDescription(oObject, GetStringLeft (sDescription, iIndex -1), TRUE);
            DelayCommand(0.1f, SetDescription(oObject, sDescription, TRUE));
        }
    }
}

