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
    if(GetLocalInt(oModule, AI_RULE_PERM_ASSOC))
    {
        object oAssociate;
        int nIndex, bDestroyable, bRaisable, bSelectableWhenDead;
        for(nIndex = 2; nIndex < 6; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                bDestroyable = GetIsDestroyable(oAssociate);
                bSelectableWhenDead = GetIsSelectableWhenDead(oAssociate);
                bRaisable = GetIsRaiseable(oAssociate);
                SetIsDestroyable(FALSE, FALSE, FALSE, oAssociate);
                DelayCommand(0.1, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
                DelayCommand(3.0, SetIsDestroyable(TRUE, bRaisable, bSelectableWhenDead, oAssociate));
            }
        }
    }
    /*if(GetLocalInt(oModule, AI_RULE_CORPSES_STAY))
    {

        int bRaisable = GetIsRaiseable(oCreature);
        SetIsDestroyable(FALSE, bRaisable, TRUE, oCreature);
    } */
    ai_ClearCombatState(oCreature);
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"));
}

