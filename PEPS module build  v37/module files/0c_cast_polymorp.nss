/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0c_cast_polymorp
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Conversation script to have a henchman cast a polymorph spell.
 int nSpell is the spell to cast.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_items"
void main()
{
    object oHenchman = OBJECT_SELF;
    int nSpell = StringToInt (GetScriptParam ("nSpell"));
    // Save the original form so we can check when we turn back (Add 1 so we don't save a 0!).
    SetLocalInt (oHenchman, AI_NORMAL_FORM, GetAppearanceType (oHenchman) + 1);
    SetLocalString (oHenchman, AI_COMBAT_SCRIPT, "ai_a_polymorphed");
    ActionCastSpellAtObject (nSpell, oHenchman, 255, TRUE);
}

