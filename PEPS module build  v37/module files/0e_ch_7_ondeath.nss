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
    if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "13", GetName(oCreature) + " has died!");
    object oModule = GetModule();
    if(GetLocalInt(oModule, AI_RULE_PERM_ASSOC))
    {
        object oAssociate;
        int nIndex;
        for(nIndex = 2; nIndex < 6; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "24", GetName(oAssociate) + " being set to permanent!");
                SetIsDestroyable(FALSE, FALSE, FALSE, oAssociate);
                DelayCommand(0.1, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
                DelayCommand(3.0, SetIsDestroyable(TRUE, FALSE, FALSE, oAssociate));
            }
        }
    }
    // Remove the widget!
    object oPC = GetMaster(oCreature);
    if(oPC != OBJECT_INVALID)
{
        if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "35", GetName(oPC) + " Removing associates widget!");
        NuiDestroy(oPC, NuiFindWindow(oPC, ai_GetAssociateType(oPC, oCreature) + AI_WIDGET_NUI));
        DelayCommand(0.5, ai_CheckXPPartyScale(oCreature));
        DelayCommand(2.0, ai_ClearCreatureActions(TRUE));
    }
    DelayCommand(2.0, ai_ClearCombatState(oCreature));
    ChangeToStandardFaction(oCreature, STANDARD_FACTION_DEFENDER);
    if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "42", "Execute second OnDeath script: " + GetLocalString(oCreature, "AI_ON_DEATH"));
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"), oCreature);
}

