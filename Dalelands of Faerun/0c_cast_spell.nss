/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_cast_spell
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script to have a henchman cast a spell.
 int nSpell is the spell to cast.
 int nGold is the cost if it has one.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
void main()
{
    object oTarget, oPC = GetPCSpeaker();
    int nSpell = StringToInt (GetScriptParam ("nSpell"));
    int nGold = StringToInt (GetScriptParam ("nGold"));
    int nPCGold = GetGold (oPC);
    // Raise dead should be cast on a body in the inventory.
    if (nSpell == SPELL_RAISE_DEAD || nSpell == SPELL_RESURRECTION || nSpell == 970/*SPELL_TRUE_RESURRECTION*/)
    {
        if (nGold <= nPCGold)
        {
            oTarget = GetCreatureHasItem (oPC, "0_corpse");
            if (oTarget != OBJECT_INVALID)
            {
                int nRaise = 3;
                if (nSpell == SPELL_RAISE_DEAD) nRaise = 1;
                else if (nSpell == SPELL_RESURRECTION) nRaise = 2;
                if (GetLocalInt (oTarget, "0_Raise") <= nRaise)
                {
                    TakeGoldFromCreature (nGold, oPC);
                    ActionCastFakeSpellAtObject (nSpell, oTarget);
                    AssignCommand (oPC, ActionCastSpellAtObject (nSpell, oTarget, 255, TRUE, 0, 0, TRUE));
                }
                else SpeakString ("This spell is not strong enought to resurrect this being!");
            }
            else SpeakString ("You need to have a body for me to raise from the dead!");
        }
        else SpeakString ("You do not have the " + IntToString (nGold) + "gold required for me to cast this spell for you!");
    }
    else
    {
        if (nGold <= nPCGold)
        {
            TakeGoldFromCreature (nGold, oPC);
            ActionCastSpellAtObject (nSpell, oPC, 255, TRUE);
        }
        else SpeakString ("You do not have the " + IntToString (nGold) + "gold required for me to cast this spell for you!");
    }
}
