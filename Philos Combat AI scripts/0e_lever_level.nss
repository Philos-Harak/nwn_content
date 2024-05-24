/*//////////////////////////////////////////////////////////////////////////////
 Script: 0e_lever_level
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
 OnUse event to switch levers on and off.
 Gives xp to gain levels.
*///////////////////////////////////////////////////////////////////////////////
#include "0i_main"
void main()
{
    object oPC = GetLastUsedBy ();
    if (!GetLocalInt(OBJECT_SELF,"Lever_is_On"))
    {
        PlayAnimation (ANIMATION_PLACEABLE_ACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_On", TRUE);
    }
    else
    {
        PlayAnimation (ANIMATION_PLACEABLE_DEACTIVATE);
        SetLocalInt (OBJECT_SELF,"Lever_is_On", FALSE);
    }
    int nNextLevel = ai_GetCharacterLevels (oPC);
    int nXp = StringToInt(Get2DAString("exptable", "XP", nNextLevel));
    GiveXPToCreature(oPC, nXp - GetXP(oPC));
    ai_SendMessages (GetPCPlayerName (oPC) + "'s character named " + GetName (oPC) + " has gained a level.", COLOR_GREEN, oPC, FALSE, TRUE);
}

