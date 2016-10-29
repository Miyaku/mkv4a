#!/sbin/sh
# 
# /system/addon.d/ayo.sh
#
. /tmp/backuptool.functions

list_files() {
cat <<EOF
apdet-i
ayo.sh
M/ViPER4Android/ViPER4Android.apk
M/ViPER4Android/v4asdk-21.apk
M/lib/soundfx/libv4a.so
M/lib/libV4AJniUtils.so
su.d/50viper.sh
su.d/enforce.sh
V4AVi
EOF
}

case "$1" in
  backup)
    list_files | while read FILE DUMMY; do
      backup_file $S/$FILE
    done
  ;;
  restore)
    list_files | while read FILE REPLACEMENT; do
      R=""
      [ -n "$REPLACEMENT" ] && R="$S/$REPLACEMENT"
      [ -f "$C/$S/$FILE" ] && restore_file $S/$FILE $R
    done
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
	# Stub
  ;;
  post-restore)
    # Normal/vendor config locations
	CONFIG_FILE=/system/etc/audio_effects.conf
	VENDOR_CONFIG=/system/vendor/etc/audio_effects.conf

	# If vendor exists, patch it
	if [ -f $VENDOR_CONFIG ];
	then
		sed -i '/v4a_fx {/,/}/d' $VENDOR_CONFIG
		sed -i '/v4a_standard_fx {/,/}/d' $VENDOR_CONFIG
		# Add libary V4A
		sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a.so\n  }/g' $VENDOR_CONFIG
		# Add effect V4A
		sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CONFIG_FILE
	fi
	
	# Remove library & effect
	sed -i '/v4a_fx {/,/}/d' $CONFIG_FILE
	sed -i '/v4a_standard_fx {/,/}/d' $CONFIG_FILE
	
	# Add libary V4A
	sed -i 's/^libraries {/libraries {\n  v4a_fx {\n    path \/system\/lib\/soundfx\/libv4a.so\n  }/g' $CONFIG_FILE

	# Add effect V4A
	sed -i 's/^effects {/effects {\n  v4a_standard_fx {\n    library v4a_fx\n    uuid 41d3c987-e6cf-11e3-a88a-11aba5d5c51b\n  }/g' $CONFIG_FILE
	
	echo " " >> /system/build.prop
	echo "## ViPER4Android Ainstaller by Miya ##" >> /system/build.prop
	echo "lpa.decode=false" >> /system/build.prop
	echo "tunnel.decode=false" >> /system/build.prop
	echo "lpa.use-stagefright=false" >> /system/build.prop
	echo "tunnel.audiovideo.decode=false" >> /system/build.prop
	echo "lpa.releaselock=false" >> /system/build.prop
	echo "persist.sys.media.use-awesome=1" >> /system/build.prop
	echo "af.resampler.quality=255" >> /system/build.prop
	echo "persist.af.resampler.quality=255" >> /system/build.prop
	echo "persist.dev.pm.dyn_samplingrate=1" >> /system/build.prop
	echo "audio.deep_buffer.media=false" >> /system/build.prop
	echo "## End of Compatible V4A ##" >> /system/build.prop
	echo " " >> /system/build.prop
  ;;
esac
