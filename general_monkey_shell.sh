#!/bin/bash

fun() {
    # 设备ID   adb devices 获取的
    serno="298d1844"
    fpath=~/Desktop/"$serno.sh"
    echo "#!/bin/bash" >"$fpath"
    echo "解析设备[$serno]开始"
    adb -s $serno shell pm list package | while read line; do
        # 获取单行的pkg name
        pkg=$(echo "$line" | cut -d ":" -f2)
#        echo "pkg: $pkg  "
        echo "adb -s $serno shell CLASSPATH=/sdcard/monkeyq.jar:/sdcard/framework.jar exec app_process /system/bin com.android.commands.monkey.Monkey -p $pkg --agent robot --running-minutes 3 --throttle 200 -v -v" >>$fpath
        echo "adb -s $serno shell am force-stop $pkg" >>$fpath
    done
    echo "解析设备[$serno]完毕"
    chmod -R 777 $fpath
}
fun
