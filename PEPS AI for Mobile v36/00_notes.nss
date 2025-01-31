/*
Key:
* Not looked at, new.
X Looked at and coded for but needs testing.
@ Coded, tested, and found to be working.
------------------------------------- BUGS -------------------------------------
X Potions of bless are being used 2 times consecutively in a row.
* AI sometimes gets stuck with his actions during combat. For example, he
  attacks an enemy and wants to heal or cast a spell, but these actions get
  stuck in a queue and are never utilized because of the looped attack action.
X Auto-healing after battle in most cases is not correct. The AI tends to flood
  with too many potions and spells, reaching 100% health but using too many
  unnecessary actions, leading to wasted spells or potions.
* Owl's Wisdom casting on fighter-type warriors (not beneficial).
X AI is afraid to use wands (probably other items too) if only 1 charge usage is left.
------------------------------------ ISSUES ------------------------------------
* Taking off a spell item during combat will make the character attempt to use it but not be able too.
    see if we can remove the talent if the item is not usable due to being unequiped.
* Check Meta magic spells (Extended etc) and see how they work in talent list.
* Put Healing Kits before healing potions in combat talent array (Rework?)
X Speed up target acquisition after a creature kills an enemy.
* Make sure spontaneous cure spells are cast after all healing spells and items.
* Summoning spells are still not being cast correctly, and the AI tries to cast
  them "on" enemies running towards them. (Regressed code to only cast near caster).
------------------------------- CAMPAIGN ISSUES --------------------------------
----------------------------- IDEAS / SUGGESTION -------------------------------
* Check how AI deals with Epic spells.
* Have creature check better in melee vs ranged (AB, weapon value, feats).
* Adjust the range when the enemy will change from ranged to melee.
X Make the AI cancel the Expertise feat during combat if the enemy is not directly
  attacking the character. [Now turns of expertise if not being attacked.]
* Make (PC)AI not run blindly over traps directly towards enemies if the trap is
  detected. [Now it checks for traps before moving towards an enemy.]
X If possible, make the AI determine the enemy class and if the enemy is not a
  spellcaster, do not buff allies or yourself with spells or elemental
  protection spells (elemental protection can be excluded if the enemy has
  elemental damage weapon).
  [Now it checks for casters and/or energy weapons from attackers.]
* Have spontaneous curing happen after all cure spells, and items are used up.
  [Should be coded this way, need to test heavily.]
* If character have Heal skills, make him prioritise healing kits for healing
  instead of potions, to prevent attacks of opportunity from enemies.
  [Noted as a rework to make items seperate from spells?]
* Make PCAI stop if it runs to pick up an item or chest and it detects a trap in
  its way towards the chest or item.
  [There is no event to help, maybe I can add a check before it is opened.]
X Turn Undead feat AI behaviour still not well utilized. AI uses as soon as
  conditions are met, which wasting feat for 1-2 zombie instead of waiting for
  more zombies to capture them all with turning them.
  [Increased the number of undead required to use to 4... needs a rework.]
* Invisibility potions/spells/items and invisibility-like spells such as
  Sanctuary, etc., should be cast as a defensive option during combat and only
  when things go bad, but not before rushing against enemies or during the
  buffing phase before engaging to enemies.
* In the buffing phase (during combat before attacking enemies) make AI
  prioritize buff spells on self or allies based on duration:
  Long -> Medium -> Short. I found that AI sometimes casts short-duration
  (turn per level) buffs first and then 1-hour buffs. So ultimately, for example
  the Divine Power buff would expire before the AI able to engage the enemy
  while it is still casting 1-hour buffs on self or allies with Divine Power
  short term buff.
* Add widget to increase/decrease looting range.
* Add widget to increase/decrease unlock range.
* Add widget to increase/decrease disarm traps range.
* Finish adding conversation AI changes to widget.
* Make other henchman use potions on allies as PC AI does?
* Make AI avoid enemies who have active death armor, wounding wispers, elemental shield, or mestil's asic sheath.
* Increase options for what type of loot should be picked up.
