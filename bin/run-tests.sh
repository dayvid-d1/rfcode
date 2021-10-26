#!/usr/bin/bash

set -x
set -o nounset
set -o errexit

timestamp() {
	date +"%Y-%m-%d %T"
}
#Robot - Pabot Script
execute_script(){
    export AUTO_BROWSER="$1"
    ROBOT_REPORTS_FINAL_DIR="$2"

    mkdir -p ${ROBOT_REPORTS_FINAL_DIR}
    if [ $ROBOT_THREADS -eq 1 ]
    then
        echo "$(timestamp) Robot run"
        xvfb-run \
            --server-args="-screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_COLOUR_DEPTH} -ac" \
            robot \
            --outputDir $ROBOT_REPORTS_FINAL_DIR \
            ${ROBOT_OPTIONS} \
            $ROBOT_TESTS_DIR 
    else
        echo "$(timestamp) Pabot run"
        xvfb-run \
            --server-args="-screen 0 ${SCREEN_WIDTH}x${SCREEN_HEIGHT}x${SCREEN_COLOUR_DEPTH} -ac" \
            pabot \
            --processes $ROBOT_THREADS \
            ${PABOT_OPTIONS} \
            --outputDir $ROBOT_REPORTS_FINAL_DIR \
            ${ROBOT_OPTIONS} \
            $ROBOT_TESTS_DIR 
    fi
}

export HOME=${ROBOT_DIR}
    
echo "$(timestamp) Report Folder"
if [ -z "${ROBOT_TEST_RUN_ID}" ]; then
    ROBOT_TEST_RUN_ID=${CONTINENT}_${PLACE}_$(date '+%d-%m-%Y_%H-%M-%S')
    export ROBOT_REPORTS_FINAL_DIR="${ROBOT_REPORTS_DIR}/${ROBOT_TEST_RUN_ID}"
else
    REPORTS_DIR_HAS_TRAILING_SLASH=`echo ${ROBOT_REPORTS_DIR} | grep '/$'`

    if [ "${REPORTS_DIR_HAS_TRAILING_SLASH}" = 0 ]
    then
        export ROBOT_REPORTS_FINAL_DIR="${ROBOT_REPORTS_DIR}${ROBOT_TEST_RUN_ID}"
    else
        export ROBOT_REPORTS_FINAL_DIR="${ROBOT_REPORTS_DIR}/${ROBOT_TEST_RUN_ID}"
    fi  
fi

echo "$(timestamp) Allure report setup"
if [ $ALLURE_REPORT = true ]; then
    export ROBOT_ALLURE_DIR="${ROBOT_REPORTS_DIR}/allure"
    mkdir -p ${ROBOT_ALLURE_DIR}
    ROBOT_OPTIONS="${ROBOT_OPTIONS} --listener allure_robotframework;${ROBOT_ALLURE_DIR}"
fi

echo "$(timestamp) Cross Browser of Auto Browser"
if [ $CROSS_BROWSER = false ]
then
    execute_script "$AUTO_BROWSER" "$ROBOT_REPORTS_FINAL_DIR"
else
    execute_script "chromium" "$ROBOT_REPORTS_FINAL_DIR/chromium"
    execute_script "firefox" "$ROBOT_REPORTS_FINAL_DIR/firefox"
    execute_script "webkit" "$ROBOT_REPORTS_FINAL_DIR/webkit"
fi

ROBOT_EXIT_CODE=$?

if [ $ALLURE_REPORT = true ]
then
    cd ${ROBOT_REPORTS_DIR}
    allure serve ./allure/
fi

if [ ${AWS_UPLOAD_TO_S3} = true ]
then
    echo "Uploading report to AWS S3..."
    aws s3 sync $ROBOT_REPORTS_FINAL_DIR/ s3://${AWS_BUCKET_NAME}/robot-reports/
    echo "Reports have been successfully uploaded to AWS S3!"
fi

if [ ${ZIP_REPORT} = true ]
then
    echo "Zipping report..."
    cd ${ROBOT_REPORTS_FINAL_DIR}
    zip -r ${ROBOT_REPORTS_FINAL_DIR}.zip ./*
fi