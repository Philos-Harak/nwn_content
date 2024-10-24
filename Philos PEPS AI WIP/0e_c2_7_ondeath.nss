/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_c2_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Monster OnDeath script;
  This fires when the creature dies.
*////////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
#include "0i_single_player"
void main()
{
    object oCreature = OBJECT_SELF;
    // Added code to allow for permanent associates in the battle!
    if(GetLocalInt(GetModule(), AI_RULE_PERM_ASSOC))
    {
        int nIndex;
        object oAssociate;
        for(nIndex = 1; nIndex < 5; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                SetIsDestroyable(FALSE, FALSE, FALSE, oAssociate);
                DelayCommand(0.1, ChangeToStandardFaction(oAssociate, STANDARD_FACTION_HOSTILE));
            }
        }
    }
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"), oCreature);
}
