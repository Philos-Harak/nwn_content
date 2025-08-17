/*
Key:
@ Not looked at.
X Coded for but needs testing.
* Coded, tested, and found to be working.
------------------------------------- BUGS -------------------------------------
X AI sometimes gets stuck with his actions during combat. For example, he
------------------------------------ ISSUES ------------------------------------
@ Taking off a spell item during combat will make the character attempt to use it but not be able too.
    see if we can remove the talent if the item is not usable due to being unequiped.
------------------------------- CAMPAIGN ISSUES --------------------------------
----------------------------- IDEAS / SUGGESTION -------------------------------
S AI using magic scrolls always succeeds? Should fail in different game difficulties.
S Check how AI deals with Epic spells.
S Have creature check better in melee vs ranged (AB, weapon value, feats).
S In the buffing phase (during combat before attacking enemies) make AI
  prioritize buff spells on self or allies based on duration:
  Long -> Medium -> Short. I found that AI sometimes casts short-duration
  (turn per level) buffs first and then 1-hour buffs. So ultimately, for example
  the Divine Power buff would expire before the AI able to engage the enemy
  while it is still casting 1-hour buffs on self or allies with Divine Power
  short term buff.
S Magic Vestment spell work on shield if armor is enchanted or would be better.
S Groups and leaders who control the group as one AI until the leader dies.
S Create a inject templates and powers to creatures. Maybe make them stand alone executables!
S Attempt to resurrect a player that is dead! :)
--------------------------------------------- Current Fixes/Additions ---------------------------------
@ Need to add spell feats to the talent system!
@ Make (PC)AI not run blindly over traps directly towards enemies if the trap is
  detected. [Now it checks for traps before moving towards an enemy.]
@ Make PCAI stop if it runs to pick up an item or chest and it detects a trap in
  its way towards the chest or item.
  [There is no event to help, maybe I can add a check before it is opened.]
@ Make AI avoid enemies who have active death armor, wounding wispers, elemental shield, or mestil's asid sheath.
@ Add killing blow checks to melee/ranged attackers.
@ Have Water elementals Drown check to see if nearby allies are also immune then go ahead and use the drown ability.
@ Plot giving NPC's in Infinite Dungeon still attacking.
@ Spell targeting should follow the rule of weakest/nearest.
@ Check out lense of detection and AI spaming conversation...
@ Add check for Knockdown to see if they can beat the Discipline check.
@ Ability to increase number of Summons.
@ Add option to allow player to pick the action when they see a trap on the floor. Follow, hold, etc.
@ Add ability to adjust the menu buttons sizes and widget sizes.
@ Check starting area where goblins fight dummies with attack weak targets on.
@ Moral checks spamming!!! Fix!
*** Henchman ideas/fixes ***
@ Add option to auto level up x levels from player.

