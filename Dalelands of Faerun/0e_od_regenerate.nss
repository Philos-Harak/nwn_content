/*//////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_od_regenerate
 Programmer: Lorinton  modified by Philos
////////////////////////////////////////////////////////////////////////////////
 Creature on damage event script.
    Sets up regeneration on creatures and how to kill them.
    NOTE: the 0e_os_regenerate script must be put on the creature that regenerates.
/*///////////////////////////////////////////////////////////////////////////////
#include "0i_creature"
#include "0i_effects"
void main()
{
    //object oDamager = GetLastDamager();
    // ****************************************************************
    // ********** Regenerating Creatures damage calculations **********
    // ****************************************************************
    int nMaxHPs = GetMaxHitPoints ();
    if (CalculateRegeneratingCreatureDamage ())
    {
        int nTempDmg = GetLocalInt (OBJECT_SELF, "0_TempDmg");
        int nPermDmg = GetLocalInt (OBJECT_SELF, "0_PermDmg");
        int nTotalDmg = nTempDmg + nPermDmg;
        // If total dmg exceeds max hps then knock it down!
        if (nTotalDmg >= nMaxHPs)
        {
            float fDuration = (2.0f * IntToFloat (nTotalDmg - nMaxHPs));
            SetCommandable (TRUE);
            ClearAllActions ();
            PlayAnimation (ANIMATION_LOOPING_DEAD_FRONT, 1.0, fDuration);
            SetLocalInt (OBJECT_SELF, "0_Unconscious", TRUE);
            DelayCommand (0.05, SetCommandable (FALSE));
        }
        // Check if they stick it with a torch while it is down!
        int nBaseItemType = GetBaseItemType (GetItemInSlot (INVENTORY_SLOT_LEFTHAND, GetLastAttacker()));
        if (GetLocalInt (OBJECT_SELF, "0_Unconscious" ) && nBaseItemType == BASE_ITEM_TORCH )
        {
            object oTroll = OBJECT_SELF;
            AssignCommand (GetLastAttacker(), KillRegeneratingCreature (oTroll, FALSE, TRUE));
        }
    }
}
