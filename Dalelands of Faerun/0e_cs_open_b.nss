/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_cs_open_b
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Event script that runs when a pc opens the character sheet.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "nwnx_events"
#include "nwnx_creature"
#include "0i_server_colors"
#include "0i_database"
#include "0i_character"
void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("TARGET"));
    object oUser = OBJECT_SELF;
    if(GetIsCharacter(oObject))
    {
        // Setup character sheet \n to remove some text.
        SetCustomToken(1003, "\n");
        // Combine Base Attack and Spell resistance on Base Attack: line (40424).
        string sACP = IntToString(NWNX_Creature_GetArmorCheckPenalty (oObject));
        string sText = "Base Attack: <CUSTOM9999>" + IntToString(GetBaseAttackBonus (oObject)) + "<CUSTOM8999>  " +
                       "Armor Check Penalty: <CUSTOM9999>" + sACP + "<CUSTOM8999><CUSTOM1003>";
        NWNX_Player_SetTlkOverride(oUser, 40424, sText);
        // Combine Arcane Spell Failure and Armor Check Penalty on Spell Resistance line (58349).
        string sASF = IntToString(GetArcaneSpellFailure(oObject)) + "%";
        sText = "Arcane Spell Failure: <CUSTOM9999>" + sASF + "<CUSTOM8999>  " +
                "Spell Resistance: <CUSTOM9999>" + IntToString(GetSpellResistance(oObject)) + "<CUSTOM8999><CUSTOM1003>";
        NWNX_Player_SetTlkOverride(oUser, 58349, sText);
        // Add Age to Arcane Spell Failure line (58350).
        sText = "Age: <CUSTOM9999>" + IntToString(GetAge(oObject)) + "<CUSTOM8999><CUSTOM1003>";
        NWNX_Player_SetTlkOverride(oUser, 58350, sText);
        // Add Fame to Armor check penalty line (58351).
        int nRep = GetObjectDatabaseInt(oObject, CHARACTER_TABLE, "fame");
        sText = IntToString(nRep) + " (" + GetFameText (nRep) + ")";
        sText = "Fame: <CUSTOM9999>" + sText + "<CUSTOM8999><CUSTOM1003>";
        NWNX_Player_SetTlkOverride(oUser, 58351, sText);
        // Add Infamy to Alignment line (58348).
        nRep = GetObjectDatabaseInt(oObject, CHARACTER_TABLE, "infamy");
        sText = IntToString(nRep) + " (" + GetInfamyText (nRep) + ")";
        sText = "Infamy: <CUSTOM9999>" + sText + "<CUSTOM8999><CUSTOM1003>";
        NWNX_Player_SetTlkOverride(oUser, 58348, sText);
        // Add Deity info to effects line (58352).
        string sDeity = GetDeity(oObject);
        if (sDeity == "") sDeity = "None";
        sText = "Deity: <CUSTOM9999>" + sDeity + "<CUSTOM8999>";
        NWNX_Player_SetTlkOverride(oUser, 58352, sText);
    }
    else
    {
        NWNX_Player_SetTlkOverride(oUser, 40424, "");
        NWNX_Player_SetTlkOverride(oUser, 58349, "");
        NWNX_Player_SetTlkOverride(oUser, 58350, "");
        NWNX_Player_SetTlkOverride(oUser, 58351, "");
        NWNX_Player_SetTlkOverride(oUser, 58348, "");
        NWNX_Player_SetTlkOverride(oUser, 58352, "");
    }
}
