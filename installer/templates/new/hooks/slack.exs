# Slack hook can be used to build a Slash command
# that will post text to Kitto Dashboards.
#
# To use:
#
# 1. From the custom app menu
#    (https://[example].slack.com/apps/build/custom-integration) open
#    Slash Commands
# 2. Add a new slash command with whatever you'd like to call it
# 3. In the setting for the URL use http://[my.kitto.dashboard]/hooks/slack
#
# As with most webhooks, your Kitto API will need to be publicly accessible
# to Slack. You can build verification using the `token` in the URL parameters
# as a shared private key between you and Slack.

use Kitto.Hooks.DSL

hook :slack do
  %{"text" => text} = conn.params
  broadcast! :slack_message, %{text: text}
end
