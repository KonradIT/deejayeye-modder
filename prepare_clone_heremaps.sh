#!/bin/bash
#
# Prepare the app for cloning before repacking it. This will allow to install
# several versions in parallel on the same device
#
# Changing the package name from dji.go.v4 to new name will have side effects.
# List of know side effects :
#
# Script Arguments :
#
# First arg  : directory of the "decompile-out" to be prepared
# Second arg : name of clone package e.g. dji.go.v5
#            : script has only been tested with package name of same length
#			 : (char count) as the original one (9 chars)
# Third arg  : Package label name
#
# More specifically, the following URL will automatically trigger generating
# an API key for the newpackagename packahe (replace in URL) matching testkey used for signing modded app
#
# example URL : !!! substitute newpackagename before using !!!
#
# e.g. command example :
#
# ./prepare_cloning.sh ijd.og.v5 decompile_out "IJD OG 4.1.14 modded"

chmod +x ./defog_strings_one_file.py

# Check if we are running an OSX or Linux system
if [ $(uname) = "Linux" ]
then
    SYSTEMTYPE=LINUX
    SED_CMD=sed
else
    SYSTEMTYPE=OSX
    OLD_LC_CTYPE=$LC_CTYPE
    # fix because OSX "tr" does not work on arbitrary chars without that environment variable set
    export LC_CTYPE=C
    SED_CMD=gsed
fi

apkver=`cat $1/apktool.yml | grep versionName: | awk '{print $2}'`

case $apkver in
    "4.1.15")
        ./defog_strings_one_file.py 2 "$1/smali_classes5/dji/pilot2/newlibrary/dshare/model/a\$a.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes5/dji/pilot2/scan/android/CaptureActivity\$11.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes2/com/dji/update/view/UpdateDialogActivity.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes3/dji/assets/b.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes4/dji/pilot/fpv/control/y.smali"
        ;;
    "4.1.22")
        ./defog_strings_one_file.py 2 "$1/smali_classes6/dji/pilot2/newlibrary/dshare/model/a\$a.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes6/dji/pilot2/scan/android/CaptureActivity\$7.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes2/com/dji/update/view/UpdateDialogActivity.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes3/dji/assets/b.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes5/dji/pilot/fpv/control/z.smali"
        ./defog_strings_one_file.py 2 "$1/smali_classes6/dji/pilot2/scan/BaseScanQrActivity\$1.smali"
        ;;
    *)
    ;;
esac

substitution_regex_packagename="s/dji.go.v4/$2/g"


newfbnumber=$(cat /dev/urandom | tr -dc '0-9' | fold -w 16 | head -n 1)
substitution_regex_facebook="s/FacebookContentProvider1820832821495825/FacebookContentProvider$newfbnumber/g"
new_package_label=$(echo "$3"|$SED_CMD -e 's/ /\\x20/g')
substitution_regex_label="s/DJI\x20GO\x204/$new_package_label/g"

#replace dji.go.v4 by new package name in all files
find $1 -type f -exec $SED_CMD -i $substitution_regex_packagename {} +

#Change specific parts in AndroidManifest.xml
#
#	Facebook provider number
#	Application Label
#

$SED_CMD -i '/\s*<permission android:name="dji.permission.broadcast"\sandroid:protectionLevel="signature"\/>/d' $1/AndroidManifest.xml
$SED_CMD -i $substitution_regex_facebook $1/AndroidManifest.xml
$SED_CMD -i $substitution_regex_label $1/AndroidManifest.xml

if [ $OSTYPE == OSX ]
then
	export LC_CTYPE=$OLD_LC_CTYPE
fi
