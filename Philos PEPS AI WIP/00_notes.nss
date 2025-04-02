/*
Key:
* Not looked at, new.
X Looked at and coded for but needs testing.
@ Coded, tested, and found to be working.
------------------------------------- BUGS -------------------------------------
------------------------------------ ISSUES ------------------------------------
* Taking off a spell item during combat will make the character attempt to use it but not be able too.
    see if we can remove the talent if the item is not usable due to being unequiped.
* Put Healing Kits before healing potions in combat talent array (Rework?)
* Make sure spontaneous cure spells are cast after all healing spells and items.
------------------------------- CAMPAIGN ISSUES --------------------------------
----------------------------- IDEAS / SUGGESTION -------------------------------
* Check how AI deals with Epic spells.
* Have creature check better in melee vs ranged (AB, weapon value, feats).
* Adjust the range when the enemy will change from ranged to melee.
* Make (PC)AI not run blindly over traps directly towards enemies if the trap is
  detected. [Now it checks for traps before moving towards an enemy.]
* Have spontaneous curing happen after all cure spells, and items are used up.
  [Should be coded this way, need to test heavily.]
* If character has Heal skills, make him prioritise healing kits for healing
  instead of potions, to prevent attacks of opportunity from enemies.
  [Noted as a rework to make items seperate from spells?]
* Make PCAI stop if it runs to pick up an item or chest and it detects a trap in
  its way towards the chest or item.
  [There is no event to help, maybe I can add a check before it is opened.]
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
* Finish adding conversation AI changes to widget.
* Make AI avoid enemies who have active death armor, wounding wispers, elemental shield, or mestil's asic sheath.
