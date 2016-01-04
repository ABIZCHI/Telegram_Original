{\rtf1\ansi\ansicpg1252\cocoartf1404\cocoasubrtf340
{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
\paperw11900\paperh16840\margl1440\margr1440\vieww10800\viewh8400\viewkind0
\pard\tx566\tx1133\tx1700\tx2267\tx2834\tx3401\tx3968\tx4535\tx5102\tx5669\tx6236\tx6803\pardirnatural\partightenfactor0

\f0\fs24 \cf0 Gems - iOS <img src="https://avatars3.githubusercontent.com/u/10553840?v=3&s=200" width="50" height="50" /> \
====================\
\
###Compiling\
1. clone all submodules\
2. clone https://github.com/peter-iakovlev/MtProtoKit.git to the same directory as Telegram\
3. comment out all config.h header imports\
4. go to thirdparty/sqlcipher and run <./configure --enable-tempstore=yes CFLAGS="-DSQLITE_HAS_CODEC\'94 \\ LDFLAGS="-lcrypto\'94>\
5. run make\
6. move tools/config.h to same project dir\
\
}