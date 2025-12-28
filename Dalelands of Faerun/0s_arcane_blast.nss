/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_arcane_blast
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Feat that allows the caster to turn offensive creature targeting spells into arcane blasts.
 This toggles it on and off.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_spells"

void main()
{
    object oCaster = GetLastSpellCaster ();
    // Check to see if we are turning on arcane blast or turning it off.
    int iArcaneBlast = GetLocalInt (oCaster, "0_Arcane_Blast");
    // If on
    if (iArcaneBlast)
    {
        // turn off
        SetLocalInt (oCaster, "0_Arcane_Blast", FALSE);
        // Send message.
        SendMessages ("Arcane Blast mode OFF!", COLOR_YELLOW, oCaster);
    }
    // If off
    else
    {
        // turn on
        SetLocalInt (oCaster, "0_Arcane_Blast", TRUE);
        // Send message.
        SendMessages ("Arcane Blast mode ON!", COLOR_YELLOW, oCaster);
    }
}
