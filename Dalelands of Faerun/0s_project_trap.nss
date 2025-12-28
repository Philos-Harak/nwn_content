/*//////////////////////////////////////////////////////////////////////////////
 0s_project_trap
 Created By: Philos
////////////////////////////////////////////////////////////////////////////////
 This projectile trap will fire a projectile at a target
 from placeable caster.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_battle"
void main()
{
    int nDmgType;
    string sDmg;
    object oCaster = OBJECT_SELF;
    // Set trap based on level. This is set in 0i_traps (TriggerSpellTrap).
    int nLevel = GetLocalInt (oCaster, "0_CasterLevel");
    // nAttacks is random unless specified.
    int nAttacks = GetLocalInt (oCaster, "0_NumOfAttacks");
    if (nAttacks == 0) nAttacks = Random (5) + 1;
    // If DmgDice is not selected then set based on level.
    int nSpell = GetSpellId ();
    switch (nSpell)
    {
        case 487 : // Arrow
        {
            sDmg = "1d8";
            nDmgType = DAMAGE_TYPE_PIERCING;
            break;
        }
        case 488 : // Bolt
        {
            sDmg = "1d6";
            nDmgType = DAMAGE_TYPE_PIERCING;
            break;
        }
        case 493 : // Dart
        {
            sDmg = "1d4";
            nDmgType = DAMAGE_TYPE_PIERCING;
            break;
        }
        case 494 : // Shuriken
        {
            sDmg = "1d2";
            nDmgType = DAMAGE_TYPE_PIERCING;
            break;
        }
    }
    // Check to see if they defined the damage.
    string sDmgDice = GetLocalString (oCaster, "0_DmgDice");
    // If not the set to base and add the level as a bonus.
    if (sDmgDice == "") sDmgDice = sDmg + "+" + IntToString (nLevel);
    object oTarget = GetSpellTargetObject();
    // Do first attack on the original target (first one into trigger).
    ActionCastFakeSpellAtObject (nSpell, oTarget, PROJECTILE_PATH_TYPE_HOMING);
    DoSpecificRangedAttack (oCaster, oTarget, nLevel, nDmgType, sDmgDice, FALSE);
    // Reduce attack since the first one has been done.
    nAttacks --;
    location lTarget = GetLocation (oTarget);
    object oNextTarget = GetFirstObjectInShape (SHAPE_SPHERE, 5.0f, lTarget, TRUE);
    while (oNextTarget != OBJECT_INVALID && nAttacks > 0)
    {
        // Don't fire at original target since that has already happened when this was called.
        if (oTarget != oNextTarget)
        {
            // Fire at the target, but use fake spell so we can do damage ourselves.
            // This shoots the projectile.
            ActionCastFakeSpellAtObject (nSpell, oNextTarget, PROJECTILE_PATH_TYPE_HOMING);
            // Do real attack!
            DoSpecificRangedAttack (oCaster, oNextTarget, nLevel, nDmgType, sDmgDice, FALSE);
        }
        nAttacks --;
        oNextTarget = GetNextObjectInShape (SHAPE_SPHERE, 5.0f, lTarget, TRUE);
    }
}

