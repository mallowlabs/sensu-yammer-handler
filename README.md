sensu-yammer-handler
====

A [Sensu](http://sensuapp.org/) handler for [Yammer](https://www.yammer.com/).

## Requirement

* Sensu 0.13.1+

## Install

1. ```/opt/sensu/embedded/bin/gem install redis```
2. Put ```yammer.rb``` to /etc/sensu/handlers/yammer.rb
3. Put ```yammer.json``` to /etc/sensu/conf.d/handlers/yammer.json
4. Edit yammer.json

Example yammer.sjon

```json
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
```

If you want to use yammer handler as a default handler.
You can use Sensu handler sets.
Put below file to ```/etc/sensu/conf.d/handlers/default.json

```json
{
  "handlers": {
    "default": {
      "type": "set",
      "handlers": ["yammer"]
    }
  }
}
```

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

