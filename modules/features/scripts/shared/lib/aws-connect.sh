#!/usr/bin/env bash

source "$HOME/.dotfiles/scripts/shared/lib/common"

DEBUG=""
LIST=""
TEMPKEY_DIR="/tmp/.ssh"
TEMPKEY="$TEMPKEY_DIR/temp"
DEFAULT_USER="${EC2_USER:-$(whoami)}"
AWS_PROFILE="$(aws configure list-profiles --output text 2>&1 | head -n1 | xargs)"
export AWS_PROFILE

usage() {
  echo -n "$(basename "$0") [OPTIONS] <arguments>
  A script to ${TYPE^^} to AWS instances using SSM session manager

  Options:
     -d, --debug              Add debugging output from the AWS commands
     -h, --help               Display this help and exit

  Arguments:
     <name>                   Optional name of the instance to connect to. These are from tag:Name on the EC2 instance
                              If no name is passed, a list is provided to select from.
"
}

cleanup_old_keys() {
  rm -rf "$TEMPKEY_DIR"
}

generate_tmp_key() {
  mkdir -p "$TEMPKEY_DIR"
  ssh-keygen -t ed25519 -f "$TEMPKEY" -q -N ""
}

push_tmp_key() {
  instance_id="$1"
  user="$2"

  aws ec2-instance-connect send-ssh-public-key \
    ${DEBUG:+--debug} \
    --instance-id "$instance_id" \
    --instance-os-user "$user" \
    --ssh-public-key "file://$TEMPKEY.pub" >/dev/null
}

check_deps() {
  require_executable "jq"

  if [ "$1" -eq 0 ]; then
    require_executable "gum"
  fi
}

find_instances() {
  readarray -t INSTANCE_IDS < <(gum spin --title "Fetching SSM managed instances..." --show-output -- aws ssm describe-instance-information | jq --raw-output '.InstanceInformationList[].InstanceId' | paste -sd ',')
  # Remove any empty values from our array
  for i in "${!INSTANCE_IDS[@]}"; do [[ -z "${INSTANCE_IDS[i]}" ]] && unset "INSTANCE_IDS[i]"; done

  # Exit if array is empty
  if ((${#INSTANCE_IDS[@]} == 0)); then
    error "Couldn't find any SSM managed instances."
  fi

  INSTANCES=("$(gum spin --title "Fetching instance names..." --show-output -- aws ec2 describe-instances --filters Name=instance-id,Values="${INSTANCE_IDS[*]}" --query "Reservations[].Instances[].[InstanceId,Tags[?Key==\`Name\`]| [0].Value]")")
  # Remove any empty values from our array
  for i in "${!INSTANCES[@]}"; do [[ -z "${INSTANCES[i]}" ]] && unset "INSTANCES[i]"; done

  # Exit if array is empty
  ((${#INSTANCES[@]})) || error "Couldn't find any instance names from the SSM managed instances."

  echo "$INSTANCES" | jq --raw-output '.[][1]' | sort
}

choose_instance() {
  find_instances

  INSTANCE_NAME=$(echo "$INSTANCES" | jq --raw-output '.[][1]' | sort | gum filter --limit 1)
  if [ -z "$INSTANCE_NAME" ]; then
    exit 1
  fi

  INSTANCE_ID=$(echo "$INSTANCES" | jq --raw-output --arg NAME "$INSTANCE_NAME" '.[] | select(.[1]==$NAME) | .[0]')
  USER="$DEFAULT_USER"
}

parse_instance() {
  IFS='@' read -ra ADDR <<<"$1"
  if [ "${#ADDR[@]}" -eq 1 ]; then
    USER="$DEFAULT_USER"
    DEST="${ADDR[0]}"
  elif [ "${#ADDR[@]}" -eq 2 ]; then
    USER="${ADDR[0]}"
    DEST="${ADDR[1]}"
  fi

  IFS=':' read -ra DEST <<<"$DEST"
  INSTANCE_NAME="${DEST[0]}"
  instance_id_from_name
}

instance_id_from_name() {
  INSTANCE_ID="$(aws ssm describe-instance-information --filters Key=tag:Name,Values="$INSTANCE_NAME" | jq --raw-output 'try .InstanceInformationList[0].InstanceId')"

  if [ "$INSTANCE_ID" == "null" ]; then
    error "Could not find instance with name \`$INSTANCE_NAME\`"
  fi
}

while :; do
  flag=${1:-}

  case "$flag" in
  -d | --debug)
    DEBUG=true
    shift
    break
    ;;
  -h | -\? | --help)
    usage
    exit
    ;;
  -l | --list)
    LIST=true
    shift
    break
    ;;
  --) # Demarcates end of all options.
    shift
    break
    ;;
  *) # End of all options if nothing matches
    break
    ;;
  esac

  shift
done

if [ -n "$LIST" ]; then
  find_instances
  exit
fi

export SSH_OPTS=(
  ${DEBUG:+-v}
  -F none
  -o IdentitiesOnly=yes
  -o UserKnownHostsFile=/dev/null
  -o StrictHostKeyChecking=no
  -o ProxyCommand="sh -c \"aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'\""
  -i "$TEMPKEY"
)
