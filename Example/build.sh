#!/bin/sh

HTTP_JOB_NAME="keyreply-ios"
SCHEMES_TO_BUILD=("KeyReply_Example")

CODE_SIGN_IDENTITY="iPhone Distribution: Originally US LLP"
PROVISIONING_PROFILE="Wildcard In-house Distribution"

####################################
#Check fastlane is installed
if ! gem spec fastlane > /dev/null 2>&1; then
  echo "Gem 'fastlane' is not installed! To install:"
  echo "sudo gem install fastlane"
  exit 1
fi

####################################
#install Provisioning Profile (simply copy it to designated folder with a uuid filename)
PROVISION_PROFILE_FILE="${HOME}/Wildcard_Inhouse_Distribution.mobileprovision"
PROV_UUID=`grep UUID -A1 -a ${PROVISION_PROFILE_FILE} | grep -io "[-A-Z0-9]\{36\}"`
echo "Provisioning Profile File: ${PROVISION_PROFILE_FILE}"
echo "Provisioning Profile UUID: ${PROV_UUID}"
cp ${PROVISION_PROFILE_FILE} ~/Library/MobileDevice/Provisioning\ Profiles/${PROV_UUID}.mobileprovision

####################################
#Available provisioning profiles
echo "== Available provisioning profiles"
/usr/bin/security find-identity -p codesigning -v

####################################
#Extract directory of current script
pushd `dirname $0` > /dev/null
SCRIPTPATH=`pwd -P`
popd > /dev/null
BUILD_DIR="${SCRIPTPATH}/build_dev/"

####################################
#Update & install pods
/usr/bin/gem install cocoapods --user-install
/usr/local/bin/pod repo update
/usr/local/bin/pod install

#Handle space character in filename
oIFS=$IFS
IFS=$'\n'

#delete all previous IPA files
rm -rf ${BUILD_DIR}
for i in `find . -name "*.ipa" -type f`; do
    rm -rf ${BUILD_DIR} "${i}"
done

IFS=$oIFS

####################################

for SCHEME in "${SCHEMES_TO_BUILD[@]}" 
do 

#Start of for-loop

	APPVERSION="$(agvtool vers -terse)"

	#delete previous builds folder
	rm -rf ${BUILD_DIR}

	#List all schemes
	#ARCHIVE_DIR="${BUILD_DIR}/${SCHEME}"
	#OUTPUT_DIR="${BUILD_DIR}/${SCHEME}"
	#/usr/local/bin/fastlane gym --export_method enterprise --scheme "${SCHEME}" --clean --build_path "${BUILD_DIR}" --archive_path "${ARCHIVE_PATH}" --output_directory "${OUTPUT_DIR}" --output_name "${SCHEME}.ipa" --codesigning_identity "${CODE_SIGN_IDENTITY}" --include_bitcode false --include_symbols false --export_options "export_options.plist" || echo "fastlane command failed"
	/usr/local/bin/fastlane gym --scheme "${SCHEME}" || echo "fastlane command failed"

	#Handle space character in filename
	oIFS=$IFS
	IFS=$'\n'

	########################################
	# Upload via HTTP
	SERVER_URL="http://by.originally.us/jenkins_post.php"
	for i in `find . -name "*.ipa" -type f`; do
	    echo "Uploading '${i}'"
	    curl -F "file=@${i}" \
	    -F "HTTP_JOB_NAME=${HTTP_JOB_NAME}" \
	    -F "HTTP_BUILD_NUMBER=${HTTP_BUILD_NUMBER}" \
	    ${SERVER_URL}
	done

	IFS=$oIFS

	echo "================================================================================"
	echo ""
	echo "Scheme: ${SCHEME}"
	echo "Version: ${APPVERSION}"
	echo "Provisioning: ${PROVISIONING_PROFILE}"
	echo "Code Signing: ${CODE_SIGN_IDENTITY}"
	echo ""
	echo "================================================================================"

#End of for-loop
done 
