#!/bin/bash

# 黑名单，不运行列表
nowork_array=(
    "android"
    "com.android.settings"
    "com.google.android.dialer"
    "com.google.android.apps.messaging"
    "com.oneplus.mms"
    "com.android.dialer"
    "com.android.settings"
)
# monkey时间
run_time_min=3

# 单个设备脚本生成
general(){
    serno="$1"
    fpath=~/Desktop/"$serno.sh"
    # echo "#!/bin/bash" >"$fpath"
    echo "解析设备[$serno]开始"
    adb -s $serno shell pm list package | while read line; do
        # 获取单行的pkg name
        pkg=$(echo "$line" | cut -d ":" -f2)
        # echo "pkg: $pkg"
        if [[ "${nowork_array[@]}"  =~ "${pkg}" ]]; then
           echo "包含. ${pkg} ，跳过."
        else
            echo "adb -s $serno shell CLASSPATH=/sdcard/monkeyq.jar:/sdcard/framework.jar:/sdcard/fastbot-thirdpart.jar exec app_process /system/bin com.android.commands.monkey.Monkey -p $pkg --agent reuseq --running-minutes 3 --throttle 200 -v -v" >>$fpath
            echo "adb -s $serno shell am force-stop $pkg" >>$fpath
            echo "adb -s $serno shell rm -rf /sdcard/fastbot*" >>$fpath
        fi

    done
    echo "解析设备[$serno]完毕"
    chmod -R 777 $fpath
}

# 支持多设备解析
fun() {
    ANDROID_SERIAL=`adb devices | grep -w 'device' | awk '{print $1}'`
    for serial in ${ANDROID_SERIAL[*]}
    do
        # 生成本地执行脚本
        general $serial
        chmod -R 777 *
        # push jar to sdcard and run
        adb -s $serial push framework.jar /sdcard/
        adb -s $serial push monkeyq.jar /sdcard/
        adb -s $serial push fastbot-thirdpart.jar /sdcard/
        adb -s $serial push libs/* /data/local/tmp/
        adb -s $serial shell chmod -R 777 /sdcard/*.jar
        adb -s $serial shell chmod -R 777 /data/local/tmp/
        adb -s $serial install -r test/ADBKeyBoard.apk
    done
}

fun
