/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnSpawn script;
  This fires when an associate dies.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    // Added code to allow for permanent associates in the battle!
    if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "13", GetName(oCreature) + " has died!" +
                 " AI_RULE_PERM_ASSOC: " + IntToString(GetLocalInt(GetModule(), AI_RULE_PERM_ASSOC)));
    object oModule = GetModule();
    if(GetLocalInt(oModule, AI_RULE_PERM_ASSOC))
    {
        object oAssociate;
        int nIndex;
        for(nIndex = 2; nIndex < 5; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                AssignCommand(oAssociate, SetIsDestroyable(FALSE, FALSE, FALSE));
                DelayCommand(0.1, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
                DelayCommand(3.0, AssignCommand(oAssociate, SetIsDestroyable(TRUE, FALSE, FALSE)));
            }
        }
    }
    // Remove the widget!
    object oPC = GetMaster(oCreature);
    if(oPC != OBJECT_INVALID)
    {
        NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oCreature) + AI_WIDGET_NUI));
        DelayCommand(0.5, ai_CheckXPPartyScale(oCreature));
        DelayCommand(2.0, ai_ClearCreatureActions(TRUE));
    }
    DelayCommand(2.0, ai_ClearCombatState(oCreature));
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"));
}

