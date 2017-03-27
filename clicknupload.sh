# Plowshare clicknupload.link module

MODULE_CLICKNUPLOAD_REGEXP_URL='https\?://\(www\.\)\?clicknupload\.link/'

MODULE_CLICKNUPLOAD_DOWNLOAD_RESUME=yes
MODULE_CLICKNUPLOAD_DOWNLOAD_FINAL_LINK_NEEDS_COOKIE=unused
MODULE_CLICKNUPLOAD_DOWNLOAD_SUCCESSIVE_INTERVAL=

MODULE_CLICKNUPLOAD_PROBE_OPTIONS=""

# Output a clicknupload file download URL
# $1: cookie file (unused here)
# $2: clicknupload url
# stdout: real file download link
clicknupload_download() {
    local -r COOKIE_FILE=$1
    local -r URL=$2
    local PAGE FILE_URL FILE_NAME URL_ID

    PAGE=$(curl -L "$URL") || return
    
    # File not Found?
    if match 'File Not Found' "$PAGE"; then
        return $ERR_LINK_DEAD
    fi
    
    # Extract URL-ID and Filename
    URL_ID=$(parse_form_input_by_name 'id' <<< "$PAGE")
    FILE_NAME=$(parse_form_input_by_name 'fname' <<< "$PAGE")
    
    # Extract direct download link
    PAGE=$(curl -L -d 'op=download2&referrer&rand' \
        -d "id=$URL_ID" \
        -d 'method_free="Free Download >>"' \
        "$URL") || return
    FILE_URL=$(parse_attr 'id="downloadbtn"' 'onClick' <<< "$PAGE") || return
    FILE_URL=$(parse '.' "window.open('\(.*\)');" <<< "$FILE_URL") || return
    log_debug "$FILE_URL"

    echo "$FILE_URL"
    echo "$FILE_NAME"
}
