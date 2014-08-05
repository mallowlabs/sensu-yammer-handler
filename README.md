sensu-yammer-handler
====

A [Sensu](http://sensuapp.org/) handler for [Yammer](https://www.yammer.com/).

## Requirement

* Sensu 0.13.1+

## Install

1. Put ```yammer.rb``` to /etc/sensu/handlers/yammer.rb
2. Put ```yammer.json``` to /etc/sensu/conf.d/handlers/yammer.json
3. Edit yammer.json

Example yammer.sjon

    {
      "handlers": {
        "yammer": {
          "type": "pipe",
          "command": "/etc/sensu/handlers/yammer.rb"
        }
      },
      "yammer": {
        "og_url": "http://localhost:3000/",
        "og_title": "Sensu",
        "access_token": "YOUR_YAMMER_ACCESS_KEY",
        "group_id" : "123456"
      }
    }

### How to get Yammer group_id

1. Access to target Yammer Group.
2. Check the URL. Extract ```feedId=xxxxx```
3. xxxxx is your group_id.


### How to get Yammer access_token

Look https://github.com/yammer/yam#configuration

## Licence

[MIT](https://github.com/mallowlabs/sensu-yammer-handler/blob/master/LICENSE)

## Author

[mallowlabs](https://github.com/mallowlabs)

