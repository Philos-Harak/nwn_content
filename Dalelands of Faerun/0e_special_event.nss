/*////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0e_special_event
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 OnUse event of a placeable.
 Used in the Halloween Special event.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_master"
#include "0i_checks"
#include "0i_spawn"
#include "0i_area"
// Gives a villians special powers based on level.
// 3st - 4th 1 power,  5th - 9th 2 powers, 10th - 14th 3 powers.
// 15th to 19th 4 powers, 20th 5 powers.
void GiveMyrkulSpecialPower(object oCreature);
// Delay transition until the creature is at the transition location.
// oCreature is the creature to wait to transition.
void WaitToJump (object oCreature, object oPlaceable);
void MoveBloodPortal(object oBloodPortal, object oArea);
void ClearDeathlessCastleArea(object oArea);
void main()
{
    object oObject = OBJECT_SELF;
    object oArea = GetArea(oObject);
    string sTag = GetTag(oObject);
    // Used to check if the items have been put in all 4 pools of blood.
    if(GetStringLeft(sTag, 13) == "pool_of_blood")
    {
        int nPlaced;
        object oBlood = GetObjectInAreaByTag(oArea, "pool_of_blood_heart", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        object oHeart = GetFirstItemInInventory(oBlood);
        if(GetTag(oHeart) == "monstrous_heart") nPlaced++;
        oBlood = GetObjectInAreaByTag(oArea, "pool_of_blood_skull", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        object oSkull = GetFirstItemInInventory(oBlood);
        if(GetTag(oSkull) == "burned_skull") nPlaced++;
        oBlood = GetObjectInAreaByTag(oArea, "pool_of_blood_femur", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        object oFemur = GetFirstItemInInventory(oBlood);
        if(GetTag(oFemur) == "femur_bone") nPlaced++;
        oBlood = GetObjectInAreaByTag(oArea, "pool_of_blood_vial", 1, OBJECT_TYPE_PLACEABLE, TRUE);
        object oVial = GetFirstItemInInventory(oBlood);
        if(GetTag(oVial) == "vial_of_blood") nPlaced++;
        if(nPlaced == 4)
        {
            DestroyObject(oHeart);
            DestroyObject(oSkull);
            DestroyObject(oFemur);
            DestroyObject(oVial);
            PlaySound("as_dr_x2ttu6op");
            PlaySound("al_mg_x2eldbrain");
            object oBloodPortal = GetObjectInAreaByTag(oArea, "bloodportal_to_myrkul", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBloodPortal, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 3.0, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
            DelayCommand(12.0, MoveBloodPortal(oBloodPortal, oArea));
            object oBlood = GetObjectInAreaByTag(oArea, "blood_heart", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -0.3, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
            oBlood = GetObjectInAreaByTag(oArea, "blood_skull", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -0.3, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
            oBlood = GetObjectInAreaByTag(oArea, "blood_femur", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -0.3, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
            oBlood = GetObjectInAreaByTag(oArea, "blood_vial", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -0.3, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
            oBlood = GetObjectInAreaByTag(oArea, "blood_center", 1, OBJECT_TYPE_PLACEABLE, TRUE);
            SetObjectVisualTransform(oBlood, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -0.35, OBJECT_VISUAL_TRANSFORM_LERP_SMOOTHERSTEP, 12.0);
        }
    }
    // Used to transition player to the Bone Castle from Aencar's Dungeon.
    else if(sTag == "dying_portal1_to_bone_castle" || sTag == "dying_portal2_to_bone_castle")
    {
        object oPC = GetPlaceableLastClickedBy();
        effect eEffect = GetTaggedEffect("Vial of Rot", oPC);
        // They have used the Potion of Rot before entering the Portal of Dying.
        if(GetIsEffectValid(eEffect)) ExecuteScript("0e_transition", oObject);
        // They have not used the Potion of Rot before entering the Portal of Dying.
        else
        {
            location lTarget = GetLocation(oObject);
            effect eVisual = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisual, oObject);
            effect eDamage = EffectDamage(d6(GetLocalInt(GetArea(oPC), "0_Area_Level")));
            object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 10.0, lTarget);
            while(oTarget == OBJECT_INVALID)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, oTarget);
                oTarget = GetNextObjectInShape(SHAPE_SPHERE, 10.0, lTarget);
            }
            SendMessages("The portal forces you back with a wave of negative energy!", COLOR_RED, oPC);
        }
    }
    else if(sTag == "crystal_ball_of_the_planes")
    {
        ExecuteScript("0e_transition", oObject);
        DelayCommand(6.0, ClearDeathlessCastleArea(oArea));
    }
    // Code for using pillars within the Catacombs of Death.
    else
    {
        object oPC = GetLastUsedBy();
        int nDC = GetLocalInt(GetArea(oPC), "0_Area_Level") + 10;
        if(nDC == 10) nDC = 11;
        int nCheck = GetSkillCheck(oPC, 16, FALSE, 0, nDC);
        location lLocation = GetLocation(oObject);
        if(!GetIsCharacter(oPC)) oPC = GetMaster(oPC);
        int nPortalLevel;
        if(sTag == "0_undead_pillar")
        {
            effect eEffectDmg, eEffect = EffectVisualEffect(VFX_FNF_LOS_EVIL_10);
            if(nCheck > -1) SendMessages("You see that these are magical symbols and figure out the order to remove them!", COLOR_GREEN, oPC);
            else
            {
                int nDamage;
                eEffect = EffectVisualEffect(VFX_FNF_LOS_EVIL_30);
                effect eEffectDmg, eImpact = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
                object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                while(oTarget != OBJECT_INVALID)
                {
                    nDamage = d6(nDC - 10);
                    //Debug("0e_special_event", "47", "oTarget: " + GetName(oTarget) +
                    //      " nDamage: " + IntToString(nDamage));
                    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE);
                    eEffectDmg = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffectDmg, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
                    oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                }
                SendMessages("You have no idea what they mean, but you wipe them off the pillar just in case.", COLOR_YELLOW, oPC);
                // Each tens place will increase the encounter by that value.
                nPortalLevel += 10;
            }
            nPortalLevel += GetLocalInt(oArea, "0_PORTAL_LEVEL") + 1;
            SetLocalInt(oArea, "0_PORTAL_LEVEL", nPortalLevel);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eEffect, lLocation);
        }
        else if(sTag == "0_undead_pedestal")
        {
            effect eEffect = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_FIRE, FALSE, 1.5f, [0.0, 0.0, 2.75]);
            if(nCheck > -1) SendMessages("You understand the magical symbols and do and incantation to remove them!", COLOR_GREEN, oPC);
            else
            {
                int nDamage;
                eEffect = EffectVisualEffect(VFX_FNF_FIREBALL);
                effect eEffectDmg, eImpact = EffectVisualEffect(VFX_IMP_FLAME_S);
                object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                while(oTarget != OBJECT_INVALID)
                {
                    nDamage = d6(nDC - 10);
                    //Debug("0e_special_event", "75", "oTarget: " + GetName(oTarget) +
                    //      " nDamage: " + IntToString(nDamage));
                    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_TYPE_FIRE);
                    eEffectDmg = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffectDmg, oTarget);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget);
                    oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                }
                SendMessages("You throw dirt on the flames to remove them from the pedestal just in case.", COLOR_YELLOW, oPC);
                // Each tens place will increase the encounter by that value.
                nPortalLevel += 10;
            }
            SetTileAnimationLoops(lLocation, FALSE, FALSE, FALSE);
            SetTileMainLightColor(lLocation, TILE_MAIN_LIGHT_COLOR_BLACK, TILE_MAIN_LIGHT_COLOR_BLACK);
            nPortalLevel += GetLocalInt(oArea, "0_PORTAL_LEVEL") + 1;
            SetLocalInt(oArea, "0_PORTAL_LEVEL", nPortalLevel);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eEffect, lLocation);
        }
        else if(sTag == "0_undead_bones")
        {
            effect eEffect = EffectVisualEffect(VFX_FNF_DISPEL);
            if(nCheck > -1) SendMessages("The bone symbols make sense and you dismantle them in the correct order!", COLOR_GREEN, oPC);
            else
            {
                int nDamage;
                eEffect = EffectVisualEffect(VFX_FNF_UNDEAD_DRAGON);
                effect eEffectDmg, eImpact = EffectVisualEffect(VFX_IMP_DEATH);
                object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                while(oTarget != OBJECT_INVALID)
                {
                    nDamage = d6(nDC - 10);
                    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, nDC);
                    eEffectDmg = EffectDamage(nDamage, DAMAGE_TYPE_MAGICAL);
                    DelayCommand(5.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eEffectDmg, oTarget));
                    DelayCommand(5.0f, ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTarget));
                    oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lLocation);
                }
                SendMessages("You knock the bones away breaking the symbols made from them.", COLOR_YELLOW, oPC);
                // Each tens place will increase the encounter by that value.
                nPortalLevel += 10;
            }
            nPortalLevel += GetLocalInt(oArea, "0_PORTAL_LEVEL") + 1;
            SetLocalInt(oArea, "0_PORTAL_LEVEL", nPortalLevel);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT,eEffect, lLocation);
        }
        DestroyObject(oObject);
        // This is used in the exit of the area. To remove the instance.
        if(nPortalLevel % 10 > 3)
        {
            // Setup Myrkuls host.
            object oWaypoint = GetNearestObjectByTag("0_myrkul_host", oPC);
            object oMyrkulHost = CreateObject(OBJECT_TYPE_CREATURE, "myrkul_host", GetLocation(oWaypoint));
            int nLevel = nDC - 10 + (nPortalLevel / 10);
            while(nLevel > 0)
            {
                LevelUpHenchman(oMyrkulHost, 10, TRUE, 118);
                nLevel--;
            }
            // Set all bosses to use battlecries.
            SetLocalInt(oMyrkulHost, "0_Battlecry", TRUE);
            // All villains cannot be dispelled.
            SetLocalInt(oMyrkulHost, "0_IMMUNE_TO_DISPEL", TRUE);
            SetLocalInt(oMyrkulHost, "0_VILLAIN", TRUE);
            // Color name based on creature CR.
            SetName(oMyrkulHost, ColorVillainName(oMyrkulHost, GetName(oMyrkulHost)));
            // Give villians a base set of items.
            GiveMagicalEquipment(oMyrkulHost, FloatToInt(GetChallengeRating (oMyrkulHost)));
            SetupCreature(oMyrkulHost, oWaypoint, oPC, TRUE);
            GiveMyrkulSpecialPower(oMyrkulHost);
            // Setup the portal
            oWaypoint = GetNearestObjectByTag("wp_myrkul_portal", oPC);
            location lLocation = GetLocation(oWaypoint);
            CreateObject(OBJECT_TYPE_PLACEABLE, "myrkul_portal", lLocation);
            SetTileMainLightColor(lLocation, TILE_MAIN_LIGHT_COLOR_DARK_PURPLE, TILE_MAIN_LIGHT_COLOR_DARK_PURPLE);
            effect eVisual = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, GetLocation(oObject));
            SendMessages("The catacomb rocks as a powerful BOOM echoes from the entrance. You have caused something to happen!", COLOR_YELLOW, oPC);
        }
    }
}
void GiveMyrkulSpecialPower(object oCreature)
{
    // Villians of Level 1 or 2 don't get special powers.
    int nLevel = FloatToInt(GetChallengeRating (oCreature));
    if(nLevel < 3) return;
    effect eEffect, eVisual, eHaste, eParalysis, eEntangle, eSlow, eMove, eHp;
    int nNumOfPowers, bColdAura, nAC = 2;
    int nToHit = 2;
    int nHp = 2;
    int nRoll, bHaste = FALSE, nConceal = 0, nRegen = 0, nSpellResist = 0;
    if (nLevel < 6) nNumOfPowers = 1;
    else if (nLevel < 12) nNumOfPowers = 2;
    else if (nLevel < 18) nNumOfPowers = 3;
    else if (nLevel < 24) nNumOfPowers = 4;
    else nNumOfPowers = 5;
    SetLocalInt(oCreature, "0_NUM_OF_POWERS", nNumOfPowers);
    while(nNumOfPowers > 0)
    {
        nRoll = d100();
        // Haste
        if (nRoll < 11 && !bHaste)
        {
            eEffect = EffectVisualEffect(VFX_DUR_FREEDOM_OF_MOVEMENT);
            eHaste = EffectHaste ();
            eParalysis = EffectImmunity(IMMUNITY_TYPE_PARALYSIS);
            eEntangle = EffectImmunity(IMMUNITY_TYPE_ENTANGLE);
            eSlow = EffectImmunity(IMMUNITY_TYPE_SLOW);
            eMove = EffectImmunity(IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE);
            //Link effects
            eEffect = EffectLinkEffects(eEffect, eParalysis);
            eEffect = EffectLinkEffects(eEffect, eEntangle);
            eEffect = EffectLinkEffects(eEffect, eSlow);
            eEffect = EffectLinkEffects(eEffect, eMove);
            eEffect = EffectLinkEffects (eEffect, eHaste);
            ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
            bHaste = TRUE;
        }
        // Regeneration +1 per hit upto 5.
        else if(nRoll < 21 && nRegen < 5) nRegen ++;
        // Spell Resistance  10 + 2 per hit up to 20.
        else if(nRoll < 31 && nSpellResist < 20) nSpellResist = nSpellResist + 2;
        // Conceal 20% if hit twice then 50%
        else if(nRoll < 41 && nConceal < 49)
        {
            if(nConceal == 0) nConceal = 20;
            else nConceal = 50;
        }
        // x4 Hitpoints.
        else if(nRoll < 71 && nHp < 3) nHp = nHp + 2;
        // AC increase +1 per 2 levels.
        else if(nRoll < 81 && nAC < 3) nAC = nAC + (nLevel / 2);
        else if(nRoll < 91 && nToHit < 3) nToHit = nToHit + (nLevel / 2);
        // Extra damage
        else if(!bColdAura)
        {
            ExecuteScript ("NW_S1_AuraCold", oCreature);
            bColdAura = TRUE;
        }
        nNumOfPowers --;
    }
    // Give bonus hitpoints.
    int nHitpoints = GetMaxHitPoints (oCreature) * nHp;
    NWNX_Object_SetMaxHitPoints (oCreature, nHitpoints);
    DelayCommand (0.1f, SetCurrentHitPoints (oCreature, nHitpoints));
    // Give bonus AC.
    eEffect = EffectACIncrease (nAC);
    if (nHp > 2)
    {
        eHp = EffectVisualEffect (VFX_DUR_GLOBE_MINOR);
        eEffect = EffectLinkEffects (eHp, eEffect);
    }
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    // Give To hit bonus.
    eEffect = EffectAttackIncrease (nToHit);
    if (nToHit > 2)
    {
        eVisual = EffectVisualEffect (VFX_DUR_PROT_PREMONITION);
        eEffect = EffectLinkEffects (eVisual, eEffect);
    }
    ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    // Give concealment.
    if (nConceal > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_BLUR);
        eEffect = EffectConcealment (nConceal, MISS_CHANCE_TYPE_NORMAL);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
    // Give regeneration.
    if (nRegen > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_PROTECTION_EVIL_MAJOR);
        eEffect = EffectRegenerate (nRegen, 6.0f);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
    // Give spell resistance.
    if (nSpellResist > 0)
    {
        eVisual = EffectVisualEffect (VFX_DUR_MAGIC_RESISTANCE);
        int nCurrentSpellResist = GetSpellResistance (oCreature);
        if (nCurrentSpellResist == 0) nSpellResist = nSpellResist + 10;
        eEffect = EffectSpellResistanceIncrease (nSpellResist);
        eEffect = EffectLinkEffects (eVisual, eEffect);
        ApplyEffectToObject (DURATION_TYPE_PERMANENT, eEffect, oCreature);
    }
}
void WaitToJump (object oCreature, object oPlaceable)
{
    // if we have run this script more than 30 times then exit.
    int nCounter = GetLocalInt (oCreature, "Move_Count");
    //Debug ("0i_area", "937", "nCounter: " + IntToString (nCounter));
    if (nCounter < 30)
    {
        // Get the distance from the transition
        float fDistance = GetDistanceBetween (oCreature, oPlaceable);
        // if its more than 2.0 meters then wait.
        if (fDistance > 3.0f)
        {
            SetLocalInt (oCreature, "Move_Count", ++nCounter);
            DelayCommand (0.5f, WaitToJump (oCreature, oPlaceable));
        }
        // We are close enough so lets transition.
        else
        {
            string sTag = GetLocalString (oPlaceable, "0_TransitionTag");
            object oJumpObject = GetNearestObjectByTag(sTag, oCreature);
            JumpToObject(oJumpObject);
        }
    }
    else
    {
        DeleteLocalInt (oCreature, "Move_Count");
        DeleteMoveVariables (oCreature);
    }
}
void MoveBloodPortal(object oBloodPortal, object oArea)
{
    vector vPosition = Vector(15.0, 114.5, 5.0);
    float fFacing = GetFacing(oBloodPortal);
    location lLocation = Location(oArea, vPosition, fFacing);
    effect eVisual = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_EVIL, FALSE, 3.0);
    NWNX_Object_SetPosition(oBloodPortal, vPosition);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVisual, lLocation);
    SetObjectVisualTransform(oBloodPortal, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0);
}
void ClearDeathlessCastleArea(object oArea)
{
    if(NWNX_Area_GetNumberOfPlayersInArea(OBJECT_SELF) == 0) ClearArea(oArea, TRUE);
}
