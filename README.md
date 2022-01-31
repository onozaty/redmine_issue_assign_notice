# Redmine issue assign notice plugin

It is a plugin of [Redmine](http://www.redmine.org) that notifies Slack, Rocket.Chat, Teams, Google Chat, Mattermost, etc. that the issue assignee changed.

## Installation

Clone this repository to the Redmine plugin directory.  
Then use `bundle install` to install the dependent libraries. 

```
cd {RAILS_ROOT}/plugins
git clone https://github.com/onozaty/redmine_issue_assign_notice.git
bundle install --without development test
```

## Usage

From the plugin's configuration screen, configure the settings for notifications.

![Screenshot of plugin configure](screenshots/configure.png)

In the "Notice URL", enter the URL of the Incoming Webhook created in the destination (Slack, Rocket.Chat, etc.).

When the assignee changed, the webhook set in the "Notice URL" will be executed and the following message will be posted.

![Screenshot of slack message](screenshots/slack_message.png)

The content of the message is as follows.

* Line #1: Information on change of assignee
* Line #2: Project name, tracker, ticket number, title, status
* Line #3: New ticket creation: description, ticket modification: note (up to 200 characters)

### Set Notice URL for each project?

If you check "Set Notice URL for each project?", you can set the Notice URL for each project.  
The Notice URL for each project is set in the custom field "Assign Notice URL" of the project. You should create a custom field and set it in each project.

![Screenshot of create project custom field](screenshots/create_project_custom_field.png)

![Screenshot of project setting](screenshots/project_setting.png)

### Mention to assignee? (If is set by others)

If you check "Mention to assignee? (If is set by others)", you can include mention for the user who was assigned to the message. However, the one set by the assignee themselves will not be notified.  

![Screenshot of slack message](screenshots/slack_mention.png)

For the mention ID, the "Assign Notice ID" of the user's custom field is used. Make sure to create a custom field and set it for each user.

![Screenshot of create user custom field](screenshots/create_user_custom_field.png)

![Screenshot of my account](screenshots/my_account.png)

The ID to be entered depends on the notification destination.

* Slack: member ID
* Rocket.Chat: user name
* Teams: UPN (email address)
* Google Chat: user ID
* Mattermost: user name

## Supported versions

Redmine 3.0.x - 3.4.x, 4.0.x or later

## License

MIT License

## Author

[onozaty](https://github.com/onozaty)

## Acknowledgements

This plugin was created with the help of the following plugin implementation. I would like to thank the author for publishing such a great plugin.

* [sciyoshi/redmine\-slack: Slack notification plugin for Redmine](https://github.com/sciyoshi/redmine-slack)

Part of the code of this plugin belongs to the above project.
