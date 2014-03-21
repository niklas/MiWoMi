MiWoMi
======

A Toolset to migrate minecraft worlds from on modpack to another, written in Ruby.

Installation
============

1. get ruby (through http://rvm.io)
2. clone the repo
3. `cd` into the directory, accept the .rvmrv
4. `bundle`


How to convert your world
=========================

Motivation
----------

The main problem when switching to one modpack to another are the changed ids.
Stone may keep id:1, but ids of blocks/items introduced by mods are usually
re-arranged by the packer to avoid conflicts and make the mods work next to
each other.

This is fine until you want to switch to a new version or a total different
modpack altogether. Liguid Spice becomes talking matrasses - utter chaos!

But there is an open source tool out there call "mIDas
*Gold*":https://code.google.com/p/midas-gold/ that can change these ids.
Entering these translations manually is quiet cumbersome and keeps you from
playing minecraft with your friends.

But it accepts "patch files", which describe the translations. *MiWoMi* will
help you to create such a file you can feed to mIDas *Gold*.


Prerequisites
-------------

1. You need to have to install MiWoMi (dah) somewhere on your machine. I only tested this with linux, it should work with other Unices, too. There may be even a way to install Ruby on Windows, but this is out of the scope of this manual.
2. A world/server for each the old and the new modpack should be runnable and have NEI installed
3. You should have some knowledge about running scripts from the command line.
4. always keep a backup of your old world. Seriously. *Make a backup now*

Let's do it
-----------

1. Start the old modpack and log in
2. Press `ESC` and find the "Options" button of NEI.
3. create a dump of all the items and blocks.
   When dumping, the minecraft console tells you where to find the dump files. Good luck.
4. close minecraft
5. repeat steps 1-4 with a world of the new modpack. Create it if needed.
6. optional: move both dumps into an easily accessible directory, cwd is ok. We support old dot-terminated and new csv dumps.
7. run `bin/midas_diff -P OLD_DUMP NEW_DUMP`
8. When it cannot match an ID, you can run the command again (arrow up) and:
  a. drop it and convert it to air with `-d`
  b. give a hint for alternative names
  c. look into the old file and `-d` a whole range - usually the blocks of one modpack are close together
  d. if you can find the match manually, just `-d` it and edit the `.midas`
     file later. Consider describing how you found it, maybe we can enhance the
     heuristic to find it automatically in the future.
9. rinse
10. and repeat

It will fail on the first try. And on he second. And on the hundredth. Don't give up.

When it is done (aka 100%), there should be a funny named file with the
`.midas` extension in your current working directory. You can override that
name with `-o`.

472. optional: Look at the file with your favorite *pure* text editor (not Word\*, iWriter etc.). Check for hard errors. Report them to me with both your full dumps ("Issues" on the side).
473. Use this file in mIDas to convert your world. It's up to you to copy it over the temporary new modpack world you created above after or before you run the conversion, as long as your backup is present. You made a backup, right?

Example
-------

I tried to convert by yogcraft1.0 server to the DNSTechpack while developing this script. I ended with the following command:

```bash
bin/midas_diff Old.dump New.csv -P -d item.PipeLiquids,eloraam.redpower,tile.rp,tile.chickenChunkLoader,tile.MFFS,tile.rcBlockMachine,214,244,245,249,254,255,501,514,625,645,850,851,852,927,928,930,931,932,933,938,939,942,943,950,1050,1051,1052,1056,1057,1059,1060,1227,1228,1476,1478,1604,1608,1612,1613,1618,2007,2727,2728,2730,2851,2852,2853,5272,5273,5275-5279,item.handsaw,GreenSapphire,item.paintcan,item.rpSeedBag,item.woolcard,item.rc.dust,liquid.creosote.liquid,item.rc.liquid.steam -a rc.liquid/railcraft.fluid -a rc.parrt/railcraft.part -a rc/railcraft -d item.blankSoulShard,item.vileDust,item.corruptedEssence,item.corrupted,binnie.extrabees,11363-11404,item.liquidMilk,item.bioMass,item.propolis,forestry.arboriculture.items.ItemGermlingGE,19757-19765,20257-20263,25256-25305,27000-27005,27275,27526-27550,item.refinedIronDust,30085-30103,itemFuelCoalDus
```


Contribution
============

When you find an error, can describe a good way to find more/exacter matches or
have general advise, feel free to create an issue or even pull request.
