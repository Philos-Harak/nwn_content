/*//////////////////////////////////////////////////
 OnHit Firedamage
 x2_s3_flamgind
 Copyright (c) 2003 Bioware Corp.
 Adjusted by Philos - Add Enhancing components.
////////////////////////////////////////////////////
   OnHit Castspell Fire Damage property for the
   flaming weapon spell (x2_s0_flmeweap).

   We need to use this property because we can not
   add random elemental damage to a weapon in any
   other way and implementation should be as close
   as possible to the book.

   Behavior:
   The casterlevel is set as a variable on the
   weapon, so if players leave and rejoin, it
   is lost (and the script will just assume a
   minimal caster level).

   Now the spell can increase the damage as well
   as change the damage type.
////////////////////////////////////////////////////
 Created By: Georg Zoeller
 Created On: 2003-07-17
*///////////////////////////////////////////////////
void main()
{
  // Get Caster Level
  int nLevel = GetCasterLevel(OBJECT_SELF);
  // Assume minimum caster level if variable is not found
  if (nLevel== 0) nLevel =1;
  object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
  // Get the damage dice.
  int nDmg, nDice = GetLocalInt(oWeapon, "0_DMG_DICE");
  if(nDice == 4) nDmg = d4() + nLevel;
  else if(nDice == 6) nDmg = d6() + nLevel;
  else if(nDice == 8) nDmg = d8() + nLevel;
  else if(nDice == 10) nDmg = d10() + nLevel;
  else nDmg = d4() + nLevel;
  int nDamageType = GetLocalInt(oWeapon, "0_DMG_TYPE");
  if(nDamageType == 0) nDamageType = DAMAGE_TYPE_FIRE;
  effect eDmg = EffectDamage(nDmg,nDamageType);
  int nVisual;
  // if we are doing above 9 points of damage, use bigger effect.
  if(nDmg < 10)
  {
     if(nDamageType == DAMAGE_TYPE_ACID) nVisual = VFX_IMP_ACID_S;
     else if(nDamageType == DAMAGE_TYPE_COLD) nVisual = VFX_IMP_FROST_S;
     else if(nDamageType == DAMAGE_TYPE_ELECTRICAL) nVisual = VFX_IMP_LIGHTNING_S;
     else if(nDamageType == DAMAGE_TYPE_FIRE) nVisual = VFX_IMP_FLAME_S;
     else if(nDamageType == DAMAGE_TYPE_SONIC) nVisual = VFX_IMP_SONIC;
     else if(nDamageType == DAMAGE_TYPE_DIVINE) nVisual = VFX_IMP_MAGBLUE;
     else if(nDamageType == DAMAGE_TYPE_POSITIVE) nVisual = VFX_IMP_MAGBLUE;
     else if(nDamageType == DAMAGE_TYPE_NEGATIVE) nVisual = VFX_IMP_NEGATIVE_ENERGY;
     else if(nDamageType == DAMAGE_TYPE_MAGICAL) nVisual = VFX_IMP_MAGBLUE;
  }
  else
  {
     if(nDamageType == DAMAGE_TYPE_ACID) nVisual = VFX_IMP_ACID_L;
     else if(nDamageType == DAMAGE_TYPE_COLD) nVisual = VFX_IMP_FROST_L;
     else if(nDamageType == DAMAGE_TYPE_ELECTRICAL) nVisual = VFX_IMP_LIGHTNING_M;
     else if(nDamageType == DAMAGE_TYPE_FIRE) nVisual = VFX_IMP_FLAME_M;
     else if(nDamageType == DAMAGE_TYPE_SONIC) nVisual = VFX_IMP_SONIC;
     else if(nDamageType == DAMAGE_TYPE_DIVINE) nVisual = VFX_IMP_MAGBLUE;
     else if(nDamageType == DAMAGE_TYPE_POSITIVE) nVisual = VFX_IMP_MAGBLUE;
     else if(nDamageType == DAMAGE_TYPE_NEGATIVE) nVisual = VFX_IMP_NEGATIVE_ENERGY;
     else if(nDamageType == DAMAGE_TYPE_MAGICAL) nVisual = VFX_IMP_MAGBLUE;
  }
  effect eVisual = EffectVisualEffect(nVisual);
  eDmg = EffectLinkEffects(eVisual, eDmg);
  object oTarget = GetSpellTargetObject();
  if(GetIsObjectValid(oTarget)) ApplyEffectToObject(DURATION_TYPE_INSTANT, eDmg, oTarget);
}
