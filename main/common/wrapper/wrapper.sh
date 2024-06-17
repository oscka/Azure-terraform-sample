#!/bin/bash
BACKEND_CONF="backend.conf"
VAR_FILE="global.tfvars"

find_from_main() {
    local file_to_find=$1
    local current_dir=$(pwd)

    # main 디렉토리로 이동
    while [[ "$current_dir" != "/" ]]; do
        if [[ "$current_dir" =~ /main$ ]]; then
            break
        fi
        current_dir=$(dirname "$current_dir")
    done

    # main 디렉토리에서 파일 찾기 시작
    if [[ "$current_dir" =~ /main$ ]]; then
        local found=$(find "$current_dir" -type f -name "$file_to_find" -print -quit)
        if [[ -n "$found" ]]; then
            echo "$found"
            return 0
        fi
    fi

    return 1
}

# Terraform 명령어 래핑 스크립트
case "$1" in
  init)
    # init 명령어에 -backend-config 옵션 추가
    BACKEND_CONFIG_PATH=$(find_from_main "$BACKEND_CONF")
    if [ -n "$BACKEND_CONFIG_PATH" ] && [ -f "$BACKEND_CONFIG_PATH" ]; then
        command terraform init -backend-config="$BACKEND_CONFIG_PATH" "${@:2}"
    else
        command terraform init "${@:2}"
    fi
    ;;
  plan|apply|destroy|refresh|import)
    # 기타 명령어에 -var-file 옵션 추가
    VAR_FILE_PATH=$(find_from_main "$VAR_FILE")
    if [ -n "$VAR_FILE_PATH" ] && [ -f "$VAR_FILE_PATH" ]; then
        command terraform "$1" -var-file="$VAR_FILE_PATH" "${@:2}"
    else
        command terraform "$1" "${@:2}"
    fi
    ;;
  *)
    command terraform "$@"
    ;;
esac
echo "wrapper running"


# 상위 디렉토리로 올라가면서 파일 검색 함수
# find_upwards() {
#     local file_to_find=$1
#     local max_levels=$2
#     local current_dir=$(pwd)
#     local level=0

#     while [ $level -lt $max_levels ]; do
#         # 현재 디렉토리와 모든 하위 디렉토리에서 파일 검색
#         local found=$(find "$current_dir" -type f -name "$file_to_find" -print -quit)
#         if [ -n "$found" ]; then
#             echo "$found"
#             return 0
#         fi

#         current_dir=$(dirname "$current_dir")
#         if [ "$current_dir" == "/" ]; then
#             break
#         fi
#         level=$((level + 1))
#     done
#     return 1
# }


# BACKEND_CONF="backend.conf"
# VAR_FILE="global.tfvars"
# MAX_LEVELS=5

# # Terraform 명령어 래핑 스크립트
# case "$1" in
#   init)
#     # init 명령어에 -backend-config 옵션 추가
#     BACKEND_CONFIG_PATH=$(find_upwards "$BACKEND_CONF" "$MAX_LEVELS")
#     if [ -n "$BACKEND_CONFIG_PATH" ] && [ -f "$BACKEND_CONFIG_PATH" ]; then
#         command terraform init -backend-config="$BACKEND_CONFIG_PATH" "${@:2}"
#     else
#         command terraform init "${@:2}"
#     fi
#     ;;
#   plan|apply|destroy|refresh|import)
#     # 기타 명령어에 -var-file 옵션 추가
#     VAR_FILE_PATH=$(find_upwards "$VAR_FILE" "$MAX_LEVELS")
#     if [ -n "$VAR_FILE_PATH" ] && [ -f "$VAR_FILE_PATH" ]; then
#         command terraform "$1" -var-file="$VAR_FILE_PATH" "${@:2}"
#     else
#         command terraform "$1" "${@:2}"
#     fi
#     ;;
#   *)
#     command terraform "$@"
#     ;;
# esac
