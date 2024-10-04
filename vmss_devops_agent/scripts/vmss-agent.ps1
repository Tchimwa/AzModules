# Variables
$organizationUrl = "${organization_url}"
$patToken = "${pat_token}"
$agentPool = "Default"  # Change to your desired agent pool

# Download the Azure DevOps agent
$agentDownloadUrl = "https://vstsagentpackage.azureedge.net/agent/2.189.0/vsts-agent-win-x64-2.189.0.zip"
$agentDir = "C:\azagent"
New-Item -ItemType Directory -Path $agentDir

Write-Output "Downloading Azure DevOps agent..."
Invoke-WebRequest -Uri $agentDownloadUrl -OutFile "$agentDir\vsts-agent.zip"

# Extract the agent
Expand-Archive "$agentDir\vsts-agent.zip" -DestinationPath $agentDir
Set-Location -Path $agentDir

# Configure the agent
Write-Output "Configuring Azure DevOps agent..."
Start-Process ".\config.cmd" -ArgumentList "--unattended --url $organizationUrl --auth PAT --token $patToken --pool $agentPool --agent $(hostname) --acceptTeeEula --runAsService" -Wait

# Install the agent service
Write-Output "Installing and starting the agent service..."
Start-Process ".\svc.sh install" -Wait
Start-Process ".\svc.sh start" -Wait

Write-Output "Azure DevOps agent installation and configuration completed."
