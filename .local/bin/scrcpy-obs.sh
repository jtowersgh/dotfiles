#!/bin/bash
scrcpy \
	--max-fps 60 \
	--max-size 1280 \
	--video-bit-rate 10M \
	--video-codec=h265 \
	--turn-screen-off \
	--stay-awake
