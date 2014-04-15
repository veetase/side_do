side_do -- a awesome tool to release game for sonkwo
=====================================================
## DESCRIPTION
**Side Do** is a simple command-line tool for making game seeds, uploading game seeds to remote servers and so on.  It does so safely and quietly, it's perfect for use with cron as a cron work.

By default, `Side Do` check all games nees to be release and pack them all one by one.  `Side Do` allow us specify the game id to just do with the exact game, Before this you can use **side_do list** to list all the game and pick a game_id to do with.

`Side Do` is also easy to configure either by yml file or command, this will be explained later.
Finally, `Side Do` allow you to extend it with ruby.


## Getting Started


----------
Install,
    
    gem install side_do

When you created a pre_release job on sonkwo admin web page.

        $ side_do pack
        # processing game 321...
        # successed
        # processing 123...
        # successed.
this will pack all games need to be released.

Perhaps you want some of them to be packed first, or you want do them both at same time, you can first pack the game by specify its id like this:

    $ side_do list
    # game_id       game_name       status
    # 123           game_1          to_be_packed
    # 321           game_2          to_be_packed

    $ side_do pack 321
    # processing game 321...
    # successed
    
    $ side_do pack 123 
    # processing game 123
    #successed

after packing games, you may want upload game seed to remote server.

    $ side_do upload 321 -r beijing

    this will upload the game to beijing remote server,if you omit the -r option, it will upload to all sonkwo download servers.
