/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0s_scattershot
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Feat that allows a character to shoot an arrow at every enemy creature within range.
*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_battle"

void main()
{
    int iBaseItemType, iStack, iHit;
    float fDelay, fDistance;
    object oAttacker, oTarget, oBow, oArrow;
    location lCenter;
    effect eArrow, eDmg, eImpact;
    //Debug ("0s_scattershot", "16", "Firing 0s_scattershot");
    // Get the shooter.
    oAttacker = OBJECT_SELF;
    lCenter = GetLocation (oAttacker);
    // Get weapon and type of oAttacker.
    oBow = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oAttacker);
    iBaseItemType = GetBaseItemType (oBow);
    // If they are not using a Longbow or Shortbow then exit.
    if (iBaseItemType != BASE_ITEM_LONGBOW && iBaseItemType != BASE_ITEM_SHORTBOW)
    {
        SendMessages ("You must equip a Longbow or a Shortbow to use scattershot!", COLOR_RED, oAttacker);
        return;
    }
    oArrow = GetItemInSlot (INVENTORY_SLOT_ARROWS, oAttacker);
    // If they have no arrows then exit.
    if (!GetIsObjectValid (oArrow))
    {
        SendMessages ("You must equip arrows to use scattershot!", COLOR_RED, oAttacker);
        return;
    }
    iStack = GetItemStackSize (oArrow);
    // Check to make sure an enemy is not within 5'.
    oTarget = GetNearestCreature (CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oAttacker);
    // If the distance is less than 5' then do only one attack against the nearest enemy.
    if (GetDistanceBetween (oAttacker, oTarget) < 3.0f)
    {
        SignalEvent (oTarget, EventSpellCastAt (oAttacker, GetSpellId(), TRUE));
        // Reduce stack size so we can make sure we have enough arrows.
        iStack--;
        // Make attack.
        DoRangedAttack (oAttacker, oBow, oArrow, oTarget);
        // Now that we are all done lets remove them from the player!
        if (iStack) SetItemStackSize (oArrow, iStack);
        else DestroyObject (oArrow);
        return;
    }
    oTarget = GetFirstObjectInShape (SHAPE_SPHERE, 18.3f, lCenter, TRUE);
    // Make attacker face first target.
    if (!GetIsObjectValid (oTarget))
    {
        SendMessages ("There are no enemies within range to use scattershot!", COLOR_RED, oAttacker);
        return;
    }
    else SetFacingPoint (GetPosition (oTarget));
    //AssignCommand (oAttacker, ActionAttack (oTarget));
    while (GetIsObjectValid (oTarget) && iStack > 0)
    {
        oTarget = GetNextObjectInShape (SHAPE_SPHERE, 18.3f, lCenter, TRUE);
        if (oTarget != oAttacker && !GetIsDead (oTarget) && GetIsEnemy (oTarget))
        {
            SignalEvent (oTarget, EventSpellCastAt (oAttacker, GetSpellId(), TRUE));
            // Reduce stack size so we can make sure we have enough arrows.
            iStack--;
            // Make attack.
            DoRangedAttack (oAttacker, oBow, oArrow, oTarget);
        }
    }
    // Now that we are all done lets remove them from the player!
    if (iStack) SetItemStackSize (oArrow, iStack);
    else DestroyObject (oArrow);
}
