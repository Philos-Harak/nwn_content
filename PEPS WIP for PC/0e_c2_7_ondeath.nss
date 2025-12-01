/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnDeath script;
  This fires when the creature dies.
*////////////////////////////////////////////////////////////////////////////////
#include "0i_module"
void main()
{
    object oCreature = OBJECT_SELF;
    // Added code to allow for permanent associates in the battle!
    object oModule = GetModule();
    if(AI_DEBUG) ai_Debug("0e_c2_7_ondeath", "14", "AI_RULE_PERM_ASSOC: " + IntToString(GetLocalInt(oModule, AI_RULE_PERM_ASSOC)));
    if(GetLocalInt(oModule, AI_RULE_PERM_ASSOC))
    {
        object oAssociate;
        int nIndex;
        for(nIndex = 2; nIndex < 6; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                SetIsDestroyable(FALSE, FALSE, FALSE, oAssociate);
                DelayCommand(0.1, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
                DelayCommand(3.0, SetIsDestroyable(TRUE, FALSE, FALSE, oAssociate));
            }
        }
    }
    if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY)) SetIsDestroyable(FALSE, FALSE, TRUE);
    ai_ClearCombatState(oCreature);
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"));
}

