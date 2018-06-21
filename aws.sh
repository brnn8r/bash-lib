svr="$(which svr)"

if [[ ! -x $svr ]]; then
    return
fi

export cRESET="\e[0m";
export cCYAN="\e[0;36m";

function list_instances ()
{
  function _describe_instances() {
    profile=$1
    region=$2
    aws ec2 describe-instances --profile $profile --region $region | jq -r '.Reservations[].Instances[] | {
      "LaunchTime": .LaunchTime,
      "InstanceId": .InstanceId,
      "Type": .InstanceType,
      "PublicDNS": .PublicDnsName,
      "PublicIP": .NetworkInterfaces[].Association.PublicIp,
      "KeyName": .KeyName,
      "State": .State.Name,
      "Tags": .Tags | (if (.!=null) then . else [] end) | from_entries
    }'
  }

  profile="${1:-i}"
  echo -e $cCYAN"Listing instances for profile:'$profile'..."$cRESET

  region=$2
  if [[ $region == "" ]]; then
    for region in $(aws ec2 describe-regions --profile $profile | jq -r '.Regions[].RegionName')
    do
      echo -e $cCYAN"Listing instances in region:'$region'..."$cRESET
      _describe_instances $profile $region
    done
  else
    echo -e $cCYAN"Listing instances only in region:'$region'..."$cRESET
    _describe_instances $profile $region
  fi
}

function get_services() {
    cluster="$1"
    profile="${2:-prod}"

    aws --profile $profile ecs list-services --cluster $cluster --query 'serviceArns[*]' --output text
}

function update_service() {
    service="$1"
    task_definition="$2"
    profile="${3:-prod}"
    aws --profile prod ecs update-service --service $service --task-definition $task_definition --cluster $service
}

#Aliases
alias aws-li="list_instances"
alias aws-gs="get_services"
alias aws-us="update_service"
alias setprod="$svr set aws.__allow_prod_access__ true"
alias unsetprod="$svr unset aws.__allow_prod_access__"

alias mfa-id="aws-mfa --profile identity"
alias mfa-prod="aws-mfa --profile identity --short-term-suffix prod --assume-role arn:aws:iam::695716229028:role/CrossAccountAdministrator --role-session-name prod-admin"
alias mfa-ops="aws-mfa --profile identity --short-term-suffix ops --assume-role arn:aws:iam::674426430959:role/CrossAccountAdministrator --role-session-name ops-admin"
alias mfa-test="aws-mfa --profile identity --short-term-suffix test --assume-role arn:aws:iam::362571885929:role/CrossAccountAdministrator --role-session-name test-admin"
alias mfa-dev="aws-mfa --profile identity --short-term-suffix dev --assume-role arn:aws:iam::005280096196:role/CrossAccountAdministrator --role-session-name dev-admin"
alias mfa-svr="aws-mfa --assume-role arn:aws:iam::362571885929:role/_TEST_TMCrossAccountEngineer --profile test"

