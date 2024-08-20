$url = "https://vstsagentpackage.azureedge.net/agent/2.189.0/vsts-agent-win-x64-2.189.0.zip"
$agent_dir = "C:\azagent"

mkdir $agent_dir
Invoke-WebRequest -Uri $url -OutFile "$agent_dir\vsts-agent.zip"
Expand-Archive "$agent_dir\vsts-agent.zip" -DestinationPath $agent_dir
cd $agent_dir

./config.cmd --unattended --url $(devops_url) --auth PAT --token $(devops_token) --pool $(devops_agent_pool_name) --agent $(hostname) --acceptTeeEula --runAsService
