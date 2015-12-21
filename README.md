Gems - iOS <img src="https://avatars3.githubusercontent.com/u/10553840?v=3&s=200" width="50" height="50" /> 
====================

###Compiling
1. clone all submodules
2. clone https://github.com/peter-iakovlev/MtProtoKit.git to the same directory as Telegram
3. comment out all config.h header imports
4. go to thirdparty/sqlcipher and run <./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC” \ LDFLAGS="-lcrypto”>
5. run make
6. move tools/config.h to same project dir

