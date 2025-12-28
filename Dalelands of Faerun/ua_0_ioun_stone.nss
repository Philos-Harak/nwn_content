/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: ua_0_ioun_stone
 Programmer: Philos
/////////////////////////////////////////////////////////////////////////////////////////////////////
 Unaquire item script for Ioun Stones.
 Used to remove Ioun Stone effects when unaquired.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"

void main()
{
    object oCreature = GetModuleItemLostBy ();
    // Get the ResRef of the Ioun stone.
    string sResRef = GetResRef (OBJECT_SELF);
    // Remove any ioun stones effects.
    effect eEffect = GetFirstEffect (oCreature);
    while (GetIsEffectValid (eEffect))
    {
        if (sResRef == GetEffectTag (eEffect)) RemoveEffect (oCreature, eEffect);
        eEffect = GetNextEffect (oCreature);
    }
}
