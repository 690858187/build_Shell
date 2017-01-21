
###设置需要编译项目的方式
buildConfig="Release" #三种可选Release，Debug，自定义的AdHoc
echo "~~~~~~~~~~~~~~~~~~~编译项目的方式:${buildConfig}~~~~~~~~~~~~~~~~~~~"

###设置需要编译项目(或者打包)的证书(这个地方用单引号因为变量中有双引号)
CODE_SIGN_ID="iPhone Distribution: HUBEI CHUNHUI SCIENCE & TECHNOLOGY CO., LTD"
echo "~~~~~~~~~~~~~~~~~~~编译项目(或者打包)的证书:${CODE_SIGN_ID}~~~~~~~~~~~~~~~~~~~"

xcodebuild  -alltargets

###设置编译项目的target的姓名 为空默认编译项目第一个
targetName="qingchu"
echo "~~~~~~~~~~~~~~~~~~~编译项目的target:${targetName}~~~~~~~~~~~~~~~~~~~"
projectFile=`pwd` #项目所在目录的绝对路径

xcodebuild  -alltargets

###设置输出ipa包的绝对路径
IPAFile=~/Desktop/打包ipa
###设置编译包的绝对路径
CompileFile=~/Desktop/编译Compile

###################蒲公英相关配置##############################
pgyerUKey="9435e0c123de5c7999ccf348193532ef"
pgyerApiKey="57389c6cc8fd63555626429a7873b122"

##########################################################################################
##############################以下部分不需更改############################
##########################################################################################

echo "~~~~~~~~~~~~~~~~~~~开始编译~~~~~~~~~~~~~~~~~~~"
if [ -d "$IPAFile" ]; then
echo $IPAFile
echo "文件目录存在"
else
echo "文件目录不存在"
mkdir -pv $IPAFile
echo "创建${IPAFile}目录成功"
fi

if [ -d "$CompileFile" ]; then
echo $CompileFile
echo "文件目录存在"
else
echo "文件目录不存在"
mkdir -pv $CompileFile
echo "创建${CompileFile}目录成功"
fi

###############进入项目目录
cd $projectFile
rm -rf ./build
buildAppToDir=$CompileFile/build #编译打包完成后.app文件存放的目录

###############开始编译app  echo输出$CODE_SIGN_ID值应用双引号，用单引号原因是输出shell命令错误 SYMROOT=$buildAppToDir:导出编译包的路径
echo "xcodebuild -target ${targetName} CODE_SIGN_IDENTITY=${CODE_SIGN_ID} SYMROOT=$buildAppToDir"
xcodebuild -target ${targetName} CODE_SIGN_IDENTITY="${CODE_SIGN_ID}" SYMROOT=$buildAppToDir

#判断编译结果
if test $? -eq 0
then
echo "~~~~~~~~~~~~~~~~~~~编译成功~~~~~~~~~~~~~~~~~~~"
else
echo "~~~~~~~~~~~~~~~~~~~编译失败~~~~~~~~~~~~~~~~~~~"
exit 1
fi

###############开始打包成.ipa  date +%Y%m%d%H%M%S生成当前时间戳
ipaName=`echo $targetName$(date +%Y-%m-%d_%H:%M:%Ss)| tr "[:upper:]" "[:lower:]"` #将项目名转小写
findFolderName=`find . -name "$buildConfig-*" -type d |xargs basename` #查找目录
appDir=$buildAppToDir/$findFolderName  #app所在路径
echo "编译路径为:${appDir}"
echo "开始打包${targetName}成${targetName}.ipa....."
echo $appDir/$ipaName.ipa
### - v:源编译路径 -o 输出的ipa的路径
xcrun -sdk iphoneos PackageApplication -v $appDir$buildConfig-iphoneos/$targetName.app -o $IPAFile/$ipaName.ipa #将app打包成ipa

###############开始拷贝到目标下载目录
#检查文件是否存在
if [ -f "$IPAFile/$ipaName.ipa" ]
then
echo "打包$ipaName.ipa成功."
else
echo "打包$ipaName.ipa失败."
exit 1
fi
echo "~~~~~~~~~~~~~~~~~~~结束打包，处理成功~~~~~~~~~~~~~~~~~~~"
open $IPAFile
###上传到蒲公英
echo "~~~~~~~~~~~~~~~~~~~正在上传到蒲公英。。。。~~~~~~~~~~~~~~~~~~~"
cd $IPAFile
curl -F "file=@$IPAFile/$ipaName.ipa" -F "uKey=${pgyerUKey}" -F "_api_key=${pgyerApiKey}" http://www.pgyer.com/apiv1/app/upload  --output httpResult.txt
httpResult= echo cat /Users/zhuxiaoyan/Desktop/打包ipa/httpResult.txt
echo ${httpResult}
echo "upload success download 下载地址"

