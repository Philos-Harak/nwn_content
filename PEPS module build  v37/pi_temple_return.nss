/*//////////////////////////////////////////////////////////////////////////////
 Script: pi_temple_return
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Plugin for returning dead companions back to the player for a fee.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
// Does startup check if the game has just been loaded.
int StartingUp(object oPC);
void JumpToPC(object oPC, object oHenchman)
{
    ClearAllActions(TRUE);
    JumpToObject(oPC);
}
int CheckAndReturnHenchman(object oPC, string sHenchmanTag, string sAreaTag)
{
    object oHenchman = GetObjectByTag(sHenchmanTag);
    string sHenchmanAreaTag = GetTag(GetArea(oHenchman));
    if(sHenchmanAreaTag == sAreaTag)
    {
        AssignCommand(oHenchman, JumpToPC(oPC, oHenchman));
        return TRUE;
    }
    return FALSE;
}
void main()
{
    object oPC = OBJECT_SELF;
    if(StartingUp(oPC)) return;
    int bUsed;
    if(GetIsInCombat(oPC))
    {
        SendMessageToPC(oPC, "You cannot return henchman while in combat!");
        return;
    }
    string sModuleTag = GetTag(GetModule());
    if(sModuleTag == "Chapter1" || sModuleTag == "ENDMODULE3")
    {
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GAL", "MAP_M1Q1F1")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_LIN", "MAP_M1Q1F1")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_DAE", "MAP_M1Q1F1")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_BOD", "MAP_M1Q1F1")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GRI", "MAP_M1Q1F1")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_SHA", "MAP_M1Q1F1")) bUsed = TRUE;
        int nGold;
        if(sModuleTag == "Chapter1") nGold = 50;
        else nGold = 400;
        if(bUsed) TakeGoldFromCreature(nGold, oPC, TRUE);
        else SendMessageToPC(oPC, "There is no one to return to you.");
    }
    else if(sModuleTag == "Chapter2")
    {
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GAL", "MAP_M2Q1P")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_LIN", "MAP_M2Q1P")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_DAE", "MAP_M2Q1P")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_BOD", "MAP_M2Q1P")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GRI", "MAP_M2Q1P")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_SHA", "MAP_M2Q1P")) bUsed = TRUE;
        if(bUsed) TakeGoldFromCreature(150, oPC, TRUE);
        else SendMessageToPC(oPC, "There is no one to return to you.");
    }
    else if(sModuleTag == "ENDMODULE2")
    {
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GAL", "M2Q4A17")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_LIN", "M2Q4A17")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_DAE", "M2Q4A17")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_BOD", "M2Q4A17")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GRI", "M2Q4A17")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_SHA", "M2Q4A17")) bUsed = TRUE;
        if(bUsed) TakeGoldFromCreature(150, oPC, TRUE);
        else SendMessageToPC(oPC, "There is no one to return to you.");
    }
    else if(sModuleTag == "Chapter3")
    {
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GAL", "M3Q1A06")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_LIN", "M3Q1A06")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_DAE", "M3Q1A06")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_BOD", "M3Q1A06")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_GRI", "M3Q1A06")) bUsed = TRUE;
        if(CheckAndReturnHenchman(oPC, "NW_HEN_SHA", "M3Q1A06")) bUsed = TRUE;
        if(bUsed) TakeGoldFromCreature(400, oPC, TRUE);
        else SendMessageToPC(oPC, "There is no one to return to you.");
    }
}
int StartingUp(object oPC)
{
    if(GetLocalInt(oPC, AI_ADD_PLUGIN))
    {
        json jPlugin = JsonArray();
        jPlugin = JsonArrayInsert(jPlugin, JsonString("pi_temple_return"));
        jPlugin = JsonArrayInsert(jPlugin, JsonInt(FALSE));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("Return Dead Henchman"));
        jPlugin = JsonArrayInsert(jPlugin, JsonString("dm_limbo"));
        json jPlugins = GetLocalJson(oPC, AI_JSON_PLUGINS);
        jPlugins = JsonArrayInsert(jPlugins, jPlugin);
        SetLocalJson(oPC, AI_JSON_PLUGINS, jPlugin);
        SetLocalInt(oPC, AI_PLUGIN_SET, TRUE);
        return TRUE;
    }
    if(!GetLocalInt(oPC, AI_STARTING_UP)) return FALSE;
    return TRUE;
}

