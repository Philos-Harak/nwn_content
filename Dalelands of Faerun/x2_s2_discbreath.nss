/*////////////////////////////////////////////////
 script: x2_s2_discbreath
 Programmer: Georg Zoeller
////////////////////////////////////////////////
  Breath Weapon for Dragon Disciple Class
  Damage Type and shape is based on dragon blood line.
  Black - Line of acid 60' long.
  Blue - Line of lightning 60' long.
  Green - Cone of acid 30' long.
  Red - Cone of fire 30' long.
  White - Cone of cold 30' long.
  Brass - Line of fire 60' long.
  Bronze - Line of lightning 60' long.
  Copper - Line of acid 60' long.
  Gold - Cone of fire 30' long.
  Silver - Cone of cold 30' long.
  Save is Reflex
  Shape  cone 30' == 10m && line 60' == 20m
  Level      Damage      Save
  ---------------------------
  3          2d10         19
  7          4d10         19
  10         6d10         19
/*///////////////////////////////////////////////
#include "0i_spells"

void main()
{
    int iLevel, iShape, iDmgType, iSaveType, iModDiceNum, iImpact, iDamage, iFeat;
    float fSize, fDelay;
    object oTarget, oObject;
    vector vCaster;
    effect eImpact, eBreath;
    // Get the dragon disciples ancestry feat and set the type and shape.
    if (GetHasFeat (FEAT_BLACK_DRAGON_BLOOD, OBJECT_SELF) || GetHasFeat (FEAT_COPPER_DRAGON_BLOOD, OBJECT_SELF))
    {
        iFeat = 1383;
        iShape = SHAPE_SPELLCYLINDER; // Line
        fSize = 60.0f;
        iDmgType = DAMAGE_TYPE_ACID;
        iSaveType = SAVING_THROW_TYPE_ACID;
        iImpact = VFX_IMP_ACID_S;
    }
    else if (GetHasFeat (FEAT_BLUE_DRAGON_BLOOD, OBJECT_SELF) || GetHasFeat (FEAT_BRONZE_DRAGON_BLOOD, OBJECT_SELF))
    {
        iFeat = 1384;
        iShape = SHAPE_SPELLCYLINDER; // Line
        fSize = 60.0f;
        iDmgType = DAMAGE_TYPE_ELECTRICAL;
        iSaveType = SAVING_THROW_TYPE_ELECTRICITY;
        iImpact = VFX_IMP_LIGHTNING_M;
    }
    else if (GetHasFeat (FEAT_BRASS_DRAGON_BLOOD, OBJECT_SELF))
    {
        iFeat = 1388;
        iShape = SHAPE_SPELLCYLINDER; // Line
        fSize = 60.0f;
        iDmgType = DAMAGE_TYPE_FIRE;
        iSaveType = SAVING_THROW_TYPE_FIRE;
        iImpact = VFX_IMP_FLAME_M;
    }
    else if (GetHasFeat (FEAT_GREEN_DRAGON_BLOOD, OBJECT_SELF))
    {
        iFeat = 1385;
        iShape = SHAPE_SPELLCONE;
        fSize = 30.0f;
        iDmgType = DAMAGE_TYPE_ACID;
        iSaveType = SAVING_THROW_TYPE_ACID;
        iImpact = VFX_IMP_ACID_S;
    }
    else if (GetHasFeat (FEAT_SILVER_DRAGON_BLOOD, OBJECT_SELF) || GetHasFeat (FEAT_WHITE_DRAGON_BLOOD, OBJECT_SELF))
    {
        iFeat = 1387;
        iShape = SHAPE_SPELLCONE;
        fSize = 30.0f;
        iDmgType = DAMAGE_TYPE_COLD;
        iSaveType = SAVING_THROW_TYPE_COLD;
        iImpact = VFX_IMP_FROST_S;
    }
    else // Red Dragon and Gold Dragon blood as well as the catch all.
    {
        iFeat = 1386;
        iShape = SHAPE_SPELLCONE;
        fSize = 30.0f;
        iDmgType = DAMAGE_TYPE_FIRE;
        iSaveType = SAVING_THROW_TYPE_FIRE;
        iImpact = VFX_IMP_FLAME_M;
    }
    // Get damage dice base on dragon disciple level.
    iLevel = GetLevelByClass (CLASS_TYPE_DRAGON_DISCIPLE, OBJECT_SELF);
    if (iLevel < 7) iModDiceNum = 2;
    else if (iLevel < 10) iModDiceNum = 4;
    else iModDiceNum = 6;
    // ***********************************************************
    // *************** Set Spell Structure ***********************
    // ***********************************************************
    // Setup the spell in the structured variables, then pass through the SetSpell function.
    Spell.iSubType = SUBTYPE_SUPERNATURAL;
    Spell.iAreaShape = iShape;
    Spell.fAreaSize = fSize;
    Spell.iLineOfSight = TRUE;
    Spell.iObjectFilter = OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE;
    Spell.iTargetType = TARGET_TYPE_ALL;
    Spell.iDurationType = DURATION_TYPE_INSTANT;
    Spell.iSave = SAVING_THROW_REFLEX;
    Spell.iSaveDC = 19;
    Spell.iSaveType = iSaveType;
    Spell.iSaveHalf = TRUE;
    Spell.iDamageType = iDmgType;
    Spell.iModNumOfDice = iModDiceNum;
    Spell.iModifierDie = 10;
    Spell.iModDicePerLvl = 1;
    Spell.iImpact = iImpact;
    // Setup the spell.
    Spell = SetSpell (Spell);
    //Get first target in spell area
    location lFinalTarget = GetSpellTargetLocation();
    // Since the target and origin are the same, we have to determine the
    // direction of the spell from the facing of OBJECT_SELF (which is more
    // intuitive than defaulting to East everytime).
    // In order to use the direction that OBJECT_SELF is facing, we have to
    // instead pick a point slightly in front of OBJECT_SELF as the target.
    vector lTargetPosition = GetPositionFromLocation (lFinalTarget);
    vector vFinalPosition;
    vFinalPosition.x = lTargetPosition.x +  cos (GetFacing(Spell.oCaster));
    vFinalPosition.y = lTargetPosition.y +  sin (GetFacing(Spell.oCaster));
    lFinalTarget = Location (GetAreaFromLocation (lFinalTarget), vFinalPosition, GetFacingFromLocation (lFinalTarget));
    eImpact = EffectVisualEffect (Spell.iImpact);
    vCaster = GetPosition (Spell.oCaster);
    //Get the spells target(s).
    Spell = GetSpellTarget (Spell);
    while (GetIsObjectValid(Spell.oAreaTarget))
    {
        if (Spell.oAreaTarget != Spell.oCaster)
        {
            // Fire cast spell at event for the specified target
            SignalEvent (Spell.oAreaTarget, EventSpellCastAt (Spell.oCaster, Spell.iSpellID));
            // Get the modifier for the breathweapon, sets Spell.iResult
            Spell = GetModifier (Spell);
            // Make resistance and save check.
            Spell = ResistAndSave (Spell);
            if (Spell.iResult > 0)
            {
                //Set Damage and VFX
                eBreath = EffectDamage (Spell.iResult, Spell.iDamageType);
                //Apply the VFX impact and effects
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpact, Spell.oAreaTarget));
                DelayCommand (Spell.fDelay, ApplyEffectToObject (DURATION_TYPE_INSTANT, eBreath, Spell.oAreaTarget));
             }
        }
        //Get the spells target(s).
        Spell = GetSpellTarget (Spell);
    }
    // Set Cooldown timer.
    DelayCommand (60.0f, IncrementRemainingFeatUses (Spell.oCaster, iFeat));
}





