#!/bin/bash
modeline='filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1'

for f in $(find -regextype posix-extended -regex '.*\.(h|nc)'); do
	sed -i "1d;2i //vim: ${modeline}" $f
done
