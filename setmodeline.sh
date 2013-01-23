#!/bin/bash
modeline='vim: filetype=nc:tabstop=4:expandtab:shiftwidth=0:softtabstop=-1'

for f in $(find -regextype posix-extended -regex '.*\.(h|nc)'); do
	sed -i "1d;2i // ${modeline}" $f
done
