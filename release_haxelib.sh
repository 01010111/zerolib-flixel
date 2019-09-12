#!/bin/sh
rm -f zerolib-flixel.zip
zip -r zerolib-flixel.zip zero *.md *.json *.hxml run.n
haxelib submit zerolib-flixel.zip $HAXELIB_PWD --always