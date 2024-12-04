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
    ai_Debug("0e_ch_7_ondeath", "14", GetName(oCreature) + " has died!" +
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
    //ai_Debug("0e_ch_7_ondeath", "28", "AI_ON_DEATH: " + GetLocalString(oCreature, "AI_ON_DEATH") +
    //         " OBJECT_SELF: " + GetName(OBJECT_SELF) + " NW_L_HEN_I_DIED: " +
    //         IntToString(GetLocalInt(oCreature, "NW_L_HEN_I_DIED")));
    ExecuteScript(GetLocalString(oCreature, "AI_ON_DEATH"));
}
