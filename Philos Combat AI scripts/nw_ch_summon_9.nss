//::///////////////////////////////////////////////
//:: Associate: On Spawn In
/*//////////////////////////////////////////////////////////////////////////////
 Script: nw_ch_summon_9
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
  Associates on spawn script for summoned creatures.
  See nw_ch_ac9 for on spawn code.
*///////////////////////////////////////////////////////////////////////////////
#include"0i_associates"
void main()
{
    // Bioware summoned shadows are not incorporeal, also set the ai code.
    if (GetTag(OBJECT_SELF) == "NW_S_SHADOW")
    {
        SetLocalInt(OBJECT_SELF, "X2_L_IS_INCORPOREAL", TRUE);
        SetLocalString(OBJECT_SELF, AI_DEFAULT_SCRIPT, "ai_shadow");
    }
    // We just use the default associate script.
    ExecuteScript("nw_ch_ac9");
}



