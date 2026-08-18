/*///////////////////////////////////////////////////////////////////////////////
 Script: 0e_lever_effects
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 This allows an admin character to text effect values.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_character"
#include "nwnx_effect"
void main()
{
    object oTrigger, oPC = GetLastUsedBy ();
    if(!GetLocalInt(OBJECT_SELF, "Lever_is_on"))
    {
        PlayAnimation (ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_on", TRUE);
    }
    else
    {
        PlayAnimation (ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_on", FALSE);
    }
    // Allow full DM's and Admins to use this lever.
    if (GetServerDatabaseInt (oPC, PLAYER_TABLE, "status") > 3)
    {
        int i, nCount = NWNX_Effect_GetTrueEffectCount (oPC);
        struct NWNX_EffectUnpacked e;
        while (i < nCount)
        {
            e = NWNX_Effect_GetTrueEffect (oPC, i);
            //PrintUnpackedEffect (e);
            i++;
        }
    }
    else SendMessages ("The lever easily moves but has no visible effect.", COLOR_GRAY);
}
