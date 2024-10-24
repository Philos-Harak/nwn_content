/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_ch_7_ondeath
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associate OnSpawn script;
  This fires when an associate dies.
*///////////////////////////////////////////////////////////////////////////////
//#include "0i_server"
#include "0i_single_player"
void main()
{
    object oCreature = OBJECT_SELF;
    // Added code to allow for permanent associates in the battle!
    int nIndex;
    object oAssociate;
    if(GetLocalInt(GetModule(), AI_RULE_PERM_ASSOC))
    {
        for(nIndex = 1; nIndex < 5; nIndex++)
        {
            oAssociate = GetAssociate(nIndex, oCreature);
            if(oAssociate != OBJECT_INVALID)
            {
                SetIsDestroyable(FALSE, FALSE, FALSE, oAssociate);
                ChangeFaction(oAssociate, oCreature);
            }
        }
    }
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"), oCreature);
}
