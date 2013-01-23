#!/bin/bash
#vim: ts=4:et:sw=0:sts=-1

args=" --indent-level4 \
	  --no-space-after-function-call-names \
	  --case-indentation4 \
	  --braces-on-if-line \
	  --no-tabs \
	  --dont-break-procedure-type \
	  -T uses \
	  -T provides \
	  -T nx_uint8_t	\
	  -T message_t \
	  "

suffix=".ermahgerd_erndernt"
SIMPLE_BACKUP_SUFFIX=$suffix indent $args $@
find -name "*${suffix}" -delete
