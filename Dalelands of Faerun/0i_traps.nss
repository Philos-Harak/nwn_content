/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 Script Name: 0i_traps
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Include scripts for use with traps.
 Trap Types:
 0 - None
 1 - Random
 2 - Bludgeoning
 3 - Piercing
 4 - Slashing
 5 - Acid
 6 - Cold
 7 - Electrical
 8 - Fire
 9 - Magical
 10 - Negative
 11 - Positive
 12 - Sonic
 13 - Disease
 14 - Poison
 15 - Confusion
 16 - Sleep
 17 - Slow
 18 - Tangled
 19 - Spell
 0_Spell - spell number to be cast on victim. -1 will randomize the spell.
 0_CasterLevel - caster level to be used with the spell. 0 uses area level.
 ****** Only use with projectile spell traps *********
 Uses 0s_project_trap script.
 487 - Arrow trap
 488 - Bolt trap
 493 - Dart trap
 494 - Shuriken trap
 0_NumOfTargets - number of targets to be hit by the spell. 0 will randomize from 1 to 5.
 0_DmgDice - a string of the damage dice to be used. 1d6, 2d6, 1d6+5, etc. 0 will set it based on level.

*/////////////////////////////////////////////////////////////////////////////////////////////////////
#include "0i_s_message"

// Does the damage for the trap and checks for a special effects.
// oCreature is the character to take the trap.
// oTrap is the object the trap is on.
// nTrapType is the Type of trap it is.
// bAOE makes the trap do damage in an area instead of only on the creature.
void TriggerTrap (object oCreature, object oTrap, int nTrapType, int bAOE = FALSE);

// Get the caster for a projectile trap. This simply returns the nearest
// object to the target that has a tag matching the tag of the trigger.
object GetSpellTrapCaster (object oTarget, object oTrigger = OBJECT_SELF);

// Causes oCaster to fire a specified spell (SPELL_*) at oTarget.
void TriggerSpellTrap (int nSpell, object oCaster, object oTarget);

int GetRandomTrapSpell (int nLevel);

// Does the damage for the trap and checks for a special effects.
// oCreature is the character to take the trap.
// oTrap is the object the trap is on.
// nTrapType is the Type of trap it is.
// bAOE makes the trap do damage in an area instead of only on the creature.
void TriggerTrap (object oCreature, object oTrap, int nTrapType, int bAOE = FALSE)
{
   effect eImpVisual, eAOEVisual, eTrap;
   int nDamageType, bMagical, bGroundImpact = FALSE;
   int nLevel = GetLocalInt (oTrap, "0_Trap_Level");
   if (nLevel == 0) nLevel = GetLocalInt (GetArea (oTrap), "0_Area_Level") / TRAP_LVL_DIVISOR;
   // Limit the trap levels to 1 through 20.
   if (nLevel < MIN_AREA_LEVEL) nLevel = MIN_AREA_LEVEL;
   else if (nLevel > MAX_AREA_LEVEL) nLevel = MAX_AREA_LEVEL;
   // Turn off the trap since it has been triggered.
   SetTrapActive (oTrap, FALSE);
   SetTrapDetectable (oTrap, FALSE);
   // If there is not a trap type then randomize one.
   if (nTrapType == 1) nTrapType = Random (18) + 2;
   // Does this trap have a damage type i.e. Bludgeoning through Sonic?
   if (nTrapType > 1 && nTrapType < 13)
   {
      int nDmg, nAdjDmg, nDie, nNum, nRoll;
      effect eDamage;
      nRoll = d100();
      if (nRoll <= MINOR_TRAP_DAMAGE_CHANCE)
      {
        nNum = nLevel * MINOR_TRAP_NUM_OF_DMG_DIE;
        nDie = MINOR_TRAP_DAMAGE_DIE;
      }
      else if (nRoll <= AVERAGE_TRAP_DAMAGE_CHANCE)
      {
        nNum = nLevel * AVERAGE_TRAP_NUM_OF_DMG_DIE;
        nDie = AVERAGE_TRAP_DAMAGE_DIE;
      }
      else if (nRoll <= STRONG_TRAP_DAMAGE_CHANCE)
      {
        nNum = nLevel * STRONG_TRAP_NUM_OF_DMG_DIE;
        nDie = STRONG_TRAP_DAMAGE_DIE;
      }
      else if (nRoll <= DEADLY_TRAP_DAMAGE_CHANCE)
      {
        nNum = nLevel * DEADLY_TRAP_NUM_OF_DMG_DIE;
        nDie = DEADLY_TRAP_DAMAGE_DIE;
      }
      switch (nTrapType)
      {
          case 2 :
          {
            nDamageType = DAMAGE_TYPE_BLUDGEONING;
            eImpVisual = EffectVisualEffect (VFX_COM_BLOOD_REG_RED);
            bMagical = FALSE;
            break;
          }
          case 3 :
          {
            nDamageType = DAMAGE_TYPE_PIERCING;
            eImpVisual = EffectVisualEffect (VFX_IMP_SPIKE_TRAP);
            bGroundImpact = TRUE;
            bMagical = FALSE; break;
          }
          case 4 :
          {
            nDamageType = DAMAGE_TYPE_SLASHING;
            eImpVisual = EffectVisualEffect (VFX_COM_BLOOD_REG_RED);
            bMagical = FALSE; break;
          }
          case 5 :
          {
            nDamageType = DAMAGE_TYPE_ACID;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_ACID);
            bMagical = TRUE; break;
          }
          case 6 :
          {
            nDamageType = DAMAGE_TYPE_COLD;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_FROST);
            bMagical = TRUE; break;
          }
          case 7 :
          {
            nDamageType = DAMAGE_TYPE_ELECTRICAL;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_ELECTRICAL);
            bMagical = TRUE; break;
          }
          case 8 :
          {
            nDamageType = DAMAGE_TYPE_FIRE;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_FIRE);
            bMagical = TRUE; break;
          }
          case 9 :
          {
            nDamageType = DAMAGE_TYPE_MAGICAL;
            eImpVisual = EffectVisualEffect (VFX_IMP_MAGBLUE);
            bMagical = TRUE; break;
          }
          case 10 :
          {
            nDamageType = DAMAGE_TYPE_NEGATIVE;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_NEGATIVE);
            bMagical = TRUE; break;
          }
          case 11 :
          {
            nDamageType = DAMAGE_TYPE_POSITIVE;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_DIVINE);
            bMagical = TRUE; break;
          }
          case 12 :
          {
            nDamageType = DAMAGE_TYPE_SONIC;
            eImpVisual = EffectVisualEffect (VFX_COM_HIT_SONIC);
            bMagical = TRUE; break;
          }
      }
      // Now Calculate the damage.
      while (nNum > 0)
      {
         nDmg = nDmg + Random (nDie) + 1;
         nNum --;
      }
      // Define if the trap is magical or not.
      if (bMagical) MagicalEffect (eTrap);
      else ExtraordinaryEffect (eTrap);
      // If an area effect lets hit them all.
      if (bAOE)
      {
         float fDelay;
         // Get the area of effect visual effect.
         switch (nTrapType)
         {
            case 2 : { eAOEVisual = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30); fDelay = 0.2; break; }
            case 3 : { eAOEVisual = EffectVisualEffect (VFX_FNF_LOS_NORMAL_30); fDelay = 0.2; break; }
            case 4 : { eAOEVisual = EffectVisualEffect (VFX_FNF_SWINGING_BLADE); fDelay = 0.5; break; }
            case 5 : { eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_NATURE); fDelay = 0.5; break; }
            case 6 : { eAOEVisual = EffectVisualEffect (VFX_FNF_ICESTORM); fDelay = 1.0; break; }
            case 7 : { eAOEVisual = EffectVisualEffect (VFX_FNF_ELECTRIC_EXPLOSION); fDelay = 0.5; break; }
            case 8 : { eAOEVisual = EffectVisualEffect (VFX_FNF_FIREBALL); fDelay = 0.5; break; }
            case 9 : { eAOEVisual = EffectVisualEffect (VFX_FNF_MYSTICAL_EXPLOSION); fDelay = 0.5; break; }
            case 10 : { eAOEVisual = EffectVisualEffect (VFX_FNF_LOS_EVIL_30); fDelay = 0.5; break; }
            case 11 : { eAOEVisual = EffectVisualEffect (VFX_FNF_LOS_HOLY_30); fDelay = 0.5; break; }
            case 12 : { eAOEVisual = EffectVisualEffect (VFX_FNF_SOUND_BURST); fDelay = 1.0; break; }
         }
         // Get the point of the effect.
         location lLocation = GetLocation (oTrap);
         // Place the area effect.
         ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eAOEVisual, lLocation);
         // Now run through all the victims.
         object oTarget = GetFirstObjectInShape (SHAPE_SPHERE, TRAP_RADIUS, lLocation, TRUE);
         while (oTarget != OBJECT_INVALID)
         {
            // Return Damage to normal for each new character by using iNum.
            // The main target takes full damage.
            if (oTarget == oCreature) nAdjDmg = GetReflexAdjustedDamage (nDmg, oTarget, TRAP_BASE_SAVE + d8() + nLevel, SAVING_THROW_TYPE_TRAP);
            // Other targets take half damage and get a +2 bonus to save.
            else nAdjDmg = GetReflexAdjustedDamage (nDmg / 2, oTarget, TRAP_BASE_SAVE - 2 + d8() + nLevel, SAVING_THROW_TYPE_TRAP);
            // Create the effect and apply.
            eDamage = EffectDamage (nAdjDmg, nDamageType);
            if (bGroundImpact)
            {
                DelayCommand (fDelay, AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, oTarget)));
                DelayCommand (fDelay, ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpVisual, GetLocation (oTarget)));
            }
            else
            {
                eTrap = EffectLinkEffects (eImpVisual, eDamage);
                DelayCommand (fDelay, AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eTrap, oTarget)));
            }
            oTarget = GetNextObjectInShape (SHAPE_SPHERE, TRAP_RADIUS, lLocation, TRUE);
         }
      }
      else
      {
         //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
         nAdjDmg = GetReflexAdjustedDamage(nDmg, oCreature, TRAP_BASE_SAVE + d8() + nLevel, SAVING_THROW_TYPE_TRAP);
         // Create the effect and apply.
         eDamage = EffectDamage (nAdjDmg, nDamageType);
         if (bGroundImpact)
         {
             AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eDamage, oCreature));
             ApplyEffectAtLocation (DURATION_TYPE_INSTANT, eImpVisual, GetLocation (oCreature));
         }
         else
         {
             eTrap = EffectLinkEffects (eImpVisual, eDamage);
             AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eTrap, oCreature));
         }
      }
   }
   // Do special effect traps.
   else
   {
      // Disease and poison must be a permanent effect, all others are temporary.
      int nDisease, nPoison, nRoll;
      int bPermanent = FALSE, nSaveType = SAVING_THROW_WILL, nSave = 0;
      float fDuration;
      string sMessage;
      switch (nTrapType)
      {
          // Now lets select the type of special effect to hit them with.
          case 13 : // Disease.
          {
              // Randomize the Disease.
              nRoll = Random (6) + 1;
              if (nRoll == 6)
              {
                  if (nLevel > 5)
                  {
                      nRoll = Random (5) + 6; // 6 to 10;
                      if (nRoll == 10)
                      {
                          if (nLevel > 10)
                          {
                              nRoll = Random (5) + 10; // 10 to 14;
                              if (nLevel > 15) nRoll = Random (3) + 14; // 14 to 16
                          }
                      }
                  }
              }
              switch (nRoll)
              {
                  case 1 : nDisease = DISEASE_MINDFIRE; break;           // DC 12 - Int d4.
                  case 2 : nDisease = DISEASE_FILTH_FEVER; break;        // DC 12 - Con d3, Int d3.
                  case 3 : nDisease = DISEASE_VERMIN_MADNESS; break;     // DC 13 - Int 1 - Wis 1 - Cha 1.
                  case 4 : nDisease = DISEASE_SHAKES; break;             // DC 13 - Str d6.
                  case 5 : nDisease = DISEASE_DREAD_BLISTERS; break;     // DC 13 - Cha d4 - Con d4.
                  case 6 : nDisease = DISEASE_DEVIL_CHILLS; break;       // DC 14 - Str d4.
                  case 7 : nDisease = DISEASE_SLIMY_DOOM; break;         // DC 14 - Dex d4.
                  case 8 : nDisease = DISEASE_RED_ACHE; break;           // DC 15 - Str d6.
                  case 9 : nDisease = DISEASE_ZOMBIE_CREEP; break;       // DC 15 - Dex d4 - Con d4.
                  case 10 : nDisease = DISEASE_CACKLE_FEVER; break;      // DC 16 - Wis d6.
                  case 11 : nDisease = DISEASE_BLINDING_SICKNESS; break; // DC 16 - Str d4, 24hr 40% blind.
                  case 12 : nDisease = DISEASE_BURROW_MAGGOTS; break;    // DC 17 - Int d4 - Wis d4.
                  case 13 : nDisease = DISEASE_GHOUL_ROT; break;         // DC 18 - Con d6 - Str d6.
                  case 14 : nDisease = DISEASE_MUMMY_ROT; break;         // DC 20 - Con d6.
                  case 15 : nDisease = DISEASE_DEMON_FEVER; break;       // DC 18 - Con d6, Fort DC 18 Perm Con 1.
                  case 16 : nDisease = DISEASE_SOLDIER_SHAKES; break;    // DC 25 - Random Ability score lowered permanently by one!
                  //case 17 : nDisease = DISEASE_RED_SLAAD_EGGS; break;    // DC 17 - Dex 2d6 - Str 2d6 - Con 2d6 Creates a Red Slad.
              }
              eImpVisual = EffectVisualEffect (VFX_IMP_DISEASE_S);
              eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_EVIL);
              eTrap = EffectDisease (nDisease);
              sMessage = "You have been diseased!";
              nSaveType = -1;
              bPermanent = TRUE;
              bMagical = FALSE;
              break;
          }
          case 14 : // Poison.
          {
              // Randomize a poison!
              nRoll = Random (10) + 1;
              if (nRoll == 10)
              {
                  if (nLevel > 5)
                  {
                      nRoll = Random (11) + 10; // 10 to 20;
                      if (nRoll == 10)
                      {
                          if (nLevel > 10)
                          {
                              nRoll = Random (11) + 20; // 20 to 30;
                              if (nLevel > 15) nRoll = Random (15) + 30; // 30 to 44
                          }
                      }
                  }
              }
              switch (nRoll)
              {
                  case 1 : nPoison = POISON_NIGHTSHADE; break;                  // DC 10 :Dex 1/Dex d2.
                  case 2 : nPoison = POISON_TINY_SPIDER_VENOM; break;           // DC 11 :Str d2/Str d2.
                  case 3 : nPoison = POISON_SMALL_CENTIPEDE_POISON; break;      // DC 11 :Dex d2/Dex d2.
                  case 4 : nPoison = POISON_SMALL_SPIDER_VENOM; break;          // DC 11 :Str d3/Str d3.
                  case 5 : nPoison = POISON_STRIPED_TOADSTOOL; break;           // DC 11 :Wis 1/Wis 2d6.
                  case 6 : nPoison = POISON_BLACK_ADDER_VENOM; break;           // DC 12 :-/Str d6.
                  case 7 : nPoison = POISON_BLOODROOT; break;                   // DC 12 :Wis d3/Con d4.
                  case 8 : nPoison = POISON_QUASIT_VENOM; break;                // DC 13 :Dex d4/Dex 2d4.
                  case 9 : nPoison = POISON_ETTERCAP_VENOM; break;              // DC 13 :Dex d6/Dex 2d4.
                  case 10 : nPoison = POISON_ARANEA_VENOM; break;               // DC 13 :Str d6 /Str 2d6.
                  case 11 : nPoison = POISON_GREENBLOOD_OIL; break;             // DC 13 :Con 1/Con d2.
                  case 12 : nPoison = POISON_CARRION_CRAWLER_BRAIN_JUICE; break;// DC 13 :Paralyze/-
                  case 13 : nPoison = POISON_ARSENIC; break;                    // DC 13 :Con 1/Con 2d8.
                  case 14 : nPoison = POISON_NITHARIT; break;                   // DC 13 :-/Con 3d6.
                  case 15 : nPoison = POISON_ID_MOSS; break;                    // DC 14 :Int d4/Int 2d6.
                  case 16 : nPoison = POISON_MEDIUM_SPIDER_VENOM; break;        // DC 14 :Str d4/Str d4.
                  case 17 : nPoison = POISON_BLUE_WHINNIS; break;               // DC 14 :Con 1/Sleep.
                  case 18 : nPoison = POISON_UNGOL_DUST; break;                 // DC 15 :Cha 1/Cha d6.
                  case 19 : nPoison = POISON_CHAOS_MIST; break;                 // DC 15 :Wis d4/Wis 2d6.
                  case 20 : nPoison = POISON_BLADE_BANE; break;                 // DC 15 :Str d4/Con d2.
                  case 21 : nPoison = POISON_OIL_OF_TAGGIT; break;              // DC 15 :-/Sleep.
                  case 22 : nPoison = POISON_PHASE_SPIDER_VENOM; break;         // DC 15 :Con 2d6/Con 2d6.
                  case 23 : nPoison = POISON_MALYSS_ROOT_PASTE; break;          // DC 16 :Dex 1/Dex 2d4.
                  case 24 : nPoison = POISON_TERINAV_ROOT; break;               // DC 16 :Dex d6/Dex 2d6.
                  case 25 : nPoison = POISON_SASSONE_LEAF_RESIDUE; break;       // DC 16 :Acid 2d12/Con d6.
                  case 26 : nPoison = POISON_LARGE_SPIDER_VENOM; break;         // DC 16 :Str d6/Str d6.
                  case 27 : nPoison = POISON_SHADOW_ESSENCE; break;             // DC 17 :Str 1/Str 2d6.
                  case 28 : nPoison = POISON_LICH_DUST; break;                  // DC 17 :Str 2d6/Str d6.
                  case 29 : nPoison = POISON_WYVERN_POISON; break;              // DC 17 :Con 2d6/Con 2d6.
                  case 30 : nPoison = POISON_IRON_GOLEM; break;                 // DC 17 :Con d4/Death.
                  case 31 : nPoison = POISON_GIANT_WASP_POISON; break;          // DC 18 :Dex d6/Dex d6.
                  case 32 : nPoison = POISON_LARGE_SCORPION_VENOM; break;       // DC 18 :Str d6/Str d6.
                  case 33 : nPoison = POISON_DARK_REAVER_POWDER; break;         // DC 18 :Con 2d6/Con 2d6.
                  case 34 : nPoison = POISON_BURNT_OTHUR_FUMES; break;          // DC 18 :Con 1P/Con 3d6.
                  case 35 : nPoison = POISON_DEATHBLADE; break;                 // DC 20 :Con d6/Con 2d6.
                  case 36 : nPoison = POISON_BEBILITH_VENOM; break;             // DC 20 :Con d6/Con 2d6.
                  case 37 : nPoison = POISON_BLACK_LOTUS_EXTRACT; break;        // DC 20 :Con 3d6/Con 3d6.
                  case 38 : nPoison = POISON_PIT_FIEND_ICHOR; break;            // DC 21 :Con 3d6/Death.
                  case 39 : nPoison = POISON_HUGE_SPIDER_VENOM; break;          // DC 22 :Str d8/Str 2d8.
                  case 40 : nPoison = POISON_PURPLE_WORM_POISON; break;         // DC 24 :Str d6/Str d6.
                  case 41 : nPoison = POISON_DRAGON_BILE; break;                // DC 26 :Str 3d6/-.
                  case 42 : nPoison = POISON_WRAITH_SPIDER_VENOM; break;        // DC 26 :Con d6/Str 2d6.
                  case 43 : nPoison = POISON_GARGANTUAN_SPIDER_VENOM; break;    // DC 31 :Str 2d6/Str 2d6.
                  case 44 : nPoison = POISON_COLOSSAL_SPIDER_VENOM; break;      // DC 35 :Str Str 2d8/Str 2d8.
              }
              eImpVisual = EffectVisualEffect (VFX_IMP_POISON_S);
              eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_GREASE);
              eTrap = EffectPoison (nPoison);
              sMessage = "You have been poisoned!";
              nSaveType = -1;
              bPermanent = TRUE;
              bMagical = FALSE;
              break;
          }
          case 15 : // Confusion.
          {
              eImpVisual = EffectVisualEffect (VFX_IMP_HEAD_MIND);
              eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_MIND);
              eTrap = EffectConfused ();
              sMessage = "You have been confused!";
              nSaveType = SAVING_THROW_WILL;
              bMagical = TRUE;
              break;
          }
          case 16 : // Sleep.
          {
              eImpVisual = EffectVisualEffect (VFX_IMP_SLEEP);
              eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_MIND);
              eTrap = EffectSleep ();
              sMessage = "You have been put to sleep!";
              nSaveType = SAVING_THROW_WILL;
              bMagical = TRUE;
              break;
          }
          case 17 : // Slow.
          {
              eImpVisual = EffectVisualEffect (VFX_IMP_SLOW);
              eAOEVisual = EffectVisualEffect (VFX_FNF_GAS_EXPLOSION_NATURE);
              eTrap = EffectSlow ();
              sMessage = "You have been slowed!";
              nSaveType = SAVING_THROW_WILL;
              bMagical = TRUE;
              break;
          }
          case 18 : // Entangle
          {
              eImpVisual = EffectVisualEffect (VFX_DUR_ENTANGLE);
              eAOEVisual = EffectVisualEffect (SPELL_ENTANGLE);
              eTrap = EffectEntangle ();
              sMessage = "You have been entangled!";
              nSaveType = SAVING_THROW_REFLEX;
              bMagical = TRUE;
              break;
          }
          case 19 : // Spell
          {
             // Get the casting placeable of the spell.
              object oCaster = GetSpellTrapCaster (oCreature, OBJECT_SELF);
              int nSpell = GetLocalInt (oCaster, "0_Spell");
              TriggerSpellTrap (nSpell, oCaster, oCreature);
              return;
          }
       }
       // Define if the trap is magical or not.
       if (bMagical) MagicalEffect (eTrap);
       else ExtraordinaryEffect (eTrap);
       // Get the point of the effect.
       location lLocation = GetLocation (oTrap);
       // Place the area effect.
       ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eAOEVisual, oTrap, 24.0f);
       // If an actual area effect lets hit them all.
       if (bAOE)
       {
           // Now run through all the victims.
           object oTarget = GetFirstObjectInShape (SHAPE_SPHERE, TRAP_RADIUS, lLocation, TRUE);
           while (GetIsObjectValid (oTarget))
           {
               // Make save if appropriate.
               switch (nSaveType)
               {
                   case SAVING_THROW_FORT: { nSave = FortitudeSave (oTarget , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
                   case SAVING_THROW_REFLEX: { nSave = ReflexSave (oTarget , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
                   case SAVING_THROW_WILL: { nSave = WillSave (oTarget , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
                   default : { nSave = FALSE; break; }
               }
               if (!nSave)
               {
                   // Create the effect and apply.
                   SendMessages (sMessage, COLOR_RED, oCreature, FALSE, FALSE);
                   if (bPermanent)
                   {
                       AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_PERMANENT, eTrap, oTarget));
                       AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpVisual, oTarget));
                   }
                   else
                   {
                       fDuration = IntToFloat (d8 (nLevel) + (nLevel * 2));
                       eTrap = EffectLinkEffects (eTrap, eImpVisual);
                       AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eTrap, oTarget, fDuration));
                   }
               }
               oTarget = GetNextObjectInShape (SHAPE_SPHERE, TRAP_RADIUS, lLocation, TRUE);
           }
       }
       else
       {
           // Make save if appropriate.
           switch (nSaveType)
           {
               case SAVING_THROW_FORT: { nSave = FortitudeSave (oCreature , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
               case SAVING_THROW_REFLEX: { nSave = ReflexSave (oCreature , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
               case SAVING_THROW_WILL: { nSave = WillSave (oCreature , TRAP_BASE_SAVE + nLevel, SAVING_THROW_TYPE_TRAP); break; }
               default : { nSave = FALSE; break; }
           }
           if (!nSave)
           {
               SendMessages (sMessage, COLOR_RED, oCreature, FALSE, FALSE);
               if (bPermanent)
               {
                   AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_PERMANENT, eTrap, oCreature));
                   AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_INSTANT, eImpVisual, oCreature));
               }
               else
               {
                  fDuration = IntToFloat (d8 (nLevel) + (nLevel * 2));
                  eTrap = EffectLinkEffects (eTrap, eImpVisual);
                  AssignCommand (oTrap, ApplyEffectToObject (DURATION_TYPE_TEMPORARY, eTrap, oCreature, fDuration));
               }
           }
       }
   }
}

// Get the caster for a projectile trap. This simply returns the nearest
// object to the target that has a tag matching the tag of the trigger.
object GetSpellTrapCaster (object oTarget, object oTrigger = OBJECT_SELF)
{
    int nCheck = 1;
    string sTag = GetTag (oTrigger);
    object oCaster = GetNearestObjectByTag (sTag, oTarget);
    while (oCaster != OBJECT_INVALID && GetObjectType (oCaster) != OBJECT_TYPE_PLACEABLE)
    {
        nCheck++;
        oCaster = GetNearestObjectByTag (sTag, oTarget, nCheck);
    }
    if (oCaster == OBJECT_INVALID) oCaster = OBJECT_SELF;
    return oCaster;
}


// Causes oCaster to fire a specified spell (SPELL_*) at oTarget.
void TriggerSpellTrap (int nSpell, object oCaster, object oTarget)
{
    int nRoll;
    int nProjectilePath = PROJECTILE_PATH_TYPE_DEFAULT;
    // If no level selected check the area for level.
    int nLevel = GetLocalInt (oCaster, "0_CasterLevel");
    if (nLevel == 0) nLevel = GetLocalInt (GetArea (oCaster), "0_Area_Level");
    if (nLevel < 1) nLevel = 1;
    else if (nLevel > 40) nLevel = 40;
    // Save the caster level to the placeable to pass to the spell.
    SetLocalInt (oCaster, "0_CasterLevel", nLevel);
    // If random spell then check level and randomize spell.
    // 0 is Acid Fog so that spell cannot be on a trap!
    if (nSpell == 0) nSpell = GetRandomTrapSpell (nLevel);
    // Set ProjectilePath for specific spells.
    switch (nSpell)
    {
        case 487 : // Trap arrow
        case 488 : // Trap bolt
        case 493 : // Trap dart
        case 494 : // Trap shuriken
        {
            nProjectilePath = PROJECTILE_PATH_TYPE_HOMING;
            break;
        }
    }
    // Cast the spell at the target.
    AssignCommand (oCaster, ActionCastSpellAtObject (nSpell, oTarget, METAMAGIC_NONE, TRUE, 0, nProjectilePath, FALSE));
}

int GetRandomTrapSpell (int nLevel)
{
    int nRoll, nSpell;
        if (nLevel < 3)
        {
            nRoll = d12();
            if (nRoll == 1) nSpell = 37; // Daze
            else if (nRoll == 2) nSpell = 424; // Acid Splash
            else if (nRoll == 3) nSpell = 439; // Electric Jolt
            else if (nRoll == 4) nSpell = 46; // Doom
            else if (nRoll == 5) nSpell = 53; // Entangle
            else if (nRoll == 6) nSpell = 66; // Grease
            else if (nRoll == 7) nSpell = 107; // Magic Missle
            else if (nRoll == 8) nSpell = 155; // Scare
            else if (nRoll == 9) nSpell = 165; // Sleep
            else if (nRoll == 10) nSpell = 449; // Bane
            else if (nRoll == 11) nSpell = 521; // Horizikaul's Boom
            else nSpell = 543; // Ice Dagger
        }
        else if (nLevel < 5)
        {
            nRoll = d12();
            if (nRoll == 1) nSpell = 107; // Magic Missle
            else if (nRoll == 2) nSpell = 155; // Scare
            else if (nRoll == 3) nSpell = 165; // Sleep
            else if (nRoll == 4) nSpell = 449; // Bane
            else if (nRoll == 5) nSpell = 521; // Horizikaul's Boom
            else if (nRoll == 6) nSpell = 543; // Ice Dagger
            else if (nRoll == 7) nSpell = 8; // Blindness & Deafness
            else if (nRoll == 8) nSpell = 115; // Melf's Acid Arrow
            else if (nRoll == 9) nSpell = 163; // Silence
            else if (nRoll == 10) nSpell = 167; // Sound Burst
            else if (nRoll == 11) nSpell = 192; // Web
            else nSpell = 457; // Tasha's Hideous Laughter
        }
        else if (nLevel < 7)
        {
            nRoll = Random (17) + 1;
            if (nRoll == 1) nSpell = 8; // Blindness & Deafness
            else if (nRoll == 2) nSpell = 115; // Melf's Acid Arrow
            else if (nRoll == 3) nSpell = 163; // Silence
            else if (nRoll == 4) nSpell = 167; // Sound Burst
            else if (nRoll == 5) nSpell = 192; // Web
            else if (nRoll == 6) nSpell = 457; // Tasha's Hideous Laughter
            else if (nRoll == 7) nSpell = 4; // Bestow Curse
            else if (nRoll == 8) nSpell = 11; // Call Lightning
            else if (nRoll == 9) nSpell = 26; // Confusion
            else if (nRoll == 10) nSpell = 41; // Dispel Magic
            else if (nRoll == 11) nSpell = 54; // Fear
            else if (nRoll == 12) nSpell = 58; // Fireball
            else if (nRoll == 13) nSpell = 75; // Gust of Wind
            else if (nRoll == 14) nSpell = 166; // Slow
            else if (nRoll == 15) nSpell = 171; // Stinking Cloud
            else if (nRoll == 16) nSpell = 370; // Negative Energy Burst
            else nSpell = 454; // Spike Growth
        }
        else if (nLevel < 9)
        {
            nRoll = Random (17) + 1;
            if (nRoll == 1) nSpell = 4; // Bestow Curse
            else if (nRoll == 2) nSpell = 11; // Call Lightning
            else if (nRoll == 3) nSpell = 26; // Confusion
            else if (nRoll == 4) nSpell = 41; // Dispel Magic
            else if (nRoll == 5) nSpell = 54; // Fear
            else if (nRoll == 6) nSpell = 58; // Fireball
            else if (nRoll == 7) nSpell = 75; // Gust of Wind
            else if (nRoll == 8) nSpell = 166; // Slow
            else if (nRoll == 9) nSpell = 171; // Stinking Cloud
            else if (nRoll == 10) nSpell = 370; // Negative Energy Burst
            else if (nRoll == 11) nSpell = 454; // Spike Growth
            else if (nRoll == 12) nSpell = 52; // Enervation
            else if (nRoll == 13) nSpell = 61; // Flame Strike
            else if (nRoll == 14) nSpell = 82; // Hold Monster
            else if (nRoll == 15) nSpell = 127; // Phantasmal Killer
            else if (nRoll == 16) nSpell = 375; // Evard's Black Tentacles
            else nSpell = 447; // Isaac's Lesser Missle Storm
        }
        else if (nLevel < 11)
        {
            nRoll = Random (14) + 1;
            if (nRoll == 1) nSpell = 52; // Enervation
            else if (nRoll == 2) nSpell = 61; // Flame Strike
            else if (nRoll == 3) nSpell = 82; // Hold Monster
            else if (nRoll == 4) nSpell = 127; // Phantasmal Killer
            else if (nRoll == 5) nSpell = 375; // Evard's Black Tentacles
            else if (nRoll == 7) nSpell = 447; // Isaac's Lesser Missle Storm
            else if (nRoll == 8) nSpell = 19; // Circle of Doom
            else if (nRoll == 9) nSpell = 23; // Cloud Kill
            else if (nRoll == 10) nSpell = 55; // Feeblemind
            else if (nRoll == 11) nSpell = 67; // Greater Dispelling
            else if (nRoll == 12) nSpell = 446; // Inferno
            else if (nRoll == 13) nSpell = 459; // Bigby's Interposing Hand
            else nSpell = 516; // Ball of Lightning
        }
        else if (nLevel < 13)
        {
            nRoll = d12();
            if (nRoll == 1) nSpell = 19; // Circle of Doom
            else if (nRoll == 2) nSpell = 23; // Cloud Kill
            else if (nRoll == 3) nSpell = 55; // Feeblemind
            else if (nRoll == 4) nSpell = 67; // Greater Dispelling
            else if (nRoll == 5) nSpell = 446; // Inferno
            else if (nRoll == 6) nSpell = 459; // Bigby's Interposing Hand
            else if (nRoll == 7) nSpell = 516; // Ball of Lightning
            else if (nRoll == 8) nSpell = 0; // Acid Fog
            else if (nRoll == 9) nSpell = 5; // Blade Barrier
            else if (nRoll == 10) nSpell = 18; // Circle of Death
            else if (nRoll == 11) nSpell = 448; // Issac's Greater Missle Storm
            else nSpell = 460; // Bigby's Forceful hand
        }
        else if (nLevel < 15)
        {
            nRoll = Random (13) + 1;
            if (nRoll == 1) nSpell = 0; // Acid Fog
            else if (nRoll == 2) nSpell = 5; // Blade Barrier
            else if (nRoll == 3) nSpell = 18; // Circle of Death
            else if (nRoll == 4) nSpell = 448; // Issac's Greater Missle Storm
            else if (nRoll == 5) nSpell = 460; // Bigby's Forceful hand
            else if (nRoll == 6) nSpell = 39; // Delay Blast Fireball
            else if (nRoll == 7) nSpell = 56; // Finger of Death
            else if (nRoll == 8) nSpell = 123; // Mordenkainen's Sword
            else if (nRoll == 9) nSpell = 132; // Power word stun
            else if (nRoll == 10) nSpell = 364; // Creeping Doom
            else if (nRoll == 11) nSpell = 366; // Destruction
            else if (nRoll == 12) nSpell = 461; // Bigby's Grasping Hand
            else nSpell = 515; // Great Thunderclap

        }
        else if (nLevel < 17)
        {
            nRoll = Random (11) + 1;
            if (nRoll == 1) nSpell = 39; // Delay Blast Fireball
            else if (nRoll == 2) nSpell = 56; // Finger of Death
            else if (nRoll == 3) nSpell = 123; // Mordenkainen's Sword
            else if (nRoll == 4) nSpell = 132; // Power word stun
            else if (nRoll == 5) nSpell = 364; // Creeping Doom
            else if (nRoll == 6) nSpell = 366; // Destruction
            else if (nRoll == 7) nSpell = 461; // Bigby's Grasping Hand
            else if (nRoll == 8) nSpell = 515; // Great Thunderclap
            else if (nRoll == 9) nSpell = 89; // Incendiary Cloud
            else if (nRoll == 10) nSpell = 367; // Horrid Wilting
            else nSpell = 462; // Bigby's Clenching fist
        }
        else
        {
            nRoll = d6();
            if (nRoll == 1) nSpell = 89; // Incendiary Cloud
            else if (nRoll == 2) nSpell = 367; // Horrid Wilting
            else if (nRoll == 3) nSpell = 462; // Bigby's Clenching fist
            else if (nRoll == 4) nSpell = 51; // Energy Drain
            else if (nRoll == 5) nSpell = 87; // Implosion
            else if (nRoll == 6) nSpell = 116; // Meteor Swarm
            else if (nRoll == 7) nSpell = 122; // Mordenkainen's Disjunction
            else if (nRoll == 8) nSpell = 131; // Power word kill
            else if (nRoll == 9) nSpell = 173; // Storm of Vengeance
            else if (nRoll == 9) nSpell = 190; // Wail of the Banshee
            else if (nRoll == 9) nSpell = 193; // Weird
            else if (nRoll == 9) nSpell = 463; // Bigby's Crushing hand
        }
        return nSpell;
}
