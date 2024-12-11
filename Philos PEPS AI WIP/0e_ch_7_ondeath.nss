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
    if(AI_DEBUG) ai_Debug("0e_ch_7_ondeath", "14", GetName(oCreature) + " has died!" +
                 " AI_RULE_PERM_ASSOC: " + IntToString(GetLocalInt(GetModule(), AI_RULE_PERM_ASSOC)));
    if(GetLocalInt(GetModule(), AI_RULE_PERM_ASSOC))
    {
        object oAssociate;
        int nIndex;
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
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"));
}
